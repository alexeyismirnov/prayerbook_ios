//
//  FastingViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/9/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

extension String {
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
}

class FastingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var fastTitleLabel: UILabel!
    
    enum FastingType {
        case NoFast, Vegetarian, FishAllowed, FastFree, Cheesefare
        
        func getAllowedFood() -> [String] {
            switch self {
            case .NoFast: return ["meat", "fish", "milk", "egg", "cupcake"]
            case .Vegetarian: return ["vegetables", "bread", "nuts"]
            case .FishAllowed: return ["fish", "vegetables", "bread", "nuts"]
            case .FastFree: return ["cake", "cheese", "meat", "fish"]
            case .Cheesefare: return ["cheese", "cupcake", "milk", "egg"]
            }
        }

        func getForbiddenFood() -> [String] {
            switch self {
            case .NoFast: return []
            case .Vegetarian: return ["fish", "meat", "milk", "egg", "cupcake"]
            case .FishAllowed: return ["meat", "milk", "egg",  "cupcake"]
            case .FastFree: return []
            case .Cheesefare: return ["meat"]
            }
        }
    }
    
    var fastTitle: String = ""
    var modal: NAModalSheet!
    var type: FastingType = .Vegetarian {
        didSet {
            self.foodTableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        fastTitleLabel.text = fastTitle
    }
    
    private func getImageName(foodName: String, allowed: Bool) -> String {
        return allowed ? "food-\(foodName)" : "food-no-\(foodName)"
    }
    
    @IBAction func clicked(sender: AnyObject) {
        modal.dismissWithCompletion({})
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "Allowed" : "Prohibited"
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? type.getAllowedFood().count : type.getForbiddenFood().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FastingCell") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "FastingCell")
        }
        
        cell?.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        
        var foodName = (indexPath.section == 0) ? type.getAllowedFood()[indexPath.row] :
            type.getForbiddenFood()[indexPath.row]

        var capitalized = "\(foodName[0])".uppercaseString + foodName.substringFromIndex(advance(foodName.startIndex, 1))
        
        cell?.textLabel?.text = capitalized
        cell?.imageView?.image =  UIImage(named: getImageName(foodName, allowed: indexPath.section == 0))
        
        return cell!
    }
    
}
