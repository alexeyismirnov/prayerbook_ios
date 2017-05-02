//
//  CalendarInfo.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/21/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarInfo: UITableViewController {
    
    var infoMonastic : [(FastingType, String)] = [(.xerophagy, "Xerophagy"),
                                             (.withoutOil, "Without oil"),
                                             (.vegetarian, "With oil"),
                                             (.fishAllowed, "Fish allowed"),
                                             (.noFood, "No food"),
                                             (.fastFree, "Fast-free week")]

    var infoLaymen : [(FastingType, String)] = [
                                                  (.vegetarian, "Vegetarian"),
                                                  (.fishAllowed, "Fish allowed"),
                                                  (.fastFree, "Fast-free week")]

    let prefs = UserDefaults(suiteName: groupId)!
    var fastingLevel : FastingLevel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fastingLevel = FastingLevel(rawValue: prefs.integer(forKey: "fastingLevel"))!
        
        view.backgroundColor =  UIColor.flatSand
        let backButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fastingLevel == .monastic) ? infoMonastic.count : infoLaymen.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as! ImageCell
        let info : (FastingType, String) = (fastingLevel == .monastic) ? infoMonastic[indexPath.row] : infoLaymen[indexPath.row]
        
        cell.title.text = Translate.s(info.1)
        cell.icon.backgroundColor = UIColor(hex: Cal.fastingColor[info.0]!)
        cell.backgroundColor = .clear
        
        return cell
    }

}

