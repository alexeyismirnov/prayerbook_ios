//
//  LanguageSelector.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/3/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

public class LanguageSelector: UIViewController, ResizableTableViewCells, PopupContentViewController {
    public var tableView: UITableView!
    
    let items = ["English", "简体中文", "繁體中文"]
    let prefs = AppGroup.prefs!

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
        
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        createTableView(style: .grouped, isPopup: true)
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var lang: String!
        
        switch (indexPath.row) {
        case 0:
            lang = "en"
            break
        case 1:
            lang = "cn"
            break
        case 2:
            lang = "hk"
            break
        default:
            break
        }
        
        Translate.language = lang
        prefs.set(lang, forKey: "language")
        prefs.synchronize()

        NotificationCenter.default.post(name: .themeChangedNotification, object: nil)
        UIViewController.popup.dismiss()

        return nil
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Translate.s("Language")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getTextDetailsCell(title: Translate.s(items[indexPath.row]), subtitle: "")
        cell.title.textColor = .black
        cell.title.textAlignment = .center
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightForCell(self.tableView(tableView, cellForRowAt: indexPath), minHeight: CGFloat(50))
    }
    
    public func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 200, height: 220)
    }
    
}

