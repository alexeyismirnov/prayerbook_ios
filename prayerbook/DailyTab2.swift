//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import NAModalSheet

class DailyTab2: UIViewController, UITableViewDelegate, UITableViewDataSource, NAModalSheetDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    static let size15 = CGSize(width: 15, height: 15)
    static let icon15x15 : [FeastType: UIImage] = [
        .noSign: UIImage(named: "nosign")!.resize(size15),
        .sixVerse: UIImage(named: "sixverse")!.resize(size15),
        .doxology: UIImage(named: "doxology")!.resize(size15),
        .polyeleos: UIImage(named: "polyeleos")!.resize(size15),
        .vigil: UIImage(named: "vigil")!.resize(size15),
        .great: UIImage(named: "great")!.resize(size15)
    ]
    
    var animation = DailyAnimator()
    var animationInteractive = DailyAnimatorInteractive()
    var appeared = false
    
    var fasting: (FastingType, String) = (.vegetarian, "")
    
    var foodIcon: [FastingType: String] = [
        .noFast:        "meat",
        .vegetarian:    "vegetables",
        .fishAllowed:   "fish",
        .fastFree:      "cupcake",
        .cheesefare:    "cheese",
        .noFood:        "nothing",
        .xerophagy:     "xerography",
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
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()

    var modalSheet: NAModalSheet!
    
    static var background : UIImage?
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)

    static func date(_ date: Date) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "Daily2") as! DailyTab2
        vc.currentDate = date
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        automaticallyAdjustsScrollViewInsets = false

        configureNavbar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDate), name: NSNotification.Name(rawValue: dateChangedNotification), object: nil)

        navigationController?.delegate = self
        animationInteractive.completionSpeed = 0.999
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
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
            return (FastingLevel() == .monastic) ? Translate.s("Monastic fasting") : Translate.s("Laymen fasting")
            
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
        headerView.textLabel?.textColor = Theme.secondaryColor
    }
    
    func getCell<T: ConfigurableCell>() -> T {
        if let newCell  = tableView.dequeueReusableCell(withIdentifier: T.cellId) as? T {
            newCell.accessoryType = .none
            newCell.backgroundColor = .clear
            return newCell
            
        } else {
            return T(style: UITableViewCellStyle.default, reuseIdentifier: T.cellId)
        }
    }
    
    func getSimpleCell() -> UITableViewCell {
        let newCell  = tableView.dequeueReusableCell(withIdentifier: "cell")!
        newCell.accessoryType = .none
        return newCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell: TextDetailsCell = getCell()
                cell.title.text = formatter.string(from: currentDate).capitalizingFirstLetter()
                cell.subtitle.text = ""
                
                cell.title.textColor = Theme.textColor
                cell.subtitle.textColor = Theme.secondaryColor
                
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
                
                cell.title.textColor =  Theme.textColor
                cell.title.text = descr
                
                return cell
                
            default:
                let feast:FeastType = dayDescription[indexPath.row-2].0
                
                if feast == .none {
                    let cell: TextCell  = getCell()
                    cell.title.textColor = Theme.textColor
                    cell.title.text = dayDescription[indexPath.row-2].1
                    return cell
                    
                } else if feast == .great {
                    let cell: ImageCell = getCell()
                    
                    cell.title.textColor = UIColor.red
                    cell.title.text = dayDescription[indexPath.row-2].1
                    cell.icon.image = UIImage(named: Cal.feastIcon[feast]!)
                    return cell
                    
                } else {
                    let cell: TextCell = getCell()
                    
                    let attachment = NSTextAttachment()
                    attachment.image = DailyTab2.icon15x15[feast]
                    
                    let myString = NSMutableAttributedString(string: "")
                    myString.append(NSAttributedString(attachment: attachment))
                    
                    let dayString = dayDescription[indexPath.row-2].1
                    let day = NSMutableAttributedString(string: dayString)
                    day.addAttribute(NSForegroundColorAttributeName, value: Theme.textColor!, range: NSMakeRange(0, dayString.characters.count))
                    myString.append(day)
                    
                    cell.title.attributedText = myString
                    
                    return cell
                }
            }
            
        } else if indexPath.section == 1 {
            let cell: ImageCell  = getCell()
            cell.title.text = fasting.1
            cell.title.textColor =  Theme.textColor
            cell.icon.image = UIImage(named: "food-\(foodIcon[fasting.0]!)")
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
                let cell: TextDetailsCell = getCell()
                cell.accessoryType = .none
                
                cell.title.textColor = Theme.textColor
                cell.title.text = title
                cell.subtitle.text = subtitle
                cell.subtitle.textColor = Theme.secondaryColor
                
                return cell
                
            } else {
                let cell = getSimpleCell()
                cell.backgroundColor = UIColor.clear
                cell.textLabel?.textColor = Theme.textColor
                cell.accessoryType = .none
                cell.textLabel?.text = title
                cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                
                return cell
            }
            
            
        } else if indexPath.section == 3 {
            let cell: TextDetailsCell = getCell()
            cell.title.textColor = Theme.textColor
            cell.title.text = Translate.s("Typica")
            cell.subtitle.text = ""
            
            return cell
            
        } else if indexPath.section == 4 {
            
            if saints[indexPath.row].0 == .none {
                if appeared {
                    let cell: TextCell = getCell()
                    cell.title.textColor =  Theme.textColor
                    cell.title.text = saints[indexPath.row].1
                    return cell
                    
                } else {
                    let cell = getSimpleCell()
                    cell.backgroundColor = UIColor.clear
                    cell.textLabel?.text = saints[indexPath.row].1
                    cell.textLabel?.textColor = Theme.textColor
                    
                    return cell
                }
                
            } else {
                let attachment = NSTextAttachment()
                attachment.image = DailyTab2.icon15x15[saints[indexPath.row].0]
                let attachmentString = NSAttributedString(attachment: attachment)
                
                let myString = NSMutableAttributedString(string: "")
                myString.append(attachmentString)
                
                let saintString = saints[indexPath.row].1
                let saint = NSMutableAttributedString(string: saintString)
                saint.addAttribute(NSForegroundColorAttributeName, value: Theme.textColor!, range: NSMakeRange(0, saintString.characters.count))
                myString.append(saint)
                
                if appeared {
                    let cell: TextCell = getCell()
                    cell.title.attributedText = myString
                    return cell
                    
                } else {
                    let cell = getSimpleCell()
                    cell.backgroundColor = UIColor.clear
                    cell.textLabel?.attributedText = myString
                    return cell
                    
                }
            }
        }
        
        let cell = getSimpleCell()
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
            
        } else if FastingLevel() == .laymen && indexPath.section == 1 && indexPath.row == 0 {
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
                return 55
                
            case (1,_), (2,_):
                return 35
                
            default:
                return 27
            }
        }
    }
    
    func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size.height+1.0
    }
    
    func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            if DailyTab2.background == nil {
                DailyTab2.background = UIImage(background: "bg3.jpg", inView: view)
            }
   
            view.backgroundColor = UIColor(patternImage: DailyTab2.background!)
        }
        
        reload()
    }
    
    func reload() {
        formatter.locale = Translate.locale as Locale!
        
        dayDescription = Cal.getDayDescription(currentDate)
        fasting = Cal.getFastingDescription(currentDate, FastingLevel())
        
        saints=Db.saints(self.currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        
        tableView.reloadData()
    }
    
    func configureNavbar() {
        navigationController?.makeTransparent()
        
        let button_monthly = UIBarButtonItem(image: UIImage(named: "calendar"), style: .plain, target: self, action: #selector(showMonthlyCalendar))
        let button_widget = UIBarButtonItem(image: UIImage(named: "question"), style: .plain, target: self, action: #selector(showTutorial))
        let button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(showOptions))
        
        button_widget.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        
        navigationItem.leftBarButtonItems = [button_monthly]
        navigationItem.rightBarButtonItems = [button_options, button_widget]
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return (animation.direction != .none) ? animation : nil
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return (animation.direction != .none) ? animationInteractive : nil
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = recognizer.velocity(in: view)
            return abs(velocity.x) > abs(velocity.y)
        }
        
        return true
    }
    
    func didPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let velocity = recognizer.velocity(in: view)
            animationInteractive.velocity = velocity
            
            if velocity.x < 0 {
                animation.direction = .positive
                navigationController?.pushViewController(DailyTab2.date(currentDate + 1.days), animated: true)
                
            } else {
                animation.direction = .negative
                navigationController?.pushViewController(DailyTab2.date(currentDate - 1.days), animated: true)
            }
            
        case .changed:
            animationInteractive.handlePan(recognizer: recognizer)
            
        case .ended:
            animationInteractive.handlePan(recognizer: recognizer)
            
            if animationInteractive.cancelled {
                let vc = DailyTab2.date(currentDate)
                navigationController?.setViewControllers([vc], animated: false)
                
            } else {
                let top = navigationController?.topViewController!
                navigationController?.setViewControllers([top!], animated: false)
            }
            
        default:
            break
        }
    }
    
    func showMonthlyCalendar() {
        var width, height : CGFloat
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            width = 300
            height = 350
            
        } else {
            width = 500
            height = 530
        }
        
        let container = UIViewController.named("CalendarContainer") as! UINavigationController
        container.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        container.navigationBar.barTintColor = UIColor(hex: "#FFEBCD")
        container.navigationBar.tintColor = .blue
        container.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]

        modalSheet = NAModalSheet(viewController: container, presentationStyle: .fadeInCentered)
        
        modalSheet.disableBlurredBackground = true
        modalSheet.cornerRadiusWhenCentered = 10
        modalSheet.delegate = self
        modalSheet.adjustContentSize(CGSize(width: width, height: height), animated: false)
        
        modalSheet.present(completion: {})
    }
        
    func updateDate(_ notification: NSNotification) {
        modalSheet.dismiss(completion: {
        })
        
        if let newDate = notification.userInfo?["date"] as? Date {
            currentDate = newDate
            reload()
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    func showTutorial() {
        let vc = UIViewController.named("Tutorial") as! Tutorial
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.present(nav, animated: true, completion: {})
    }
    
    func showOptions() {
        let vc = UIViewController.named("Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true, completion: {})
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
