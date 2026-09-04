//
//  DayContent.swift
//  CalendarWidget
//

import SwiftUI
import UIKit
import WidgetKit
import swift_toolkit_calendar

struct SaintLine: Hashable {
    let name: String
    let isGreat: Bool
    let feastType: FeastType
}

struct MonthDayCell: Identifiable, Hashable {
    let id: String
    let dayNumber: Int?
    let date: Date?
    let background: Color
    let textColor: Color
    let isBold: Bool
    let isSelected: Bool
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let selectedDate: Date
    let needsSetup: Bool
    let dateTitle: String
    let weekToneFasting: String
    let saint: SaintLine?
    let monthTitle: String
    let weekdaySymbols: [String]
    let monthCells: [MonthDayCell]
}

enum DayContentBuilder {
    static func previewEntry() -> CalendarEntry {
        CalendarEntry(
            date: Date(),
            selectedDate: Date(),
            needsSetup: false,
            dateTitle: dualChurchDateTitle(Date()),
            weekToneFasting: "Fast • tone",
            saint: SaintLine(name: "Orthodox Calendar", isGreat: false, feastType: .none),
            monthTitle: "Calendar",
            weekdaySymbols: ["S", "M", "T", "W", "T", "F", "S"],
            monthCells: []
        )
    }

    static func makeEntry(selectedDate: Date, needsSetup: Bool) -> CalendarEntry {
        if needsSetup {
            return CalendarEntry(
                date: Date(),
                selectedDate: selectedDate,
                needsSetup: true,
                dateTitle: "",
                weekToneFasting: "",
                saint: nil,
                monthTitle: "",
                weekdaySymbols: [],
                monthCells: []
            )
        }

        do {
            return try build(selectedDate: selectedDate)
        } catch {
            return makeEntry(selectedDate: selectedDate, needsSetup: true)
        }
    }

    private static func build(selectedDate: Date) throws -> CalendarEntry {
        guard WidgetBootstrap.ensureConfigured() else {
            throw CocoaError(.fileNoSuchFile)
        }
        // Ensure fasting level is applied before month cell colors / descriptions.
        _ = WidgetBootstrap.fastingLevel
        let cal = Cal.fromDate(selectedDate)

        var body = ""
        if let week = cal.getWeekDescription(selectedDate) {
            body += week
        }
        if let tone = cal.getToneDescription(selectedDate) {
            if !body.isEmpty { body += "; " }
            body += tone
        }
        let fasting = ChurchFasting.forDate(selectedDate)
        if !body.isEmpty { body += ". " }
        body += fasting.descr

        let saints = SaintModel.saints(selectedDate)
        let day = cal.getDayDescription(selectedDate)
        let feasts = (saints + day).sorted { $0.type.rawValue > $1.type.rawValue }
        let saintLine: SaintLine? = feasts.first.map {
            SaintLine(name: $0.name, isGreat: $0.type == .great, feastType: $0.type)
        }

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Translate.locale
        monthFormatter.dateFormat = "LLLL yyyy"
        let monthTitle = monthFormatter.string(from: selectedDate).capitalizingFirstLetter()

        var calLocale = Calendar.current
        calLocale.locale = Translate.locale
        let symbols = calLocale.veryShortWeekdaySymbols
        let firstWeekday = calLocale.firstWeekday
        var orderedSymbols: [String] = []
        for i in 0..<7 {
            let idx = (firstWeekday - 1 + i) % 7
            orderedSymbols.append(symbols[idx])
        }

        return CalendarEntry(
            date: Date(),
            selectedDate: selectedDate,
            needsSetup: false,
            dateTitle: dualChurchDateTitle(selectedDate),
            weekToneFasting: body,
            saint: saintLine,
            monthTitle: monthTitle,
            weekdaySymbols: orderedSymbols,
            monthCells: monthCells(for: selectedDate, textColor: .primary)
        )
    }

    /// New-style / old-style church date, e.g. "30/17 Sep" or Chinese "9月23/10日".
    static func dualChurchDate(_ date: Date, monthFormat: String) -> String {
        let old = date - 13.days
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Translate.locale
        monthFormatter.dateFormat = monthFormat
        let chinese = Translate.language == "cn" || Translate.language == "hk"

        if date.month == old.month && date.year == old.year {
            let month = monthFormatter.string(from: date)
            if chinese {
                return "\(month)\(date.day)/\(old.day)日"
            }
            return "\(date.day)/\(old.day) \(month)"
        }

        let newMonth = monthFormatter.string(from: date)
        let oldMonth = monthFormatter.string(from: old)
        if chinese {
            return "\(newMonth)\(date.day)日/\(oldMonth)\(old.day)日"
        }
        return "\(date.day) \(newMonth)/\(old.day) \(oldMonth)"
    }

    static func dualChurchDateTitle(_ date: Date) -> String {
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Translate.locale
        weekdayFormatter.dateFormat = "cccc"
        let weekday = weekdayFormatter.string(from: date).capitalizingFirstLetter()
        let dual = dualChurchDate(date, monthFormat: "MMMM")
        let yearSuffix: String = {
            switch Translate.language {
            case "ru": return " г."
            case "cn", "hk": return "年"
            default: return ""
            }
        }()
        return "\(weekday) \(dual) \(date.year)\(yearSuffix)"
    }

    static func dualChurchDateShort(_ date: Date) -> String {
        dualChurchDate(date, monthFormat: "LLL")
    }

    static func monthCells(for selectedDate: Date, textColor: Color) -> [MonthDayCell] {
        WidgetBootstrap.ensureConfigured()
        let monthStart = Date(1, selectedDate.month, selectedDate.year)
        var cal = Calendar.current
        cal.locale = Translate.locale
        let startGap: Int = {
            if monthStart.weekday < cal.firstWeekday {
                return 7 - (cal.firstWeekday - monthStart.weekday)
            }
            return monthStart.weekday - cal.firstWeekday
        }()

        let range = (Calendar.current as NSCalendar).range(of: .day, in: .month, for: selectedDate)
        let dayCount = range.length
        var cells: [MonthDayCell] = []

        for row in 0..<(dayCount + startGap) {
            if row < startGap {
                cells.append(MonthDayCell(
                    id: "empty-\(row)",
                    dayNumber: nil,
                    date: nil,
                    background: .clear,
                    textColor: textColor,
                    isBold: false,
                    isSelected: false
                ))
                continue
            }

            let dayIndex = row + 1 - startGap
            let date = Date(dayIndex, selectedDate.month, selectedDate.year)
            let fasting = ChurchFasting.forDate(date)
            let isGreat = !Cal.getGreatFeast(date).isEmpty
            let isSelected = date == selectedDate

            let bg = Color(uiColor: fasting.color)
            let fg: Color = {
                if isSelected { return .white }
                if isGreat { return .red }
                if fasting.type == .noFast || fasting.type == .noFastMonastic {
                    return textColor
                }
                return .black
            }()

            cells.append(MonthDayCell(
                id: "\(date.timeIntervalSince1970)",
                dayNumber: dayIndex,
                date: date,
                background: isSelected ? .red : bg,
                textColor: fg,
                isBold: isGreat || isSelected,
                isSelected: isSelected
            ))
        }

        return cells
    }
}
