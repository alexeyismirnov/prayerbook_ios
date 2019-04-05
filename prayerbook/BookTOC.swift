//
//  Library.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/26/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

protocol BookModel {
    func getTitle() -> String
    func getSections() -> [String]
    func getItems(_ section : Int) -> [String]
    
    func isExpandable() -> Bool
    func getNumChapters(_ index : IndexPath) -> Int
    
    func getVC(index : IndexPath, chapter : Int) -> UIViewController
}

class BookTOC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    var expanded = Set<IndexPath>()
    var model : BookModel!
    var expandable : Bool!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expandable = model.isExpandable()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "ChaptersCell", bundle: nil), forCellReuseIdentifier: "ChaptersCell")
        tableView.register(UINib(nibName: "TextCell", bundle: toolkit), forCellReuseIdentifier: TextCell.cellId)
        
        automaticallyAdjustsScrollViewInsets = false
        navigationController?.makeTransparent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showChapter), name: NSNotification.Name(rawValue: chapterSelectedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .optionsSavedNotification, object: nil)
        
        reloadTheme()
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        reload()
    }
    
    @objc func reload() {
        tableView.reloadData()
        title = model.getTitle()
    }
    
    @objc func showChapter(_ notification: NSNotification) {
        if let index = notification.userInfo?["index"] as? IndexPath,
           let chapter = notification.userInfo?["chapter"] as? Int {
            let vc = model.getVC(index: index, chapter: chapter)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (expandable) {
            if (indexPath.row % 2 == 0) {
                let expandedRow = IndexPath(row: indexPath.row/2, section: indexPath.section)
                if expanded.contains(expandedRow)  {
                    expanded.remove(expandedRow)
                } else {
                    expanded.insert(expandedRow)
                }
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
        } else {
            let vc = model.getVC(index: indexPath, chapter: -1)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.getSections().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numItems = model.getItems(section).count
        return expandable ?  numItems * 2 : numItems
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.getSections()[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if (expandable) {
            let index = indexPath.row / 2
            
            if indexPath.row % 2 == 0 {
                let newCell = tableView.dequeueReusableCell(withIdentifier: TextCell.cellId) as! TextCell
               
                newCell.backgroundColor = .clear
                newCell.title.textColor =  Theme.textColor
                newCell.title.text = Translate.s(model.getItems(section)[index])
                
                return newCell
                
            } else {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "ChaptersCell") as! ChaptersCell
                let newIndex = IndexPath(row: index, section: section)
                
                newCell.backgroundColor = .clear
                newCell.index = newIndex
                newCell.numChapters = model.getNumChapters(newIndex)
                newCell.collectionView.reloadData()
                
                return newCell
            }
            
        } else {
            let newCell = tableView.dequeueReusableCell(withIdentifier: TextCell.cellId) as! TextCell
            newCell.backgroundColor = .clear
            newCell.title.textColor =  Theme.textColor
            newCell.title.text = Translate.s(model.getItems(section)[indexPath.row])
            
            return newCell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (expandable) {
            let index = indexPath.row / 2
            
            if (indexPath.row % 2 == 0) {
                return calculateHeightForCell(self.tableView(tableView, cellForRowAt: indexPath))
                
            } else if (expanded.contains(IndexPath(row: index, section: indexPath.section))) {
                let cell = self.tableView(tableView, cellForRowAt: indexPath) as! ChaptersCell
                
                cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                
                let layout = cell.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
                return layout.collectionViewContentSize.height
                
            } else {
                return 0.0
            }
            
        } else {
            return calculateHeightForCell(self.tableView(tableView, cellForRowAt: indexPath))
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = Theme.textColor
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return max(size.height+1.0, 40)
    }
    
}

