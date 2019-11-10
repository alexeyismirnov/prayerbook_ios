//
//  TodayViewController.swift
//  CalendarWidget
//
//  Created by Alexey Smirnov on 1/18/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class ExpandedViewController: UIViewController {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var buttonRight: UIButton!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saintsLabel: UILabel!
    
    var currentDate: Date = {
        return DateComponents(date: Date()).toDate()
    }()
    
    var selectedDate: Date!
    
    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        switch Translate.language {
        case "cn":
            formatter.dateFormat = "y年M月"
            break
        default:
            formatter.dateFormat = "LLLL yyyy"
        }
        
        formatter.locale = Translate.locale
        return formatter
    }()
    
    var dark = false

    var textColor : UIColor!
    var calendarDelegate: CalendarDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOSApplicationExtension 12.0, *) {
            dark = (traitCollection.userInterfaceStyle == .dark)
        }
        
        let arrowLeft = UIImage(named: "fat-left")?.withRenderingMode(.alwaysTemplate)
        buttonLeft.imageView?.tintColor = UIColor.white
        buttonLeft.setImage(arrowLeft, for: UIControl.State())
        
        let arrowRight = UIImage(named: "fat-right")?.withRenderingMode(.alwaysTemplate)
        buttonRight.imageView?.tintColor = UIColor.white
        buttonRight.setImage(arrowRight, for: UIControl.State())

        selectedDate = currentDate
        
        calendarDelegate = CalendarDelegate(fontSize: 16.0, textColor: dark ? .white : .black)
        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.tapOnCell(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        CalendarContainer.generateLabels(view, standalone: false, textColor: dark ? .white : .black)
        refresh()
    }
        
    func refresh() {
        monthLabel.text = formatter.string(from: currentDate).capitalizingFirstLetter()
        monthLabel.textColor = .white
        calendarDelegate.currentDate = currentDate
        calendarDelegate.selectedDate = selectedDate
        
        collectionView.reloadData()
        showSaints()
    }

    @IBAction func prevMonth(_ sender: AnyObject) {
        Animation.swipe(orientation: .horizontal,
                        direction: .negative,
                        inView: view,
                        update: {
                            self.currentDate = self.currentDate - 1.months
                            self.selectedDate = Date(1, self.currentDate.month, self.currentDate.year)
                            self.refresh()
        })
    }
    
    @IBAction func nextMonth(_ sender: AnyObject) {
        Animation.swipe(orientation: .horizontal,
                        direction: .positive,
                        inView: view,
                        update: {
                            self.currentDate = self.currentDate + 1.months
                            self.selectedDate = Date(1, self.currentDate.month, self.currentDate.year)
                            self.refresh()
        })
    }
    
    func showSaints() {
        let date = selectedDate!
        let saints = SaintModel.saints(date)
        let dayDescription = Cal.getDayDescription(date)
        let feasts = (saints+dayDescription).sorted { $0.0.rawValue > $1.0.rawValue }
        
        saintsLabel.attributedText = MainViewController.describe(saints: feasts, font: saintsLabel.font, dark: dark)
    }
    
    @objc func tapOnCell(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: collectionView)
        
        if  let path = collectionView.indexPathForItem(at: loc),
            let cell = collectionView.cellForItem(at: path) as? DayViewCell,
            let date = cell.currentDate {
                selectedDate = date
                refresh()
        }
    }
    
    @IBAction func onTapLabel(_ sender: AnyObject) {
        let seconds = selectedDate!.timeIntervalSince1970
        let scheme = Translate.language == "ru" ? "ponomar-ru" : "ponomar"
        let url = URL(string: "\(scheme)://open?\(seconds)")!
        extensionContext!.open(url, completionHandler: nil)
    }
    
}
