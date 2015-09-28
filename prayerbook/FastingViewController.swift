//
//  FastingViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/9/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit


class FastingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var fastTitleLabel: UILabel!
    
    var fastTitle: String = ""
    var modal: NAModalSheet!
    var type: FastingType = .Vegetarian {
        didSet {
            self.foodTableView?.reloadData()
        }
    }
    
    var allowedFood: [FastingType: [String]] = [
        .NoFast:        ["meat", "fish", "milk", "egg", "cupcake"],
        .Vegetarian:    ["vegetables", "bread", "nuts"],
        .FishAllowed:   ["fish", "vegetables", "bread", "nuts"],
        .FastFree:      ["cupcake", "meat", "fish", "cheese"],
        .Cheesefare:    ["cheese", "cupcake", "milk", "egg"]
    ]
    
    var forbiddenFood: [FastingType: [String]] = [
        .NoFast:        [],
        .Vegetarian:    ["fish", "meat", "milk", "egg", "cupcake"] ,
        .FishAllowed:   ["meat", "milk", "egg",  "cupcake"],
        .FastFree:      [],
        .Cheesefare:    ["meat"]
    ]
    
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
        return (section == 0) ? Translate.s("Allowed") : Translate.s("Prohibited")
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? allowedFood[type]!.count : forbiddenFood[type]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FastingCell") 
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "FastingCell")
        }
        
        cell?.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        
        let foodName = (indexPath.section == 0) ? allowedFood[type]![indexPath.row] : forbiddenFood[type]![indexPath.row]

        let capitalized = "\(foodName[0])".uppercaseString + foodName.substringFromIndex(foodName.startIndex.advancedBy(1))
        
        cell?.textLabel!.text = Translate.s(capitalized)
        cell?.imageView!.image =  UIImage(named: getImageName(foodName, allowed: indexPath.section == 0))
        
        return cell!
    }
    
}
