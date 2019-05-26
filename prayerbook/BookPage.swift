//
//  BookPage.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class FontSizeViewController : UIViewController, PopupContentViewController {
    let prefs = UserDefaults(suiteName: groupId)!
    var delegate: BookPage!
    
    var text : String!
    var fontSize: Int!
    var con : [NSLayoutConstraint]!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        let label = UILabel()
        label.text = "Размер шрифта"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = .gray
        slider.minimumValue = 12
        slider.maximumValue = 30
        slider.setValue(Float(fontSize), animated: false)
        
        slider.addTarget(self, action: #selector(self.sliderVlaue(_:)), for: .valueChanged)
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("OK", for: .normal)
        button.setTitleColor(Theme.textColor, for: .normal)
        button.layer.borderColor = Theme.secondaryColor.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(slider)
        view.addSubview(button)
        
        con = [
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 100.0),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),

        ]
        
        NSLayoutConstraint.activate(con)
    }
    
    @objc func sliderVlaue(_ sender: UISlider) {
        prefs.set(Int(sender.value), forKey: "fontSize")
        prefs.synchronize()
    }
    
    @objc func buttonAction(sender: UIButton!) {
        delegate.popup.dismiss()
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 250, height: 170)
    }
}

class BookPage: UIViewController {
    let prefs = UserDefaults(suiteName: groupId)!
    var fontSize : Int
    
    var model : BookModel
    var pos : BookPosition
    
    var bookmark: String
    
    var button_fontsize, button_add_bookmark, button_remove_bookmark : CustomBarButton!
    var button_close, button_next, button_prev : CustomBarButton!
    
    var contentView1, contentView2: UIView!
    var con, con2 : [NSLayoutConstraint]!
    
    var popup : PopupController!

    func createContentView(_ pos: BookPosition) -> UIView { preconditionFailure("This method must be overridden") }

    func reloadTheme() { preconditionFailure("This method must be overridden") }
    
    init?(_ pos: BookPosition) {
        guard let model = pos.model else { return nil }
        
        self.model = model
        self.pos = pos
        self.bookmark = model.getBookmark(at: pos)
        
        fontSize = prefs.integer(forKey: "fontSize")
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createNavigationButtons() {
        automaticallyAdjustsScrollViewInsets = false
        
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        
        button_close = CustomBarButton(image: UIImage(named: "close", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(close))
        
        button_next = CustomBarButton(image: UIImage(named: "arrow-right", in: nil, compatibleWith: nil), style: .plain, target: self, action: #selector(showNext))
        
        button_prev = CustomBarButton(image: UIImage(named: "arrow-left", in: nil, compatibleWith: nil), style: .plain, target: self, action: #selector(showPrev))
        
        if model.hasNavigation {
            navigationItem.leftBarButtonItems = [button_close, button_prev, button_next]

        } else {
            navigationItem.leftBarButtonItem = button_close
        }
        
        button_fontsize = CustomBarButton(image: UIImage(named: "fontsize", in: nil, compatibleWith: nil)!
            , target: self, btnHandler: #selector(self.showFontSizeDialog))
        
        button_add_bookmark = CustomBarButton(image: UIImage(named: "add_bookmark", in: nil, compatibleWith: nil)!
            , target: self, btnHandler: #selector(self.addBookmark))
        
        button_remove_bookmark = CustomBarButton(image: UIImage(named: "remove_bookmark", in: nil, compatibleWith: nil)!
            , target: self, btnHandler: #selector(self.removeBookmark))
    }
    
    @objc func showNext() {
        if let nextPos = model.getNextSection(at: pos) {
            let width = view.frame.width;
            contentView2 = createContentView(nextPos)
            
            con2 = generateConstraints(forView: contentView2, leading: 10+width, trailing: -10 + width)
            NSLayoutConstraint.activate(con2)
            
            view.layoutIfNeeded()
            
            NSLayoutConstraint.deactivate(con2)
            con2 = generateConstraints(forView: contentView2, leading: 10, trailing: -10)
            NSLayoutConstraint.activate(con2)
            
            NSLayoutConstraint.deactivate(con)
            con = generateConstraints(forView: contentView1, leading: 10 - width, trailing: -10 - width)
            NSLayoutConstraint.activate(con)
            
            UIView.animate(withDuration: 0.5,
                           animations: { self.view.layoutIfNeeded() },
                           completion: { _ in
                            NSLayoutConstraint.deactivate(self.con)
                            self.contentView1.removeFromSuperview()
                            
                            self.contentView1 = self.contentView2
                            self.con = self.con2
                            
                            self.pos = nextPos
                            self.bookmark = self.model.getBookmark(at: self.pos)
                            
                            self.showBookmarkButton()
            }
            )
        }
    }
    
    @objc func showPrev() {
        if let prevPos = model.getPrevSection(at: pos) {
            let width = view.frame.width;
            
            contentView2 = createContentView(prevPos)
            
            con2 = generateConstraints(forView: contentView2, leading: 10-width, trailing: -10 - width)
            NSLayoutConstraint.activate(con2)
            
            view.layoutIfNeeded()
            
            NSLayoutConstraint.deactivate(con2)
            con2 = generateConstraints(forView: contentView2, leading: 10, trailing: -10)
            NSLayoutConstraint.activate(con2)
            
            NSLayoutConstraint.deactivate(con)
            con = generateConstraints(forView: contentView1, leading: 10 + width, trailing: -10 + width)
            NSLayoutConstraint.activate(con)
            
            UIView.animate(withDuration: 0.5,
                           animations: { self.view.layoutIfNeeded() },
                           completion: { _ in
                            NSLayoutConstraint.deactivate(self.con)
                            self.contentView1.removeFromSuperview()
                            
                            self.contentView1 = self.contentView2
                            self.con = self.con2
                            self.pos = prevPos
                            
                            self.bookmark = self.model.getBookmark(at: self.pos)
                            
                            self.showBookmarkButton()
            }
            )
        }
    }
    
    @objc func addBookmark() {
        var bookmarks = prefs.stringArray(forKey: "bookmarks")!
        bookmarks.append(bookmark)
        prefs.set(bookmarks, forKey: "bookmarks")
        prefs.synchronize()
        
        navigationItem.rightBarButtonItems = [button_fontsize, button_remove_bookmark]
    }
    
    @objc func removeBookmark() {
        var bookmarks = prefs.stringArray(forKey: "bookmarks")!
        bookmarks.removeAll(where: { $0 == bookmark })
        prefs.set(bookmarks, forKey: "bookmarks")
        prefs.synchronize()
        
        navigationItem.rightBarButtonItems = [button_fontsize, button_add_bookmark]
    }
    
    func showBookmarkButton() {
        if model.hasNavigation {
            let bookmarks = prefs.stringArray(forKey: "bookmarks")!
            
            navigationItem.rightBarButtonItems = bookmarks.contains(bookmark)  ? [button_fontsize, button_remove_bookmark]:
                [button_fontsize, button_add_bookmark]
            
        } else {
            navigationItem.rightBarButtonItem = button_fontsize
        }
      
    }
    
    @objc func close() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func generateConstraints(forView : UIView, leading: CGFloat, trailing : CGFloat) -> [NSLayoutConstraint] {
        return [
            forView.topAnchor.constraint(equalTo: view.topAnchor, constant: (navigationController?.navigationBar.frame.height ?? 0.0) + UIApplication.shared.statusBarFrame.height),
            forView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarController?.tabBar.frame.size.height ?? 0.0)),
            forView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading),
            forView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing)
        ]
    }
    
    func showPopup(_ vc: UIViewController, reload: Bool = false) {
        popup = PopupController
            .create(self.navigationController!)
            .customize(
                [
                    .animation(.fadeIn),
                    .layout(.center),
                    .backgroundStyle(.blackFilter(alpha: 0.5))
                ]
            ).didCloseHandler { _ in if reload { self.reloadTheme() } }
        
        popup.show(vc)
    }
    
    @objc func showFontSizeDialog() {
        let vc = FontSizeViewController()
        vc.fontSize = fontSize
        vc.delegate = self
        
        showPopup(vc, reload: true)
    }

}
