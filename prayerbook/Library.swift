//
//  Library.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/26/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

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


class Library: UITableViewController {
    var code:String = "Library"
    var index:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(Library.reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)

        let button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(Library.showOptions))
        navigationItem.rightBarButtonItems = [button_options]
        
        reload()
    }
    
    func reload() {
        tableView.reloadData()

        if (code == "Library") {
            title = Translate.s("Library")
            
        } else {
            title = Translate.s(NewTestament[index].0)
        }
    }
    
    func showOptions() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "Options") as! Options
        let nav = UINavigationController(rootViewController: vc)        
        navigationController?.present(nav, animated: true, completion: {})
    }

    // MARK: Table view data source

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (code == "Library") {
            let vc = storyboard.instantiateViewController(withIdentifier: "Library") as! Library
            vc.index = (indexPath as NSIndexPath).row
            vc.code = NewTestament[(indexPath as NSIndexPath).row].1
            navigationController?.pushViewController(vc, animated: true)

        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "Scripture") as! Scripture
            vc.code = .chapter(code, (indexPath as NSIndexPath).row+1)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (code == "Library") ? NewTestament.count : Db.numberOfChapters(code)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (code == "Library") ? Translate.s("New Testament") : nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TextCell"
        
        var newCell  = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TextCell
        if newCell == nil {
            newCell = TextCell(style: UITableViewCellStyle.default, reuseIdentifier: TextCell.cellId)
        }
        
        newCell!.title.textColor =  UIColor.black
        newCell!.title.text = (code == "Library") ?
            Translate.s(NewTestament[(indexPath as NSIndexPath).row].0) :
            String(format: Translate.s("Chapter %@"), Translate.stringFromNumber((indexPath as NSIndexPath).row+1))

        return newCell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell)
    }
    
    func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return max(size.height+1.0, 40)
    }


}

