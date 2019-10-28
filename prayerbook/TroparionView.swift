//
//  TroparionView.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/1/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

extension Notification.Name {
    public static let stopPlaybackNotification = Notification.Name("STOP_PLAYBACK")
}

class TroparionView:  UIViewController, ResizableTableViewCells, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    
    var fontSize = AppGroup.prefs.integer(forKey: "fontSize")
    
    var troparion : [Troparion]
    var players : [AudioPlayerCell?]
    
    public init?(_ troparion: [Troparion]) {
        self.troparion = troparion
        players = [AudioPlayerCell?]()
        
        for t in troparion {
            if let url = t.url {
                let cell:AudioPlayerCell = .fromNib()
                cell.filename = url
                players.append(cell)

            } else {
                players.append(nil)
            }
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView(style: .plain)
        tableView.register(UINib(nibName: "AudioPlayerCell", bundle: nil), forCellReuseIdentifier: "AudioPlayerCell")

        reloadTheme()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .stopPlaybackNotification, object: nil)
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
        let t = troparion[indexPath.section]
        
        if indexPath.row == 0 {
            let cell = getTextCell(t.title)
            cell.title.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
            return cell

        } else if indexPath.row == 1 && t.url != nil {
            return players[indexPath.section]!
            
        } else {
            let cell = getTextCell(t.content)
            cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            return cell
        }
        
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
