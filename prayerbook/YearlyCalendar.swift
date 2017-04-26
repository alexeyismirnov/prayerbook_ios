//
//  YearlyCalendar.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/26/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

class YearlyCalendar: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var year = Cal.currentYear!
    let numCols:CGFloat = 3
    let insets:CGFloat = 10
    let interitemSpacing:CGFloat = 10
    let lineSpacing:CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(year)"
        navigationController?.makeTransparent()

        let backButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view))
        }
        
        collectionView.register(CalendarViewCell.self, forCellWithReuseIdentifier: CalendarViewCell.cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(insets, insets, insets, insets)
        layout.minimumInteritemSpacing = interitemSpacing
        layout.minimumLineSpacing = lineSpacing

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarViewCell.cellId, for: indexPath) as! CalendarViewCell
        cell.currentDate = Date(1, indexPath.row+1, year)
        cell.textSize = 9
        cell.textColor = Theme.textColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - insets*2.0 - (numCols-1)*interitemSpacing) / numCols
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func close() {
        dismiss(animated: true, completion: {})
    }

}
