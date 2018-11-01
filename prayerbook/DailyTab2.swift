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
import swift_toolkit
import AVKit

class DailyTab2: UIViewControllerAnimated, ResizableTableViewCells, UITableViewDelegate, UITableViewDataSource, NAModalSheetDelegate {
    
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
    var synaxarion : (String,String)?
    
    var feofan = [(String,String)]()
    var dayDescription = [(FeastType, String)]()
    var saints = [(FeastType, String)]()
    var saintIcons = [Saint]()
    var greatFeast : NameOfDay?

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
    var popup : PopupController!
    
    static var background : UIImage?

    static func date(_ date: Date) -> UIViewController {
        let vc = UIViewController.named("Daily2") as! DailyTab2
        vc.currentDate = date
        return vc
    }
    
    override func viewControllerCurrent() -> UIViewController {
        return DailyTab2.date(currentDate)
    }
    
    override func viewControllerForward() -> UIViewController {
        return DailyTab2.date(currentDate + 1.days)
    }
    
    override func viewControllerBackward() -> UIViewController {
        return DailyTab2.date(currentDate - 1.days)
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

        let prefs = UserDefaults(suiteName: groupId)!

        if prefs.object(forKey: "welcome30") == nil {
            prefs.set(true, forKey: "welcome30")
            prefs.synchronize()
            
            let url = URL(string: "saints-ru://open?12345")!
            
            if !UIApplication.shared.canOpenURL(url) {
                let alert = UIAlertController(title: "Православный календарь", message: "Предлагаем установить новое приложение - \"Жития святых на каждый день\". " +
                    "Приложение открывается при нажатии кнопки в панели навигации (сверху). Установить?"
                    , preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Да", style: .default, handler: { _ in self.showSaints()} );
                let noAction = UIAlertAction(title: "Нет", style: .default, handler: { _ in  });
                
                alert.addAction(yesAction)
                alert.addAction(noAction)
                
                present(alert, animated: true, completion: {})
            }
            
        }
        
        reloadTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appeared = true
        reloadAfterAppeared()

        tableView.reloadData()
    }
    
    func hasTypica() -> Bool {
        return false
        /*
         if (currentDate > Cal.d(.beginningOfGreatLent) && currentDate < Cal.d(.sunday2AfterPascha) ||
         Cal.currentWeekday != .sunday) {
         return false
         
         } else {
         return true
         }
         */
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dayDescription.count+2
            
        case 1:
            return 1
            
        case 2:
            return 1
            
        case 3:
            return readings.count + feofan.count + (synaxarion != nil ? 1:0) + (greatFeast != nil ? 1:0)
            
        case 4:
            return hasTypica() ? 1 : 0
            
        case 5:
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
            return ""
            
        case 2:
            return (FastingLevel() == .monastic) ? Translate.s("Monastic fasting") : Translate.s("Laymen fasting")
            
        case 3:
            return readings.count > 0 ? Translate.s("Gospel of the day") : nil
            
        case 4:
            return hasTypica() ? Translate.s("Prayers") : nil
            
        case 5:
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell: TextDetailsCell = getCell()
                cell.title.text = formatter.string(from: currentDate).capitalizingFirstLetter()
                cell.subtitle.text = formatterOldStyle.string(from: currentDate-13.days)
                
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
                    if descr.count > 0 {
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
                    day.addAttribute(NSAttributedString.Key.foregroundColor, value: Theme.textColor!, range: NSMakeRange(0, dayString.count))
                    myString.append(day)
                    
                    cell.title.attributedText = myString
                    
                    return cell
                }
            }
            
        } else if indexPath.section == 1 {
            if appeared {
                let cell: SaintIconCell  = getCell()
                cell.saints = saintIcons
                return cell

            } else {
                return getSimpleCell()
                
            }
           
        } else if indexPath.section == 2 {
            let cell: ImageCell  = getCell()
            cell.title.text = fasting.1
            cell.title.textColor =  Theme.textColor
            cell.icon.image = UIImage(named: "food-\(foodIcon[fasting.0]!)")
            cell.accessoryType =  .none
            
            return cell
            
        } else if indexPath.section == 3 {
            
            var title : String!
            var subtitle : String!
            
            switch indexPath.row {
            case 0 ..< readings.count:
                let currentReading = readings[indexPath.row].components(separatedBy: "#")
                
                title = Translate.readings(currentReading[0])
                subtitle = (currentReading.count > 1) ? Translate.s(currentReading[1].trimmingCharacters(in: CharacterSet.whitespaces)) : ""
                
            case readings.count ..< readings.count + feofan.count:
                let ind = indexPath.row - readings.count
                title = "Мысли на каждый день"
                subtitle =  feofan.count == 1 ? "" : feofan[ind].0
                
            default:
                if synaxarion != nil && indexPath.row == readings.count + feofan.count {
                    title = synaxarion!.0
                    subtitle = ""
                    
                } else if greatFeast != nil {
                    title = "Тропарь и кондак праздника"
                    subtitle = ""
                    
                } else {
                    title = ""
                    subtitle=""
                }
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
            
            
        } else if indexPath.section == 4 {
            let cell = getSimpleCell()
            
            /*
             let cell: TextDetailsCell = getCell()
             cell.title.textColor = Theme.textColor
             cell.title.text = Translate.s("Typica")
             cell.subtitle.text = ""
             cell.accessoryType = .disclosureIndicator
             */
            return cell
            
        } else if indexPath.section == 5 {
            
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
                saint.addAttribute(NSAttributedString.Key.foregroundColor, value: Theme.textColor!, range: NSMakeRange(0, saintString.count))
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
        if indexPath.section == 3 {
            var vc : UIViewController!
            
            switch indexPath.row {
            case 0 ..< readings.count:
                let currentReading = readings[indexPath.row].components(separatedBy: "#")
                vc = UIViewController.named("Scripture")
                (vc as! Scripture).code = .pericope(currentReading[0])
                
            case readings.count ..< readings.count + feofan.count:
                let ind = indexPath.row - readings.count
                
                vc = UIViewController.named("RTFDocument")
                (vc as! RTFDocument).content = NSMutableAttributedString(string: feofan[ind].1)
                
            default:
                let synaxarion = Cal.synaxarion[currentDate]!
                
                vc = UIViewController.named("RTFDocument")
                (vc as! RTFDocument).docTitle = synaxarion.0
                (vc as! RTFDocument).docFilename = synaxarion.1
                
            }
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if FastingLevel() == .laymen && indexPath.section == 2 && indexPath.row == 0 {
            let fastingInfo = FastingViewController(nibName: "FastingViewController", bundle: nil)
            modalSheet = NAModalSheet(viewController: fastingInfo, presentationStyle: .fadeInCentered)!
            
            modalSheet.disableBlurredBackground = true
            modalSheet.cornerRadiusWhenCentered = 10
            modalSheet.delegate = self
            
            fastingInfo.modalSheet = modalSheet
            fastingInfo.type =  fasting.0
            fastingInfo.fastTitle = fasting.1
            
            modalSheet.present(completion: {})
            
        } else if indexPath.section == 4 {
            let prayer = UIViewController.named("Prayer") as! Prayer
            prayer.code = "typica"
            prayer.index = 0
            prayer.name = Translate.s("Typica")
            navigationController?.pushViewController(prayer, animated: true)
            
        } else if indexPath.section == 5 {
            showSaints()
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (appeared) {
            if indexPath.section == 1 {
                return SaintIconCell.itemSize().height + 40 // some margin
                
            } else {
                let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
                return calculateHeightForCell(cell)
            }
            
        } else {
            switch (indexPath.section, indexPath.row) {
            case (0,0):
                return 55
                
            case (1,_):
                return 0
                
            case (2,_), (3,_):
                return 35
                
            default:
                return 27
            }
        }
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            if DailyTab2.background == nil {
                DailyTab2.background = UIImage(background: "bg3.jpg", inView: view, bundle: Bundle(identifier: "com.rlc.swift-toolkit"))
            }
   
            view.backgroundColor = UIColor(patternImage: DailyTab2.background!)
        }
        
        reload()
    }
    
    @objc func reload() {
        formatter.locale = Translate.locale as Locale
        formatterOldStyle.locale = Translate.locale as Locale
        
        dayDescription = Cal.getDayDescription(currentDate)
        fasting = Cal.getFastingDescription(currentDate, FastingLevel())
        
        saints=Db.saints(self.currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        synaxarion = Cal.synaxarion[currentDate]
        greatFeast = Cal.getGreatFeast(currentDate)
        
        /*
        if let _ = greatFeast {
            print(Db.troparionExists(greatFeast!))
        }
        */
        
        if (appeared) {
            reloadAfterAppeared()
        
        } else {
            feofan = [("Мысли на каждый день", "")]
        }
        
        tableView.reloadData()
    }
    
    func reloadAfterAppeared() {
        feofan = DailyReading.getFeofan(currentDate)
        
        if feofan.count == 0 {
            feofan = DailyReading.getFeofan(currentDate, fuzzy: true)
        }
        
        saintIcons = SaintIcons.get(currentDate)
    }
    
    func configureNavbar() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")

        navigationController?.makeTransparent()
        
        let button_monthly = UIBarButtonItem(image: UIImage(named: "calendar", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(calendarSelector))
        
        let button_saint = UIBarButtonItem(image: UIImage(named: "saint"), style: .plain, target: self, action: #selector(showSaints))
        
        let button_widget = UIBarButtonItem(image: UIImage(named: "question", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(showTutorial))
        let button_options = UIBarButtonItem(image: UIImage(named: "options", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(showOptions))
        
        button_saint.imageInsets = UIEdgeInsets.init(top: 0,left: 0,bottom: 0,right: -20)
        button_widget.imageInsets = UIEdgeInsets.init(top: 0,left: -20,bottom: 0,right: 0)
        
        navigationItem.leftBarButtonItems = [button_monthly, button_saint]
        navigationItem.rightBarButtonItems = [button_options, button_widget]
    }
    
    @objc func showSaints() {
        let seconds = currentDate.timeIntervalSince1970
        let url = URL(string: "saints-ru://open?\(seconds)")!
        
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)

            } else {
                UIApplication.shared.openURL(url)
            }

        } else {
            let urlStr = "https://itunes.apple.com/us/app/apple-store/id1343569925?mt=8"
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: urlStr)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(URL(string: urlStr)!)
            }
        }
       
    }
    
    @objc func calendarSelector() {
        let container = UIViewController.named("CalendarSelector", bundle: nil) as! CalendarSelector
        container.delegate = self

        popup = PopupController
            .create(self.navigationController!)
            .customize(
                [
                    .animation(.fadeIn),
                    .layout(.center),
                    .backgroundStyle(.blackFilter(alpha: 0.7))
                ]
        )
        
        popup.show(container)
    }
    
    func showMonthlyCalendar() {
        popup.dismiss({
            let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
            
            DateViewCell.textColor = nil
            DateViewCell.textSize = nil
            
            let image = UIImage(named: "question", in: toolkit, compatibleWith: nil)!.withRenderingMode(.alwaysOriginal)
            let button_info = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.showInfo))
            
            self.popup =  CalendarContainer.show(inVC: self.navigationController!,
                                                 cellReuseIdentifier: "DateViewCell",
                                                 cellNibName: "DateViewCell",
                                                 leftButton: nil,
                                                 rightButton: button_info)
        })
    }
    
    func showYearlyCalendar() {
        popup.dismiss({
            let vc = UIViewController.named("yearly") as! YearlyCalendar
            let nav = UINavigationController(rootViewController: vc)
            
            self.navigationController?.present(nav, animated: true, completion: {})
        })
        
    }
    
    @objc func showInfo() {
        let responder: UIResponder? = popup.popupView?.next
        if let container = responder as? UINavigationController {
            let calendar_info = UIViewController.named("calendar_info")
            container.pushViewController(calendar_info, animated: true)
        }
    }
    
    @objc func updateDate(_ notification: NSNotification) {
        popup.dismiss()
        
        if let newDate = notification.userInfo?["date"] as? Date {
            currentDate = newDate
            reload()
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    @objc func showTutorial() {
        let videoURL = Bundle.main.url(forResource: "demo", withExtension: "mp4")
        
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @objc func showOptions() {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
