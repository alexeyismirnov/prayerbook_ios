//
//  CalendarWidget.swift
//  CalendarWidget
//

import WidgetKit
import SwiftUI

@main
struct PrayerbookWidgetBundle: WidgetBundle {
    var body: some Widget {
        OrthodoxCalendarWidget()
    }
}

struct OrthodoxCalendarWidget: Widget {
    let kind = WidgetBootstrap.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarWidgetProvider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Orthodox Calendar")
        .description("Day and month of the Orthodox calendar")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
