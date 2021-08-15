//
//  ChurchInfo.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/13/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit
import StoreKit

import swift_toolkit

class ChurchInfo: UITableViewController {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var appButton: UIButton!
    @IBOutlet weak var donationButton1: UIButton!
    @IBOutlet weak var donationButton2: UIButton!
    @IBOutlet weak var donationButton3: UIButton!
    @IBOutlet weak var donationButtonOther: UIButton!
    
    static let productIds: Set<ProductIdentifier> = ["calendar_ru1", "calendar_ru2", "calendar_ru3"]
    let store = IAPHelper(productIds: ChurchInfo.productIds)
    var products: [SKProduct] = []

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .themeChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseComplete), name: .IAPHelperPurchaseNotification, object: nil)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        makeRoundedCorners(appButton)
        makeRoundedCorners(donationButton1)
        makeRoundedCorners(donationButton2)
        makeRoundedCorners(donationButton3)
        makeRoundedCorners(donationButtonOther)

        loadProducts()
        reload()
    }

    @IBAction func installApp(_ sender: Any) {
        let urlStr = "https://itunes.apple.com/us/app/apple-store/id1566259967"
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            
        } else {
            UIApplication.shared.openURL(URL(string: urlStr)!)
        }
    }
    
    @IBAction func makeDonationOther(_ sender: Any) {
        showPopup(ChurchDonation())
    }
    
    @IBAction func makeDonation1(_ sender: Any) {
        store.buyProduct(products[0])
    }
    
    @IBAction func makeDonation2(_ sender: Any) {
        store.buyProduct(products[1])
    }
    
    @IBAction func makeDonation3(_ sender: Any) {
        store.buyProduct(products[2])
    }
    
    func loadProducts() {
        donationButton1.isHidden = true
        donationButton2.isHidden = true
        donationButton3.isHidden = true
        
        products = []
        
        store.requestProducts{ success, products in
          if success {
            self.products = products!.sorted {$0.price.floatValue < $1.price.floatValue }
                        
            for p in self.products {
                print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.intValue)")
            }
            
            DispatchQueue.main.async {
                
                self.donationButton1.setTitle("Пожертвовать \(self.products[0].price.intValue) р.", for: .normal)
                self.donationButton2.setTitle("Пожертвовать \(self.products[1].price.intValue) р.", for: .normal)
                self.donationButton3.setTitle("Пожертвовать \(self.products[2].price.intValue) р.", for: .normal)

                self.donationButton1.isHidden = false
                self.donationButton2.isHidden = false
                self.donationButton3.isHidden = false
                    
                self.tableView.reloadData()
            }
          }
        }
        
        tableView.reloadData()
    }
    
    @objc func purchaseComplete() {
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: Translate.s("Donation"),
                                          message: Translate.s("Thanks for your donation"),
                                          preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func reload() {
        label1.textColor = Theme.textColor

        label2.textColor = Theme.textColor
        label2.text = Translate.s("church_info")
        
        label3.textColor = Theme.textColor
        label3.text = Translate.s("app_info")
        
        label4.textColor = Theme.textColor
        label4.text = Translate.s("donation_info")
        
        updateButtonStyle(appButton)
        updateButtonStyle(donationButton1)
        updateButtonStyle(donationButton2)
        updateButtonStyle(donationButton3)
        updateButtonStyle(donationButtonOther)
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    
    func makeRoundedCorners(_ button: UIButton!) {
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.contentEdgeInsets =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func updateButtonStyle(_ button: UIButton!) {
        button.backgroundColor = .flatWhite()
        button.layer.borderColor = UIColor.gray.cgColor
        button.setTitleColor(.black, for: .normal)
    }
    
}

