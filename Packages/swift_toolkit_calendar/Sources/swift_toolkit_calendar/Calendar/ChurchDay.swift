//
//  ChurchDay.swift
//  swift-toolkit
//
//  Created by Alexey Smirnov on 2/17/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import UIKit

public enum FeastType: Int, Codable {
    case none=0, noSign, sixVerse, doxology, polyeleos, vigil, great
    
    init?(_ string: String) {
           switch string{
           case "none": self = .none
           case "noSign": self = .noSign
           case "sixVerse": self = .sixVerse
           case "doxology": self = .doxology
           case "polyeleos": self = .polyeleos
           case "vigil": self = .vigil
           case "great": self = .great
           default: return nil
           }
    }
    
    public func toString() -> String {
        switch self {
        case .none: return "none"
        case .noSign: return "noSign"
        case .sixVerse: return "sixVerse"
        case .doxology: return "doxology"
        case .polyeleos: return "polyeleos"
        case .vigil: return "vigil"
        case .great: return "great"
        }
    }
    
    static let tk = Bundle.module
    static let size15 = CGSize(width: 15, height: 15)

    private static func loadIcon(_ name: String) -> UIImage {
        UIImage(named: name, in: tk, compatibleWith: nil) ?? UIImage()
    }
    
    static let icon : [FeastType: UIImage] = [
        .noSign: loadIcon("nosign"),
        .sixVerse: loadIcon("sixverse"),
        .doxology: loadIcon("doxology"),
        .polyeleos: loadIcon("polyeleos"),
        .vigil: loadIcon("vigil"),
        .great: loadIcon("great")
    ]
    
    static let icon15x15 : [FeastType: UIImage] = [
        .noSign: loadIcon("nosign").resize(size15),
        .sixVerse: loadIcon("sixverse").resize(size15),
        .doxology: loadIcon("doxology").resize(size15),
        .polyeleos: loadIcon("polyeleos").resize(size15),
        .vigil: loadIcon("vigil").resize(size15),
        .great: loadIcon("great").resize(size15)
    ]
    
    public var icon15x15: UIImage { FeastType.icon15x15[self] ?? UIImage() }
    public var icon: UIImage { FeastType.icon[self] ?? UIImage() }
}

public enum DayOfWeek: Int  {
    case sunday=1, monday, tuesday, wednesday, thursday, friday, saturday
    
    public init?(date: Date) {
        self.init(rawValue: DateComponents(date: date).weekday!)
    }
}

public extension CodingUserInfoKey {
    static let year = CodingUserInfoKey(rawValue: "year")!
}

public class ChurchDay : Hashable, Equatable, Codable, CustomStringConvertible  {
    var _name : String
    
    public var name : String {
        get { Translate.s(_name) }
    }
    
    public var id : String {
        get { _name }
    }
    
    public var type : FeastType
    public var date: Date?
    public var reading : String?
    public var comment: String?
    
    public init(_ name: String = "", _ type: FeastType = .none, date: Date? = nil, reading: String? = nil, comment: String? = nil) {
        self._name = name
        self.type = type
        self.date = date
        self.reading = reading
        self.comment = comment
    }

    private enum CodingKeys : String, CodingKey {
            case name = "feastName", type = "feastType", date, reading, comment = "saint"
    }
    
    // DECODE
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let year = decoder.userInfo[.year] as! Int

        _name = (try? container.decode(String.self, forKey: .name)) ?? ""
        
        reading = try? container.decode(String.self, forKey: .reading)
        comment = try? container.decode(String.self, forKey: .comment)

        type = FeastType(try! container.decode(String.self, forKey: .type))!
        
        if let dateStr = try? container.decode(String.self, forKey: .date),
            let d = formatter.date(from: dateStr) {
            date = Date(d.day, d.month, year)
        }
    }
    
    // ENCODE
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if _name.count > 0 {
            try container.encode(_name, forKey: .name)
        }
        
        if let date = date {
            try container.encode(formatter.string(from: date), forKey: .date)
        }
                 
        if let reading = reading {
            try container.encode(reading, forKey: .reading)
        }
        
        if let comment = comment {
            try container.encode(comment, forKey: .comment)
        }
        
        try container.encode(type.toString(), forKey: .type)
    }
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "en")
        return formatter
    }

    public var description: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "en")
        
        var s = "\(_name), \(type.toString())"
        
        if let date = date {
            let str = formatter.string(from: date)
            s += ", \(str)"
        }
        
        if let reading = reading {
            s += ", \(reading)"
        }
        
        if let comment = comment {
            s += " // \(comment)"
        }
        
        return "ChurchDay(\(s))\n"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_name)
        hasher.combine(type)
        hasher.combine(reading)
    }
    
    public static func == (lhs: ChurchDay, rhs: ChurchDay) -> Bool {
        lhs._name == rhs._name &&
        lhs.type == rhs.type &&
        lhs.date == rhs.date &&
        lhs.reading == rhs.reading
    }
}
