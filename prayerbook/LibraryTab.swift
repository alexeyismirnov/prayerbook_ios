//
//  LibraryTab.swift
//  ponomar
//
//  Created by Alexey Smirnov on 2/22/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class LibraryTab: UIViewController, UITableViewDelegate, UITableViewDataSource, ResizableTableViewCells  {

    let bookTitles = ["Old Testament", "New Testament"]
    
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "TextCell", bundle: toolkit), forCellReuseIdentifier: "TextCell")
        tableView.register(UINib(nibName: "TextDetailsCell", bundle: toolkit), forCellReuseIdentifier: "TextDetailsCell")

        automaticallyAdjustsScrollViewInsets = false
        navigationController?.makeTransparent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)

        reloadTheme()
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell: TextDetailsCell = getCell()
        
        cell.backgroundColor = .clear
        cell.title.textColor =  Theme.textColor
        cell.title.text = Translate.s(bookTitles[indexPath.row])
        cell.subtitle.text = ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let bible = UIViewController.named("Bible") as! BibleIndex
        navigationController?.pushViewController(bible, animated: true)

        return nil
    }
    
    
}
