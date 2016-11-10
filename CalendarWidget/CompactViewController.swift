//
//  CompactViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/1/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class CompactViewController: UIViewController {
    enum AnimationDirection: Int {
        case positive = 1
        case negative = -1
    }

    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "cccc d MMMM yyyy г. "
        
        return formatter
    }()

    var currentDate: Date = {
        return DateComponents(date: Date()).toDate()
    }()
    
    var fasting: (FastingType, String) = (.vegetarian, "")
    var fastingLevel: FastingLevel = .monastic

    let prefs = UserDefaults(suiteName: groupId)!

    @IBOutlet weak var dayInfo: UITextView!
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var buttonDown: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image1 = UIImage(named: "fat-up")!.withRenderingMode(.alwaysTemplate)
        buttonUp.setImage(image1, for: UIControlState())
        buttonUp.imageView?.tintColor = UIColor.darkGray

        let image2 = UIImage(named: "fat-down")!.withRenderingMode(.alwaysTemplate)
        buttonDown.setImage(image2, for: UIControlState())
        buttonDown.imageView?.tintColor = UIColor.darkGray

        Translate.files = ["trans_ui", "trans_cal", "trans_library"]

        if let language = prefs.object(forKey: "language") as? String {
            Translate.language = language
        }
        
        formatter.locale = Translate.locale as Locale!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)    
        dayInfo.attributedText = describe()
    }
    
    func describe() -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        
        var fontSize : CGFloat

        if ["iPhone 5", "iPhone 5s", "iPhone 5c", "iPhone 6", "iPhone 6s", "iPhone 7"].contains(UIDevice.modelName) {
            fontSize = 15
        } else {
            fontSize = 18
        }

        let fontRegular = UIFont.systemFont(ofSize: fontSize)
        let fontBold = UIFont.systemFont(ofSize: fontSize).withTraits(.traitBold)
        let fontItalic = UIFont.systemFont(ofSize: fontSize).withTraits(.traitItalic)

        var descr = formatter.string(from: currentDate).capitalizingFirstLetter()
        
        let s1 = NSAttributedString(string: descr, attributes: [NSFontAttributeName: fontBold])
        result.append(s1)

        if let weekDescription = Cal.getWeekDescription(currentDate) {
            descr = weekDescription
            
            let s2 = NSAttributedString(string: descr, attributes: [NSFontAttributeName: fontRegular])
            result.append(s2)
        }
        
        if let toneDescription = Cal.getToneDescription(currentDate) {
            descr = "; " + toneDescription
            
            let s3 = NSAttributedString(string: descr, attributes: [NSFontAttributeName: fontRegular])
            result.append(s3)
        }
        
        fastingLevel = FastingLevel(rawValue: prefs.integer(forKey: "fastingLevel"))!
        fasting = Cal.getFastingDescription(currentDate, fastingLevel)
        
        descr = ". " + fasting.1

        let s4 = NSAttributedString(string: descr, attributes: [NSFontAttributeName: fontItalic])
        result.append(s4)
        
        let saints = Db.saints(currentDate)
        let day = Cal.getDayDescription(currentDate)
        let feasts = (saints+day).sorted { $0.0.rawValue > $1.0.rawValue }
        
        result.append(NSAttributedString(string: "\n"))
        result.append(MainViewController.describe(saints: feasts, font: fontRegular))

        return result
    }
    
    @IBAction func prevDay(_ sender: Any) {
        Animation.swipe(orientation: .vertical,
                        direction: .negative,
                        inView: view,
                        update: {
                            self.currentDate = self.currentDate - 1.days
                            self.dayInfo.attributedText = self.describe()
        })
        
    }
    
    @IBAction func nextDay(_ sender: Any) {
        Animation.swipe(orientation: .vertical,
                        direction: .positive,
                        inView: view,
                        update: {
                            self.currentDate = self.currentDate + 1.days
                            self.dayInfo.attributedText = self.describe()
        })

    }
    
}
