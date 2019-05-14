//
//  Monster.swift
//  ToManster
//
//  Created by Иван Романов on 12/05/2019.
//  Copyright © 2019 Иван Романов. All rights reserved.
//

import SceneKit
import UIKit

class Monster: SCNNode {
    override init() {
        super.init()
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        self.geometry = box
        
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        //////////////////////////////////////////////////////////////
        // К какой категории относится
        self.physicsBody?.categoryBitMask = CollisionCategory.monsters.rawValue
        // С какими объектами уведомлять о сталкивании
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
        //////////////////////////////////////////////////////////////
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "Monster")
        // for each face
        self.geometry?.materials = [material, material,material,material,material,material]
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        // in the case of error
        fatalError("init(coder:) has not been implemented")
    }
}
