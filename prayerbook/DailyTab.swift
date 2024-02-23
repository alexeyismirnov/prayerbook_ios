//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import FolioReaderKit
import swift_toolkit

class DailyTab: UIViewControllerAnimated, ResizableTableViewCells {
    static let bookIcon = UIImage(named: "book")!.maskWithColor(.red).resize(CGSize(width: 20, height: 20))
    var toolkit: Bundle!
    
    var tableView: UITableView!
    var appeared = false
    
    var fasting: FastingModel!
    
    var readings = [String]()
    var extraReadings = [Preachment]()

    static var pericope: PericopeModel = PericopeModel(lang: Translate.language)
    static var synaxarion: SynaxarionModel = SynaxarionModel(lang: Translate.language)
    static var livesOfSaints: LivesOfSaintsModel = LivesOfSaintsModel()
    
    var dayDescription = [ChurchDay]()
    var saints = [Saint]()
    var saintIcons = [SaintIcon]()

    var currentDate: Date? {
        didSet {
           if let date = currentDate {
               cal = Cal.fromDate(date)
           }
        }
    }
    
    var cal: Cal!
    
    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
        
    static func date(_ date: Date) -> UIViewController {
        let vc = UIViewController.named("Daily") as! DailyTab
        vc.currentDate = date
        return vc
    }
    
    override func viewControllerCurrent() -> UIViewController {
        return DailyTab.date(currentDate!)
    }
    
    override func viewControllerForward() -> UIViewController {
        return DailyTab.date(currentDate! + 1.days)
    }
    
    override func viewControllerBackward() -> UIViewController {
        return DailyTab.date(currentDate! - 1.days)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolkit = Bundle(identifier: "swift-toolkit-swift-toolkit-resources")!
        
        if currentDate == nil {
            currentDate = DateComponents(date: Date()).toDate()
        }
              
        createTableView(style: .grouped)
        configureNavbar()
        
        if #available(iOS 11.0, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .themeChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDate), name: .dateChangedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showToday), name: .todayCalendarNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showWeeklyCalendar), name: .weeklyCalendarNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMonthlyCalendar), name: .monthlyCalendarNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showYearlyCalendar), name: .yearlyCalendarNotification, object: nil)
        
        reloadTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appeared = true
        reloadAfterAppeared()

        tableView.reloadData()
        
        if AppGroup.prefs.object(forKey: "welcome51") == nil {
            AppGroup.prefs.set(true, forKey: "welcome51")
            AppGroup.prefs.synchronize()
            showPopup(LanguageSelector(), dismissWhenTaps: false)
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
            return 1
            
        case 3:
            return readings.count + extraReadings.count
            
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
              return ""
            
        case 2:
            return (FastingModel.fastingLevel == .monastic) ? Translate.s("Monastic fasting") : Translate.s("Laymen fasting")
            
        case 3:
            return readings.count > 0 ? Translate.s("Reading of the day") : nil
            
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
                return getTextDetailsCell(title: formatter.string(from: currentDate!).capitalizingFirstLetter(),
                                          subtitle: "", isBold: true)
                
            case 1:
                var descr = ""
                
                if let weekDescription = cal.getWeekDescription(currentDate!) {
                  descr = weekDescription
                }
                              
                if let toneDescription = cal.getToneDescription(currentDate!) {
                  if descr.count > 0 {
                      descr += "; "
                  }
                  descr += toneDescription
                }

                
                return getTextCell(descr)
                
            default:
                let feast:FeastType = dayDescription[indexPath.row-2].type

                if feast == .none {
                    return getTextCell(dayDescription[indexPath.row-2].name)
                    
                } else if feast == .great {
                    let cell: ImageCell = getCell()
                    
                    cell.title.textColor = UIColor.red
                    cell.title.text = dayDescription[indexPath.row-2].name
                    cell.icon.image = feast.icon
                    return cell
                    
                } else {
                    let cell: TextCell = getCell()
                    
                    let attachment = NSTextAttachment()
                    attachment.image = feast.icon15x15
                    
                    let myString = NSMutableAttributedString(string: "")
                    myString.append(NSAttributedString(attachment: attachment))
                    
                    let dayString = dayDescription[indexPath.row-2].name
                    let day = dayString.colored(with: Theme.textColor)

                    myString.append(day)
                    
                    cell.title.attributedText = myString
                    
                    return cell
                }
                
            }
        } else if indexPath.section == 1 {
            if appeared {
                let cell: SaintIconCell = tableView.dequeueReusableCell(for: indexPath)
                cell.saints = saintIcons
                cell.selectable = false
                return cell
                
            } else {
                return getSimpleCell("")
                
            }
        } else if indexPath.section == 2 {
            let cell: ImageCell  = getCell()

            cell.title.attributedText = NSAttributedString(string: fasting.descr)
            cell.title.textColor =  Theme.textColor
            cell.icon.image = UIImage(named: "food-\(fasting.icon)", in: toolkit)
            cell.accessoryType =  .none
            
            return cell
            
        } else if indexPath.section == 3 {
            var title : String!
            var subtitle : String!
            
            switch indexPath.row {
            case 0 ..< readings.count:
                let currentReading = readings[indexPath.row].components(separatedBy: "#")
                
                title = Translate.readings(currentReading[0])
                if Translate.language == "cn" {
                    subtitle = ""
                } else {
                    subtitle = (currentReading.count > 1) ? Translate.s(currentReading[1].trim()) : ""
                }
                
            case readings.count ..< readings.count + extraReadings.count:
                let ind = indexPath.row - readings.count
                title = extraReadings[ind].title
                subtitle = extraReadings[ind].subtitle
                
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
            
        } else if indexPath.section == 4 {
            if saints[indexPath.row].type == .none {
                if appeared {
                    return getTextCell(saints[indexPath.row].name)
                    
                } else {
                    return getSimpleCell(saints[indexPath.row].name)
                }
                            
            } else {
                let attachment = NSTextAttachment()
                attachment.image = saints[indexPath.row].type.icon15x15
                let attachmentString = NSAttributedString(attachment: attachment)

                let myString = NSMutableAttributedString(string: "")
                myString.append(attachmentString)

                let saintString = saints[indexPath.row].name
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
        var vc : UIViewController!

        if indexPath.section == 3 {
            switch indexPath.row {
                case 0 ..< readings.count:
                    let currentReading = readings[indexPath.row].components(separatedBy: "#").first!
                    
                    let pos = BookPosition(model: DailyTab.pericope, location: currentReading)
                    vc = BookPageSingle(pos, lang: DailyTab.pericope.lang)
            
                case readings.count ..< readings.count + extraReadings.count:
                    let ind = indexPath.row - readings.count
                    let pos = extraReadings[ind].position
                
                    if (pos.model?.contentType == .epub) {
                        let path = pos.data as! String
                        let bookPath =  Bundle.main.path(forResource: "epubs/\(path)", ofType: "epub")!

                        let folioReader = FolioReader()
                        folioReader.showEpub(path: bookPath)
                        
                        return nil
                        
                    } else {
                        vc = BookPageSingle(pos)
                    }
                            
                default:
                    break
            }
            
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (appeared) {
            if indexPath.section == 1 {
                return SaintIconCell.getItemSize().height + 40 // some margin
                
            } else {
                let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
                let h = calculateHeightForCell(cell)
                return (indexPath.section == 2 || indexPath.section == 3) ? max(h, 35) : h
            }
            
        } else {
            switch (indexPath.section, indexPath.row) {
            case (0,0):
                return 35
                
            case (1,_):
                return 0
                
            case (2,_), (3,_):
                return 35
                
            default:
                return 27
            }
        }
    }
    
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
       let title = UILabel()
       let content = self.tableView(tableView, titleForHeaderInSection: section)!
       
       if content.count == 0 {
           return nil
       }

       title.numberOfLines = 1
       title.font = UIFont.boldSystemFont(ofSize: 18)
       title.textColor = Theme.secondaryColor
       title.text = content
       
       headerView.backgroundColor = UIColor.clear
       headerView.addSubview(title)
       headerView.fullScreen(view: title, marginX: 15, marginY: 5)
       
       return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let content = self.tableView(tableView, titleForHeaderInSection: section)!
        return content.count == 0 ? 0 : 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        if DailyTab.pericope.lang != Translate.language {
            DailyTab.pericope = PericopeModel(lang: Translate.language)
        }
        
        if DailyTab.synaxarion.lang != Translate.language {
            DailyTab.synaxarion = SynaxarionModel(lang: Translate.language)
        }
        
        reload()
    }
    
    @objc func reload() {
        formatter.locale = Translate.locale
        
        dayDescription = cal.getDayDescription(currentDate!)
        fasting = ChurchFasting.forDate(currentDate!)
        readings = ChurchReading.forDate(currentDate!)
        saints = SaintModel.saints(currentDate!)

        if (appeared) {
            reloadAfterAppeared()
        }
        
        tableView.reloadData()
    }
    
    func reloadAfterAppeared() {
        saintIcons = SaintIconModel.get(currentDate!)
        
        extraReadings = DailyTab.synaxarion.forDate(currentDate!)
        
        if Translate.language == "en" {
            extraReadings.append(contentsOf: FeofanModel.shared.getPreachment(currentDate!))
            extraReadings.append(contentsOf: DailyTab.livesOfSaints.forDate(currentDate!))
        }
    }
    
    func configureNavbar() {
        navigationController?.makeTransparent()
        
        let button_monthly = CustomBarButton(image: UIImage(named: "calendar", in: toolkit)!, style: .plain, target: self, action: #selector(calendarSelector))
       
        let button_options = CustomBarButton(image: UIImage(named: "options", in: toolkit)!, style: .plain, target: self, action: #selector(showOptions))
        
         let button_review = CustomBarButton(image: UIImage(named: "review", in: toolkit)!, target: self, btnHandler: #selector(writeReview))
        
        navigationItem.leftBarButtonItems = [button_monthly]
        navigationItem.rightBarButtonItems = [button_options, button_review]
    }
    
    @objc func calendarSelector() {
        showPopup(CalendarSelector())
    }
    
    @objc func showWeeklyCalendar() {
        UIViewController.popup.dismiss({
            let dateComponents = DateComponents(date: self.currentDate!)
            let currentWeekday = DayOfWeek(rawValue: dateComponents.weekday!)!
            
            let nearestMonday = currentWeekday == .sunday ?
                self.currentDate! - 6.days :
                Cal.nearestSundayBefore(self.currentDate!) + 1.days
            
            let vc = WeekCalendar(nearestMonday)
            let nav = UINavigationController(rootViewController: vc)
            
            self.navigationController?.present(nav, animated: true, completion: {})
        })
    }
    
    @objc func showMonthlyCalendar() {
        UIViewController.popup.dismiss({
            let image_info = UIImage(named: "help", in: self.toolkit)!.withRenderingMode(.alwaysOriginal)
            let button_info = UIBarButtonItem(image: image_info, style: .plain, target: self, action: #selector(self.showInfo))
            
            let container = UIViewController.named("CalendarContainer", bundle: self.toolkit) as! CalendarNavigation
            container.rightButton = button_info
            container.initialDate = self.currentDate
            self.showPopup(container)
        })
    }
    
    @objc func showYearlyCalendar() {
        UIViewController.popup.dismiss({
            let vc = YearCalendarContainer()
            let nav = UINavigationController(rootViewController: vc)
                        
            self.navigationController?.present(nav, animated: true, completion: {})
        })
        
    }
    
    @objc func showToday() {
        UIViewController.popup.dismiss({
            self.currentDate = DateComponents(date: Date()).toDate()
            self.reload()
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        })
    }
    
    @objc func showInfo() {
        let responder: UIResponder? = UIViewController.popup.popupView?.next
        if let container = responder as? UINavigationController {
            let calendar_info = FastingLegendTableView()
            container.pushViewController(calendar_info, animated: true)
        }
    }
    
    @objc func writeReview() {
        let app_id = 1010208102
        var link:String
        
        if #available(iOS 11.0, *) {
            link = "itms-apps://itunes.apple.com/xy/app/foo/id\(app_id)?action=write-review"
        } else {
            link = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(app_id)&action=write-review"
        }
        
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        let vc = Options()
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true, completion: {})
    }
    
}
