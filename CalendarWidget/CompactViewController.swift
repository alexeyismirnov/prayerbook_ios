//
//  CompactViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/1/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class CompactViewController: UIViewController {

    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "cccc d MMMM yyyy г.; "
        
        return formatter
    }()

    var currentDate: Date = {
        return DateComponents(date: Date()).toDate()
    }()
    
    var fasting: (FastingType, String) = (.vegetarian, "")
    var fastingLevel: FastingLevel = .monastic

    let prefs = UserDefaults(suiteName: groupId)!
    
    @IBOutlet weak var dayDescription: UILabel!
    @IBOutlet weak var saintsDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Translate.files = ["trans_ui", "trans_cal", "trans_library"]

        if let language = prefs.object(forKey: "language") as? String {
            Translate.language = language
        }
        
        formatter.locale = Translate.locale as Locale!
        
        var descr = formatter.string(from: currentDate)
        
        if let weekDescription = Cal.getWeekDescription(currentDate) {
            descr += weekDescription
        }
        
        if let toneDescription = Cal.getToneDescription(currentDate) {
            if descr.characters.count > 0 {
                descr += "; "
            }
            descr += toneDescription
        }
        
        fastingLevel = FastingLevel(rawValue: prefs.integer(forKey: "fastingLevel"))!
        fasting = Cal.getFastingDescription(currentDate, fastingLevel)

        descr += "; " + fasting.1

        dayDescription.text = descr
        
        let saints = Db.saints(currentDate)
        let day = Cal.getDayDescription(currentDate)
        let feasts = (saints+day).sorted { $0.0.rawValue > $1.0.rawValue }
        
        MainViewController.describe(saints: feasts, label: saintsDescription)

    }
    
    
}
