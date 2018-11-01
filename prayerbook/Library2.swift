//
//  Library.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/26/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

let NewTestament: [(String, String)] = [
    ("Gospel of St Matthew", "matthew"),
    ("Gospel of St Mark", "mark"),
    ("Gospel of St Luke", "luke"),
    ("Gospel of St John", "john"),
    ("Acts of the Apostles", "acts"),
    ("Epistle of St Paul to Romans", "rom"),
    ("1st Epistle of St Paul to Corinthians", "1cor"),
    ("2nd Epistle of St Paul to Corinthians", "2cor"),
    ("Epistle of St Paul to Galatians", "gal"),
    ("Epistle of St Paul to Ephesians", "ephes"),
    ("Epistle of St Paul to Philippians", "phil"),
    ("Epistle of St Paul to Colossians", "col"),
    ("1st Epistle of St Paul Thessalonians", "1thess"),
    ("2nd Epistle of St Paul Thessalonians", "2thess"),
    ("1st Epistle of St Paul to Timothy", "1tim"),
    ("2nd Epistle of St Paul to Timothy", "2tim"),
    ("Epistle of St Paul to Titus", "tit"),
    ("Epistle of St Paul to Philemon", "philem"),
    ("Epistle of St Paul to Hebrews", "heb"),
    ("General Epistle of James", "james"),
    ("1st Epistle General of Peter", "1pet"),
    ("2nd General Epistle of Peter", "2pet"),
    ("1st Epistle General of John", "1john"),
    ("2nd Epistle General of John", "2john"),
    ("3rd Epistle General of John", "3john"),
    ("General Epistle of Jude", "jude"),
    ("Revelation of St John the Devine", "rev")
]

let OldTestament: [(String, String)] = [
    ("Genesis", "gen"),
    ("The Proverbs", "prov"),
    ("The Book of Prophet Isaiah", "isa")
]


class Library2: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var index:Int = 0
    var expanded = [Bool]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: "ChaptersCell", bundle: nil), forCellReuseIdentifier: "ChaptersCell")
        
        expanded = [Bool](repeating: false, count: NewTestament.count)
        
        automaticallyAdjustsScrollViewInsets = false
        navigationController?.makeTransparent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showChapter), name: NSNotification.Name(rawValue: chapterSelectedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)
        
        reloadTheme()
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
        
        reload()
    }
    
    @objc func reload() {
        tableView.reloadData()
        title = Translate.s("Library")
    }
    
    @objc func showChapter(_ notification: NSNotification) {
        if let book = notification.userInfo?["book"] as? Int,
           let chapter = notification.userInfo?["chapter"] as? Int {
            
            let vc = UIViewController.named("Scripture") as! Scripture
            let code = NewTestament[book].1
            
            vc.code = .chapter(code, chapter+1)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let index = indexPath.row / 2
        
        if (indexPath.row % 2 == 0) {
            expanded[index] = !expanded[index]
            
            tableView.beginUpdates()
            tableView.endUpdates()
        } 
        
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = Theme.textColor
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NewTestament.count * 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Translate.s("New Testament")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row / 2;

        if indexPath.row % 2 == 0 {
            let cellIdentifier = "TextCell"
            
            var newCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TextCell
            if newCell == nil {
                newCell = TextCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: TextCell.cellId)
            }
            
            newCell?.backgroundColor = .clear
            newCell!.title.textColor =  Theme.textColor
            newCell!.title.text = Translate.s(NewTestament[index].0)
            
            return newCell!
            
        } else {
            let cellIdentifier = "ChaptersCell"
            let code = NewTestament[index].1
            
            let newCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ChaptersCell

            newCell?.backgroundColor = .clear
            newCell?.book = index
            newCell?.numChapters = Db.numberOfChapters(code)
            newCell!.collectionView.reloadData()
            
            return newCell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row % 2 == 0) {
            let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
            return calculateHeightForCell(cell)
            
        } else if (expanded[indexPath.row/2]) {
            let cell  = self.tableView(tableView, cellForRowAt: indexPath) as? ChaptersCell

            cell!.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell!.bounds.height)
            cell!.setNeedsLayout()
            cell!.layoutIfNeeded()
            
            let layout = cell!.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            return layout.collectionViewContentSize.height
            
        } else {
            return 0.0
        }
    }
    
    func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return max(size.height+1.0, 40)
    }
    
    
}

