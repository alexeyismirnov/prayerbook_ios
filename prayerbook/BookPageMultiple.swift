//
//  BookPage2.swift
//  ponomar
//
//  Created by Alexey Smirnov on 6/29/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

protocol BookPageDelegate {
    func hideBars() -> CGRect
    func showBars() -> CGRect
    func showComment(_ popup: UIViewController)
}

public class BookPageMultiple: UIViewController, BookPageDelegate {
    let prefs = AppGroup.prefs!

    var collectionView: UICollectionView!
    var isScrolling: Bool!

    var model : BookModel
    var bookPos = [BookPosition]()
    var initialPos : Int!
    var toolbarLabel: UILabel!

    var bookmark: String?
    
    var button_fontsize, button_add_bookmark, button_remove_bookmark : CustomBarButton!
    var button_close : CustomBarButton!
    
    public init?(_ pos: BookPosition) {
        guard let model = pos.model else { return nil }
        
        self.model = model
        self.bookmark = model.getBookmark(at: pos)
        
        let prevPos = model.getPrevSection(at: pos)
        let nextPos = model.getNextSection(at: pos)
        
        if prevPos == nil {
            let nextnextPos = model.getNextSection(at: nextPos!)
            
            bookPos.append(pos)
            bookPos.append(nextPos!)
            bookPos.append(nextnextPos!)
            
            initialPos = 0
            
        } else if nextPos == nil {
            let prevprevPos = model.getPrevSection(at: prevPos!)
            
            bookPos.append(prevprevPos!)
            bookPos.append(prevPos!)
            bookPos.append(pos)
            
            initialPos = 2
            
        } else {
            bookPos.append(prevPos!)
            bookPos.append(pos)
            bookPos.append(nextPos!)
            
            initialPos = 1
        }
        
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
        updateNavigationButtons()
        
        createCollectionView()
        createToolbar()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.scrollToItem(at: IndexPath(item: initialPos, section: 0), at: .left, animated: false)

        navigationController?.toolbar.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.width - 70.0),
                                                     size: CGSize(width: view.frame.width, height: 70.0))
        
        
        navigationController?.setToolbarHidden(false, animated: false)
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
        
        isScrolling = false

        view.addSubview(collectionView)
    }
    
    func createToolbar() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        var items = [UIBarButtonItem]()

        toolbarLabel = UILabel(frame: .zero)
        toolbarLabel.textAlignment = .center
        toolbarLabel.numberOfLines = 2
        toolbarLabel.textColor = Theme.textColor
        
        toolbarLabel.font = UIFont(name: "TimesNewRomanPSMT", size: CGFloat(22))

        toolbarLabel.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width-120, height: 60)
        
        let customBarButton = UIBarButtonItem(customView: toolbarLabel)
        
        items.append(UIBarButtonItem(image: UIImage(named: "arrow-left", in: toolkit),
                                     style: .plain,
                                     target: self,
                                     action: #selector(self.showPrev)))
        
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        items.append(customBarButton)
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        
        items.append(UIBarButtonItem(image: UIImage(named: "arrow-right", in: toolkit),
                                     style: .plain,
                                     target: self,
                                     action: #selector(self.showNext)))
        
        updateToolbar(pos: bookPos[initialPos])

        self.toolbarItems = items
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func updateToolbar(pos: BookPosition) {
        toolbarLabel.text = model.getTitle(at: pos)
    }
    
    func createNavigationButtons() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        
        button_close = CustomBarButton(image: UIImage(named: "close", in: toolkit), style: .plain, target: self, action: #selector(close))
        
        button_fontsize = CustomBarButton(image: UIImage(named: "fontsize", in: toolkit)!
            , target: self, btnHandler: #selector(showFontSizeDialog))
        
        button_add_bookmark = CustomBarButton(image: UIImage(named: "add_bookmark", in: toolkit)!
            , target: self, btnHandler: #selector(addBookmark))
        
        button_remove_bookmark = CustomBarButton(image: UIImage(named: "remove_bookmark", in: toolkit)!
            , target: self, btnHandler: #selector(removeBookmark))
    }
    
    func updateNavigationButtons() {
        var right_nav_buttons = [CustomBarButton]()
        
        if let bookmark = bookmark {
            let bookmarks = prefs.stringArray(forKey: "bookmarks")!
            right_nav_buttons.append(bookmarks.contains(bookmark) ? button_remove_bookmark : button_add_bookmark)
        }
        
        right_nav_buttons.insert(button_fontsize, at: 0)
        
        navigationItem.rightBarButtonItems = right_nav_buttons
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
    
    @objc func showNext() {
        if (isScrolling) { return }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = collectionView.indexPathForItem(at: visiblePoint)!
        
        if (index.row < 2) {
            isScrolling = true
            collectionView.scrollToItem(at: IndexPath(item: index.row+1, section: 0), at: .left, animated: true)
        }
    }
    
    @objc func showPrev() {
        if (isScrolling) { return }

        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = collectionView.indexPathForItem(at: visiblePoint)!
        
        if (index.row > 0) {
            isScrolling = true
            collectionView.scrollToItem(at: IndexPath(item: index.row-1, section: 0), at: .left, animated: true)
        }
    }
    
    @objc func showFontSizeDialog() {
        showPopup(FontSizeViewController(), onClose: { _ in self.collectionView.reloadData() })
    }
    
    @objc func addBookmark() {
        guard let bookmark = bookmark else { return }
        
        var bookmarks = prefs.stringArray(forKey: "bookmarks")!
        bookmarks.append(bookmark)
        prefs.set(bookmarks, forKey: "bookmarks")
        prefs.synchronize()
        
        navigationItem.rightBarButtonItems = [button_fontsize, button_remove_bookmark]
    }
    
    @objc func removeBookmark() {
        guard let bookmark = bookmark else { return }

        var bookmarks = prefs.stringArray(forKey: "bookmarks")!
        bookmarks.removeAll(where: { $0 == bookmark })
        prefs.set(bookmarks, forKey: "bookmarks")
        prefs.synchronize()
        
        navigationItem.rightBarButtonItems = [button_fontsize, button_add_bookmark]
    }
    
    func hideBars() -> CGRect {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
        return getFullScreenFrame()
    }
    
    func showBars() -> CGRect {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        return getFullScreenFrame()
    }

    func showComment(_ popup: UIViewController) {
        showPopup(popup)
    }
}

extension  BookPageMultiple: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if model.mode == .html {
            let cell: BookPageCellHTML = collectionView.dequeueReusableCell(for: indexPath)
            cell.text = model.getContent(at: bookPos[indexPath.row]) as? String
            cell.cellFrame = getFullScreenFrame()
            cell.delegate = self
            cell.model = model
            
            return cell
            
        } else {
            let cell: BookPageCellText = collectionView.dequeueReusableCell(for: indexPath)
            cell.attributedText = model.getContent(at: bookPos[indexPath.row]) as? NSAttributedString
            cell.cellFrame = getFullScreenFrame()
            cell.delegate = self
            
            return cell
        }
            
    }
    
    func adjustView(_ scrollView: UIScrollView) {
        let contentOffsetWhenFullyScrolledRight = collectionView.frame.size.width * CGFloat(bookPos.count - 1)
        var newPos = bookPos[1]
        
        if scrollView.contentOffset.x == 0 {
            newPos = bookPos[0]
        } else if scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight {
            newPos = bookPos[2]
        }
        
        let prevPos = model.getPrevSection(at: newPos)
        let nextPos = model.getNextSection(at: newPos)
        
        updateToolbar(pos: newPos)

        if prevPos == nil {
            let nextnextPos = model.getNextSection(at: nextPos!)
            
            collectionView.performBatchUpdates({
                self.bookPos[0] = newPos
                self.bookPos[1] = nextPos!
                self.bookPos[2] = nextnextPos!
            }, completion: { _ in
                UIView.setAnimationsEnabled(false)
                self.collectionView.reloadData()
                UIView.setAnimationsEnabled(true)
            })
            
        } else if nextPos == nil {
            let prevprevPos = model.getPrevSection(at: prevPos!)

            collectionView.performBatchUpdates({
                self.bookPos[0] = prevprevPos!
                self.bookPos[1] = prevPos!
                self.bookPos[2] = newPos
            }, completion: { _ in
                UIView.setAnimationsEnabled(false)
                self.collectionView.reloadData()
                UIView.setAnimationsEnabled(true)
            })
        } else {
            collectionView.performBatchUpdates({
                self.bookPos[0] = prevPos!
                self.bookPos[1] = newPos
                self.bookPos[2] = nextPos!
                
            }, completion: { _ in
                UIView.setAnimationsEnabled(false)
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
                UIView.setAnimationsEnabled(true)
            })
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
        adjustView(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustView(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            adjustView(scrollView)
        }
    }
    
}
