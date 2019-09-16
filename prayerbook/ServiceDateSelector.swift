//
//  ServiceDateSelector.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/16/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class ServiceDateSelector: UIViewController, ResizableTableViewCells, PopupContentViewController {
    var tableView: UITableView!
    var model : BookModel
    var iterator: AnyIterator<Date>
    
    var dates = [Date]()
    var formatter = DateFormatter()
    
    init?(_ model: BookModel) {
        self.model = model
        self.iterator = model.dateIterator(startDate: Date())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        formatter.locale = Translate.locale
        
        createTableView(style: .grouped, isPopup: true)
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        
        dates.append(contentsOf: iterator.prefix(5))

    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Translate.s("Service date")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let descr = formatter.string(from: dates[indexPath.row]).capitalizingFirstLetter()
        let cell = getTextDetailsCell(title: descr, subtitle: "")
        cell.title.textAlignment = .center
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightForCell(self.tableView(tableView, cellForRowAt: indexPath), minHeight: CGFloat(40))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dates.count-1 {
            dates.append(contentsOf: iterator.prefix(5))
            tableView.reloadData()
        }
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 250, height: 200)
    }
}

