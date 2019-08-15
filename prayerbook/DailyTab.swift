//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

class DailyTab: UIViewControllerAnimated, ResizableTableViewCells {
    var tableView: UITableView!
    
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    
    static let size15 = CGSize(width: 15, height: 15)
    static let icon15x15 : [FeastType: UIImage] = [
        .noSign: UIImage(named: "nosign")!.resize(size15),
        .sixVerse: UIImage(named: "sixverse")!.resize(size15),
        .doxology: UIImage(named: "doxology")!.resize(size15),
        .polyeleos: UIImage(named: "polyeleos")!.resize(size15),
        .vigil: UIImage(named: "vigil")!.resize(size15),
        .great: UIImage(named: "great")!.resize(size15)
    ]
    
    var appeared = false
    
    var fasting: FastingModel!
    var readings = [String]()
    
    var dayDescription = [(FeastType, String)]()
    var saints = [(FeastType, String)]()
    
    var currentDate: Date = {
        // this is done to remove time component from date
        return DateComponents(date: Date()).toDate()
    }()
    
    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    static var background : UIImage?
    
    static func date(_ date: Date) -> UIViewController {
        let vc = UIViewController.named("Daily") as! DailyTab
        vc.currentDate = date
        return vc
    }
    
    override func viewControllerCurrent() -> UIViewController {
        return DailyTab.date(currentDate)
    }
    
    override func viewControllerForward() -> UIViewController {
        return DailyTab.date(currentDate + 1.days)
    }
    
    override func viewControllerBackward() -> UIViewController {
        return DailyTab.date(currentDate - 1.days)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView(style: .plain)
        configureNavbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .optionsSavedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .themeChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDate), name: .dateChangedNotification, object: nil)
        
        reloadTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appeared = true
        tableView.reloadData()
    }
    
    func hasTypica() -> Bool {
        if Translate.language != "cn" {
            return false
        }
        if (currentDate > Cal.d(.beginningOfGreatLent) && currentDate < Cal.d(.sunday2AfterPascha) || Cal.currentWeekday != .sunday) {
            return false
         
        } else {
            return true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dayDescription.count+2
            
        case 1:
            return 1
            
        case 2:
            return readings.count
            
        case 3:
            return hasTypica() ? 1 : 0
            
        case 4:
            return saints.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
            
        case 1:
            return (FastingModel.fastingLevel == .monastic) ? Translate.s("Monastic fasting") : Translate.s("Laymen fasting")
            
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return getTextDetailsCell(title: formatter.string(from: currentDate).capitalizingFirstLetter(),
                                          subtitle: "")
                
            case 1:
                var descr = ""
                
                if let weekDescription = Cal.getWeekDescription(currentDate) {
                    descr = weekDescription
                }
                
                if let toneDescription = Cal.getToneDescription(currentDate) {
                    if descr.count > 0 {
                        descr += "; "
                    }
                    descr += toneDescription
                }
                
                return getTextCell(descr)
                
            default:
                let feast:FeastType = dayDescription[indexPath.row-2].0
                
                if feast == .none {
                    return getTextCell(dayDescription[indexPath.row-2].1)
                    
                } else if feast == .great {
                    let cell: ImageCell = getCell()
                    
                    cell.title.textColor = UIColor.red
                    cell.title.text = dayDescription[indexPath.row-2].1
                    cell.icon.image = UIImage(named: Cal.feastIcon[feast]!)
                    return cell
                    
                } else {
                    let cell: TextCell = getCell()
                    
                    let attachment = NSTextAttachment()
                    attachment.image = DailyTab.icon15x15[feast]
                    
                    let myString = NSMutableAttributedString(string: "")
                    myString.append(NSAttributedString(attachment: attachment))
                    
                    let dayString = dayDescription[indexPath.row-2].1
                    let day = dayString.colored(with: Theme.textColor)
                    myString.append(day)
                    
                    cell.title.attributedText = myString
                    
                    return cell
                }
            }
            
        } else if indexPath.section == 1 {
            let cell: ImageCell  = getCell()

            cell.title.attributedText = NSAttributedString(string: fasting.descr)
            cell.title.textColor =  Theme.textColor
            cell.icon.image = UIImage(named: "food-\(fasting.icon)", in: toolkit, compatibleWith: nil)
            cell.accessoryType =  .none
            
            return cell
            
        } else if indexPath.section == 2 {
            var title : String!
            var subtitle : String!
            
            switch indexPath.row {
            case 0 ..< readings.count:
                let currentReading = readings[indexPath.row].components(separatedBy: "#")
                
                title = Translate.readings(currentReading[0])
                if Translate.language == "cn" {
                    subtitle = ""
                } else {
                    subtitle = (currentReading.count > 1) ? Translate.s(currentReading[1].trimmingCharacters(in: CharacterSet.whitespaces)) : ""
                }
                
            default:
                title = ""
                subtitle=""
            }
            
            if appeared {
                return getTextDetailsCell(title: title, subtitle: subtitle)
                
            } else {
                let cell = getSimpleCell(title)
                cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                
                return cell
            }
            
            
        } else if indexPath.section == 3 {
            return getTextDetailsCell(title: Translate.s("Typica"), subtitle: "")

        } else if indexPath.section == 4 {
            
            if saints[indexPath.row].0 == .none {
                if appeared {
                    return getTextCell(saints[indexPath.row].1)
                    
                } else {
                    return getSimpleCell(saints[indexPath.row].1)
                }
                
            } else {
                let attachment = NSTextAttachment()
                attachment.image = DailyTab.icon15x15[saints[indexPath.row].0]
                let attachmentString = NSAttributedString(attachment: attachment)
                
                let myString = NSMutableAttributedString(string: "")
                myString.append(attachmentString)
                
                let saintString = saints[indexPath.row].1
                let saint = saintString.colored(with: Theme.textColor)
               
                myString.append(saint)
                
                if appeared {
                    let cell: TextCell = getCell()
                    cell.title.attributedText = myString
                    return cell
                    
                } else {
                    let cell = getSimpleCell("")
                    cell.backgroundColor = UIColor.clear
                    cell.textLabel?.attributedText = myString
                    return cell
                    
                }
            }
        }
        
        let cell = getSimpleCell("")
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 {
            var vc : UIViewController!
            
            switch indexPath.row {
            case 0 ..< readings.count:
                let currentReading = readings[indexPath.row].components(separatedBy: "#")
                vc = UIViewController.named("Scripture")
                (vc as! Scripture).code = .pericope(currentReading[0])
                
            default:
                break
                
            }
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 3 {
            let prayer = UIViewController.named("Prayer") as! Prayer
            prayer.code = "typica"
            prayer.index = 0
            prayer.name = Translate.s("Typica")
            navigationController?.pushViewController(prayer, animated: true)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (appeared) {
            let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
            return calculateHeightForCell(cell)
            
        } else {
            switch (indexPath.section, indexPath.row) {
            case (0,0):
                return 35
                
            case (1,_), (2,_):
                return 35
                
            default:
                return 27
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
        headerView.textLabel?.textColor = Theme.secondaryColor
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            if DailyTab.background == nil {
                DailyTab.background = UIImage(background: "bg3.jpg", inView: view, bundle: toolkit)
            }
   
            view.backgroundColor = UIColor(patternImage: DailyTab.background!)
        }
        
        reload()
    }
    
    @objc func reload() {
        formatter.locale = Translate.locale
        
        dayDescription = Cal.getDayDescription(currentDate)
        fasting = FastingModel.fasting(forDate: currentDate)
        
        saints = SaintModel.saints(currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        
        tableView.reloadData()
    }
    
    func configureNavbar() {
        navigationController?.makeTransparent()
        
        let button_monthly = CustomBarButton(image: UIImage(named: "calendar"), style: .plain, target: self, action: #selector(showMonthlyCalendar))
       
        let button_options = CustomBarButton(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(showOptions))
        
        navigationItem.leftBarButtonItems = [button_monthly]
        navigationItem.rightBarButtonItems = [button_options]
    }
    
    @objc func showMonthlyCalendar() {
        let container = UIViewController.named("CalendarContainer", bundle: toolkit) as! CalendarNavigation
        container.initialDate = currentDate
        showPopup(container)
    }
        
    @objc func updateDate(_ notification: NSNotification) {
        UIViewController.popup.dismiss()
        
        if let newDate = notification.userInfo?["date"] as? Date {
            currentDate = newDate
            reload()
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    @objc func showOptions() {
        let vc = UIViewController.named("Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true, completion: {})
    }
    
}
