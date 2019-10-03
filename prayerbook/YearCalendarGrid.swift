//
//  YearCalendarGrid.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/30/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class YearCalendarGridHeader: UICollectionReusableView {
    var title: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        title = UILabel()

        title.numberOfLines = 1
        title.font = UIFont.systemFont(ofSize: Theme.defaultFontSize)
        title.textColor = Theme.textColor
        title.adjustsFontSizeToFitWidth = false
        title.clipsToBounds = true
        title.textAlignment = .center
        title.baselineAdjustment = .alignCenters

        addSubview(title)
        fullScreen(view: title)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class YearCalendarGrid: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    
    let theme = YearCalendarGridTheme.shared
    var appeared = false  {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var year: Int
    let numCols:CGFloat = 3
        
    let fastingTypes : [FastingModel] = (FastingModel.fastingLevel == .monastic) ? FastingModel.monasticTypes : FastingModel.laymenTypes
    
    init(_ year: Int) {
        self.year = year
        super.init(frame: CGRect.zero)
        
        setupGrid()
    }
    
    required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
    }
    
    func setupGrid() {
        backgroundColor = .clear

        let layout =  TopAlignedCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: theme.insets, left: theme.insets, bottom: theme.insets, right: theme.insets)
        layout.minimumInteritemSpacing = theme.interitemSpacing
        layout.minimumLineSpacing = theme.lineSpacing
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(YearCalendarGridHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: "header")

        collectionView.register(UINib(nibName: "YearlyMonthViewCell", bundle: nil), forCellWithReuseIdentifier: YearlyMonthViewCell.cellId)

        addSubview(collectionView)
        fullScreen(view: collectionView)
        
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       if section == 0 {
           return 12
           
       } else if section == 1 {
           return fastingTypes.count
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
            let cell:FastingLegendCell = collectionView.dequeueReusableCell(for: indexPath)
            let fasting = fastingTypes[indexPath.row]
            
            cell.icon.backgroundColor = fasting.color
            cell.title.text = fasting.descr
            cell.title.font = UIFont.systemFont(ofSize: theme.fontSize)
            cell.title.textColor = theme.textColor
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath) as! YearCalendarGridHeader
        
        headerView.title.text =  "Православный календарь на \(year) г."
       
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - theme.insets*2.0 - (numCols-1) * theme.interitemSpacing) / numCols
        
        if indexPath.section == 1 {
            let fasting = fastingTypes[indexPath.row]
            let str = NSAttributedString(string: fasting.descr, attributes: [.font: UIFont.systemFont(ofSize: theme.fontSize)])
            let rect = str.boundingRect(with:  CGSize(width:cellWidth-35,height:999), options: .usesLineFragmentOrigin, context: nil)

            return CGSize(width: cellWidth-0.1, height: rect.height+10)

        } else {
            return CGSize(width: cellWidth-0.1, height: cellWidth+40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0  {
            return CGSize(width: 0, height: 50)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func shareGrid() -> UIActivityViewController {
        let pdfData = NSMutableData()
        let contentWidth = collectionView.contentSize.width
        let contentHeight = collectionView.contentSize.height
        
        let newFrame = CGRect(origin: CGPoint(x:0,y:0),
                              size: CGSize(width: contentWidth, height: contentHeight))
        
        collectionView.removeConstraints()
        
        collectionView.widthAnchor.constraint(equalToConstant: contentWidth).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
        
        collectionView.layoutIfNeeded()
                
        UIGraphicsBeginPDFContextToData(pdfData, newFrame, nil)
        UIGraphicsBeginPDFPage()
        
        let pdfContext = UIGraphicsGetCurrentContext()!
        
        theme.setSharing(true)
        collectionView.reloadData()
        
        collectionView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        theme.setSharing(false)
        
        collectionView.removeConstraints()
        fullScreen(view: collectionView)
        collectionView.reloadData()

        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsFileName = documentDirectories + "/" + "calendar.pdf"
        debugPrint(documentsFileName)
        
        pdfData.write(toFile: documentsFileName, atomically: true)
        let result = convertPDFPageToImage()
        let activityViewController = UIActivityViewController(activityItems: [result], applicationActivities: nil)

        return activityViewController
            /*
            
            
 */
        
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
}

