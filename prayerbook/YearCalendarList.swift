//
//  YearCalendarList.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/3/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class YearCalendarList: UIView {
    var year: Int
    var textView : UITextView!
    var feasts : NSAttributedString!

    init(_ year: Int) {
        self.year = year
        super.init(frame: CGRect.zero)
        
        setupList()
    }
    
    required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
    }
    
    func setupList() {
        backgroundColor = .clear
        
        textView = UITextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isPagingEnabled = false
        textView.bounces = true
        textView.isEditable = false
        
        addSubview(textView)
        fullScreen(view: textView, marginX: 10.0, marginY: 0.0)
        
        createFeastList()
        textView.attributedText = feasts
    }
    
    func addFeasts(_ title: String, _ data : [Date: NSAttributedString]) {
        feasts += title.colored(with: FL.textFontColor).boldFont(ofSize: 18.0).centered + "\n"
        
        for feast in data.sorted(by: { $0.0 < $1.0 }) {
            feasts = feasts + feast.1
        }
    }
    
    func createFeastList(sharing: Bool = false) {
        FL.sharing = sharing
        FL.setDate(Date(1, 1, year))

        feasts = "Посты и праздники в \(year) г.\n\n".colored(with: FL.textFontColor) .boldFont(ofSize: 20.0).centered
            +
            FL.makeFeastStr(code: .pascha, color: UIColor.red) +
        "\n"
        
        addFeasts("Многодневные посты\n", FL.longFasts)
        addFeasts("Однодневные посты\n", FL.shortFasts)
        addFeasts("Сплошные седмицы\n", FL.fastFreeWeeks)
        addFeasts("Двунадесятые переходящие праздники\n", FL.movableFeasts)
        addFeasts("Двунадесятые непереходящие праздники\n", FL.nonMovableFeasts)
        addFeasts("Великие праздники\n", FL.greatFeasts)
        
        addFeasts("Дни особого поминовения усопших\n", FL.remembrance)
        
        feasts = feasts + "Суббота 2-й, 3-й и 4-й седмицы Великого поста\n\n".colored(with: FL.textFontColor).systemFont(ofSize: FL.textFontSize)
    }
    
    // https://www.hackingwithswift.com/example-code/uikit/how-to-render-an-nsattributedstring-to-a-pdf
    func shareList() -> UIActivityViewController {
        let pageSize = CGSize(width: 595.2, height: 841.8)
        let pageMargins = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)

        createFeastList(sharing: true)

        let printFormatter = UISimpleTextPrintFormatter(attributedText: feasts!)
               
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSMakeRange(0, renderer.numberOfPages))
        
        let bounds = UIGraphicsGetPDFContextBounds()
        
        for i in 0  ..< renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            
            renderer.drawPage(at: i, in: bounds)
        }
        
        UIGraphicsEndPDFContext()
        
        createFeastList(sharing: false)

        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsFileName = documentDirectories + "/" + "calendar.pdf"
        debugPrint(documentsFileName)
        
        pdfData.write(toFile: documentsFileName, atomically: true)
        
        let activityViewController = UIActivityViewController(activityItems: [URL(fileURLWithPath: documentsFileName)], applicationActivities: nil)
        return activityViewController
    }
    
}
