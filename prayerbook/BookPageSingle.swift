//
//  BookPageSingle.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/20/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

public class BookPageSingle: UIViewController, BookPageDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    let prefs = AppGroup.prefs!

    var collectionView: UICollectionView!

    var model : BookModel
    var bookPos : BookPosition
        
    var button_fontsize, button_close : CustomBarButton!
    
    public init?(_ pos: BookPosition) {
        guard let model = pos.model else { return nil }
        
        self.model = model
        self.bookPos = pos
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.tabBar.isHidden = true
        
        reloadTheme()
        createNavigationButtons()
        createCollectionView()
    }
    
    func createCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = view.frame.size
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }
    
    func createNavigationButtons() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        
        button_close = CustomBarButton(image: UIImage(named: "close", in: toolkit), style: .plain, target: self, action: #selector(close))
        
        button_fontsize = CustomBarButton(image: UIImage(named: "fontsize", in: toolkit)!
            , target: self, btnHandler: #selector(showFontSizeDialog))
        
        navigationItem.rightBarButtonItems = [button_fontsize]
        navigationItem.leftBarButtonItems = [button_close]
       
    }
    
    @objc func close() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func reloadTheme() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
    }
    
    @objc func showFontSizeDialog() {
        showPopup(FontSizeViewController(), onClose: { _ in self.collectionView.reloadData() })
    }
    
    func hideBars() -> CGRect {
        navigationController?.setNavigationBarHidden(true, animated: true)
        return getFullScreenFrame()
    }
    
    func showBars() -> CGRect {
        navigationController?.setNavigationBarHidden(false, animated: true)
        return getFullScreenFrame()
    }

    func showComment(_ popup: UIViewController) {
        showPopup(popup)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if model.contentType == .html {
            let cell: BookPageCellHTML = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = model.getContent(at: bookPos) as? String
            cell.cellFrame = getFullScreenFrame()
            cell.delegate = self
            cell.model = model
            
            return cell
            
        } else {
            let cell: BookPageCellText = collectionView.dequeueReusableCell(for: indexPath)
            cell.attributedText = model.getContent(at: bookPos) as? NSAttributedString
            cell.cellFrame = getFullScreenFrame()
            cell.delegate = self
            
            return cell
        }
            
    }

}

