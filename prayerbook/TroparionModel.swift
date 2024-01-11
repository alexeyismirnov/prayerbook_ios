//
//  TroparionModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/9/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import Foundation
import SQLite
import swift_toolkit

fileprivate let tropari = Table("tropari")
fileprivate let f_id = Expression<Int>("id")
fileprivate let f_code = Expression<Int>("code")
fileprivate let f_title = Expression<String>("title")
fileprivate let f_content = Expression<String>("content")
fileprivate let f_url = Expression<String>("url")

struct Troparion {
    var title : String
    var content : String
    var url : String?
    
    init(title : String, content : String, url : String? = nil) {
        self.title = title
        self.content = content
        self.url = url
    }
}

protocol TroparionModel {
    var url : String { get }
    var fileSize : Int { get }

    func isDownloaded() -> Bool
    func isAvailable(_ date : Date) -> Bool
    func getTroparion(_ date : Date) -> [Troparion]
    func getTitle(_ date : Date) -> String
}

class TroparionFeastModel : TroparionModel {
    var url = "https://filedn.com/lUdNcEH0czFSe8uSnCeo29F/prayerbook/tropari.zip"
    var fileSize = 22

    var path:String!

    static let shared = TroparionFeastModel()
    
    init() {
        let documentDirectory:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        path = documentDirectory.path + "/tropari/tropari/tropari.sqlite"
    }
    
    func getTitle(_ date : Date) -> String { "Тропарь и кондак праздника" }
    
    func isAvailable(_ date : Date) -> Bool { !Cal.getGreatFeast(date).isEmpty }

    func getTroparion(_ date : Date) -> [Troparion]  {
        let feasts = Cal.getGreatFeast(date)
        let db = try! Connection(path, readonly: true)
        
        let codes = ["pascha": 1,
                     "pentecost": 2,
                     "ascension": 3,
                     "palmSunday" :4,
                     "nativityOfGod": 6,
                     "circumcision": 7,
                     "theophany": 9,
                     "meetingOfLord": 10,
                     "annunciation": 11,
                     "nativityOfJohn": 12,
                     "peterAndPaul": 13,
                     "transfiguration": 14,
                     "dormition": 15,
                     "beheadingOfJohn": 16,
                     "nativityOfTheotokos": 17,
                     "exaltationOfCross": 18,
                     "veilOfTheotokos": 19,
                     "entryIntoTemple": 20 ]
        
        var troparion = [Troparion]()
        
        for f in feasts {
            let code = codes[f.id]!
            
            troparion.append(
                contentsOf: try! db.prepareRowIterator(tropari
                    .filter(f_code == code)
                    .order(f_id.asc))
                .map {
                    var url: String?
                    
                    do {
                        url = try $0.get(f_url)
                    } catch _ { }
                    
                    return Troparion(
                        title: $0[f_title],
                        content: $0[f_content],
                        url: url != nil ? "/tropari/tropari/\(url!).mp3" : nil)
                })
        }

        return troparion
    }
    
    func isDownloaded() -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
}

class TroparionDayModel : TroparionModel {
    var url = "https://filedn.com/lUdNcEH0czFSe8uSnCeo29F/prayerbook/tropari_day.zip"
    var fileSize = 20
    
    var path:String!

    static let shared = TroparionDayModel()
    
    init() {
        let documentDirectory:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        path = documentDirectory.path + "/tropari_day/tropari_day/tropari_day.sqlite"
    }
    
    func getTitle(_ date : Date) -> String {
        let cal = Cal.fromDate(date)
        
        if cal.pascha ..< cal.d("sunday2AfterPascha") ~= date {
            return "Часы пасхальные"
        } else {
            return "Тропарь и кондак дня"
        }
    }
    
    func isAvailable(_ date : Date) -> Bool {
        let cal = Cal.fromDate(date)

        if cal.d("palmSunday") ... cal.pascha  ~= date {
            return false
            
        } else {
            return Cal.getGreatFeast(date).isEmpty
        }
    }
    
    func getTroparion(_ date : Date) -> [Troparion]  {
        let cal = Cal.fromDate(date)

        var troparion = [Troparion]()
        let db = try! Connection(path, readonly: true)

        var code: Int = 0
        let dateComponents = DateComponents(date: date)

        if cal.pascha ..< cal.d("sunday2AfterPascha") ~= date {
            code = 100
            
        } else if dateComponents.weekday! == 1 {
            code = 10 + cal.getTone(date)!
            
        } else {
            code = dateComponents.weekday!
        }
        
        troparion.append(
            contentsOf: try! db.prepareRowIterator(tropari
                .filter(f_code == code)
                .order(f_id.asc))
            .map {
                var url: String?
                
                do {
                    url = try $0.get(f_url)
                } catch _ { }
                
                return Troparion(
                    title: $0[f_title],
                    content: $0[f_content],
                    url: url != nil ? "/tropari_day/tropari_day/\(url!).mp3" : nil)
            })
        
        return troparion
    }
    
    func isDownloaded() -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}

