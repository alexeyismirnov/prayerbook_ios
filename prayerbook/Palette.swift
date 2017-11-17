//
//  Palette.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/19/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

class Palette: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let colors : [UIColor] = [.flatRed, .flatOrange, .flatYellow, .flatSand, .flatNavyBlue, .flatBlack,
                              .flatMagenta, .flatTeal, .flatSkyBlue, .flatGreen, .flatMint, .flatWhite,
                              .flatGray, .flatForestGreen, .flatPurple, .flatBrown, .flatPlum, .flatWatermelon,
                              .flatLime, .flatPink, .flatMaroon, .flatCoffee, .flatPowderBlue, .flatBlue, .flatSandDark]
    
    var edgeInsets: CGFloat!
    var interitemSpacing: CGFloat!
    var delegate: Options!
    let numberOfItemsPerRow = 5
    let cellId = "DateViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            edgeInsets = 10
            interitemSpacing = 5
            
        } else {
            edgeInsets = 20
            interitemSpacing = 10
        }

        collectionView.backgroundColor = .lightGray
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(edgeInsets, edgeInsets, edgeInsets, edgeInsets)
        layout.minimumInteritemSpacing = interitemSpacing
        layout.minimumLineSpacing = interitemSpacing

        let recognizer = UITapGestureRecognizer(target: self, action:#selector(chooseColor(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DateViewCell
        cell.backgroundColor = colors[indexPath.row]
        cell.dateLabel.text = ""
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
    
    func chooseColor(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: collectionView)
        
        if let path = collectionView.indexPathForItem(at: loc),
           let cell = collectionView.cellForItem(at: path) as? DateViewCell,
           let color = cell.backgroundColor {
                delegate.doneWithColor(color)            
        }
    }
}

