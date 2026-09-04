//
//  CalendarWidgetProvider.swift
//  CalendarWidget
//

import WidgetKit
import swift_toolkit_calendar

struct CalendarWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        // Gallery discovery must not touch App Group / SQLite.
        DayContentBuilder.previewEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        if context.isPreview {
            completion(DayContentBuilder.previewEntry())
            return
        }
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        WidgetState.resetToTodayIfNewCalendarDay()
        let entry = currentEntry()
        let nextMidnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0, second: 5),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    private func currentEntry() -> CalendarEntry {
        guard WidgetBootstrap.ensureConfigured() else {
            return DayContentBuilder.makeEntry(selectedDate: Date(), needsSetup: true)
        }
        let selected = WidgetState.selectedDate
        let needsSetup = !WidgetBootstrap.hasSaintsData(for: selected)
        return DayContentBuilder.makeEntry(selectedDate: selected, needsSetup: needsSetup)
    }
}
