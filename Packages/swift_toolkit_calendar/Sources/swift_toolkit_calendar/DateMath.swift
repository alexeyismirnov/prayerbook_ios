//
//  DateMath.swift
//  swift_toolkit_calendar
//

import UIKit

public enum TimeIntervalUnit {
    case seconds, minutes, hours, days, months, years

    func dateComponents(_ interval: Int) -> DateComponents {
        var components = DateComponents()
        switch self {
        case .seconds: components.second = interval
        case .minutes: components.minute = interval
        case .days: components.day = interval
        case .months: components.month = interval
        case .years: components.year = interval
        default: components.day = interval
        }
        return components
    }
}

public struct CalTimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit

    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

public extension Int {
    var days: CalTimeInterval {
        CalTimeInterval(interval: self, unit: .days)
    }

    var months: CalTimeInterval {
        CalTimeInterval(interval: self, unit: .months)
    }
}

public func - (left: Date, right: CalTimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(-right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

public func + (left: Date, right: CalTimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

public extension DateComponents {
    init(_ day: Int, _ month: Int, _ year: Int) {
        self.init()
        self.day = day
        self.month = month
        self.year = year
    }

    init(date: Date) {
        self.init()
        let calendar = Calendar.current
        let dateComponents = (calendar as NSCalendar).components([.day, .month, .year, .weekday], from: date)
        self.day = dateComponents.day
        self.month = dateComponents.month
        self.year = dateComponents.year
        self.weekday = dateComponents.weekday
    }

    func toDate() -> Date {
        Calendar.current.date(from: self)!
    }
}

public extension Date {
    init(_ day: Int, _ month: Int, _ year: Int) {
        self.init(timeInterval: 0, since: DateComponents(day, month, year).toDate())
    }

    var day: Int { DateComponents(date: self).day! }
    var weekday: Int { DateComponents(date: self).weekday! }
    var month: Int { DateComponents(date: self).month! }
    var year: Int { DateComponents(date: self).year! }
}

public func += <K, V>(left: inout [K: V], right: [K: V]) {
    for (k, v) in right { left[k] = v }
}

public func += <K, V>(left: inout Dictionary<K, [V]>, right: Dictionary<K, [V]>) {
    for (k, v) in right {
        if let leftValue = left[k] {
            left.updateValue(v + leftValue, forKey: k)
        } else {
            left.updateValue(v, forKey: k)
        }
    }
}

public struct DateRange: Sequence {
    var startDate: Date
    var endDate: Date

    public init(_ arg1: Date, _ arg2: Date) {
        startDate = arg1 - 1.days
        endDate = arg2
    }

    public func makeIterator() -> Iterator {
        Iterator(range: self)
    }

    public struct Iterator: IteratorProtocol {
        var range: DateRange

        public mutating func next() -> Date? {
            let nextDate = range.startDate + 1.days
            if range.endDate < nextDate {
                return nil
            } else {
                range.startDate = nextDate
                return nextDate
            }
        }
    }
}

public func >> (left: Date, right: Date) -> Int {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components(.day, from: left, to: right, options: [])
    return components.day!
}

public extension UIColor {
    convenience init(hex: String) {
        if hex == "" {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
        } else {
            let alpha: Float = 100
            var rgb: UInt32 = 0
            let s = Scanner(string: hex)
            s.scanLocation = 1
            s.scanHexInt32(&rgb)
            self.init(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: CGFloat(alpha / 100)
            )
        }
    }
}

public extension UIImage {
    func resize(_ sizeChange: CGSize) -> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        draw(in: CGRect(origin: .zero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
}

public extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
}
