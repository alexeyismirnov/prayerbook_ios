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
    
    init() {
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Expanded")
        
        super.init(rootViewController: viewController)
        
        isNavigationBarHidden = true
    

        if #available(iOSApplicationExtension 10.0, *) { // Xcode would suggest you implement this.
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
    
    static func describe(saints: [(FeastType, String)], label: UILabel!)  {
        let myString = NSMutableAttributedString(string: "")
        
        if let iconName = Cal.feastIcon[saints[0].0] {
            let iconColor = (saints[0].0 == .noSign || saints[0].0 == .sixVerse) ? UIColor.black : UIColor.red
            let image = UIImage(named: iconName)!.maskWithColor(iconColor)
            
            let attachment = NSTextAttachment()
            attachment.image = image.resize(CGSize(width: 15, height: 15))
            
            attachment.bounds = CGRect(x: 0.0, y: label.font.descender, width: attachment.image!.size.width, height: attachment.image!.size.height)
            
            myString.append(NSAttributedString(attachment: attachment))
        }
        
        myString.append(NSMutableAttributedString(string: saints[0].1,
                                                  attributes: [NSForegroundColorAttributeName:
                                                    (saints[0].0 == .great) ? UIColor.red:UIColor.black] ))
        
        label.attributedText = myString
    }
    

}
