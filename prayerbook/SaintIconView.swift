//
//  SaintIconView.swift
//  ponomar
//
//  Created by Alexey Smirnov on 2/6/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class SaintIconCell : UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate  {
    var saints = [Saint]()  {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectable = true
    
    var collectionView: UICollectionView!

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        clipsToBounds = true
        
        let flowLayout = CenterViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = SaintIconCell.getItemSize()
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
        fullScreen(view: collectionView)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return saints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageViewCell = collectionView.dequeueReusableCell(for: indexPath)

        guard let resourcePath = Bundle.main.resourcePath else { return cell }
        let iconPath = resourcePath + "/icons/\(saints[indexPath.row].id).jpg"
        
        if saints[indexPath.row].has_icon {
            try! cell.icon.image = UIImage(data: Data(contentsOf: URL(fileURLWithPath: iconPath)))
            cell.icon.contentMode = .scaleAspectFit
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectable {
            _ = UIAlertController(title: saints[indexPath.row].name,
                                         message: "",
                                         view: self.parentViewController!,
                                         handler: { _ in })
        }
    }

    static func getItemSize() -> CGSize {
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            if ["iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus"].contains(UIDevice.modelName) {
                return CGSize(width: 120, height: 120)
                
            } else  if ["iPhone 4s", "iPhone 5", "iPhone 5s", "iPhone SE"].contains(UIDevice.modelName) {
                return CGSize(width: 90, height: 90)
                
            } else {
                return CGSize(width: 110, height: 110)
                
            }
        } else {
            return CGSize(width: 180, height: 180)
        }
    }
}

extension SaintIconCell: ReusableView {}
