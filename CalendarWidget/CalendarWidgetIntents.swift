//
//  CalendarWidgetIntents.swift
//  CalendarWidget
//

import AppIntents
import WidgetKit
import swift_toolkit_calendar

struct ShiftWidgetDayIntent: AppIntent {
    static var title: LocalizedStringResource = "Shift calendar day"
    static var isDiscoverable = false

    @Parameter(title: "Days")
    var days: Int

    init() {
        self.days = 1
    }

    init(days: Int) {
        self.days = days
    }

    func perform() async throws -> some IntentResult {
        WidgetBootstrap.ensureConfigured()
        WidgetState.shiftDays(days)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetBootstrap.kind)
        return .result()
    }
}

struct ShiftWidgetMonthIntent: AppIntent {
    static var title: LocalizedStringResource = "Shift calendar month"
    static var isDiscoverable = false

    @Parameter(title: "Months")
    var months: Int

    init() {
        self.months = 1
    }

    init(months: Int) {
        self.months = months
    }

    func perform() async throws -> some IntentResult {
        WidgetBootstrap.ensureConfigured()
        WidgetState.shiftMonths(months)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetBootstrap.kind)
        return .result()
    }
}

struct SelectWidgetDateIntent: AppIntent {
    static var title: LocalizedStringResource = "Select calendar date"
    static var isDiscoverable = false

    @Parameter(title: "Epoch")
    var epoch: Double

    init() {
        self.epoch = Date().timeIntervalSince1970
    }

    init(date: Date) {
        self.epoch = date.timeIntervalSince1970
    }

    func perform() async throws -> some IntentResult {
        WidgetBootstrap.ensureConfigured()
        WidgetState.selectedDate = Date(timeIntervalSince1970: epoch)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetBootstrap.kind)
        return .result()
    }
}
