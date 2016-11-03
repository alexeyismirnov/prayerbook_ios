//
//  MainViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/31/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import NotificationCenter

class MainViewController : UINavigationController, NCWidgetProviding {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isNavigationBarHidden = true

        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            
        } else {
            self.preferredContentSize = CGSize(width: 0.0, height: 350)

            let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "Expanded")
            pushViewController(viewController, animated: false)
        }
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        var viewController : UIViewController!
        
        popViewController(animated: false)

        if activeDisplayMode == NCWidgetDisplayMode.compact {
            self.preferredContentSize = maxSize
            viewController = storyboard.instantiateViewController(withIdentifier: "Compact")
            
        } else if activeDisplayMode == NCWidgetDisplayMode.expanded {
            self.preferredContentSize = CGSize(width: 0.0, height: 350)
            viewController = storyboard.instantiateViewController(withIdentifier: "Expanded")
        }

        pushViewController(viewController, animated: false)
    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    static func describe(saints: [(FeastType, String)], font: UIFont!) -> NSAttributedString {
        let myString = NSMutableAttributedString(string: "")
        
        if let iconName = Cal.feastIcon[saints[0].0] {
            
            var iconColor:UIColor
            
            if #available(iOSApplicationExtension 10.0, *) {
                iconColor = (saints[0].0 == .noSign || saints[0].0 == .sixVerse) ? UIColor.black : UIColor.red
            } else {
                iconColor = (saints[0].0 == .noSign || saints[0].0 == .sixVerse) ? UIColor.white : UIColor.red
            }
            
            let image = UIImage(named: iconName)!.maskWithColor(iconColor)
            
            let attachment = NSTextAttachment()
            attachment.image = image.resize(CGSize(width: 15, height: 15))
            
            attachment.bounds = CGRect(x: 0.0, y: font.descender, width: attachment.image!.size.width, height: attachment.image!.size.height)
            
            myString.append(NSAttributedString(attachment: attachment))
        }
        
        var textColor:UIColor
        
        if #available(iOSApplicationExtension 10.0, *) {
            textColor = (saints[0].0 == .great) ? UIColor.red:UIColor.black
        } else {
            textColor = (saints[0].0 == .great) ? UIColor.red:UIColor.white
        }
        
        myString.append(NSMutableAttributedString(string: saints[0].1,
                                                  attributes: [
                                                    NSForegroundColorAttributeName: textColor,
                                                               NSFontAttributeName: font
                                                               ]))
        
        return myString
    }
    

}
