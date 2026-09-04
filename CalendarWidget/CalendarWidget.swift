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
        .configurationDisplayName("Православный календарь")
        .description("День и месяц православного календаря")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
