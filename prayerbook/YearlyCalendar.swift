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

class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout
{
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        if let attrs = super.layoutAttributesForElements(in: rect)
        {
            var baseline: CGFloat = -2
            var sameLineElements = [UICollectionViewLayoutAttributes]()
            for element in attrs
            {
                if element.representedElementCategory == .cell
                {
                    let frame = element.frame
                    let centerY = frame.midY
                    if abs(centerY - baseline) > 1
                    {
                        baseline = centerY
                        TopAlignedCollectionViewFlowLayout.alignToTopForSameLineElements(sameLineElements: sameLineElements)
                        sameLineElements.removeAll()
                    }
                    sameLineElements.append(element)
                }
            }
            TopAlignedCollectionViewFlowLayout.alignToTopForSameLineElements(sameLineElements: sameLineElements) // align one more time for the last line
            return attrs
        }
        return nil
    }
    
    private class func alignToTopForSameLineElements(sameLineElements: [UICollectionViewLayoutAttributes])
    {
        if sameLineElements.count < 1
        {
            return
        }
        let sorted = sameLineElements.sorted { (obj1: UICollectionViewLayoutAttributes, obj2: UICollectionViewLayoutAttributes) -> Bool in
            
            let height1 = obj1.frame.size.height
            let height2 = obj2.frame.size.height
            let delta = height1 - height2
            return delta <= 0
        }
        if let tallest = sorted.last
        {
            for obj in sameLineElements
            {
                obj.frame = obj.frame.offsetBy(dx: 0, dy: tallest.frame.origin.y - obj.frame.origin.y)
            }
        }
    }
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

    var year = Cal.currentYear!
    let numCols:CGFloat = 3
    
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

        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")

        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        let shareButton = UIBarButtonItem(image: UIImage(named: "share", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = shareButton

        navigationController?.makeTransparent()
        automaticallyAdjustsScrollViewInsets = false
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view,  bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
        
        collectionView.register(UINib(nibName: "YearlyMonthViewCell", bundle: nil), forCellWithReuseIdentifier: YearlyMonthViewCell.cellId)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        let layout =  TopAlignedCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(YC.config.insets, YC.config.insets, YC.config.insets, YC.config.insets)
        layout.minimumInteritemSpacing = YC.config.interitemSpacing
        layout.minimumLineSpacing = YC.config.lineSpacing
        
        collectionView.collectionViewLayout  = layout
        collectionView.reloadData()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.contentInset.top = 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return (FastingLevel() == .monastic) ? Cal.fastingMonastic.count : Cal.fastingLaymen.count
        
        } else {
            return 12
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YearlyMonthViewCell.cellId, for: indexPath) as! YearlyMonthViewCell
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
            let str = NSAttributedString(string: Translate.s(info.1), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(YC.config.fontSize))])

            let rect = str.boundingRect(with:  CGSize(width:cellWidth-35,height:999), options: .usesLineFragmentOrigin, context: nil)

            return CGSize(width: cellWidth-0.1, height: rect.height+10)

        } else {
            return CGSize(width: cellWidth-0.1, height: cellWidth+40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath)
        
        let label = UILabel(frame: headerView.frame)
        label.textAlignment = .center
        label.text = "Православный календарь на \(year) г."
        label.textColor = YearlyCalendar.isSharing ? .black : Theme.textColor
        
        headerView.addSubview(label)
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: 0, height: 50)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func close() {
        dismiss(animated: true, completion: { })
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
        
        if let data = UIImageJPEGRepresentation(pdfImage, 0.9) {
            let filename = documentsURL.appendingPathComponent("calendar.jpg")
            try? data.write(to: filename)
        }
        
        return pdfImage
    }
    
    func share() {
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
