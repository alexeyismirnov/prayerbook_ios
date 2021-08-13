//
//  ChurchInfo.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/13/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class ChurchInfo: UITableViewController {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    @IBOutlet weak var appButton: UIButton!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .themeChangedNotification, object: nil)
                
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        appButton.backgroundColor = .clear
        appButton.layer.cornerRadius = 8
        appButton.layer.borderWidth = 1
        appButton.contentEdgeInsets =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        

        reload()
    }

    @IBAction func installApp(_ sender: Any) {
        let urlStr = "https://itunes.apple.com/us/app/apple-store/id1566259967"
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            
        } else {
            UIApplication.shared.openURL(URL(string: urlStr)!)
        }
    }
    
    @objc func reload() {
        label1.textColor = Theme.textColor

        label2.textColor = Theme.textColor
        label2.text = Translate.s("church_info")
        
        label3.textColor = Theme.textColor
        label3.text = Translate.s("app_info")
        
        appButton.backgroundColor = .flatWhite()
        appButton.layer.borderColor = UIColor.gray.cgColor
        appButton.setTitleColor(.black, for: .normal)
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    
}

