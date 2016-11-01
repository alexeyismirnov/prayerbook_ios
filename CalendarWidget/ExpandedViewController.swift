//
//  TodayViewController.swift
//  CalendarWidget
//
//  Created by Alexey Smirnov on 1/18/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import NotificationCenter

class ExpandedViewController: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var buttonRight: UIButton!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saintsLabel: UILabel!
    
    var currentDate: Date = {
        return DateComponents(date: Date()).toDate()
    }()
    
    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    let prefs = UserDefaults(suiteName: groupId)!
    
    var calendarDelegate: CalendarGridDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        Translate.files = ["trans_ui", "trans_cal", "trans_library"]

        let arrowLeft = UIImage(named: "fat-left")?.withRenderingMode(.alwaysTemplate)
        buttonLeft.imageView?.tintColor = UIColor.white
        buttonLeft.setImage(arrowLeft, for: UIControlState())
        
        let arrowRight = UIImage(named: "fat-right")?.withRenderingMode(.alwaysTemplate)
        buttonRight.imageView?.tintColor = UIColor.white
        buttonRight.setImage(arrowRight, for: UIControlState())

        calendarDelegate = CalendarGridDelegate()
        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.tapOnCell(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
        
        calendarDelegate.selectedDate = currentDate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let language = prefs.object(forKey: "language") as? String {
            Translate.language = language
        }
        
        calendarDelegate.generateLabels(view)

        refresh()
    }
        
    func refresh() {
        formatter.locale = Locale(identifier: "ru")

        monthLabel.text = formatter.string(from: currentDate)
        calendarDelegate.currentDate = currentDate
        collectionView.reloadData()
        
        showSaints()
    }

    @IBAction func prevMonth(_ sender: AnyObject) {
        currentDate = currentDate - 1.months
        calendarDelegate.selectedDate = Date(1, currentDate.month, currentDate.year)
        refresh()
    }
    
    @IBAction func nextMonth(_ sender: AnyObject) {
        currentDate = currentDate + 1.months
        calendarDelegate.selectedDate = Date(1, currentDate.month, currentDate.year)
        refresh()
    }
    
    func showSaints() {
        let date = calendarDelegate.selectedDate!
        let saints = Db.saints(date)
        let dayDescription = Cal.getDayDescription(date)
        let feasts = (saints+dayDescription).sorted { $0.0.rawValue > $1.0.rawValue }
        
        MainViewController.describe(saints: feasts, label: saintsLabel)
    }
    
    func tapOnCell(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: collectionView)
        var curDate: Date? = nil
        
        if let
            path = collectionView.indexPathForItem(at: loc),
            let cell = collectionView.cellForItem(at: path) as? CalendarViewTextCell,
            let dayNum = Int(cell.dateLabel.text!) {
                curDate = Date(dayNum, currentDate.month, currentDate.year)
                calendarDelegate.selectedDate = curDate
                
                showSaints()
                collectionView.reloadData()

        }
    }
    
    @IBAction func onTapLabel(_ sender: AnyObject) {
        let seconds = calendarDelegate.selectedDate!.timeIntervalSince1970
        let url = URL(string: "ponomar-ru://open?\(seconds)")!
        extensionContext!.open(url, completionHandler: nil)
    }
    
}
