//
//  Bullet.swift
//  ToManster
//
//  Created by Иван Романов on 12/05/2019.
//  Copyright © 2019 Иван Романов. All rights reserved.
//

import SceneKit
import UIKit

class Bullet: SCNNode {
    override init() {
        super.init()
        
        let sphere = SCNSphere(radius: 0.15)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        
        
        /*let tomatoScene = SCNScene(named: "tomato.scn")
        guard let tomatoNode = tomatoScene?.rootNode.childNode(withName: "TomatoNode", recursively: false) else {
            return
        }
        
        //let tomatoShape = SCNPhysicsShape(geometry: (tomatoNode?.geometry)!, options: nil)
        tomatoNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: tomatoNode,  options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        
        tomatoNode.physicsBody?.isAffectedByGravity = false
        */
        
        ///////////////////////////////
        //относится
        self.physicsBody?.categoryBitMask = CollisionCategory.bullets.rawValue
        // сталкивается
        self.physicsBody?.contactTestBitMask = CollisionCategory.monsters.rawValue
        ///////////////////////////////
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "Bullet")//UIColor.orange
        self.geometry?.materials = [material]
 
        
        //self.addChildNode(tomatoNode)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        // в случае ошибки содания объекта
        fatalError("init(coder:) has not been implemented")
    }
}
