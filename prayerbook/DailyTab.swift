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
    
    static let bookIcon = UIImage(named: "book")!.maskWithColor(.red).resize(CGSize(width: 20, height: 20))
    
    var appeared = false
    
    var fasting: FastingModel!
    var readings = [String]()
    var synaxarion : (String,String)?
    
    var feofan = [(String,String)]()
    var saintTroparia = [(String,String)]()
    let troparia : [TroparionModel] = [TroparionFeastModel.shared]

    var dayDescription = [(FeastType, String)]()
    var saints = [(FeastType, String)]()
    var saintIcons = [Saint]()

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
        
        createTableView(style: .grouped)
        configureNavbar()
        
        if #available(iOS 11.0, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .themeChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDate), name: .dateChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMonthlyCalendar), name: .monthlyCalendarNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showYearlyCalendar), name: .yearlyCalendarNotification, object: nil)

        /*
        if prefs.object(forKey: "welcome40") == nil {
            prefs.set(true, forKey: "welcome40")
            prefs.synchronize()
            
            let alert = UIAlertController(title: "Православный календарь 4.0", message: """
В "Библиотеку" добавлены книги: Всенощное бдение и Божественная Литургия с комментариями, "Хлеб небесный" и другие.
"""
                , preferredStyle: .alert)
            
            // let yesAction = UIAlertAction(title: "Да", style: .default, handler: { _ in self.downloadTroparion()} );
            let noAction = UIAlertAction(title: "OK", style: .default, handler: { _ in  });
            
            // alert.addAction(yesAction)
            alert.addAction(noAction)
            
            present(alert, animated: true, completion: {})
        }
        */
        
        reloadTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appeared = true
        reloadAfterAppeared()

        tableView.reloadData()
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
            return readings.count + feofan.count + (synaxarion != nil ? 1:0)
          
        case 4:
            return troparia.filter({$0.isAvailable(on: currentDate)}).count + (saintTroparia.count > 0 ? 1:0)
            
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
            return (FastingModel.fastingLevel == .monastic) ? Translate.s("Monastic fasting") : Translate.s("Laymen fasting")
            
        case 3:
            return Translate.s("Gospel of the day")
           
        case 4:
            return "Тропари и кондаки"
            
        case 5:
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
                                          subtitle: formatterOldStyle.string(from: currentDate-13.days))
                
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
            if appeared {
                let cell: SaintIconCell = tableView.dequeueReusableCell(for: indexPath)
                cell.saints = saintIcons
                return cell

            } else {
                return getSimpleCell("")
                
            }
           
        } else if indexPath.section == 2 {
            let cell: ImageCell  = getCell()
            
            if let _ = fasting.comments {
                let attachment = NSTextAttachment()
                attachment.image = DailyTab.bookIcon
                
                cell.title.attributedText = NSAttributedString(string: fasting.descr) + "\u{2000}" + NSAttributedString(attachment: attachment)
                
            } else {
                cell.title.attributedText = NSAttributedString(string: fasting.descr)
            }

            cell.title.textColor =  Theme.textColor
            cell.icon.image = UIImage(named: "food-\(fasting.icon)", in: toolkit, compatibleWith: nil)
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
                    
                } else {
                    title = ""
                    subtitle=""
                }
            }
            
            if appeared {
                return getTextDetailsCell(title: title, subtitle: subtitle)
                
            } else {
                let cell = getSimpleCell(title)
                cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                
                return cell
            }
            
        } else if indexPath.section == 4 {
            var titles = [String]()
            
            titles = troparia.filter({$0.isAvailable(on: currentDate)}).map { $0.title }
            titles.append("Тропари и кондаки святым")
            
            if appeared {
                return getTextDetailsCell(title: titles[indexPath.row], subtitle: "")
                
            } else {
                let cell = getSimpleCell(titles[indexPath.row])
                cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                return cell
            }
            
        } else if indexPath.section == 5 {
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
        var vc : UIViewController!

        if indexPath.section == 3 {
            switch indexPath.row {
            case 0 ..< readings.count:
                let currentReading = readings[indexPath.row].components(separatedBy: "#").first!
                
                let pos = BookPosition(model: PericopeModel.shared, location: currentReading)
                vc = BookPageText(pos)
                
            case readings.count ..< readings.count + feofan.count:
                let ind = indexPath.row - readings.count
                let pos = BookPosition(model: FeofanModel.shared, location: feofan[ind].1)
                vc = BookPageText(pos)
                
            default:
                if synaxarion != nil && indexPath.row == readings.count + feofan.count {
                    let pos = BookPosition(model: SynaxarionModel.shared, location: synaxarion!.1)
                    vc = BookPageText(pos)
                }
            }
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 2 && indexPath.row == 0 {
            if var comments = fasting.comments {
                comments = comments.replacingOccurrences(of: "\\n", with: "\n")

                let labelVC = LabelViewController()
                labelVC.text = comments
                labelVC.fontSize = AppGroup.prefs.integer(forKey: "fontSize")
                
                showPopup(labelVC)
            }
            
        } else if indexPath.section == 4 {
            var count = indexPath.row+1
            
            for t in troparia.filter({$0.isAvailable(on: currentDate)}) {
                count -= 1
                
                if count == 0 {
                    if t.isDownloaded() {
                        navigationController?.pushViewController(TroparionView(t.getTroparion(for: currentDate))!, animated: true)
                        
                    } else {
                        downloadTroparion(model: t)
                    }
                    
                    break
                }
            }
            
            if count > 0 {
                let pos = BookPosition(model: SaintTropariaModel.shared, data: saintTroparia)
                navigationController?.pushViewController(BookPageText(pos)!, animated: true)

            }
            
        } else if indexPath.section == 5 {
            showSaints()
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
                
                return (indexPath.section == 3 || indexPath.section == 4) ? max(h, 35) : h
            }
            
        } else {
            switch (indexPath.section, indexPath.row) {
            case (0,0):
                return 55
                
            case (1,_):
                return 0
                
            case (2,_), (3,_), (4,_):
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
            if DailyTab.background == nil {
                DailyTab.background = UIImage(background: "bg3.jpg", inView: view, bundle: toolkit)
            }
   
            view.backgroundColor = UIColor(patternImage: DailyTab.background!)
        }
        
        reload()
    }
    
    @objc func reload() {
        formatter.locale = Translate.locale as Locale
        formatterOldStyle.locale = Translate.locale as Locale
        
        dayDescription = Cal.getDayDescription(currentDate)
        fasting = FastingModel.fasting(forDate: currentDate)
        
        saints = SaintModel.saints(currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        synaxarion = SynaxarionModel.shared.getSynaxarion(for: currentDate)
        
        if (appeared) {
            reloadAfterAppeared()
        
        } else {
            feofan = [("Мысли на каждый день", "")]
        }
        
        tableView.reloadData()
    }
    
    func reloadAfterAppeared() {
        feofan = FeofanModel.getFeofan(for: currentDate)
        saintTroparia = SaintTropariaModel.getTroparion(for: currentDate)
        saintIcons = SaintIconModel.get(currentDate)
    }
    
    func configureNavbar() {
        navigationController?.makeTransparent()
        
        let button_monthly = CustomBarButton(image: UIImage(named: "calendar", in: toolkit, compatibleWith: nil)!, target: self, btnHandler: #selector(calendarSelector))
        
        let button_saint = CustomBarButton(image: UIImage(named: "saint")!, target: self, btnHandler: #selector(showSaints))
        
        let button_options = CustomBarButton(image: UIImage(named: "options", in: toolkit, compatibleWith: nil)!, target: self, btnHandler: #selector(showOptions))
        
        let button_review = CustomBarButton(image: UIImage(named: "review", in: toolkit, compatibleWith: nil)!, target: self, btnHandler: #selector(writeReview))
        
        navigationItem.leftBarButtonItems = [button_monthly, button_saint]
        navigationItem.rightBarButtonItems = [button_options, button_review]
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
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(URL(string: urlStr)!)
            }
        }
       
    }
    
    @objc func calendarSelector() {
        showPopup(CalendarSelector())
    }
    
    @objc func showMonthlyCalendar() {
        UIViewController.popup.dismiss({
            let image_info = UIImage(named: "help", in: self.toolkit, compatibleWith: nil)!.withRenderingMode(.alwaysOriginal)
            let button_info = UIBarButtonItem(image: image_info, style: .plain, target: self, action: #selector(self.showInfo))

            let image_today = UIImage(named: "today", in: self.toolkit, compatibleWith: nil)!.withRenderingMode(.alwaysOriginal)
            let button_today = UIBarButtonItem(image: image_today, style: .plain, target: self, action: #selector(self.showToday))
            
            let container = UIViewController.named("CalendarContainer", bundle: self.toolkit) as! CalendarNavigation
            container.leftButton = button_today
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
    
    @objc func writeReview() {
        let app_id = 1095609748
        var link:String
        
        if #available(iOS 11.0, *) {
            link = "itms-apps://itunes.apple.com/xy/app/foo/id\(app_id)?action=write-review"
        } else {
            link = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(app_id)&action=write-review"
        }
        
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func downloadTroparion(model t: TroparionModel) {
        let container = UIViewController.named("DownloadView") as! DownloadView
        container.url = t.url
        container.fileSize = t.fileSize
        showPopup(container)
    }
    
}
