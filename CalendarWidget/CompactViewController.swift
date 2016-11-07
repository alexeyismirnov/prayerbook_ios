//
//  CompactViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/1/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

extension UIFont {
    
    func withTraits(_ traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(.traitBold, .traitItalic)
    }
}

extension UIDevice {
       static var modelName: String {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let DEVICE_IS_SIMULATOR = true
        #else
            let DEVICE_IS_SIMULATOR = false
        #endif
        
        var machineString = String()
        
        if DEVICE_IS_SIMULATOR == true
        {
            if let dir = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                machineString = dir
            }
        }
        else {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            machineString = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 , value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        }
        switch machineString {
        case "iPod4,1":                                 return "iPod Touch 4G"
        case "iPod5,1":                                 return "iPod Touch 5G"
        case "iPod7,1":                                 return "iPod Touch 6G"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone 9,4":                 return "iPhone 7 Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7 inch)"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9 inch)"
        case "AppleTV5,3":                              return "Apple TV"
        default:                                        return machineString
        }
    }
    
}

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
        
        if ["iPhone 5", "iPhone 5s", "iPhone 5c", "iPhone 6", "iPhone 6s", "iPhone 7"].contains(UIDevice.modelName) {
            dayDescription.numberOfLines = 5
        } else {
            dayDescription.numberOfLines = 4
        }
        
        dayDescription.attributedText = describe()

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
