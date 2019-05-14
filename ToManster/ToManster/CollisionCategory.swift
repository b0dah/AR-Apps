//
//  CollisionCategory.swift
//  ToManster
//
//  Created by Иван Романов on 13/05/2019.
//  Copyright © 2019 Иван Романов. All rights reserved.
//

import Foundation

// Categories
struct CollisionCategory: OptionSet {
    let rawValue : Int
    static let bullets = CollisionCategory(rawValue: 1 << 0) // 0000001
    static let monsters = CollisionCategory(rawValue: 1 << 1) // 0000010
}

