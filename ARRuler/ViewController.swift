//
//  ViewController.swift
//  ARRuler
//
//  Created by Slava on 20.05.2021.
//

import UIKit
import SceneKit
import ARKit



class ViewController: UIViewController, ARSCNViewDelegate {
    
    var doteNodes = [SCNNode]()
    var textNode = SCNNode()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if doteNodes.count >= 2 {
            for dot in doteNodes {
                dot.removeFromParentNode()
            }
            doteNodes = [SCNNode]()
        }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.raycastQuery(from: touchLocation, allowing: ARRaycastQuery.Target.estimatedPlane, alignment: .any)
            
            if let hitRes = results {
                
                let rayCast = sceneView.session.raycast(hitRes)
                
                guard let ray = rayCast.first else {return}
                addDot(at: ray)
            }
            
        }
    }
    
    func addDot(at hitResult: ARRaycastResult) {
        
        let sphereScene = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        
        material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_nightmap.jpg")
        
        sphereScene.materials = [material]
        
        let node = SCNNode()
        
        node.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + sphereScene.boundingSphere.radius,
            hitResult.worldTransform.columns.3.z
        )
        
        node.geometry = sphereScene
        
        sceneView.scene.rootNode.addChildNode(node)
        
        doteNodes.append(node)
        
        if doteNodes.count >= 2 {
            calculate()
        }
        
    }
    
    func calculate() {
        
        let start = doteNodes[0]
        let end = doteNodes[1]
        
        print(start.position)
        print(end.position)
        
        let distnce = sqrt(pow(start.position.x-end.position.x, 2) +
                           pow(start.position.y-end.position.y, 2) +
                           pow(start.position.z-end.position.z, 2))
        
        //        distance = sqrt() ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        
        updateText(text: "\(abs(distnce))", atPosition: end.position)
        
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
