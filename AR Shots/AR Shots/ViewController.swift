//
//  ViewController.swift
//  AR Shots
//
//  Created by Иван Романов on 08/05/2019.
//  Copyright © 2019 Иван Романов. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var hoopAdded = false

    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        if !hoopAdded {
            let touchLocation = sender.location(in: sceneView)
            
            let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlane])
            
            if let result = hitTestResult.first {
                print("Ray intersected a discovered plane!")
                addHoop(result: result)
                
                hoopAdded = true
                
            }
        }
        else {
            createBasketball()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/hoop.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
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
    
    func addHoop(result: ARHitTestResult) {
        // Retrieve the scene file and locate the hoop node
        let hoopScene = SCNScene(named: "art.scnassets/hoop.scn")
        
        guard let hoopNode = hoopScene?.rootNode.childNode(withName: "Hoop", recursively: false) else {
            return
        }
        
        // Place the node in the correct position
        let planePosition = result.worldTransform.columns.3
        hoopNode.position = SCNVector3(planePosition.x, planePosition.y, planePosition.z)
        
        // Apply the correct physics body
        hoopNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: hoopNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        // Place the node to the scene
        sceneView.scene.rootNode.addChildNode(hoopNode)
        
    }
    
    func createBasketball() {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        
        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        ball.transform = cameraTransform
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball, options: [SCNPhysicsShape.Option.collisionMargin: 0.01]))
        ball.physicsBody = physicsBody
        
        let power = Float(10.0)
        let force = SCNVector3(-cameraTransform.m31*power, -cameraTransform.m32*power, -cameraTransform.m33*power)
        ball.physicsBody?.applyForce(force, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(ball)
    }
    
   /* func createCover() -> SCNNode {
        let node = SCNNode()
        
        let geometry = SCNPlane(width: 1.0, height: 1.0)
        node.geometry = geometry
       
        //node.eulerAngles.x = -Float.pi / 2
        node.opacity = 0.25
       
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node:
        SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
       
        let cover = createCover()
        node.addChildNode(cover)
    }*/
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
