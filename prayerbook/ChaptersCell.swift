//
//  ChaptersCell.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/11/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit

public let chapterSelectedNotification = "CHAPTER_SELECTED"

class ChaptersCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    var numChapters: Int!
    var book : Int!
    let cellId = "DateViewCell"
    
    required override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(chapterSelected(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
        
    }
    
    @objc func chapterSelected(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: collectionView)
        
        if  let path = collectionView.indexPathForItem(at: loc) {
            let userInfo = ["book": book, "chapter": path.row]
            NotificationCenter.default.post(name: Notification.Name(rawValue: chapterSelectedNotification), object: nil, userInfo: userInfo as [AnyHashable : Any])
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numChapters
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DateViewCell
        cell.dateLabel.text = "\(indexPath.row+1)"
        
        return cell
    }
}
