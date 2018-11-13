//
//  FastingViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/9/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class FastingViewController: UITableViewController, PopupContentViewController, ResizableTableViewCells {
    var type: FastingType = .vegetarian {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var delegate: DailyTab2!

    var allowedFood: [FastingType: [String]] = [
        .noFast:        ["meat", "fish", "milk", "egg", "cupcake"],
        .vegetarian:    ["vegetables", "bread", "nuts"],
        .fishAllowed:   ["fish", "vegetables", "bread", "nuts"],
        .fastFree:      ["cupcake", "meat", "fish", "cheese"],
        .cheesefare:    ["cheese", "cupcake", "milk", "egg"]
    ]
    
    var forbiddenFood: [FastingType: [String]] = [
        .noFast:        [],
        .vegetarian:    ["fish", "meat", "milk", "egg", "cupcake"] ,
        .fishAllowed:   ["meat", "milk", "egg",  "cupcake"],
        .fastFree:      [],
        .cheesefare:    ["meat"]
    ]
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        tableView.register(UINib(nibName: "ImageCell", bundle: toolkit), forCellReuseIdentifier: "ImageCell")
    }
    
    fileprivate func getImageName(_ foodName: String, allowed: Bool) -> String {
        return allowed ? "food-\(foodName)" : "food-no-\(foodName)"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? Translate.s("Allowed") : Translate.s("Prohibited")
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? allowedFood[type]!.count : forbiddenFood[type]!.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCell = getCell()
        
        let foodName = (indexPath.section == 0) ? allowedFood[type]![indexPath.row] : forbiddenFood[type]![indexPath.row]
        let capitalized = foodName.capitalizingFirstLetter()
        
        cell.title.text = Translate.s(capitalized)
        cell.icon.image =  UIImage(named: getImageName(foodName, allowed: indexPath.section == 0))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        delegate.popup.dismiss()
        return nil
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 250, height: 300)
    }
    
}
