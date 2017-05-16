//
//  CalendarContainer.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/20/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import ChameleonFramework

let showYearlyNotification = "SHOW_YEARLY"

class CalendarContainer: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dates = [Date]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button_widget = UIBarButtonItem(image: UIImage(named: "question"), style: .plain, target: self, action: #selector(showInfo))
        navigationItem.rightBarButtonItem = button_widget
        
        let button_year = UIBarButtonItem(title: "Год", style: .plain, target: self, action: #selector(showYear))
        navigationItem.leftBarButtonItem = button_year

        view.backgroundColor = UIColor(hex: "#FFEBCD")
        collectionView.backgroundColor = UIColor.clear
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            resizeCalendar(300, 300)
            
        } else {
            collectionView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
            resizeCalendar(500, 500)
        }
        
        view.setNeedsLayout()
        
        let currentDate: Date = ChurchCalendar.currentDate
        setTitle(fromDate: currentDate)
        dates = [currentDate-1.months, currentDate, currentDate+1.months]
        
        collectionView.register(CalendarViewCell.self, forCellWithReuseIdentifier: CalendarViewCell.cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            layout.itemSize = CGSize(width: 300, height: 300)
        } else {
            layout.itemSize = CGSize(width: 500, height: 500)
        }
        
        CalendarDelegate.generateLabels(view, container: .mainApp)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)

    }
    
    func showInfo() {
        let vc = UIViewController.named("calendar_info")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showYear() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: showYearlyNotification), object: nil, userInfo: nil)
    }
    
    func setTitle(fromDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "ru")

        title = formatter.string(from: date).capitalizingFirstLetter()
    }
    
    func resizeCalendar(_ width: Int, _ height: Int) {
        collectionView.constraints.forEach { con in
            if con.identifier == "calendar-width" {
                con.constant = CGFloat(width)
                
            } else if con.identifier == "calendar-height" {
                con.constant = CGFloat(height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarViewCell.cellId, for: indexPath) as! CalendarViewCell
        cell.currentDate = dates[indexPath.row]
        
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetWhenFullyScrolledRight = collectionView.frame.size.width * CGFloat(dates.count - 1)
        var current = dates[1]

        if scrollView.contentOffset.x == 0 {
            current = dates[0]
        } else if scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight {
            current = dates[2]
        }
        
        setTitle(fromDate: current)

        collectionView.performBatchUpdates({
            self.dates[0] = current-1.months
            self.dates[1] = current
            self.dates[2] = current+1.months
            
        }, completion: { _ in
            UIView.setAnimationsEnabled(false)
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
            UIView.setAnimationsEnabled(true)
        })
        
    }
    
}
