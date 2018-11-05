//
//  TroparionView.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/1/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal

import swift_toolkit

struct Troparion {
    var title : String
    var content : String
    var url : String?
    
    init(title : String, content : String, url : String? = nil) {
        self.title = title
        self.content = content
        self.url = url
    }
}

class TroparionView:  UITableViewController, ResizableTableViewCells {
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    let prefs = UserDefaults(suiteName: groupId)!

    var greatFeast : NameOfDay!
    var troparion = [Troparion]()
    var fontSize  = 0
    
    func getTroparion()  {
        let path = Bundle.main.path(forResource: "tropari", ofType: "sqlite")!
        let db = try! Database(path:path)
        
        let results = try! db.selectFrom("tropari", whereExpr:"code=\(greatFeast.rawValue)", orderBy: "id") { ["title": $0["title"], "content": $0["content"], "url": $0["url"]]}
        
        for line in results {
            let title = line["title"] as! String
            let content =  line["content"] as! String
            let url = line["url"] as? String
            
            troparion.append(Troparion(title: title, content: content, url: url))
        }
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "TextCell", bundle: toolkit), forCellReuseIdentifier: "TextCell")

        fontSize = prefs.integer(forKey: "fontSize")

        getTroparion()
        reloadTheme()
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor.clear
            tableView.backgroundView  = UIImageView(image: UIImage(background: "bg3.jpg", inView: view, bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return troparion.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextCell = getCell()
        let t = troparion[indexPath.section]
        
        if indexPath.row == 0 {
            cell.title.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
            cell.title.text = t.title

        } else {
            cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            cell.title.text = t.content

        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell)
    }
}

/*
 
 view.addSubview(textView)
 textView.translatesAutoresizingMaskIntoConstraints = false
 
 NSLayoutConstraint.activate([
 textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
 textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10),
 textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
 textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
 ])
 
 */
