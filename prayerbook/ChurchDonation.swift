//
//  ChurchDonation.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/14/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

public class ChurchDonation: UIViewController, ResizableTableViewCells, PopupContentViewController {
    public var tableView: UITableView!
    
    var items = [("Paypal", "church@orthodoxy.hk"),
                 ("Bitcoin", "3QzG3dooTfQ7fGctwirZJyJcqxMF3YSoKR"),
                 ("WeChat", "frdionisy")]

    public init() {
        super.init(nibName: nil, bundle: nil)
        
        if Translate.language == "ru" {
            items.insert(("Тинькофф", "+7 (903) 104-27-94"), at: 0)
        } else {
            items.insert(("Alipay", "+852 94385021"), at: 0)
        }
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
        let title = items[indexPath.row].0
        let subtitle = items[indexPath.row].1
        
        UIPasteboard.general.string = subtitle
            
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: title, message: Translate.s("Copied to clipboard"), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                UIViewController.popup.dismiss()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Translate.s("Donation")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getTextDetailsCell(title: items[indexPath.row].0, subtitle: items[indexPath.row].1)
        cell.title.textColor = .black
        cell.title.textAlignment = .left
        
        cell.subtitle.textColor = .gray
        cell.subtitle.textAlignment = .left
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightForCell(self.tableView(tableView, cellForRowAt: indexPath), minHeight: CGFloat(50))
    }
    
    public func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            let screenSize = UIScreen.main.bounds
            
            if UIDevice.modelName.contains("Plus") {
                return CGSize(width: screenSize.width-50, height: 400)
            
            } else if UIDevice.modelName.contains("iPhone X") {
                return CGSize(width: screenSize.width-50, height: 450)
           
            } else {
                return CGSize(width: screenSize.width-50, height: 350)
            }
            
        } else {
            return CGSize(width: 500, height: 550)
        }
    }
    
}
