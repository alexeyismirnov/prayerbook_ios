//
//  WeekCalendar.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/6/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class WeekCalendar: UIViewControllerAnimated, ResizableTableViewCells {
    var tableView: UITableView!
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    
    var currentDate: Date = {
        // this is done to remove time component from date
        return DateComponents(date: Date()).toDate()
    }()
    
    override func viewControllerCurrent() -> UIViewController {
        return WeekCalendar(currentDate)
    }
    
    override func viewControllerForward() -> UIViewController {
        return WeekCalendar(currentDate + 7.days)
    }
    
    override func viewControllerBackward() -> UIViewController {
        return WeekCalendar(currentDate - 7.days)
    }
    
    public init(_ date: Date) {
        self.currentDate = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
        createTableView(style: .grouped)
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
    }
    
    func setupNavbar() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        
        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        navigationController?.makeTransparent()
        automaticallyAdjustsScrollViewInsets = false
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view,  bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: { })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let title = Cal.getWeekDescription(currentDate)
            let subtitle = Cal.getToneDescription(currentDate)
            
            return getTextDetailsCell(title: title ?? "", subtitle: subtitle ?? "")
            
        } else {
            let date = currentDate + (indexPath.row).days
            let cell: WeekCalendarCell = tableView.dequeueReusableCell()
            
            var content = [(FeastType, String)]()
            
            content.append(contentsOf:
                Cal.getDayDescription(date).filter({ !$0.1.contains("Предпразднство") && !$0.1.contains("Попразднство") }))
            
            content.append(contentsOf: SaintModel.saints(date))
            
            cell.configureCell(date: date, content: content, cellWidth: tableView.frame.width)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell)
    }
}

