//
//  LibraryTab.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

let books_en : [[BookModel]] = [[BookmarksModel.shared],
    [OldTestamentModel(lang: "en"),
     NewTestamentModel(lang: "en")],
    [EbookModel("vigil_en_ebook"),
     EbookModel("liturgy_en_ebook"),
     TypikaModel("en")],
    [EbookModel("prayerbook_en"),
     EbookModel("synaxarion_en")
]]

let books_cn : [[BookModel]] =  [[BookmarksModel.shared],
    [OldTestamentModel(lang: "cn"),
    NewTestamentModel(lang: "cn")],
    [EbookModel("vigil_cn_ebook"),
    EbookModel("liturgy_cn_ebook"),
    TypikaModel("cn")],
    [EbookModel("prayerbook_cn"),
    EbookModel("synaxarion_cn")
]]

let books_hk : [[BookModel]] = [[BookmarksModel.shared],
    [OldTestamentModel(lang: "hk"),
    NewTestamentModel(lang: "hk")],
    [EbookModel("vigil_hk_ebook"),
    EbookModel("liturgy_hk_ebook"),
    TypikaModel("hk")],
    [EbookModel("prayerbook_hk"),
    EbookModel("synaxarion_hk")
]]

class LibraryTab: UIViewController, ResizableTableViewCells  {
    var toolkit : Bundle!
    var tableView: UITableView!
    var serviceModel : ServiceModel?
    
    let sections : [String] = ["", "bible", "liturgical_books", "other"]
    var books : [[BookModel]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolkit = Bundle(identifier: "swift-toolkit-swift-toolkit-resources")!
                
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
        title = Translate.s("Library")

        switch (Translate.language) {
        case "en":
            books = books_en
            break
        case "cn":
            books = books_cn
            break
        case "hk":
            books = books_hk
            break
        default:
            break
        }

        BookmarksModel.books = books.flatMap { $0 }
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Translate.s(sections[section])
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
                                  flipped: true)
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
