//
//  DownloadView.swift
//  saints
//
//  Created by Alexey Smirnov on 1/25/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit
import Zip

class DownloadView: UIViewController, PopupContentViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var button: UIButton!
    
    let url = "https://filedn.com/lUdNcEH0czFSe8uSnCeo29F/prayerbook/tropari.zip"
    var delegate: DailyTab2!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        DownloadManager.delegate = self
        DownloadManager.startTransfer(url, completionHandler: {fileURL in
            DispatchQueue.main.async() {
                self.titleLabel.text = "Распаковка..."
            }
            
            do {
                let _ = try Zip.quickUnzipFile(fileURL)
                try FileManager.default.removeItem(at: fileURL)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
                self.showInfo(title: "Ошибка", message: "Ошибка распаковки")
                
                return
            }
            
            self.showInfo(title: "Православный календарь", message: "Тропари и кондаки двунадесятых праздников добавлены в календарь")
        })
    }
    
    func setupUI() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
        
        titleLabel.textColor = Theme.textColor
                
        button.layer.borderColor = Theme.secondaryColor.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        
        progressBar.progress = 0
    }
    
    @IBAction func cancel(_ sender: Any) {
        DownloadManager.cancelTransfer(url)
        delegate.popup.dismiss()
    }
    
    func showInfo(title: String, message: String) {
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.delegate.popup.dismiss()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 300, height: 200)
    }
    
    
}

