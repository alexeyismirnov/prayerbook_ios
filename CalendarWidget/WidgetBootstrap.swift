//
//  WidgetBootstrap.swift
//  CalendarWidget
//

import Foundation
import swift_toolkit_calendar

enum WidgetBootstrap {
    static let appGroupId = "group.rlc.ponomar2"
    static let kind = "OrthodoxCalendarWidget"

    private static var didLoadTranslateFiles = false

    /// Refresh App Group prefs and apply language / fasting level.
    /// Always re-creates `UserDefaults(suiteName:)` so the extension sees
    /// values written by the host app (cached suite instances go stale).
    @discardableResult
    static func ensureConfigured() -> Bool {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId),
              let defaults = UserDefaults(suiteName: appGroupId) else {
            return false
        }

        AppGroup.id = appGroupId
        AppGroup.url = container
        AppGroup.prefs = defaults

        if !didLoadTranslateFiles {
            Translate.files = [
                "trans_ui_en", "trans_cal_en",
                "trans_ui_cn", "trans_cal_cn", "trans_library_cn",
                "trans_ui_hk", "trans_cal_hk", "trans_library_hk",
            ]
            didLoadTranslateFiles = true
        }

        if let lang = defaults.string(forKey: "language") {
            Translate.language = lang
        } else {
            Translate.language = "en"
        }

        // Host app stores laymen=0 / monastic=1 in the App Group suite.
        let level = defaults.integer(forKey: "fastingLevel")
        FastingModel.fastingLevel = FastingLevel(rawValue: level) ?? .laymen
        return true
    }

    static var fastingLevel: FastingLevel {
        ensureConfigured()
        return FastingModel.fastingLevel ?? .laymen
    }

    static func hasSaintsData(for date: Date = Date()) -> Bool {
        guard ensureConfigured(), let url = AppGroup.url else { return false }
        let month = DateComponents(date: date).month ?? 1
        let filename = String(format: "saints_%02d_%@.sqlite", month, Translate.language)
        return FileManager.default.fileExists(atPath: url.appendingPathComponent(filename).path)
    }

    static func openURL(for date: Date) -> URL {
        URL(string: "ponomar://open?\(date.timeIntervalSince1970)")!
    }
}
