//
//  YearlyCalendar.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/26/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

struct YearlyCalendarConfig {
    var insets : CGFloat
    var interitemSpacing : CGFloat
    var lineSpacing : CGFloat
    var titleFontSize : CGFloat
    var fontSize : CGFloat
}

class YearlyCalendar: UIViewControllerAnimated, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    static var isSharing = false
    static var config : YearlyCalendarConfig!

    static let iPhone5sConfig = YearlyCalendarConfig(insets: 10,
                                                    interitemSpacing: 10,
                                                    lineSpacing: 0,
                                                    titleFontSize: 12,
                                                    fontSize: 8)
    
    static let iPhoneConfig = YearlyCalendarConfig(insets: 10,
                                                    interitemSpacing: 14,
                                                    lineSpacing: 0,
                                                    titleFontSize: 15,
                                                    fontSize: 9)

    static let iPhonePlusConfig = YearlyCalendarConfig(insets: 20,
                                                    interitemSpacing: 15,
                                                    lineSpacing: 10,
                                                    titleFontSize: 17,
                                                    fontSize: 10)

    static let iPadConfig = YearlyCalendarConfig(insets: 20,
                                                interitemSpacing: 25,
                                                lineSpacing: 5,
                                                titleFontSize: 20,
                                                fontSize: 14)
    
    enum ViewType {
        case list, grid
    }
    
    static var viewType = ViewType.list
    
    var appeared = false
    var year = Cal.currentYear!
    let numCols:CGFloat = 3
    
    var headerLabel : UILabel!
    var textView : UITextView!
    var textViewSize : CGSize!
    var feasts : NSMutableAttributedString? = nil
    
    var shareButton, listButton, gridButton :UIBarButtonItem!
    
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    static func year(_ year: Int) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "yearly") as! YearlyCalendar
        vc.year = year
        return vc
    }
    
    override func viewControllerCurrent() -> UIViewController {
        return YC.year(year)
    }
    
    override func viewControllerForward() -> UIViewController {
        return YC.year(year+1)
    }
    
    override func viewControllerBackward() -> UIViewController {
        return YC.year(year-1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ["iPhone 5", "iPhone 5s", "iPhone 5c", "iPhone 4", "iPhone 4s", "iPhone SE"].contains(UIDevice.modelName) {
            YC.config = YC.iPhone5sConfig
        
        } else if ["iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8"].contains(UIDevice.modelName) {
            YC.config = YC.iPhoneConfig
            
        } else if ["iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus"].contains(UIDevice.modelName) {
            YC.config = YC.iPhonePlusConfig

        } else  if (UIDevice.current.userInterfaceIdiom == .phone) {
            YC.config = YC.iPhoneConfig

        } else {
            YC.config = YC.iPadConfig
        }

        createFeastList()
        createHeaderViews()

        setupNavbar()
        
        collectionView.register(UINib(nibName: "YearlyMonthViewCell", bundle: nil), forCellWithReuseIdentifier: YearlyMonthViewCell.cellId)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        let layout =  TopAlignedCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: YC.config.insets, left: YC.config.insets, bottom: YC.config.insets, right: YC.config.insets)
        layout.minimumInteritemSpacing = YC.config.interitemSpacing
        layout.minimumLineSpacing = YC.config.lineSpacing
        
        collectionView.collectionViewLayout  = layout
        collectionView.reloadData()
    }
    
    func addFeasts(_ title: String, _ data : [Date: NSMutableAttributedString]) {
        feasts = feasts + FeastList.makeTitle(title: title) + "\n"
        
        for feast in data.sorted(by: { $0.0 < $1.0 }) {
            feasts = feasts + feast.1
        }
    }
    
    func createFeastList(sharing: Bool = false) {
        FeastList.sharing = sharing
        FeastList.setDate(Date(1, 1, year))

        let title1 = FeastList.makeTitle(title: "Посты и праздники в \(year) г.\n\n", fontSize: 20.0)
        let cal1 = FeastList.makeFeastStr(code: .pascha, color: UIColor.red)
        
        feasts = title1 + cal1 + "\n"
        
        addFeasts("Многодневные посты\n", FeastList.longFasts)
        addFeasts("Однодневные посты\n", FeastList.shortFasts)
        addFeasts("Сплошные седмицы\n", FeastList.fastFreeWeeks)
        addFeasts("Двунадесятые переходящие праздники\n", FeastList.movableFeasts)
        addFeasts("Двунадесятые непереходящие праздники\n", FeastList.nonMovableFeasts)
        addFeasts("Великие праздники\n", FeastList.greatFeasts)
    }
    
    func createHeaderViews() {
        let margin = CGFloat(10.0)
        
        textView =  UITextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isPagingEnabled = false
        textView.bounces = false
        textView.isEditable = false
        
        textView.attributedText = feasts
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textViewSize = textView.sizeThatFits(CGSize(width: view.frame.width-2*margin, height: CGFloat.greatestFiniteMagnitude))
        textView.frame = CGRect(origin: CGPoint(x: margin, y: 0), size: textViewSize)
        
        headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        headerLabel.textAlignment = .center
        headerLabel.text = "Православный календарь на \(year) г."
        headerLabel.textColor = YearlyCalendar.isSharing ? .black : Theme.textColor
    }
    
    func setupNavbar() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        
        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        shareButton = UIBarButtonItem(image: UIImage(named: "share", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(share))
        
        listButton = UIBarButtonItem(image: UIImage(named: "list", in: nil, compatibleWith: nil), style: .plain, target: self, action: #selector(switchView))
        
        gridButton = UIBarButtonItem(image: UIImage(named: "grid", in: nil, compatibleWith: nil), style: .plain, target: self, action: #selector(switchView))
        
        if (YC.viewType == .grid) {
            navigationItem.rightBarButtonItems = [shareButton, listButton]

        } else {
            navigationItem.rightBarButtonItems = [shareButton, gridButton]
        }
        
        navigationController?.makeTransparent()
        automaticallyAdjustsScrollViewInsets = false
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view,  bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.contentInset.top = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appeared = true
        collectionView.reloadData()
    }
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return YC.viewType == .grid ? 2 : 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return YC.viewType == .grid ? 12 : 0
            
        } else if section == 1 {
            return (FastingLevel() == .monastic) ? Cal.fastingMonastic.count : Cal.fastingLaymen.count
        
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YearlyMonthViewCell.cellId, for: indexPath) as! YearlyMonthViewCell
            cell.appeared = appeared
            cell.currentDate = Date(1, indexPath.row+1, year)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarImageCell", for: indexPath) as! CalendarImageCell
            let info = (FastingLevel() == .monastic) ? Cal.fastingMonastic[indexPath.row] : Cal.fastingLaymen[indexPath.row]
            
            cell.imageView.backgroundColor = UIColor(hex: Cal.fastingColor[info.0]!)
            cell.textLabel.text = Translate.s(info.1)
            cell.textLabel.font = UIFont.systemFont(ofSize: YC.config.fontSize)
            cell.textLabel.textColor = YearlyCalendar.isSharing ? .black : Theme.textColor
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - YC.config.insets*2.0 - (numCols-1) * YC.config.interitemSpacing) / numCols
        
        if indexPath.section == 1 {
            let info = (FastingLevel() == .monastic) ? Cal.fastingMonastic[indexPath.row] : Cal.fastingLaymen[indexPath.row]
            let str = NSAttributedString(string: Translate.s(info.1), attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: CGFloat(YC.config.fontSize))]))

            let rect = str.boundingRect(with:  CGSize(width:cellWidth-35,height:999), options: .usesLineFragmentOrigin, context: nil)

            return CGSize(width: cellWidth-0.1, height: rect.height+10)

        } else {
            return CGSize(width: cellWidth-0.1, height: cellWidth+40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath)
        
        headerLabel.removeFromSuperview()
        textView.removeFromSuperview()
        
        if YC.viewType == .grid {
            headerView.addSubview(headerLabel)
            
        } else {
            headerView.addSubview(textView)
        }
        
        return headerView
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return YC.viewType == .grid ? CGSize(width: 0, height: 50) : textViewSize
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: { })
    }
    
    @objc func switchView() {
        if (YC.viewType == .grid) {
            YC.viewType = .list
            navigationItem.rightBarButtonItems = [shareButton, gridButton]

        } else {
            YC.viewType = .grid
            navigationItem.rightBarButtonItems = [shareButton, listButton]
        }
        
        collectionView.reloadData()
    }
    
    func convertPDFPageToImage() -> UIImage {
        let page = 1
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("calendar.pdf").path
        
        print(filePath)
        
        let pdfdata = try! NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.init(rawValue: 0))
        
        let pdfData = pdfdata as CFData
        let provider:CGDataProvider = CGDataProvider(data: pdfData)!
        let pdfDoc:CGPDFDocument = CGPDFDocument(provider)!

        let pdfPage:CGPDFPage = pdfDoc.page(at: page)!
        var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
        pageRect.size = CGSize(width:pageRect.size.width*3, height:pageRect.size.height*3)
        
        print("\(pageRect.width) by \(pageRect.height)")
        
        UIGraphicsBeginImageContext(pageRect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.translateBy(x: 0.0, y: pageRect.size.height)
        context.scaleBy(x: 3.0, y: -3.0)
        context.drawPDFPage(pdfPage)
        context.restoreGState()
        
        let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if let data = pdfImage.jpegData(compressionQuality: 0.9) {
            let filename = documentsURL.appendingPathComponent("calendar.jpg")
            try? data.write(to: filename)
        }
        
        return pdfImage
    }
    
    @objc func share() {
        if YC.viewType == .grid {
            shareGrid()
        } else {
            createFeastList(sharing: true)
            shareList()
            createFeastList(sharing: false)

        }
    }
    
    // https://www.hackingwithswift.com/example-code/uikit/how-to-render-an-nsattributedstring-to-a-pdf
    func shareList() {
        let printFormatter = UISimpleTextPrintFormatter(attributedText: feasts!)
        
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pageSize = CGSize(width: 595.2, height: 841.8)
        let pageMargins = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)

        
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
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + "calendar.pdf"
            debugPrint(documentsFileName)
            
            do {
                try pdfData.write(to: URL(fileURLWithPath: documentsFileName))
                
                let activityViewController = UIActivityViewController(activityItems: [URL(fileURLWithPath: documentsFileName)], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                self.present(activityViewController, animated: true, completion: nil)
                
            } catch {
                print(error.localizedDescription)
            }
        }

    }
    
    
    func shareGrid() {
        let pdfData = NSMutableData()
        
        let newSize = CGSize(width: collectionView.contentSize.width,
                             height: collectionView.contentSize.height + navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height)
        
        let newFrame = CGRect(origin: CGPoint(x:0,y:0), size: newSize)
        let origFrame = view.frame
        let origCollectionFrame = collectionView.frame

        print(origFrame)
        print(newFrame)

        view.frame = newFrame
        collectionView.frame = newFrame
        
        UIGraphicsBeginPDFContextToData(pdfData, newFrame, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        YearlyCalendar.isSharing = true
        collectionView.reloadData()
        
        collectionView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        YearlyCalendar.isSharing = false
        collectionView.reloadData()

        view.frame = origFrame
        collectionView.frame = origCollectionFrame
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + "calendar.pdf"
            debugPrint(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
            
            let result = convertPDFPageToImage()
            
            let activityViewController = UIActivityViewController(activityItems: [result], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

}

typealias YC = YearlyCalendar

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
