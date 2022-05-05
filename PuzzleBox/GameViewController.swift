//
//  GameViewController.swift
//  PuzzleBox
//
//  Created by Phil Stern on 5/4/22.
//
//  Japanese puzzle box design from: https://dictum.com/en/blog/tutorials/build-your-own-japanese-puzzle-box
//
//  Initial setup: File | New | Project... | Game (Game Technology: SceneKit)
//  TARGETS | Deployment Info | iOS 12.4
//  PROJECT | Deployment Target | iOS Deployment Target: 12.4  <- if warning "built for newer iOS Simulator version...", make this change and Clean Build Folder
//  Delete art.scnassets (move to Trash)
//

import UIKit
import QuartzCore
import SceneKit

struct Box {
    static let length = 15.0
    static let height = 10.0
    static let width = 10.0
}

class GameViewController: UIViewController {
    
    private var scnView: SCNView!
    private var scnScene: SCNScene!
    private var cameraNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        createPuzzleBox()
    }
    
    private func createPuzzleBox() {
        let horizontalOffset = Box.length / 2 - 1.5 * Wall.thickness
        let verticalOffset = Box.height / 2 - 1.5 * Wall.thickness

        let leftSideNode = MovableSideNode(width: Box.width, height: Box.height, isLeft: true)
        leftSideNode.position = SCNVector3(-horizontalOffset, 0, 0)
        scnScene.rootNode.addChildNode(leftSideNode)
        
        let rightSideNode = MovableSideNode(width: Box.width, height: Box.height, isLeft: false)
        rightSideNode.position = SCNVector3(horizontalOffset, -Wall.thickness / 2, 0)
        rightSideNode.transform = SCNMatrix4Rotate(rightSideNode.transform, .pi, 0, 1, 0)
        scnScene.rootNode.addChildNode(rightSideNode)
        
        let topSideNode = MovableSideNode(width: Box.width, height: Box.length, isLeft: false)
        topSideNode.position = SCNVector3(Wall.thickness / 2, verticalOffset, 0)
        topSideNode.transform = SCNMatrix4Rotate(topSideNode.transform, -.pi / 2, 0, 0, 1)
        scnScene.rootNode.addChildNode(topSideNode)
        
        let floorSideNode = MovableSideNode(width: Box.width, height: Box.length - Wall.thickness, isLeft: false)
        floorSideNode.position = SCNVector3(0, -verticalOffset, 0)
        floorSideNode.transform = SCNMatrix4Rotate(floorSideNode.transform, .pi / 2, 0, 0, 1)
        scnScene.rootNode.addChildNode(floorSideNode)
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
//        rotateCameraAroundBoardCenter(deltaAngle: -.pi/4)  // move up 45 deg
        rotateCameraAroundBoardCenter(deltaAngle: 0)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    // rotate camera around board x-axis, while continuing to point at board center
    private func rotateCameraAroundBoardCenter(deltaAngle: CGFloat) {
        cameraNode.transform = SCNMatrix4Rotate(cameraNode.transform, Float(deltaAngle), 1, 0, 0)
        let cameraAngle = CGFloat(cameraNode.eulerAngles.x)
        let cameraDistance = max(9.7 * scnView.frame.height / scnView.frame.width, 40)
        cameraNode.position = SCNVector3(0, -cameraDistance * sin(cameraAngle), cameraDistance * cos(cameraAngle))
    }
}
