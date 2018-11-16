//
//  RTFDocument.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 3/8/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

extension UITextView {
    func increaseFontSize () {
        self.font =  UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)!+1)!
    }
}

class RTFDocument: UIViewController {

    @IBOutlet weak var textView: UITextView!
    let prefs = UserDefaults(suiteName: groupId)!
    var fontSize: Int = 0

    var docFilename : String?
    var content : NSMutableAttributedString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        fontSize = prefs.integer(forKey: "fontSize")

        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }

        let button_zoom_in = CustomBarButton(image: UIImage(named: "zoom_in", in: toolkit, compatibleWith: nil)!
, target: self, btnHandler: #selector(self.zoom_in))
        let button_zoom_out = CustomBarButton(image: UIImage(named: "zoom_out", in: toolkit, compatibleWith: nil)!, target: self, btnHandler: #selector(self.zoom_out))
        
        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]
        
        if let filename = docFilename,
           let rtfPath = Bundle.main.url(forResource: filename, withExtension: "rtf") {
            
            do {
                let opts : [NSAttributedString.DocumentReadingOptionKey : Any] =
                    [.documentType : NSAttributedString.DocumentType.rtf]
                
                content = try NSMutableAttributedString(fileURL: rtfPath, options: opts, documentAttributes: nil)

            } catch let error {
                print("We got an error \(error)")
            }
        }
        
        content!.addAttribute(NSAttributedString.Key.foregroundColor, value: Theme.textColor ,
                           range: NSMakeRange(0, content!.length))

        textView.attributedText = content
        textView.font =  UIFont(name: (textView.font?.fontName)!, size: CGFloat(fontSize))!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func updateFontSize(_ newSize : Int) {
        fontSize = newSize
        prefs.set(fontSize, forKey: "fontSize")
        prefs.synchronize()
        
        textView.font =  UIFont(name: (textView.font?.fontName)!, size: CGFloat(fontSize))!
    }
    
    @objc func zoom_in() {
        updateFontSize(fontSize+2)
    }
    
    @objc func zoom_out() {
        updateFontSize(fontSize-2)
    }
    
}
