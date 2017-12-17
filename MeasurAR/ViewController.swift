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
        switch dotNodes.count {
        case 0:
            displayLabel.text = "Touch Screen to place 1st point"
        case 1:
            displayLabel.text = "Now place 2nd point"
        default:
            sceneView.isUserInteractionEnabled = false
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                showDot(at: hitResult)
            }
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
        
    }
    
    @IBAction func restartPressed(_ sender: Any) {
        dotNodes.forEach({ $0.removeFromParentNode() })
        restartButton.isHidden = true
        sceneView.isUserInteractionEnabled = true
    }
    
}

