//
//  PreachmentModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 2/4/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import Foundation
import swift_toolkit

public struct Preachment {
    public init(position: BookPosition, title: String, subtitle: String = "") {
        self.position = position
        self.title = title
        self.subtitle = subtitle
    }
    
    public var position : BookPosition
    public var title: String
    public var subtitle: String
}

public protocol PreachmentModel {
    func getPreachment(_ date: Date) -> [Preachment]
}

