//
//  CalendarInfo.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/21/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class CalendarInfo: UITableViewController {
    let fastingTypes : [FastingModel] = (FastingLevel() == .monastic) ? FastingModel.monasticTypes : FastingModel.laymenTypes

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        tableView.register(UINib(nibName: "ImageCell", bundle: toolkit), forCellReuseIdentifier: "ImageCell")

        view.backgroundColor = UIColor(hex: "#FFEBCD")

        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit, compatibleWith: nil)!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(close))
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func close() {
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fastingTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as! ImageCell
        let fasting = fastingTypes[indexPath.row]
        
        cell.title.text = fasting.descr
        cell.icon.backgroundColor = fasting.color
        cell.backgroundColor = .clear
        
        return cell
    }

}

