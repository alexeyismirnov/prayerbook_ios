//
//  Extensions.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

enum TimeIntervalUnit {
    case seconds, minutes, hours, days, months, years
    
    func dateComponents(_ interval: Int) -> DateComponents {
        var components:DateComponents = DateComponents()
        
        switch (self) {
        case .seconds:
            components.second = interval
        case .minutes:
            components.minute = interval
        case .days:
            components.day = interval
        case .months:
            components.month = interval
        case .years:
            components.year = interval
        default:
            components.day = interval
        }
        return components
    }
}

struct CalTimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit
    
    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

// FYI: http://stackoverflow.com/questions/24116271/whats-the-cleanest-way-of-applying-map-to-a-dictionary-in-swift

extension Int {
    var days: CalTimeInterval {
        return CalTimeInterval(interval: self, unit: TimeIntervalUnit.days);
    }
    
    var months: CalTimeInterval {
        return CalTimeInterval(interval: self, unit: TimeIntervalUnit.months);
    }
}

func - (left:Date, right:CalTimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(-right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

func + (left:Date, right:CalTimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

extension DateComponents {
    init(_ day: Int, _ month:Int, _ year: Int) {
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
        let calendar = Calendar.current
        return calendar.date(from: self)!
    }
}

extension Date {
    init(_ day: Int, _ month:Int, _ year: Int) {
        self.init(timeInterval: 0, since: DateComponents(day, month, year).toDate())
    }

    var day: Int {
        get {
            return DateComponents(date: self).day!
        }
    }

    var weekday: Int {
        get {
            return DateComponents(date: self).weekday!
        }
    }
    
    var month: Int {
        get {
            return DateComponents(date: self).month!
        }
    }

    var year: Int {
        get {
            return DateComponents(date: self).year!
        }
    }

}


func + (str: String, date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    
    return formatter.string(from: date)
}

func + (arg1: NSMutableAttributedString?, arg2: NSMutableAttributedString?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.append(rightArg)
            return result
            
        } else {
            return arg2
        }
        
    } else {
        return arg1
    }
    
}

func + (arg1: NSMutableAttributedString?, arg2: String?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.append(NSMutableAttributedString(string: rightArg))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg)
        }
        
    } else {
        return arg1
    }
}

func + (arg1: NSMutableAttributedString?, arg2: (String?, UIColor)) -> NSMutableAttributedString? {
    
    if let rightArg = arg2.0 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.append(NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1]))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1])
        }
        
    } else {
        return arg1
    }
}

func += <K,V> (left: inout Dictionary<K, [V]>, right: Dictionary<K, [V]>) {
    for (k, v) in right {
        if let leftValue = left[k] {
            left.updateValue(v + leftValue, forKey: k)
        } else {
            left.updateValue(v, forKey: k)
        }
    }
}

func +=<K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right { left[k] = v }
}

struct DateRange : Sequence {
    var startDate: Date
    var endDate: Date
    
    init (_ arg1: Date, _ arg2: Date){
        startDate = arg1-1.days
        endDate = arg2
    }
    
    func makeIterator() -> Iterator {
        return Iterator(range: self)
    }
    
    struct Iterator: IteratorProtocol {
        var range: DateRange
        
        mutating func next() -> Date? {
            let nextDate = range.startDate + 1.days
            
            if range.endDate < nextDate {
                return nil
            }
            else {
                range.startDate = nextDate
                return nextDate
            }
        }
    }
}

func >> (left: Date, right: Date) -> Int {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components(.day, from: left, to: right, options: [])
    return components.day!
}

extension String {
    subscript (i: Int) -> String {
        return String(Array(self.characters)[i])
    }
}

// http://stackoverflow.com/a/29218836/995049
extension UIColor {
    convenience init(hex: String) {
        let alpha: Float = 100
        
        // Establishing the rgb color
        var rgb: UInt32 = 0
        let s: Scanner = Scanner(string: hex)
        // Setting the scan location to ignore the leading `#`
        s.scanLocation = 1
        // Scanning the int into the rgb colors
        s.scanHexInt32(&rgb)
        
        // Creating the UIColor from hex int
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha / 100)
        )
    }
}

extension UIImage {
    func maskWithColor(_ color: UIColor) -> UIImage {
        
        let maskImage = self.cgImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitmapContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        bitmapContext?.clip(to: bounds, mask: maskImage!)
        bitmapContext?.setFillColor(color.cgColor)
        bitmapContext?.fill(bounds)
        
        let cImage = bitmapContext?.makeImage()
        let coloredImage = UIImage(cgImage: cImage!)
        
        return coloredImage
    }
    
    func resize(_ sizeChange:CGSize)-> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }

}

