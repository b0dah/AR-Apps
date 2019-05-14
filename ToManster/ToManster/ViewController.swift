//
//  ViewController.swift
//  ToManster
//
//  Created by Иван Романов on 12/05/2019.
//  Copyright © 2019 Иван Романов. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var userScored: Int = 0 {
        didSet /*#*/ { // если поменялсмя
            DispatchQueue.main.async {
                self.scoreLabel.text = String(self.userScored)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new empty scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self //as? SCNPhysicsContactDelegate // ######
        
        addNewMonster()
        
        userScored = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.confireSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Session failed with error: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    /*   custom funcs    */
    
    func confireSession() {
        if ARWorldTrackingConfiguration.isSupported {
            // if processor version supported for full experienced AR
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            
            // run config
            sceneView.session.run(configuration) //let configuration = ARSessionConfiguration() // cocoaHeads version
            
        }
        else { // if processor lower than A9
            let configuration = AROrientationTrackingConfiguration()
            sceneView.session.run(configuration)
        }
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        
        let bulletNode = Bullet()
        
        // position node exactly to the user's position
        let (direction, position) = self.getUserVector()
        bulletNode.position = position
    
        bulletNode.physicsBody?.applyForce(direction, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletNode)
        
    }
    
    

    
    func floatBetween(first: Float, second: Float) -> Float {
        return ( Float(arc4random()) / Float(UInt32.max) * (first - second) ) + second
    }
    
    // get direction and camera position of the user
    func getUserVector() -> (SCNVector3, SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let userMatrix = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(-1*userMatrix.m31, -1*userMatrix.m32, -1*userMatrix.m33)
            let pos = SCNVector3(userMatrix.m41, userMatrix.m42, userMatrix.m43)
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0 , -1), SCNVector3(0, 0, -0.2))
    }
    
    // Contact case //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // in case of any collision with Monster's body
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.monsters.rawValue || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.monsters.rawValue {
            
            print("The target was hit")
            self.removeNodeWithAnimation(contact.nodeB, explosion: false) //remove bullet
            self.userScored += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.removeNodeWithAnimation(contact.nodeA, explosion: true) // remove monster
                self.addNewMonster()
                })
        }
    }
    
    func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
        
        if explosion { // animated explosion
            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
            let explosionNode = SCNNode()
            explosionNode.addParticleSystem(particleSystem!)
            explosionNode.position = node.position
            // add to the scene
            sceneView.scene.rootNode.addChildNode(explosionNode)
        }
        // just remove
        node.removeFromParentNode()
    }
    
    func addNewMonster() {
        let monsterNode = Monster()
        
        let posX = floatBetween(first: -0.9, second: 0.9)
        let posY = floatBetween(first: -0.9, second: 0.9)
        // two random coordinates and fixed distance to user
        monsterNode.position = SCNVector3(posX, posY, -1)
        sceneView.scene.rootNode.addChildNode(monsterNode)
    }
}


