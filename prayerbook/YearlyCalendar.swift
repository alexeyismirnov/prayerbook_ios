//
//  YearlyCalendar.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/26/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

struct YearlyCalendarConfig {
    var insets : CGFloat
    var interitemSpacing : CGFloat
    var lineSpacing : CGFloat
    var titleFontSize : CGFloat
    var fontSize : CGFloat
}

class YearlyCalendar: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
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

    static let iPhonePlusConfig = YearlyCalendarConfig(insets: 10,
                                                    interitemSpacing: 15,
                                                    lineSpacing: 0,
                                                    titleFontSize: 17,
                                                    fontSize: 10)

    static let iPadConfig = YearlyCalendarConfig(insets: 10,
                                                interitemSpacing: 25,
                                                lineSpacing: 5,
                                                titleFontSize: 20,
                                                fontSize: 14)

    var year = Cal.currentYear!
    let numCols:CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ["iPhone 5", "iPhone 5s", "iPhone 5c", "iPhone 4", "iPhone 4s", "iPhone SE"].contains(UIDevice.modelName) {
            YC.config = YC.iPhone5sConfig
        
        } else if ["iPhone 6", "iPhone 6s", "iPhone 7"].contains(UIDevice.modelName) {
            YC.config = YC.iPhoneConfig
            
        } else if ["iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus"].contains(UIDevice.modelName) {
            YC.config = YC.iPhonePlusConfig

        } else  if (UIDevice.current.userInterfaceIdiom == .phone) {
            YC.config = YC.iPhoneConfig

        } else {
            YC.config = YC.iPadConfig

        }
        
        title = "\(year)"
        navigationController?.makeTransparent()

        let backButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view))
        }
                
        collectionView.register(UINib(nibName: "YearlyMonthViewCell", bundle: nil), forCellWithReuseIdentifier: YearlyMonthViewCell.cellId)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(YC.config.insets, YC.config.insets, YC.config.insets, YC.config.insets)
        layout.minimumInteritemSpacing = YC.config.interitemSpacing
        layout.minimumLineSpacing = YC.config.lineSpacing

        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.contentInset.top = 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YearlyMonthViewCell.cellId, for: indexPath) as! YearlyMonthViewCell
        cell.currentDate = Date(1, indexPath.row+1, year)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - YC.config.insets*2.0 - (numCols-1) * YC.config.interitemSpacing) / numCols
        
        return CGSize(width: cellWidth, height: cellWidth+40)
    }
    
    func close() {
        dismiss(animated: true, completion: {})
    }
}

typealias YC = YearlyCalendar
