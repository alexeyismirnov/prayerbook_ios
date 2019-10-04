//
//  CalendarSelector2.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/4/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

public extension Notification.Name {
    static let monthlyCalendarNotification = Notification.Name("SHOW_MONTHLY")
}

public extension Notification.Name {
    static let yearlyCalendarNotification = Notification.Name("SHOW_YEARLY")
}

class CalendarSelector2: UIViewController, ResizableTableViewCells, PopupContentViewController {
    var tableView: UITableView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        createTableView(style: .grouped, isPopup: true)
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        NotificationCenter.default.post(name:  indexPath.row == 0 ? .monthlyCalendarNotification : .yearlyCalendarNotification,
                                        object: nil,
                                        userInfo: nil)

        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Translate.s("Calendar")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getTextDetailsCell(title: Translate.s(indexPath.row == 0 ? "Monthly" : "Yearly"), subtitle: "")
        cell.title.textAlignment = .center
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightForCell(self.tableView(tableView, cellForRowAt: indexPath), minHeight: CGFloat(50))
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 200, height: 170)
    }
    
}
