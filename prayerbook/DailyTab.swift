//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal

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
        return NSDateComponents(date: NSDate()).toDate()
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
    
    func hasTypica() -> Bool {
        if Translate.language != "cn" {
            return false
        }
        
        if (currentDate > Cal.d(.BeginningOfGreatLent) && currentDate < Cal.d(.Sunday2AfterPascha) ||
            Cal.currentWeekday != .Sunday) {
            return false

        } else {
            return true
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dayDescription.count+2
        case 1:
            return readings.count
        case 2:
            return hasTypica() ? 1 : 0
        case 3:
            return saints.count
            
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""

        case 1:
            return readings.count > 0 ? Translate.s("Gospel of the day") : nil

        case 2:
            return hasTypica() ? Translate.s("Prayers") : nil

        case 3:
            return Translate.s("Memory of saints")
            
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
                let cell: TextDetailsCell = getCell()
                cell.title.text = formatter.stringFromDate(currentDate)

                var subtitle:String = ""
                
                if let weekDescription = Cal.getWeekDescription(currentDate) {
                    subtitle = weekDescription
                }
                
                if let toneDescription = Cal.getToneDescription(currentDate) {
                    if subtitle.characters.count > 0 {
                        subtitle += "; "
                    }
                    subtitle += toneDescription
                }
                
                cell.subtitle.text = subtitle
                return cell

            case 1:
                let cell: ImageCell  = getCell()
                cell.title.text = fasting.1
                cell.title.textColor =  UIColor.blackColor()
                cell.icon.image = UIImage(named: "food-\(foodIcon[fasting.0]!)")
                cell.accessoryType = .DisclosureIndicator
                return cell
                
            default:
                let feast:FeastType = dayDescription[indexPath.row-2].0

                if feast == .None {
                    let cell: TextCell = getCell()
                    cell.title.textColor =  UIColor.blackColor()
                    cell.title.text = dayDescription[indexPath.row-2].1
                    return cell
                    
                } else if feast == .Great {
                    let cell: ImageCell = getCell()
                    cell.title.textColor = UIColor.redColor()
                    cell.title.text = dayDescription[indexPath.row-2].1
                    cell.icon.image = UIImage(named: Cal.feastIcon[feast]!)
                    return cell
                    
                } else {
                    let cell: TextCell = getCell()
                    let attachment = NSTextAttachment()
                    let image = UIImage(named: Cal.feastIcon[feast]!)
                    attachment.image = imageResize(image!, sizeChange: CGSizeMake(15, 15))
                    let attachmentString = NSAttributedString(attachment: attachment)
                    
                    let myString = NSMutableAttributedString(string: "")
                    myString.appendAttributedString(attachmentString)
                    myString.appendAttributedString(NSMutableAttributedString(string: dayDescription[indexPath.row-2].1))
                    cell.title.attributedText = myString
                    
                    return cell
                }
            }
        
        } else if indexPath.section == 1 {
            let cell: TextDetailsCell = getCell()
            cell.title.textColor = UIColor.blackColor()
            cell.title.text = Translate.readings(readings[indexPath.row])
            cell.subtitle.text = ""
            cell.accessoryType = .DisclosureIndicator
            return cell
            
        } else if indexPath.section == 2 {
            let cell: TextDetailsCell = getCell()
            cell.title.textColor = UIColor.blackColor()
            cell.title.text = Translate.s("Typica")
            cell.subtitle.text = ""
            cell.accessoryType = .DisclosureIndicator
            return cell

        } else if indexPath.section == 3 {
            if saints[indexPath.row].0 == .None {
                let cell: TextCell = getCell()
                cell.title.textColor =  UIColor.blackColor()
                cell.title.text = saints[indexPath.row].1
                return cell

            } else {
                let cell: TextCell = getCell()
                let attachment = NSTextAttachment()
                let image = UIImage(named: Cal.feastIcon[saints[indexPath.row].0]!)
                attachment.image = imageResize(image!, sizeChange: CGSizeMake(15, 15))
                let attachmentString = NSAttributedString(attachment: attachment)
                
                let myString = NSMutableAttributedString(string: "")
                myString.appendAttributedString(attachmentString)
                myString.appendAttributedString(NSMutableAttributedString(string: saints[indexPath.row].1))
                cell.title.attributedText = myString
                
                return cell

            }
        }
        
        let cell: TextCell = getCell()
        return cell

    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && readings.count > 0 {
            let vc = storyboard!.instantiateViewControllerWithIdentifier("Scripture") as! Scripture
            vc.code = .Pericope(readings[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)

        } else if indexPath.section == 0 && indexPath.row == 1 {
            let fastingInfo = FastingViewController(nibName: "FastingViewController", bundle: nil)
            let modal = NAModalSheet(viewController: fastingInfo, presentationStyle: .FadeInCentered)
            
            modal.disableBlurredBackground = true
            modal.cornerRadiusWhenCentered = 10
            modal.delegate = self
            
            fastingInfo.modal = modal
            fastingInfo.type =  fasting.0
            fastingInfo.fastTitle = fasting.1
            
            modal.presentWithCompletion({})

        } else if indexPath.section == 2 {
            let prayer = storyboard!.instantiateViewControllerWithIdentifier("Prayer") as! Prayer
            prayer.code = "typica"
            prayer.index = 0
            prayer.name = Translate.s("Typica")
            navigationController?.pushViewController(prayer, animated: true)

        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        return calculateHeightForCell(cell)
    }

    func calculateHeightForCell(cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(cell.bounds))
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height+1.0
    }

    // MARK: private stuff
    
    func reload() {
        formatter.locale = Translate.locale
        
        dayDescription = Cal.getDayDescription(currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        fasting = Cal.getFastingDescription(currentDate)

        saints=[]
        
        var saintsDB = [[String:Bindable?]]()
        let isLeapYear = (Cal.currentYear % 400) == 0 || ((Cal.currentYear%4 == 0) && (Cal.currentYear%100 != 0))

        if (isLeapYear) {
            let leapStart = NSDate(29, 2, Cal.currentYear)
            let leapEnd = NSDate(13, 3, Cal.currentYear)
            
            switch currentDate {
            case leapStart ..< leapEnd:
                saintsDB = Db.saints(currentDate+1.days)
                break
                
            case leapEnd:
                saintsDB = Db.saints(NSDate(29, 2, Cal.currentYear))
                break
                
            default:
                saintsDB = Db.saints(currentDate)
            }

        } else {
            saintsDB = Db.saints(currentDate)
            if (currentDate == NSDate(13, 3, Cal.currentYear)) {
                saintsDB += Db.saints(NSDate(29, 2, 2000))
            }
        }
        
        for line in saintsDB {
            let name = line["name"] as! String
            let typikon = FeastType(rawValue: Int(line["typikon"] as! Int64))
            saints.append((typikon!, name))
        }

        tableView.reloadData()
    }

    func addBarButtons() {
        let button_calendar = UIBarButtonItem(image: UIImage(named: "calendar"), style: .Plain, target: self, action: "showCalendar")
        let button_left = UIBarButtonItem(image: UIImage(named: "arrow-left"), style: .Plain, target: self, action: "prevDay")
        let button_right = UIBarButtonItem(image: UIImage(named: "arrow-right"), style: .Plain, target: self, action: "nextDay")
        let button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .Plain, target: self, action: "showOptions")

        button_calendar.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        button_left.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        
        navigationItem.leftBarButtonItems = [button_calendar, button_left, button_right]
        navigationItem.rightBarButtonItems = [button_options]
    }

    func prevDay() {
        currentDate = currentDate - 1.days;
        reload()
    }
    
    func nextDay() {
        currentDate = currentDate + 1.days;
        reload()
    }
    
    func showCalendar() {
        var width, height : CGFloat
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            width = 300
            height = 350

        } else {
            width = 500
            height = 500
        }

        let container = storyboard!.instantiateViewControllerWithIdentifier("CalendarContainer") as! UINavigationController
        
        container.view.frame = CGRectMake(0, 0, width, height)
        
        let modal = NAModalSheet(viewController: container, presentationStyle: .FadeInCentered)
        
        modal.disableBlurredBackground = true
        modal.cornerRadiusWhenCentered = 10
        modal.delegate = self
        modal.adjustContentSize(CGSizeMake(width, height), animated: false)

        modal.presentWithCompletion({})
    }
    
    /*
    func showCalendar() {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("Calendar") as! CalendarViewController
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self

        navigationController?.presentViewController(nav, animated: true, completion: {})
    }
*/
    
    func showOptions() {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.presentViewController(nav, animated: true, completion: {})
    }    
    
    // MARK: NAModalSheetDelegate
    
    func modalSheetTouchedOutsideContent(sheet: NAModalSheet!) {
        sheet.dismissWithCompletion({})
    }
    
    func modalSheetShouldAutorotate(sheet: NAModalSheet!) -> Bool {
        return shouldAutorotate()
    }
    
    func modalSheetSupportedInterfaceOrientations(sheet: NAModalSheet!) -> UInt {
        return supportedInterfaceOrientations().rawValue
    }

}