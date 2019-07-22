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

    enum AnimationDirection: Int {
        case positive = 1
        case negative = -1
    }

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
    
    var calendarDelegate: CalendarDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        Translate.files = ["trans_ui", "trans_cal", "trans_library"]

        let arrowLeft = UIImage(named: "fat-left")?.withRenderingMode(.alwaysTemplate)
        buttonLeft.imageView?.tintColor = UIColor.white
        buttonLeft.setImage(arrowLeft, for: UIControl.State())
        
        let arrowRight = UIImage(named: "fat-right")?.withRenderingMode(.alwaysTemplate)
        buttonRight.imageView?.tintColor = UIColor.white
        buttonRight.setImage(arrowRight, for: UIControl.State())

        calendarDelegate = CalendarDelegate()
        calendarDelegate.containerType = .todayExtension
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
        
        CalendarDelegate.generateLabels(view, container: .todayExtension)
        
        refresh()
    }
        
    func refresh() {
        formatter.locale = Translate.locale as Locale!

        monthLabel.text = formatter.string(from: currentDate).capitalizingFirstLetter()
        calendarDelegate.currentDate = currentDate
        collectionView.reloadData()
        
        showSaints()
    }

    @IBAction func prevMonth(_ sender: AnyObject) {
        Animation.swipe(orientation: .horizontal,
                        direction: .negative,
                        inView: view,
                        update: {
                            self.currentDate = self.currentDate - 1.months
                            self.calendarDelegate.selectedDate = Date(1, self.currentDate.month, self.currentDate.year)
                            self.refresh()
        })
    }
    
    @IBAction func nextMonth(_ sender: AnyObject) {
        Animation.swipe(orientation: .horizontal,
                        direction: .positive,
                        inView: view,
                        update: {
                            self.currentDate = self.currentDate + 1.months
                            self.calendarDelegate.selectedDate = Date(1, self.currentDate.month, self.currentDate.year)
                            self.refresh()
        })
    }
    
    func showSaints() {
        let date = calendarDelegate.selectedDate!
        let saints = Db.saints(date)
        let dayDescription = Cal.getDayDescription(date)
        let feasts = (saints+dayDescription).sorted { $0.0.rawValue > $1.0.rawValue }
        
        saintsLabel.attributedText = MainViewController.describe(saints: feasts, font: saintsLabel.font)
    }
    
    @objc func tapOnCell(_ recognizer: UITapGestureRecognizer) {
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
        let url = URL(string: "ponomar://open?\(seconds)")!
        extensionContext!.open(url, completionHandler: nil)
    }
    
}
