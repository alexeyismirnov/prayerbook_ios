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

class TroparionView:  UIViewController, ResizableTableViewCells, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        automaticallyAdjustsScrollViewInsets = false

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "AudioPlayerCell", bundle: nil), forCellReuseIdentifier: "AudioPlayerCell")
        tableView.register(UINib(nibName: "TextCell", bundle: toolkit), forCellReuseIdentifier: "TextCell")

        fontSize = prefs.integer(forKey: "fontSize")
        reloadTheme()

        getTroparion()
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return troparion.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return troparion[section].url == nil ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextCell = getCell()
        cell.title.textColor = Theme.textColor
        
        let t = troparion[indexPath.section]
        
        if indexPath.row == 0 {
            cell.title.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
            cell.title.text = t.title

        } else if indexPath.row == 1 && t.url != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioPlayerCell") as! AudioPlayerCell
            cell.filename = "019-Tropar-Glas-4"
            return cell

        } else {
            cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            cell.title.text = t.content
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && troparion[indexPath.section].url != nil {
            return 50
            
        } else {
            let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
            return calculateHeightForCell(cell)
        }
        
    }
}
