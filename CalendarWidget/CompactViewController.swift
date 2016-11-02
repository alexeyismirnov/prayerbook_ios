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
    
    var dayDescription: UILabel!
    
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
    
        let frame = CGRect(x: view.bounds.origin.x+10,
                           y: view.bounds.origin.y,
                           width: view.bounds.width - buttonUp.bounds.width - 20,
                           height: 110)
        
        dayDescription = UILabel(frame: frame)
        view.addSubview(dayDescription)
        
        dayDescription.numberOfLines = 4
        dayDescription.attributedText = describe()

    }
    
    func describe() -> NSAttributedString {
        var descr = formatter.string(from: currentDate).capitalizingFirstLetter()
        
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
        
        descr += ". " + fasting.1
        
        let saints = Db.saints(currentDate)
        let day = Cal.getDayDescription(currentDate)
        let feasts = (saints+day).sorted { $0.0.rawValue > $1.0.rawValue }
        
        let result = NSMutableAttributedString(string: "")
        
        result.append(NSAttributedString(string: descr))
        result.append(NSAttributedString(string: "\n"))
        result.append(MainViewController.describe(saints: feasts, font: dayDescription.font))

        return result
    }
    
    func linearTransition(label: UILabel, text: NSAttributedString, direction: AnimationDirection) {
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.center.y -= view.bounds.height * CGFloat(direction.rawValue)
        auxLabel.attributedText = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.numberOfLines = label.numberOfLines
        
        label.superview?.addSubview(auxLabel)
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        auxLabel.center.y += self.view.bounds.height * CGFloat(direction.rawValue)
                        self.dayDescription.center.y += self.view.bounds.height * CGFloat(direction.rawValue)
        },
                       completion: { _ in
                        auxLabel.removeFromSuperview()
                        self.dayDescription.center.y -= self.view.bounds.height * CGFloat(direction.rawValue)
                        self.dayDescription.attributedText = text
        })

    }

    @IBAction func prevDay(_ sender: Any) {
        currentDate = currentDate - 1.days
        linearTransition(label: dayDescription,
                       text: describe(),
                       direction: .positive)
        
    }
    
    @IBAction func nextDay(_ sender: Any) {
        currentDate = currentDate + 1.days
        linearTransition(label: dayDescription,
                       text: describe(),
                       direction: .negative)
    }
    
}
