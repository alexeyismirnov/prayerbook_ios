//
//  YearCalendarContainer.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/30/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class YearCalendarContainer: UIViewControllerAnimated {
    enum ViewType {
           case list, grid
       }
       
    static var viewType = ViewType.grid
    var year : Int?
    
    var grid: YearCalendarGrid!
    var list: YearCalendarList!
    
    var shareButton, listButton, gridButton:UIBarButtonItem!

    static func year(_ year: Int) -> UIViewController {
        let vc = YearCalendarContainer()
        vc.year = year
        
        return vc
    }
    
    override func viewControllerCurrent() -> UIViewController {
        return YCC.year(year!)
    }
    
    override func viewControllerForward() -> UIViewController {
        return YCC.year(year!+1)
    }
    
    override func viewControllerBackward() -> UIViewController {
        return YCC.year(year!-1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if year == nil {
            year = DateComponents(date: Date()).toDate().year
        }

        setupNavbar()
        
        grid = YearCalendarGrid(year!)
        view.addSubview(grid)
        fullScreen(view: grid)
        
        list = YearCalendarList(year!)
        view.addSubview(list)
        fullScreen(view: list)
        
        if YCC.viewType == .grid {
            showGrid()

        } else {
            showList()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: .dateChangedNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        grid.appeared = true
    }
    
    func setupNavbar() {
        let toolkit = Bundle(identifier: "swift-toolkit-swift-toolkit-resources")!
        
        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        shareButton = UIBarButtonItem(image: UIImage(named: "share", in: toolkit), style: .plain, target: self, action: #selector(share))
        
        listButton = UIBarButtonItem(image: UIImage(named: "list"), style: .plain, target: self, action: #selector(switchView))
        
        gridButton = UIBarButtonItem(image: UIImage(named: "grid"), style: .plain, target: self, action: #selector(switchView))
        
        navigationController?.makeTransparent()
        automaticallyAdjustsScrollViewInsets = false
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view,  bundle: toolkit))
        }
        
    }
    
    @objc func close() {
        dismiss(animated: true, completion: { })
    }
    
    func showList() {
        YCC.viewType = .list
        
        navigationItem.rightBarButtonItems = [shareButton, gridButton]
        list.isHidden = false
        grid.isHidden = true
    }
    
    func showGrid() {
        YCC.viewType = .grid

        navigationItem.rightBarButtonItems = [shareButton, listButton]
        list.isHidden = true
        grid.isHidden = false
    }
    
    @objc func switchView() {
        if YCC.viewType == .grid {
            showList()

        } else {
            showGrid()
        }
    }
    
    @objc func share() {
        var activity: UIActivityViewController!
        
        if YCC.viewType == .grid {
            activity = grid.shareGrid()

        } else {
            activity = list.shareList()
        }
        
        activity.popoverPresentationController?.sourceView = view // so that iPads won't crash
        present(activity, animated: true, completion: nil)
    }
    
}

typealias YCC = YearCalendarContainer
