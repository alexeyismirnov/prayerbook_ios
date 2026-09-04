//
//  WidgetState.swift
//  CalendarWidget
//

import Foundation
import swift_toolkit_calendar

enum WidgetState {
    static let selectedKey = "widgetSelectedDate"
    private static let timelineDayKey = "widgetTimelineDay"

    static var today: Date {
        DateComponents(date: Date()).toDate()
    }

    static var selectedDate: Date {
        get {
            WidgetBootstrap.ensureConfigured()
            let prefs = AppGroup.prefs!
            if prefs.object(forKey: selectedKey) != nil {
                let epoch = prefs.double(forKey: selectedKey)
                return DateComponents(date: Date(timeIntervalSince1970: epoch)).toDate()
            }
            return today
        }
        set {
            WidgetBootstrap.ensureConfigured()
            let day = DateComponents(date: newValue).toDate()
            AppGroup.prefs.set(day.timeIntervalSince1970, forKey: selectedKey)
            AppGroup.prefs.synchronize()
        }
    }

    /// Snap to today once per calendar day (midnight timeline refresh), without
    /// undoing in-widget browsing that happens during the same day.
    static func resetToTodayIfNewCalendarDay() {
        WidgetBootstrap.ensureConfigured()
        let prefs = AppGroup.prefs!
        let dayEpoch = today.timeIntervalSince1970
        if prefs.object(forKey: timelineDayKey) as? Double != dayEpoch {
            selectedDate = today
            prefs.set(dayEpoch, forKey: timelineDayKey)
            prefs.synchronize()
        }
    }

    static func shiftDays(_ delta: Int) {
        selectedDate = selectedDate + delta.days
    }

    static func shiftMonths(_ delta: Int) {
        let current = selectedDate
        let moved = current + delta.months
        selectedDate = Date(1, moved.month, moved.year)
    }
}
