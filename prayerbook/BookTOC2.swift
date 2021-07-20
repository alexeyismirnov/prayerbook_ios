//
//  Library.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/26/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import swift_toolkit

class CustomToolbar: UIToolbar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize: CGSize = super.sizeThatFits(size)
        newSize.height = 70  // there to set your toolbar height
        
        return newSize
    }
}

public class BookTOC2: UIViewController, ResizableTableViewCells {
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    let prefs = AppGroup.prefs!

    var expanded = Set<IndexPath>()
    
    var model : BookModel!
    var expandable : Bool!

    public var tableView: UITableView!
    
    public init?(_ model: BookModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        expandable = model.hasChapters
        
        createTableView(style: .grouped)
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showChapter), name: .chapterSelectedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .themeChangedNotification, object: nil)
        
        reloadTheme()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if model.code == "Bookmarks" {
            tableView.reloadData()
        }
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        tableView.reloadData()
    }
    
    func openBook(_ index: IndexPath, _ chapter: Int) {
        var vc : UIViewController!
        var pos : BookPosition!
        
        if model.code == "Bookmarks" {
            pos = (model as! BookmarksModel).resolveBookmarkAt(row: index.row)
            
        } else {
            pos = BookPosition(model: model, index: index, chapter: chapter)
        }
        
        vc = BookPageMultiple(pos)

        vc.hidesBottomBarWhenPushed = true;
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showChapter(_ notification: NSNotification) {
        if let index = notification.userInfo?["index"] as? IndexPath,
           let chapter = notification.userInfo?["chapter"] as? Int {
            openBook(index, chapter)
        }
    }
    
    // MARK: Table view data source
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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
            openBook(indexPath, -1)
        }
        
        return nil
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        let numSections = model.getSections().count
        
        if (numSections == 0) {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            messageLabel.text = Translate.s("No bookmarks")
            messageLabel.textColor =  Theme.textColor
            messageLabel.textAlignment = .center
            tableView.backgroundView = messageLabel
        }
        
        return numSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numItems = model.getItems(section).count
        return expandable ?  numItems * 2 : numItems
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.getSections()[section]
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if (expandable) {
            if indexPath.row % 2 == 0 {
                return getTextDetailsCell(title: model.getItems(section)[indexPath.row / 2], subtitle: "")
                
            } else {
                let newCell: ChapterViewCell = tableView.dequeueReusableCell()
                let newIndex = IndexPath(row: indexPath.row / 2, section: section)
                newCell.index = newIndex
                newCell.numChapters = model.getNumChapters(newIndex)
                newCell.collectionView.reloadData()
                
                return newCell
            }
            
        } else {
            return getTextDetailsCell(title: model.getItems(section)[indexPath.row], subtitle: "")
        }

    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (expandable) {
            let index = indexPath.row / 2
            
            if (indexPath.row % 2 == 0) {
                return calculateHeightForCell(self.tableView(tableView, cellForRowAt: indexPath))
                
            } else if (expanded.contains(IndexPath(row: index, section: indexPath.section))) {
                let cell = self.tableView(tableView, cellForRowAt: indexPath) as! ChapterViewCell

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
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = Theme.textColor
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return model.code == "Bookmarks"
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            var bookmarks = prefs.stringArray(forKey: "bookmarks")!
            bookmarks.remove(at: indexPath.row)
            prefs.set(bookmarks, forKey: "bookmarks")
            prefs.synchronize()
            
            tableView.reloadData()
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Translate.s("Delete")
    }
    
    public func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return max(size.height+1.0, 40)
    }
    
}


