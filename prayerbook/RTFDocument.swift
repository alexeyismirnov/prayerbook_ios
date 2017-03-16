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
    var content : NSAttributedString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontSize = prefs.integer(forKey: "fontSize")

        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg3.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let button_zoom_in = UIBarButtonItem(image: UIImage(named: "zoom_in"), style: .plain, target: self, action: #selector(self.zoom_in))
        let button_zoom_out = UIBarButtonItem(image: UIImage(named: "zoom_out"), style: .plain, target: self, action: #selector(self.zoom_out))
        
        button_zoom_in.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]

        view.backgroundColor = UIColor(patternImage: image)
        title = docTitle
        
        if let filename = docFilename,
           let rtfPath = Bundle.main.url(forResource: filename, withExtension: "rtf") {
            
            do {
                content = try NSAttributedString(fileURL: rtfPath, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)

            } catch let error {
                print("We got an error \(error)")
            }
        }
        
        self.textView.attributedText = content
        self.textView.font =  UIFont(name: (textView.font?.fontName)!, size: CGFloat(fontSize))!


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
    
    func zoom_in() {
        updateFontSize(fontSize+2)
    }
    
    func zoom_out() {
        updateFontSize(fontSize-2)
    }
    
}

