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
//  - nothing keeps the children nodes attached to the parent (they can all fall apart under gravity or collisions, if dynamic)
//  - you must set flattenedNode = parentNode.flattenedClone() outside the parent node class (flattening not used in this app)
//  - flattened node's physics body shape does not follow the individual children closely, and can't be adjusted
//  - to see the flattened node's shape, set scnView.debugOptions = SCNDebugOptions.showPhysicsShapes
//  - flattenedClone() requires parent node to implement override init() { super.init() }
//
//  To do...
//  - panel that is not close to perpendicular to camera can be panned through other panels
//

import UIKit
import QuartzCore
import SceneKit

struct Box {
    static let length = 15.0  // web-site dimensions divided by 10
    static let height = 10.0
    static let width = 10.0
    static let wallThickness = 0.5
    static let gap = 0.01
}

class GameViewController: UIViewController, UIGestureRecognizerDelegate {  // delegate needed for func gestureRecognizer (bottom of file)
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    
    var pastLocation = CGPoint.zero
    var isCameraPanning = true
    var sideNodes = [MovableSideNode]()
    var deltaPanWorld = SCNVector3(0, 0, 0)
    var selectedSideNode: MovableSideNode?

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
        
        // require my pan gesture to fail, before allowing camera's pan gesture to work (force my pan to fail in handlePan)
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
//        let leftSideNode = MovableSideNode(width: 2 * Box.width, height: 2 * Box.height, wallThickness: Box.wallThickness, isLeft: true)
        leftSideNode.position = SCNVector3(-horizontalOffset - Box.gap, 0, 0)
        scnScene.rootNode.addChildNode(leftSideNode)
        sideNodes.append(leftSideNode)
        
        let rightSideNode = MovableSideNode(width: Box.width, height: Box.height, wallThickness: Box.wallThickness, isLeft: false)
//        let rightSideNode = MovableSideNode(width: 2 * Box.width, height: 2 * Box.height, wallThickness: Box.wallThickness, isLeft: false)
        rightSideNode.transform = SCNMatrix4Rotate(rightSideNode.transform, .pi, 0, 1, 0)  // rotate before setting position, to work on iPad device
        rightSideNode.position = SCNVector3(horizontalOffset + Box.gap, -Box.wallThickness / 2, 0)
        scnScene.rootNode.addChildNode(rightSideNode)
        sideNodes.append(rightSideNode)

        let topSideNode = MovableSideNode(width: Box.width, height: Box.length, wallThickness: Box.wallThickness, isLeft: false)
        topSideNode.transform = SCNMatrix4Rotate(topSideNode.transform, -.pi / 2, 0, 0, 1)
        topSideNode.position = SCNVector3(Box.wallThickness / 2, verticalOffset + Box.gap, 0)
        scnScene.rootNode.addChildNode(topSideNode)
        sideNodes.append(topSideNode)

        let floorSideNode = MovableSideNode(width: Box.width, height: Box.length - Box.wallThickness, wallThickness: Box.wallThickness, isLeft: false)
        floorSideNode.transform = SCNMatrix4Rotate(floorSideNode.transform, .pi / 2, 0, 0, 1)
        floorSideNode.position = SCNVector3(0, -verticalOffset - Box.gap, 0)
        scnScene.rootNode.addChildNode(floorSideNode)
        sideNodes.append(floorSideNode)
        
        let boxNode = InnerBoxNode(width: Box.length, height: Box.height, depth: Box.width, wallThickness: Box.wallThickness)
        boxNode.position = SCNVector3(0, 0, 0)
        scnScene.rootNode.addChildNode(boxNode)
    }
    
    // MARK: - Gesture actions
    
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
        let location = recognizer.location(in: scnView)  // screen coordinates
        if let tappedSideNode = getSideNodeAt(location) {
            // pan started on a side node (toggle its selection)
            selectedSideNode = tappedSideNode
        } else {
            // pan started off of a side node (deselect all side nodes)
            selectedSideNode = nil
            recognizer.state = .failed  // force my pan gesture to fail, so camera's pan gesture can take over
            return
        }
        if let selectedSideNode = selectedSideNode {
            // move selected side
            switch recognizer.state {
            case .changed:
                // move selectedSideNode to pan location (moves in plane of surface being touched)
                if let sideCoordinates = getSideCoordinatesAt(location), let pastSideCoordinates = getSideCoordinatesAt(pastLocation) {
                    let deltaPanLocal = sideCoordinates.local - pastSideCoordinates.local
                    deltaPanWorld = sideCoordinates.world - pastSideCoordinates.world
//                    print(deltaPanWorld)
                    selectedSideNode.localTranslate(by: deltaPanLocal)  // contacts are prevented in render, below
                }
            default:
                break
            }
        }
        pastLocation = location
    }
    
    // convert from screen to local (sideNode) and world (scene) coordinates
    private func getSideCoordinatesAt(_ location: CGPoint) -> (local: SCNVector3, world: SCNVector3)? {
        var sideCoordinates: (SCNVector3, SCNVector3)?
        let hitResults = scnView.hitTest(location, options: [.searchMode: SCNHitTestSearchMode.all.rawValue])
        if let result = hitResults.first(where: { $0.node.parent == selectedSideNode }) {  // must be touching selectedSideNode
            sideCoordinates = (result.localCoordinates, result.worldCoordinates)
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
        scnView.delegate = self  // needed for renderer, below
    }
    
    private func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = "Background_Diffuse.png"
        scnView.scene = scnScene
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        rotateCameraAroundBoardCenter(deltaAngle: -.pi/4)  // move up 45 deg (looking down)
        scnScene.rootNode.addChildNode(cameraNode)
    }

    // rotate camera around scene x-axis, while continuing to point at scene center
    private func rotateCameraAroundBoardCenter(deltaAngle: CGFloat) {
        cameraNode.transform = SCNMatrix4Rotate(cameraNode.transform, Float(deltaAngle), 1, 0, 0)
        let cameraAngle = CGFloat(cameraNode.eulerAngles.x)
        let cameraDistance = CGFloat(3 * Box.length)
        cameraNode.position = SCNVector3(0, -cameraDistance * sin(cameraAngle), cameraDistance * cos(cameraAngle))
    }

    // MARK: - UIGestureRecognizerDelegate
    
    // allow two simultaneous pan gesture recognizers (mine and the camera's)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension GameViewController: SCNSceneRendererDelegate {  // requires scnView.delegate = self
    
    // use willRenderScene, to prevent contacts before they render (prevents jitter)
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        preventContacts()
    }
    
    // if contact is made, back it out by amount of penetration
    // from: https://stackoverflow.com/questions/46843254
    func preventContacts() {
        if let selectedSideNode = selectedSideNode {
            if let contact = contactWith(selectedSideNode) {
                let penetration = Float(contact.penetrationDistance)
                let transform = SCNMatrix4MakeTranslation((contact.contactNormal.x) * penetration,
                                                          (contact.contactNormal.y) * penetration,
                                                          (contact.contactNormal.z) * penetration)
                selectedSideNode.transform = SCNMatrix4Mult(selectedSideNode.transform, transform)
                deltaPanWorld = SCNVector3(0, 0, 0)
            }
        }
    }
    
    // return contact if any child of input node is contacting a node not belonging to its parent (non-sibling)
    private func contactWith(_ parentNode: MovableSideNode) -> SCNPhysicsContact? {
        for childNode in parentNode.childNodes {
            let contacts = scnScene.physicsWorld.contactTest(with: childNode.physicsBody!, options: nil)
            for contact in contacts {
                if contact.nodeA.parent != parentNode || contact.nodeB.parent != parentNode {
                    if contact.contactNormal * deltaPanWorld < -0.01 {
                        // contact is in opposite direction of pan by a sufficient threshold
//                        print(contact.contactNormal, deltaPanWorld, contact.contactNormal * deltaPanWorld)
                        return contact
                    }
                }
            }
        }
        return nil
    }
}
