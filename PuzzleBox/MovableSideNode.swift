//
//  MovableSideNode.swift
//  PuzzleBox
//
//  Created by Phil Stern on 5/4/22.
//
//             y
//             |__
//            /| /|
//    length / |/ |
//          /  /  |
//         /__/   |
//         |  |  ---- x
//         |  |   /
//  height | /|  /
//         |/ | /
//         /__|/
//        z
//      thickness
//

import UIKit
import SceneKit

class MovableSideNode: SCNNode {
    
    private static var numberFactory = 0
    private var sideNumber = 0  // index into color arrays

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(length: Double, height: Double, wallThickness: Double, isLeft: Bool) {
        super.init()
        name = "Side"
        sideNumber = MovableSideNode.numberFactory
        MovableSideNode.numberFactory += 1
        let outsideHeight = isLeft ? height : height - wallThickness
        let yPosition = isLeft ? Float(wallThickness) / 2 : 0
        
        let outside = SCNBox(width: wallThickness, height: outsideHeight, length: length - 2 * wallThickness, chamferRadius: 0)
        let outsideNode = createNodeFrom(geometry: outside, withColor: Box.sideColors[sideNumber])
        outsideNode.position = SCNVector3(x: -Float(wallThickness), y: 0, z: 0)
        
        let middle = SCNBox(width: wallThickness, height: height - 3 * wallThickness, length: length - 4 * wallThickness, chamferRadius: 0)
        let middleNode = createNodeFrom(geometry: middle, withColor: Box.sideColors[sideNumber])
        middleNode.position = SCNVector3(x: 0, y: yPosition, z: 0)
        
        let inside = SCNBox(width: wallThickness, height: height - 5 * wallThickness, length: length - 2 * wallThickness, chamferRadius: 0)
        let insideNode = createNodeFrom(geometry: inside, withColor: Box.sideColors[sideNumber])
        insideNode.position = SCNVector3(x: Float(wallThickness), y: yPosition, z: 0)
    }
    
    private func createNodeFrom(geometry: SCNGeometry, withColor color: UIColor) -> SCNNode {
        geometry.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        node.physicsBody = SCNPhysicsBody.kinematic()
        addChildNode(node)
        return node
    }
}
