//
//  ViewController.swift
//  ARKitDemo
//
//  Created by DenisZemskikh on 7/19/17.
//  Copyright © 2017 Denis Zemskix. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var userScore: Int = 0 {
        didSet {
            // Обеспечиваем обновление пользовательского интерфейса в основном потоке
            DispatchQueue.main.async {
                self.scoreLabel.text = String(self.userScore)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Создаем новую пустую сцену
        let scene = SCNScene()
        
        // Установите сцену для отображения
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
        
        self.addNewCocoaheads()
        
        self.userScore = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.configureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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
        // Представить пользователю сообщение об ошибке
        print("Session failed with error: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Сообщите пользователю, что сеанс был прерван, например, путем представления наложения
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Сбросить отслеживание и / или удалить существующие якоря, если требуется постоянное отслеживание
    }
    
    
    // MARK: - Actions
    
    @IBAction func didTapScreen(_ sender: UITapGestureRecognizer) { // стрельба по центру
        
        
        
        let bulletsNode = Bullet()
        
        let (direction, position) = self.getUserVector()
        bulletsNode.position = position // SceneKit/AR Координаты в метрах
        
        let bulletDirection = direction
        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
        
    }
    
    // MARK: - Game Functionality
    
   func configureSession() {
        if ARWorldTrackingSessionConfiguration.isSupported { // Проверяет, поддерживает ли пользовательское устройство более точное ARWorldTrackingSessionConfiguration
         
            // Создание конфигурации сеанса
            let configuration = ARWorldTrackingSessionConfiguration()
            configuration.planeDetection = ARWorldTrackingSessionConfiguration.PlaneDetection.horizontal
            
            // Запуск сеанса просмотра
            sceneView.session.run(configuration)
        } else {
            // Чуть менее впечатляющий AR если процессор ниже A9
            let configuration = ARSessionConfiguration()
            
            // Запуск сеанса просмотра
            sceneView.session.run(configuration)
        }
    }
    
    // добавляем новый квадрат
    func addNewCocoaheads() {
        let cubeNode = CocoaHeads()
        
        let posX = floatBetween(-0.9, and: 0.9)
        let posY = floatBetween(-0.9, and: 0.9 )
        cubeNode.position = SCNVector3(posX, posY, -1) // расчет в метрах
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    // анимация взрыва
    func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
        
        //показываем взрыв
        if explosion {
            
            
            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem!)
            //добавляем якорь для взрыва
            systemNode.position = node.position
            sceneView.scene.rootNode.addChildNode(systemNode)
        }
        
        // убираем взрыв
        node.removeFromParentNode()
    }
    
    
    // получение Направление, положение пользователя
    func getUserVector() -> (SCNVector3, SCNVector3) { // (Направление, положение)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    // Создание случайной позиции для цели
    func floatBetween(_ first: Float,  and second: Float) -> Float {
        
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    
    // удар по цели
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.cocoaheads.rawValue || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.cocoaheads.rawValue { // любое прикосновение с нашим объектом будет считаться за очко
            
            print("Ура мы сбили!")
            self.removeNodeWithAnimation(contact.nodeB, explosion: false) // убираем мяч
            self.userScore += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { // через пол сикунды убирает квадрат
                self.removeNodeWithAnimation(contact.nodeA, explosion: true)
                self.addNewCocoaheads()
            })
            
        }
    }
    
}

//выбор значения
struct CollisionCategory: OptionSet {
    let rawValue: Int
    static let bullets  = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let cocoaheads = CollisionCategory(rawValue: 1 << 1) // 00..10
}


