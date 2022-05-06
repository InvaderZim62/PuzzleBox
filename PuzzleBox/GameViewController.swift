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
//  Lessons learned:
//  - parent node's physics properties don't propagate to children (set each child separately)
//  - nothing keeps the children nodes attached to the parent (they can all fall apart under gravity or collisions)
//  - you must set flattenedNode = parentNode.flattenedClone() outside the parent node class
//  - flattened node's physics body shape does not follow the individual children closely, and can't be adjusted
//  - to see the flattened node's shape, set scnView.debugOptions = SCNDebugOptions.showPhysicsShapes
//  - flattenedClone() requires parent node to implement override init() { super.init() }
//

import UIKit
import QuartzCore
import SceneKit

struct Box {
    static let length = 15.0  // web-site dimensions divided by 10
    static let height = 10.0
    static let width = 10.0
    static let wallThickness = 0.5
}

class GameViewController: UIViewController, UIGestureRecognizerDelegate {  // delegate needed for func gestureRecognizer (bottom of file)
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    
    var pastLocation = CGPoint.zero
    var isCameraPanning = true
    var sideNodes = [MovableSideNode]()
    var selectedSideNode: MovableSideNode? {
        didSet {
            sideNodes.forEach { $0.resetColor() }  // reset all colors, before highlighting selected node (if any)
            if let selectedNode = selectedSideNode {
                selectedNode.highlightColor()
                isCameraPanning = false  // don't allow camera panning when a side node is selected
            } else {
                isCameraPanning = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        createPuzzleBox()
        
        // add gestures to scnView
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.maximumNumberOfTouches = 1  // prevents panning during rotation
        pan.delegate = self  // allows system to call gestureRecognizer (bottom of file)
        scnView.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.require(toFail: pan)  // prevents tap from being called right before pan gesture ends (deselecting side node)
        scnView.addGestureRecognizer(tap)
        
        // require my pan gesture to fail, before allowing camera's pan gesture to work (force my pan to fail in handlePan, if isCameraPanning)
        let panGestures = scnView.gestureRecognizers!.filter { $0 is UIPanGestureRecognizer } as! [UIPanGestureRecognizer]  // my pan and default camera pan
        if !panGestures.isEmpty {
            let cameraPanGesture = panGestures.first!
            cameraPanGesture.require(toFail: pan)
        }
    }
    
    private func createPuzzleBox() {
        let horizontalOffset = Box.length / 2 - 1.5 * Box.wallThickness
        let verticalOffset = Box.height / 2 - 1.5 * Box.wallThickness

        let leftSideNode = MovableSideNode(width: Box.width, height: Box.height, wallThickness: Box.wallThickness, isLeft: true)
        leftSideNode.position = SCNVector3(-horizontalOffset, 0, 0)
        scnScene.rootNode.addChildNode(leftSideNode)
        sideNodes.append(leftSideNode)
        
        let rightSideNode = MovableSideNode(width: Box.width, height: Box.height, wallThickness: Box.wallThickness, isLeft: false)
        rightSideNode.transform = SCNMatrix4Rotate(rightSideNode.transform, .pi, 0, 1, 0)  // rotate before setting position, to work on iPad device
        rightSideNode.position = SCNVector3(horizontalOffset, -Box.wallThickness / 2, 0)
        scnScene.rootNode.addChildNode(rightSideNode)
        sideNodes.append(rightSideNode)

        let topSideNode = MovableSideNode(width: Box.width, height: Box.length, wallThickness: Box.wallThickness, isLeft: false)
        topSideNode.transform = SCNMatrix4Rotate(topSideNode.transform, -.pi / 2, 0, 0, 1)
        topSideNode.position = SCNVector3(Box.wallThickness / 2, verticalOffset, 0)
        scnScene.rootNode.addChildNode(topSideNode)
        sideNodes.append(topSideNode)

        let floorSideNode = MovableSideNode(width: Box.width, height: Box.length - Box.wallThickness, wallThickness: Box.wallThickness, isLeft: false)
        floorSideNode.transform = SCNMatrix4Rotate(floorSideNode.transform, .pi / 2, 0, 0, 1)
        floorSideNode.position = SCNVector3(0, -verticalOffset, 0)
        scnScene.rootNode.addChildNode(floorSideNode)
        sideNodes.append(floorSideNode)
    }
    
    // MARK: - Gesture actions

    // if tap on side node, toggle between selecting and deselecting it (all others are deselected)
    // if tap on nothing, deselect all
    @objc func handleTap(recognizer: UITapGestureRecognizer) {  // Note: system calls tap gesture at start of pan gesture
        let location = recognizer.location(in: scnView)
        if let tappedSideNode = getSideNodeAt(location) {
            // a side node was tapped (toggle its selection)
            selectedSideNode = selectedSideNode == tappedSideNode ? nil : tappedSideNode
        } else {
            // nothing was tapped (deselect all side nodes)
            selectedSideNode = nil
        }
    }
    
    // get side node at location provided by tap gesture
    private func getSideNodeAt(_ location: CGPoint) -> MovableSideNode? {
        var sideNode: MovableSideNode?
        let hitResults = scnView.hitTest(location, options: nil)  // nil returns closest hit
        if let result = hitResults.first(where: { $0.node.parent?.name == "Side" }) {
            sideNode = result.node.parent as? MovableSideNode
        }
        return sideNode
    }

    // if a side is selected, move it along pan gesture
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if isCameraPanning {
            recognizer.state = .failed  // force my pan gesture to fail, so camera's pan gesture can take over
            return
        }
        let location = recognizer.location(in: scnView)
        if let pannedSideNode = selectedSideNode {
            // move selected side
            switch recognizer.state {
            case .changed:
                // move pannedSideNode to pan location (moves in plane of surface being touched)
                if let sideCoordinates = getSideCoordinatesAt(location), let pastSideCoordinates = getSideCoordinatesAt(pastLocation) {
                    let deltaSideCoordinates = sideCoordinates - pastSideCoordinates
                    pannedSideNode.localTranslate(by: deltaSideCoordinates)
                }
            case .ended, .cancelled:
                break
            default:
                break
            }
        }
        pastLocation = location
    }
    
    // convert from screen to selected side coordinates
    private func getSideCoordinatesAt(_ location: CGPoint) -> SCNVector3? {
        var sideCoordinates: SCNVector3?
        let hitResults = scnView.hitTest(location, options: [.searchMode: SCNHitTestSearchMode.all.rawValue])
        if let result = hitResults.first(where: { $0.node.parent == selectedSideNode }) {  // must be touching selectedSideNode
            sideCoordinates = result.localCoordinates
        }
        return sideCoordinates
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
        cameraNode.position = SCNVector3(0, 0, 3 * Box.length)
        scnScene.rootNode.addChildNode(cameraNode)
    }

    // MARK: - UIGestureRecognizerDelegate
    
    // allow two simultaneous pan gesture recognizers (mine and the camera's)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
