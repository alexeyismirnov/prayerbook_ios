//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class DailyTab: UITableViewController, NAModalSheetDelegate {
    
    var fasting: (FastingType, String) = (.Vegetarian, "")
    var foodIcon: [FastingType: String] = [
        .NoFast:        "meat",
        .Vegetarian:    "vegetables",
        .FishAllowed:   "fish",
        .FastFree:      "cupcake",
        .Cheesefare:    "cheese",
    ]
    
    var readings = [String]()
    var dayDescription = [(FeastType, String)]()
    var saints = [(FeastType, String)]()

    var currentDate: NSDate = {
        // this is done to remove time component from date
        let dateComponents = NSDateComponents(date: NSDate())
        return dateComponents.toDate()
    }()
    
    var formatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBarButtons()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)

        reload()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return count(dayDescription)+2
        case 1:
            return count(readings)
        case 2:
            return count(saints)
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return count(readings) > 0 ? "Daily Reading" : nil
        case 2:
            return "Daily Saints"
        default:
            return ""
        }
    }

    func getCell<T: ConfigurableCell>() -> T {
        if let newCell  = tableView.dequeueReusableCellWithIdentifier(T.cellId) as? T {
            newCell.accessoryType = .None
            return newCell
            
        } else {
            return T(style: UITableViewCellStyle.Default, reuseIdentifier: T.cellId)
        }
    }

    func imageResize(image:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                var cell: TextDetailsCell = getCell()
                cell.title.text = formatter.stringFromDate(currentDate)

                var subtitle:String = ""
                
                if let weekDescription = Cal.getWeekDescription(currentDate) {
                    subtitle = weekDescription
                }
                
                if let toneDescription = Cal.getToneDescription(currentDate) {
                    if count(subtitle) > 0 {
                        subtitle += ". "
                    }
                    subtitle += toneDescription
                }
                
                cell.subtitle.text = subtitle
                return cell

            case 1:
                var cell: ImageCell  = getCell()
                cell.title.text = fasting.1
                cell.title.textColor =  UIColor.blackColor()
                cell.icon.image = UIImage(named: "food-\(foodIcon[fasting.0]!)")
                cell.accessoryType = .DisclosureIndicator
                return cell
                
            default:
                let feast:FeastType = dayDescription[indexPath.row-2].0

                if feast == .None {
                    var cell: TextCell = getCell()
                    cell.title.textColor =  UIColor.blackColor()
                    cell.title.text = dayDescription[indexPath.row-2].1
                    return cell
                    
                } else if feast == .Great {
                    var cell: ImageCell = getCell()
                    cell.title.textColor = (feast == .Great) ? UIColor.redColor() : UIColor.blackColor()
                    cell.title.text = dayDescription[indexPath.row-2].1
                    cell.icon.image = UIImage(named: Cal.feastIcon[feast]!)
                    return cell
                    
                } else {
                    var cell: TextCell = getCell()
                    var attachment = NSTextAttachment()
                    var image = UIImage(named: Cal.feastIcon[feast]!)
                    attachment.image = imageResize(image!, sizeChange: CGSizeMake(15, 15))
                    var attachmentString = NSAttributedString(attachment: attachment)
                    
                    var myString = NSMutableAttributedString(string: "")
                    myString.appendAttributedString(attachmentString)
                    myString.appendAttributedString(NSMutableAttributedString(string: dayDescription[indexPath.row-2].1))
                    cell.title.attributedText = myString
                    
                    return cell
                }
            }
        
        } else if indexPath.section == 1 {
            var cell: TextDetailsCell = getCell()
            cell.title.textColor = UIColor.blackColor()
            cell.title.text = readings[indexPath.row]
            cell.subtitle.text = ""
            cell.accessoryType = .DisclosureIndicator

            return cell
            
        } else if indexPath.section == 2 {
            if saints[indexPath.row].0 == .None {
                var cell: TextCell = getCell()
                cell.title.textColor =  UIColor.blackColor()
                cell.title.text = saints[indexPath.row].1
                return cell

            } else {
                var cell: TextCell = getCell()
                var attachment = NSTextAttachment()
                var image = UIImage(named: Cal.feastIcon[saints[indexPath.row].0]!)
                attachment.image = imageResize(image!, sizeChange: CGSizeMake(15, 15))
                var attachmentString = NSAttributedString(attachment: attachment)
                
                var myString = NSMutableAttributedString(string: "")
                myString.appendAttributedString(attachmentString)
                myString.appendAttributedString(NSMutableAttributedString(string: saints[indexPath.row].1))
                cell.title.attributedText = myString
                
                return cell

            }
        }
        
        var cell: TextCell = getCell()
        return cell

    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if indexPath.section == 1 && readings.count > 0 {
            var vc = storyboard.instantiateViewControllerWithIdentifier("Scripture") as! Scripture
            vc.code = .Pericope(readings[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)

        } else if indexPath.section == 0 && indexPath.row == 1 {
            var fastingInfo = FastingViewController(nibName: "FastingViewController", bundle: nil)
            var modal = NAModalSheet(viewController: fastingInfo, presentationStyle: .FadeInCentered)
            
            modal.disableBlurredBackground = true
            modal.cornerRadiusWhenCentered = 10
            modal.delegate = self
            
            fastingInfo.modal = modal
            fastingInfo.type =  fasting.0
            fastingInfo.fastTitle = fasting.1
            
            modal.presentWithCompletion({})
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell : UITableViewCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        return calculateHeightForCell(cell)
    }

    func calculateHeightForCell(cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(cell.bounds))
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height+1.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Calendar" {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.viewControllers[0] as! CalendarViewController
            dest.delegate = self
        }
    }

    // MARK: private stuff
    
    func reload() {
        formatter.locale = Translate.locale
        
        dayDescription = Cal.getDayDescription(currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        fasting = Cal.getFastingDescription(currentDate)

        saints=[]
        for line in Db.saints(currentDate) {
            let name = line!["name"] as! String
            let typikon = FeastType(rawValue: Int(line!["typikon"] as! Int64))
            saints.append((typikon!, name))
        }

        tableView.reloadData()
    }

    func addBarButtons() {
        var button_left = UIBarButtonItem(image: UIImage(named: "arrow-left"), style: .Plain, target: self, action: "prev_day")
        var button_right = UIBarButtonItem(image: UIImage(named: "arrow-right"), style: .Plain, target: self, action: "next_day")
        
        button_left.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        navigationItem.rightBarButtonItems = [button_right, button_left]
    }

    func prev_day() {
        currentDate = currentDate - 1.days;
        reload()
    }
    
    func next_day() {
        currentDate = currentDate + 1.days;
        reload()
    }
    
    // MARK: NAModalSheetDelegate
    
    func modalSheetTouchedOutsideContent(sheet: NAModalSheet!) {
        sheet.dismissWithCompletion({})
    }
    
    func modalSheetShouldAutorotate(sheet: NAModalSheet!) -> Bool {
        return shouldAutorotate()
    }
    
    func modalSheetSupportedInterfaceOrientations(sheet: NAModalSheet!) -> UInt {
        return UInt(supportedInterfaceOrientations())
    }

}