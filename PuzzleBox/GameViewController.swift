//
//  GameViewController.swift
//  PuzzleBox
//
//  Created by Phil Stern on 5/4/22.
//
//  Initial setup: File | New | Project... | Game (Game Technology: SceneKit)
//  TARGETS | Deployment Info | iOS 12.4
//  PROJECT | Deployment Target | iOS Deployment Target: 12.4  <- if warning "built for newer iOS Simulator version...", make this change and Clean Build Folder
//  Delete art.scnassets (move to Trash)
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    private var scnView: SCNView!
    private var scnScene: SCNScene!
    private var cameraNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
    }
    
    // MARK: - Setup functions
    
    private func setupView() {
        scnView = self.view as? SCNView
        scnView.allowsCameraControl = true  // allow standard camera controls with swiping
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true  // prevent SceneKit from entering a "paused" state, if there isn't anything to animate
    }
    
    private func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = "Background_Diffuse.png"
        scnView.scene = scnScene
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        rotateCameraAroundBoardCenter(deltaAngle: -.pi/4)  // move up 45 deg
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    // rotate camera around board x-axis, while continuing to point at board center
    private func rotateCameraAroundBoardCenter(deltaAngle: CGFloat) {
        cameraNode.transform = SCNMatrix4Rotate(cameraNode.transform, Float(deltaAngle), 1, 0, 0)
        let cameraAngle = CGFloat(cameraNode.eulerAngles.x)
        let cameraDistance = max(9.7 * scnView.frame.height / scnView.frame.width, 15)
        cameraNode.position = SCNVector3(0, -cameraDistance * sin(cameraAngle), cameraDistance * cos(cameraAngle))
    }
}
