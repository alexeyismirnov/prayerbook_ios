//
//  CalendarInfo.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/21/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarInfo: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor =  UIColor.flatSand
        let backButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (FastingLevel() == .monastic) ? Cal.fastingMonastic.count : Cal.fastingLaymen.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as! ImageCell
        let info = (FastingLevel() == .monastic) ? Cal.fastingMonastic[indexPath.row] : Cal.fastingLaymen[indexPath.row]
        
        cell.title.text = Translate.s(info.1)
        cell.icon.backgroundColor = UIColor(hex: Cal.fastingColor[info.0]!)
        cell.backgroundColor = .clear
        
        return cell
    }

}

