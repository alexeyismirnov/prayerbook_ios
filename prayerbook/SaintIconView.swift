//
//  SaintIconView.swift
//  ponomar
//
//  Created by Alexey Smirnov on 2/6/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class CollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
}

class SaintIconCell : ConfigurableCell, UICollectionViewDataSource, UICollectionViewDelegate  {
    override class var cellId: String {
        get { return "SaintIconCell" }
    }
    
    var saints = [Saint]()  {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    let collectionReuseIdentifier = "collectionViewCellId"
    
    static func itemSize() -> CGSize {
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            if ["iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus", "iPhone X"].contains(UIDevice.modelName) {
                return CGSize(width: 120, height: 120)
                
            } else {
                return CGSize(width: 110, height: 110)
            }
        } else {
            return CGSize(width: 180, height: 180)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        (collectionView.collectionViewLayout as!  UICollectionViewFlowLayout).itemSize = SaintIconCell.itemSize()
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return saints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath) as! CollectionViewCell
        
        guard let resourcePath = Bundle.main.resourcePath else { return cell }
        let iconPath = resourcePath + "/icons/icon_\(saints[indexPath.row].id).jpg"
        
        try! cell.icon!.image = UIImage(data: Data(contentsOf: URL(fileURLWithPath: iconPath)))
        cell.icon!.contentMode = .scaleAspectFit
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _ = UIAlertController(title: saints[indexPath.row].name,
                              message: "",
                              view: self.parentViewController!,
                              handler: { _ in })
    }

}

