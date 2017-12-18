//
//  ViewController.swift
//  MeasurAR
//
//  Created by Spencer Yang on 12/16/17.
//  Copyright © 2017 Seungho Yang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    
    var dotNodes = [SCNNode]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        displayLabel.text = "Touch Screen to place 1st point"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
        if dotNodes.count >= 2 {
            dotNodes.forEach({ $0.removeFromParentNode() })
            sceneView.isUserInteractionEnabled = false
        }*/
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                showDot(at: hitResult)
            }
        }
        print(dotNodes.count)
        switch dotNodes.count {
        case 1:
            displayLabel.text = "Now place 2nd point"
            break
        default:
            sceneView.isUserInteractionEnabled = false
            break
        }
    }
    
    func showDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let node = SCNNode()
        node.geometry = dotGeometry
        node.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z )
        
        sceneView.scene.rootNode.addChildNode(node)
        dotNodes.append(node)
        
        if dotNodes.count >= 2 {
            calculateDistance()
            restartButton.isHidden = false
        }
    }
    
    func calculateDistance() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let x = end.position.x - start.position.x
        let y = end.position.y - start.position.y
        let z = end.position.z - start.position.z
        
        let distance = abs(sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)))
        
        print("Distance is %.2f meters", distance)
        displayLabel.text = "Distance is " + String(format: "%.2f", distance) + " meters"
        restartButton.isHidden = false
    }
    
    @IBAction func restartPressed(_ sender: Any) {
        dotNodes.forEach({ $0.removeFromParentNode() })
        dotNodes.removeAll()
        restartButton.isHidden = true
        sceneView.isUserInteractionEnabled = true
        displayLabel.text = "Touch Screen to place 1st point"
    }
    
}

