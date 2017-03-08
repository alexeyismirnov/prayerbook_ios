//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal

extension UIAlertController {
    
    convenience init(title: String, message: String, view: UIViewController, handler: @escaping (UIAlertAction) -> ()) {
        self.init(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in handler(action) });
        addAction(defaultAction)
        view.present(self, animated: true, completion: {})
    }
    
}

class DailyTab: UITableViewController, NAModalSheetDelegate, UINavigationControllerDelegate {

    let animation = DailyAnimator()
    let prefs = UserDefaults(suiteName: groupId)!

    var fasting: (FastingType, String) = (.vegetarian, "")
    var fastingLevel: FastingLevel = .monastic
    
    var foodIcon: [FastingType: String] = [
        .noFast:        "meat",
        .vegetarian:    "vegetables",
        .fishAllowed:   "fish",
        .fastFree:      "cupcake",
        .cheesefare:    "cheese",
        .noFood:        "nothing",
        .xerography:    "xerography",
        .withoutOil:    "without-oil",
        .noFastMonastic:"pizza"
    ]
    
    var readings = [String]()
    var dayDescription = [(FeastType, String)]()
    var saints = [(FeastType, String)]()

    var currentDate: Date = {
        // this is done to remove time component from date
        return DateComponents(date: Date()).toDate()
    }()
    
    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "cccc d MMMM yyyy г."
        return formatter
    }()

    var formatterOldStyle: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM yyyy г. (ст. ст.)"
        return formatter
    }()

    var modalSheet: NAModalSheet!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(view.frame.size)
        UIImage(named: "bg3.jpg")?.draw(in: view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        view.backgroundColor = UIColor.clear
        tableView.backgroundView = UIImageView(image: image)
        
        addBarButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(DailyTab.reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)

        reload()
        
        navigationController?.delegate = self
        
        if prefs.object(forKey: "welcome15") == nil {
            prefs.set(true, forKey: "welcome15")
            prefs.synchronize()

            _ = UIAlertController(title: "Православный календарь",
                                  message: "В новой версии программы добавлен Синаксарь Постной Триоди (в разделе \"Чтение дня\")",
                                  view: self,
                                  handler: { _ in })

        }
    }

    func hasTypica() -> Bool {        
        if (currentDate > Cal.d(.beginningOfGreatLent) && currentDate < Cal.d(.sunday2AfterPascha) ||
            Cal.currentWeekday != .sunday) {
            return false

        } else {
            return true
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dayDescription.count+2
        case 1:
            return 1
        case 2:
            return readings.count + (Cal.synaxarion[currentDate] != nil ? 1:0)
        case 3:
            return hasTypica() ? 1 : 0
        case 4:
            return saints.count
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""

        case 1:
            return (fastingLevel == .monastic) ? Translate.s("Monastic fasting") : Translate.s("Laymen fasting")
        case 2:
            return readings.count > 0 ? Translate.s("Gospel of the day") : nil

        case 3:
            return hasTypica() ? Translate.s("Prayers") : nil

        case 4:
            return Translate.s("Memory of saints")
            
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
    }

    func getCell<T: ConfigurableCell>() -> T {
        if let newCell  = tableView.dequeueReusableCell(withIdentifier: T.cellId) as? T {
            newCell.accessoryType = .none
            return newCell
            
        } else {
            return T(style: UITableViewCellStyle.default, reuseIdentifier: T.cellId)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell: TextDetailsCell = getCell()
                cell.title.text = formatter.string(from: currentDate).capitalizingFirstLetter()
                cell.subtitle.text = formatterOldStyle.string(from: currentDate-13.days)
                return cell

            case 1:
                let cell: TextCell = getCell()
                var descr = ""
                
                if let weekDescription = Cal.getWeekDescription(currentDate) {
                    descr = weekDescription
                }
                
                if let toneDescription = Cal.getToneDescription(currentDate) {
                    if descr.characters.count > 0 {
                        descr += "; "
                    }
                    descr += toneDescription
                }

                cell.title.textColor =  UIColor.black
                cell.title.text = descr
                return cell
                
            default:
                let feast:FeastType = dayDescription[(indexPath as NSIndexPath).row-2].0

                if feast == .none {
                    let cell: TextCell = getCell()
                    cell.title.textColor =  UIColor.black
                    cell.title.text = dayDescription[(indexPath as NSIndexPath).row-2].1
                    return cell
                    
                } else if feast == .great {
                    let cell: ImageCell = getCell()
                    cell.title.textColor = UIColor.red
                    cell.title.text = dayDescription[(indexPath as NSIndexPath).row-2].1
                    cell.icon.image = UIImage(named: Cal.feastIcon[feast]!)
                    return cell
                    
                } else {
                    let cell: TextCell = getCell()
                    let image = UIImage(named: Cal.feastIcon[feast]!)!
                    
                    let attachment = NSTextAttachment()
                    attachment.image = image.resize(CGSize(width: 15, height: 15))
                    
                    let myString = NSMutableAttributedString(string: "")
                    myString.append(NSAttributedString(attachment: attachment))
                    myString.append(NSMutableAttributedString(string: dayDescription[(indexPath as NSIndexPath).row-2].1))
                    cell.title.attributedText = myString
                    
                    return cell
                }
            }
        
        } else if indexPath.section == 1 {
            let cell: ImageCell  = getCell()
            cell.title.text = fasting.1
            cell.title.textColor =  UIColor.black
            cell.icon.image = UIImage(named: "food-\(foodIcon[fasting.0]!)")
            cell.accessoryType = (fastingLevel == .monastic) ?  .none : .disclosureIndicator
            return cell

        } else if indexPath.section == 2 {
            let cell: TextDetailsCell = getCell()
            
            cell.title.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator

            if indexPath.row >= readings.count {
                guard let synaxarion = Cal.synaxarion[currentDate]  else { cell.title.text = "" ; cell.subtitle.text = ""; return cell }
                cell.title.text = synaxarion.0
                cell.subtitle.text = ""
            
            } else {
                let currentReading = readings[indexPath.row].components(separatedBy: "#")
                cell.title.text = Translate.readings(currentReading[0])
                cell.subtitle.text = (currentReading.count > 1) ? Translate.s(currentReading[1].trimmingCharacters(in: CharacterSet.whitespaces)) : ""
            }
            
            return cell
            
        } else if indexPath.section == 3 {
            let cell: TextDetailsCell = getCell()
            cell.title.textColor = UIColor.black
            cell.title.text = Translate.s("Typica")
            cell.subtitle.text = ""
            cell.accessoryType = .disclosureIndicator
            return cell

        } else if indexPath.section == 4 {
            if saints[indexPath.row].0 == .none {
                let cell: TextCell = getCell()
                cell.title.textColor =  UIColor.black
                cell.title.text = saints[indexPath.row].1
                return cell

            } else {
                let cell: TextCell = getCell()
                let image = UIImage(named: Cal.feastIcon[saints[(indexPath as NSIndexPath).row].0]!)!
                
                let attachment = NSTextAttachment()
                attachment.image = image.resize(CGSize(width: 15, height: 15))
                let attachmentString = NSAttributedString(attachment: attachment)
                
                let myString = NSMutableAttributedString(string: "")
                myString.append(attachmentString)
                myString.append(NSMutableAttributedString(string: saints[(indexPath as NSIndexPath).row].1))
                cell.title.attributedText = myString
                
                return cell
            }
        }
        
        let cell: TextCell = getCell()
        return cell

    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 {
            if indexPath.row < readings.count {
                let vc = storyboard!.instantiateViewController(withIdentifier: "Scripture") as! Scripture
                let currentReading = readings[(indexPath as NSIndexPath).row].components(separatedBy: "#")
                
                vc.code = .pericope(currentReading[0])
                navigationController?.pushViewController(vc, animated: true)
                
            } else {
                let vc = storyboard!.instantiateViewController(withIdentifier: "RTFDocument") as! RTFDocument
                let synaxarion = Cal.synaxarion[currentDate]!
                
                vc.docTitle = synaxarion.0
                vc.docFilename = synaxarion.1
                
                navigationController?.pushViewController(vc, animated: true)
                
            }

        } else if fastingLevel == .laymen && indexPath.section == 1 && indexPath.row == 0 {
            let fastingInfo = FastingViewController(nibName: "FastingViewController", bundle: nil)
            modalSheet = NAModalSheet(viewController: fastingInfo, presentationStyle: .fadeInCentered)!
            
            modalSheet.disableBlurredBackground = true
            modalSheet.cornerRadiusWhenCentered = 10
            modalSheet.delegate = self
            
            fastingInfo.modalSheet = modalSheet
            fastingInfo.type =  fasting.0
            fastingInfo.fastTitle = fasting.1
            
            modalSheet.present(completion: {})

        } else if indexPath.section == 3 {
            let prayer = storyboard!.instantiateViewController(withIdentifier: "Prayer") as! Prayer
            prayer.code = "typica"
            prayer.index = 0
            prayer.name = Translate.s("Typica")
            navigationController?.pushViewController(prayer, animated: true)
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell)
    }

    func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size.height+1.0
    }

    // MARK: private stuff
    
    func reload() {
        formatter.locale = Translate.locale as Locale!
        formatterOldStyle.locale = Translate.locale as Locale!

        dayDescription = Cal.getDayDescription(currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        fastingLevel = FastingLevel(rawValue: prefs.integer(forKey: "fastingLevel"))!
        fasting = Cal.getFastingDescription(currentDate, fastingLevel)
        saints=Db.saints(currentDate)

        tableView.reloadData()
    }

    func addBarButtons() {
        let button_calendar = UIBarButtonItem(image: UIImage(named: "calendar"), style: .plain, target: self, action: #selector(DailyTab.showCalendar))
        let button_left = UIBarButtonItem(image: UIImage(named: "arrow-left"), style: .plain, target: self, action: #selector(DailyTab.prevDay))
        let button_right = UIBarButtonItem(image: UIImage(named: "arrow-right"), style: .plain, target: self, action: #selector(DailyTab.nextDay))
        
        let button_widget = UIBarButtonItem(image: UIImage(named: "widget"), style: .plain, target: self, action: #selector(DailyTab.showTutorial))
        let button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(DailyTab.showOptions))

        button_calendar.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        button_left.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        button_widget.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        
        navigationItem.leftBarButtonItems = [button_calendar, button_left, button_right]
        navigationItem.rightBarButtonItems = [button_options, button_widget]
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if animation.direction != .none {
            return animation
            
        } else {
            return nil
        }
    }
    
    func prevDay() {
        animation.direction = .negative
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "Daily") as! DailyTab
        vc.currentDate = currentDate - 1.days
        
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    func nextDay() {
        animation.direction = .positive
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "Daily") as! DailyTab
        vc.currentDate = currentDate + 1.days
        
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    func showCalendar() {
        var width, height : CGFloat
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            width = 300
            height = 350

        } else {
            width = 500
            height = 500
        }

        let container = storyboard!.instantiateViewController(withIdentifier: "CalendarContainer") as! UINavigationController
        container.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        modalSheet = NAModalSheet(viewController: container, presentationStyle: .fadeInCentered)
        
        modalSheet.disableBlurredBackground = true
        modalSheet.cornerRadiusWhenCentered = 10
        modalSheet.delegate = self
        modalSheet.adjustContentSize(CGSize(width: width, height: height), animated: false)
        
        (container.topViewController as! CalendarContainer).delegate = self

        modalSheet.present(completion: {})
    }
    
    func updateDate(_ date: Date?) {
        if let newDate = date {
            currentDate = newDate
            reload()
        }
        
        modalSheet.dismiss(completion: {  })
    }
    
    func showTutorial() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "Tutorial") as! Tutorial
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.present(nav, animated: true, completion: {})
    }

    func showOptions() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        
        vc.delegate = self
        navigationController?.present(nav, animated: true, completion: {})
    }

    func showHistory() {
        navigationController?.dismiss(animated: false, completion: {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "RTFDocument") as! RTFDocument
            vc.docTitle = "История храма"
            vc.docFilename = "church_history"
            
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    // MARK: NAModalSheetDelegate
    
    func modalSheetTouchedOutsideContent(_ sheet: NAModalSheet!) {
        sheet.dismiss(completion: {})
    }
    
    func modalSheetShouldAutorotate(_ sheet: NAModalSheet!) -> Bool {
        return shouldAutorotate
    }
    
    func modalSheetSupportedInterfaceOrientations(_ sheet: NAModalSheet!) -> UInt {
        return supportedInterfaceOrientations.rawValue
    }

}
