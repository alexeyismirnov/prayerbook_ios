//
//  RTFDocument.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 3/8/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

extension UITextView {
    func increaseFontSize () {
        self.font =  UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)!+1)!
    }
}

class RTFDocument: UIViewController {

    @IBOutlet weak var textView: UITextView!
    let prefs = UserDefaults(suiteName: groupId)!
    var fontSize: Int = 0

    var docTitle : String!
    var docFilename : String?
    var content : NSMutableAttributedString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontSize = prefs.integer(forKey: "fontSize")

        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view))
        }
        
        let button_zoom_in = UIBarButtonItem(image: UIImage(named: "zoom_in"), style: .plain, target: self, action: #selector(self.zoom_in))
        let button_zoom_out = UIBarButtonItem(image: UIImage(named: "zoom_out"), style: .plain, target: self, action: #selector(self.zoom_out))
        
        button_zoom_in.imageInsets = UIEdgeInsets.init(top: 0,left: 0,bottom: 0,right: -20)
        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]

        title = docTitle
        
        if let filename = docFilename,
           let rtfPath = Bundle.main.url(forResource: filename, withExtension: "rtf") {
            
            do {
                content = try NSMutableAttributedString(fileURL: rtfPath, options: [convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.documentType):convertFromNSAttributedStringDocumentType(NSAttributedString.DocumentType.rtf)], documentAttributes: nil)

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


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentAttributeKey(_ input: NSAttributedString.DocumentAttributeKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentType(_ input: NSAttributedString.DocumentType) -> String {
	return input.rawValue
}
