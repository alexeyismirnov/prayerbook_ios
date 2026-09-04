//
//  CalendarWidgetViews.swift
//  CalendarWidget
//

import SwiftUI
import WidgetKit
import swift_toolkit_calendar

struct CalendarWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: CalendarEntry

    var body: some View {
        if entry.needsSetup {
            setupPlaceholder
                .containerBackground(for: .widget) { Color(.systemBackground) }
        } else {
            content
                .containerBackground(for: .widget) { Color(.systemBackground) }
                .widgetURL(WidgetBootstrap.openURL(for: entry.selectedDate))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            SmallDayView(entry: entry)
        case .systemMedium:
            MediumDayView(entry: entry)
        case .systemLarge:
            LargeMonthView(entry: entry)
        default:
            MediumDayView(entry: entry)
        }
    }

    private var setupPlaceholder: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Православный календарь")
                .font(.headline)
            Text("Откройте приложение «Молитвослов» один раз, чтобы загрузить данные календаря.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(4)
    }
}

struct SmallDayView: View {
    let entry: CalendarEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DayContentBuilder.dualChurchDateShort(entry.selectedDate))
                .font(.caption.weight(.semibold))
                .lineLimit(2)
            Text(entry.weekToneFasting)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            if let saint = entry.saint {
                SaintLabel(saint: saint, font: .caption2)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(2)
    }
}

struct MediumDayView: View {
    let entry: CalendarEntry

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.dateTitle)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(2)
                Text(entry.weekToneFasting)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                if let saint = entry.saint {
                    SaintLabel(saint: saint, font: .caption)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 6) {
                Button(intent: ShiftWidgetDayIntent(days: -1)) {
                    Image(systemName: "chevron.up")
                        .font(.body.weight(.semibold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Button(intent: ShiftWidgetDayIntent(days: 1)) {
                    Image(systemName: "chevron.down")
                        .font(.body.weight(.semibold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
    }
}

struct LargeMonthView: View {
    let entry: CalendarEntry

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Button(intent: ShiftWidgetMonthIntent(months: -1)) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)

                Text(entry.monthTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)

                Button(intent: ShiftWidgetMonthIntent(months: 1)) {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(entry.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(entry.monthCells) { cell in
                    if let date = cell.date, let day = cell.dayNumber {
                        Button(intent: SelectWidgetDateIntent(date: date)) {
                            dayLabel(day: day, cell: cell)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }

            if let saint = entry.saint {
                SaintLabel(saint: saint, font: .caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(4)
    }

    private func dayLabel(day: Int, cell: MonthDayCell) -> some View {
        Text("\(day)")
            .font(cell.isBold ? .caption.weight(.bold) : .caption)
            .foregroundStyle(cell.textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background {
                if cell.isSelected {
                    Circle().fill(cell.background)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(cell.background)
                }
            }
    }
}

struct SaintLabel: View {
    let saint: SaintLine
    let font: Font

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if saint.feastType != .none {
                Image(uiImage: saint.feastType.icon15x15)
                    .resizable()
                    .frame(width: 12, height: 12)
            }
            Text(saint.name)
                .font(font)
                .foregroundStyle(saint.isGreat ? Color.red : Color.primary)
        }
    }
}
