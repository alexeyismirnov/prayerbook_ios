//
//  LibraryTab.swift
//  ponomar
//
//  Created by Alexey Smirnov on 2/22/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

// https://ms.pravoslavie.ru/289/

let books : [[BookModel]] = [[BookmarksModel.shared],
                             [OldTestamentModel(lang: "ru"),
                              NewTestamentModel(lang: "ru"),
                              OldTestamentModel(lang: "cs"),
                              NewTestamentModel(lang: "cs"),
                              EbookModel("yungerov"),
                             ],
                             [EbookModel("prayerbook"), EbookModel("canons")],
                             [EbookModel("vigil"),
                              EbookModel("liturgy"),
                              TypikaModel.shared],
                             [EbookModel("old_testament_overview"),
                              EbookModel("new_testament_overview"),
                              EbookModel("zerna"),
                              EbookModel("zvezdinsky"),
                              EbookModel("synaxarion")]]

class LibraryTab: UIViewController, ResizableTableViewCells  {
    let sections : [String] = ["", "Библия", "Молитвослов", "Богослужение", "Разное"]

    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    var tableView: UITableView!
    var serviceModel : ServiceModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        BookmarksModel.books = books.flatMap { $0 }
        
        createTableView(style: .grouped)
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)

        navigationController?.makeTransparent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .themeChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setServiceDate), name: .dateSelectedNotification, object: nil)

        reloadTheme()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }

        tableView.reloadData()
        title = Translate.s("Library")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Theme.textColor
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getTextDetailsCell(title: books[indexPath.section][indexPath.row].title,
                                  subtitle: books[indexPath.section][indexPath.row].author ?? "",
                                  lang: books[indexPath.section][indexPath.row].lang,
                                  flipped: true
        )
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell, minHeight: CGFloat(40))
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {        
        if let model = books[indexPath.section][indexPath.row] as? ServiceModel {
            serviceModel = model
            showPopup(ServiceDateSelector(serviceModel!)!)
            
        } else {
            navigationController?.pushViewController(BookTOC(books[indexPath.section][indexPath.row])!, animated: true)
        }
        
        return nil
    }
    
    @objc func setServiceDate(_ notification: NSNotification) {
        UIViewController.popup.dismiss({
            if let date = notification.userInfo?["date"] as? Date {
                self.serviceModel!.date = date
                self.navigationController?.pushViewController(BookTOC(self.serviceModel!)!, animated: true)
            }
        })
        
    }
    
}
