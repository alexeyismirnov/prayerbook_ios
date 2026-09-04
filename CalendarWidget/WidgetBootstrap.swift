//
//  WidgetBootstrap.swift
//  CalendarWidget
//

import Foundation
import swift_toolkit_calendar

enum WidgetBootstrap {
    static let appGroupId = "group.rlc.ponomar-ru"
    static let kind = "OrthodoxCalendarWidget"

    private static var didConfigure = false

    @discardableResult
    static func ensureConfigured() -> Bool {
        if didConfigure, AppGroup.url != nil, AppGroup.prefs != nil {
            return true
        }

        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId),
              let defaults = UserDefaults(suiteName: appGroupId) else {
            return false
        }

        AppGroup.id = appGroupId
        // Ensure didSet values are present even if id was already set earlier.
        AppGroup.url = container
        AppGroup.prefs = defaults

        if Translate.files.isEmpty {
            Translate.files = ["trans_ui_ru", "trans_cal_ru", "trans_library_ru"]
        }

        if let lang = defaults.object(forKey: "language") as? String {
            Translate.language = lang
        } else {
            Translate.language = "ru"
        }

        let level = defaults.integer(forKey: "fastingLevel")
        FastingModel.fastingLevel = FastingLevel(rawValue: level) ?? .laymen
        didConfigure = true
        return true
    }

    static func hasSaintsData(for date: Date = Date()) -> Bool {
        guard ensureConfigured(), let url = AppGroup.url else { return false }
        let month = DateComponents(date: date).month ?? 1
        let filename = String(format: "saints_%02d_%@.sqlite", month, Translate.language)
        return FileManager.default.fileExists(atPath: url.appendingPathComponent(filename).path)
    }

    static func openURL(for date: Date) -> URL {
        URL(string: "ponomar-ru://open?\(date.timeIntervalSince1970)")!
    }
}
