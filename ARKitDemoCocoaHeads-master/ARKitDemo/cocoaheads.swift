//
//  cocoaheads.swift
//  ARKitDemo
//
//  Created by DenisZemskikh on 7/19/17.
//  Copyright © 2017 Denis Zemskix. All rights reserved.
//

import UIKit
import SceneKit

//Создаем квадрат
class CocoaHeads: SCNNode {
    override init() {
        super.init()
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        /*Маска проверяет к какой категории объектов относится данный объект
        в нашем случае короб CocoaHeads*/
        self.physicsBody?.categoryBitMask = CollisionCategory.cocoaheads.rawValue
        /*Маска с объектом мяч производит уведомление при пересечении с объектом
        в нашем случае коробом CocoaHeads*/
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
        
        // накладываем текстуру короба с логотипом CocoaHeads
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "cocoaheads")
        self.geometry?.materials  = [material, material, material, material, material, material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        // в случае ошибки содания объекта
        fatalError("init(coder:) has not been implemented")
    }
    
}

