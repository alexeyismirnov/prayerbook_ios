//
//  LabelViewCell.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/24/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

public protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    public static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        register(T.self)
        return dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as! T
    }
}

class LabelViewCell: UICollectionViewCell {
    var title: UILabel!
    var con : [NSLayoutConstraint]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let fontSize = CGFloat(UIDevice.current.userInterfaceIdiom == .phone ? 16.0 : 18.0)

        title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false

        title.numberOfLines = 1
        title.font = UIFont.systemFont(ofSize: fontSize)
        title.textColor = Theme.textColor
        title.adjustsFontSizeToFitWidth = false
        title.clipsToBounds = true
        title.textAlignment = .center
        title.baselineAdjustment = .alignCenters
        
        addSubview(title)
        
        con = [
            title.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(con)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LabelViewCell: ReusableView {}
