//
//  FastingViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/9/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import NAModalSheet

class FastingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var fastTitleLabel: UILabel!
    
    var fastTitle: String = ""
    var modalSheet: NAModalSheet!
    var type: FastingType = .vegetarian {
        didSet {
            self.foodTableView?.reloadData()
        }
    }
    
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
        view.backgroundColor =  UIColor.flatSand
        fastTitleLabel.text = fastTitle
    }
    
    fileprivate func getImageName(_ foodName: String, allowed: Bool) -> String {
        return allowed ? "food-\(foodName)" : "food-no-\(foodName)"
    }
    
    @IBAction func clicked(_ sender: AnyObject) {
        modalSheet.dismiss(completion: {})
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? Translate.s("Allowed") : Translate.s("Prohibited")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? allowedFood[type]!.count : forbiddenFood[type]!.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "FastingCell") 
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "FastingCell")
        }
        
        cell?.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        
        let foodName = ((indexPath as NSIndexPath).section == 0) ? allowedFood[type]![(indexPath as NSIndexPath).row] : forbiddenFood[type]![(indexPath as NSIndexPath).row]

        let capitalized = "\(foodName[0])".uppercased() + foodName.substring(from: foodName.characters.index(foodName.startIndex, offsetBy: 1))
        
        
        cell?.textLabel!.text = Translate.s(capitalized)
        cell?.imageView!.image =  UIImage(named: getImageName(foodName, allowed: (indexPath as NSIndexPath).section == 0))
        
        return cell!
    }
    
}
