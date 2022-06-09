//
//  LibraryTab.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

let books_en : [BookModel] =  [
    BookmarksModel.shared,
    OldTestamentModel(lang: "en"),
    NewTestamentModel(lang: "en"),
    EbookModel("vigil_en_ebook"),
    EbookModel("liturgy_en_ebook"),
    EbookModel("prayerbook_en"),
    TypikaModel.shared,
    EbookModel("sokolovski"),
]

let books_cn : [BookModel] =  [
    BookmarksModel.shared,
    OldTestamentModel(lang: "cn"),
    NewTestamentModel(lang: "cn"),
    // EbookModel("vigil_hk_ebook"),
    EbookModel("vigil_cn_ebook"),
    // EbookModel("liturgy_hk_ebook"),
    EbookModel("liturgy_cn_ebook"),
    EbookModel("prayerbook_cn"),
    TypikaModel.shared
]

class LibraryTab: UIViewController, ResizableTableViewCells  {
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    var tableView: UITableView!
    var serviceModel : ServiceModel?
    
    var books : [BookModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
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

        books = Translate.language == "en" ? books_en : books_cn
        BookmarksModel.books = books
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getTextDetailsCell(title: books[indexPath.row].title,
                                  subtitle: books[indexPath.row].author ?? "",
                                  flipped: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell, minHeight: CGFloat(40))
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if let model = books[indexPath.row] as? ServiceModel {
           serviceModel = model
           showPopup(ServiceDateSelector(serviceModel!)!)
           
        } else {
           navigationController?.pushViewController(BookTOC(books[indexPath.row])!, animated: true)
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
