//
//  YearCalendarContainer.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/6/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//


import UIKit
import swift_toolkit

class YearCalendarContainer: UIViewControllerAnimated {
    var year = Cal.currentYear!
    var grid: YearCalendarGrid!
    
    static func year(_ year: Int) -> UIViewController {
        let vc = YearCalendarContainer()
        vc.year = year
        
        return vc
    }
    
    override func viewControllerCurrent() -> UIViewController {
        return YCC.year(year)
    }
    
    override func viewControllerForward() -> UIViewController {
        return YCC.year(year+1)
    }
    
    override func viewControllerBackward() -> UIViewController {
        return YCC.year(year-1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
        grid = YearCalendarGrid(year)
        view.addSubview(grid)
        fullScreen(view: grid)
        
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: .dateChangedNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        grid.appeared = true
    }
    
    func setupNavbar() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        
        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        let shareButton = UIBarButtonItem(image: UIImage(named: "share", in: toolkit), style: .plain, target: self, action: #selector(share))

        navigationItem.rightBarButtonItem = shareButton
        
        navigationController?.makeTransparent()
        automaticallyAdjustsScrollViewInsets = false
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view,  bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: { })
    }
    
    @objc func share() {
        var activity: UIActivityViewController!
        
        activity = grid.shareGrid()
        
        activity.popoverPresentationController?.sourceView = view // so that iPads won't crash
        present(activity, animated: true, completion: nil)
    }
    
    
}

typealias YCC = YearCalendarContainer
