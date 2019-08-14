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
    let fastingTypes : [FastingModel] = (FastingModel.fastingLevel == .monastic) ? FastingModel.monasticTypes : FastingModel.laymenTypes
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let cell: ImageCell = tableView.dequeueReusableCell()
        let fasting = fastingTypes[indexPath.row]
        
        cell.title.text = fasting.descr
        cell.icon.backgroundColor = fasting.color
        cell.backgroundColor = .clear
        
        return cell
    }

}

