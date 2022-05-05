//
//  MovableSideNode.swift
//  PuzzleBox
//
//  Created by Phil Stern on 5/4/22.
//

import UIKit
import SceneKit

struct Wall {
    static let outsideColors = [#colorLiteral(red: 0.5229098201, green: 0.3702836037, blue: 0.2074212134, alpha: 1), #colorLiteral(red: 0.6524503827, green: 0.4620540142, blue: 0.2582799792, alpha: 1), #colorLiteral(red: 0.7442863584, green: 0.5344663858, blue: 0.3011149168, alpha: 1), #colorLiteral(red: 0.8364808559, green: 0.6006908417, blue: 0.3381323516, alpha: 1)]
    static let middleColors = [#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1), #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1), #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1), #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)]
    static let insideColors = [#colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1), #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)]
}

class MovableSideNode: SCNNode {
    
    static var number = 0

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(width: Double, height: Double, wallThickness: Double, isLeft: Bool) {
        super.init()
        let outsideHeight = isLeft ? height : height - wallThickness
        let yPosition = isLeft ? Float(wallThickness) / 2 : 0
        
        let outside = SCNBox(width: wallThickness, height: outsideHeight, length: width - 2 * wallThickness, chamferRadius: 0)
        outside.firstMaterial?.diffuse.contents = Wall.outsideColors[MovableSideNode.number]
        let outsideNode = SCNNode(geometry: outside)
        outsideNode.position = SCNVector3(x: -Float(wallThickness), y: 0, z: 0)
        outsideNode.physicsBody = SCNPhysicsBody.static()
        addChildNode(outsideNode)
        
        let middle = SCNBox(width: wallThickness, height: height - 3 * wallThickness, length: width - 4 * wallThickness, chamferRadius: 0)
        middle.firstMaterial?.diffuse.contents = Wall.middleColors[MovableSideNode.number]
        let middleNode = SCNNode(geometry: middle)
        middleNode.position = SCNVector3(x: 0, y: yPosition, z: 0)
        middleNode.physicsBody = SCNPhysicsBody.static()
        addChildNode(middleNode)
        
        let inside = SCNBox(width: wallThickness, height: height - 5 * wallThickness, length: width - 2 * wallThickness, chamferRadius: 0)
        inside.firstMaterial?.diffuse.contents = Wall.insideColors[MovableSideNode.number]
        let insideNode = SCNNode(geometry: inside)
        insideNode.position = SCNVector3(x: Float(wallThickness), y: yPosition, z: 0)
        insideNode.physicsBody = SCNPhysicsBody.static()
        addChildNode(insideNode)
        
        MovableSideNode.number += 1
    }
}
