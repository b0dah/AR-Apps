//
//  bullet.swift
//  ARKitDemo
//
//  Created by DenisZemskikh on 7/19/17.
//  Copyright © 2017 Denis Zemskix. All rights reserved.
//

import UIKit
import SceneKit

// Мяч
class Bullet: SCNNode {
    override init () {
        super.init()
        let sphere = SCNSphere(radius: 0.025)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        
        self.physicsBody?.categoryBitMask = CollisionCategory.bullets.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.cocoaheads.rawValue
        
        //Добавляем текстуру
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "bullet")
        self.geometry?.materials  = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        // в случае ошибки содания объекта
        fatalError("init(coder:) has not been implemented")
    }
}

