//
//  MovableSideNode.swift
//  PuzzleBox
//
//  Created by Phil Stern on 5/4/22.
//

import UIKit
import SceneKit

struct Wall {
    static let outsideColors = [#colorLiteral(red: 0.5229098201, green: 0.3702836037, blue: 0.2074212134, alpha: 1), #colorLiteral(red: 0.6524503827, green: 0.4620540142, blue: 0.2582799792, alpha: 1), #colorLiteral(red: 0.7442863584, green: 0.5344663858, blue: 0.3011149168, alpha: 1), #colorLiteral(red: 0.8364808559, green: 0.6006908417, blue: 0.3381323516, alpha: 1)]  // one for each side
    static let middleColors = [#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1), #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1), #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1), #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)]
    static let insideColors = [#colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1), #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)]
    static let highlightColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
}

class MovableSideNode: SCNNode {
    
    static var numberFactory = 0
    
    private var number = 0  // index into color arrays
    private var outside = SCNBox()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(width: Double, height: Double, wallThickness: Double, isLeft: Bool) {
        super.init()
        name = "Side"
        number = MovableSideNode.numberFactory
        MovableSideNode.numberFactory += 1
        let outsideHeight = isLeft ? height : height - wallThickness
        let yPosition = isLeft ? Float(wallThickness) / 2 : 0
        
        outside = SCNBox(width: wallThickness, height: outsideHeight, length: width - 2 * wallThickness, chamferRadius: 0)
        let outsideNode = createNodeFrom(geometry: outside, withColor: Wall.outsideColors[number])
        outsideNode.position = SCNVector3(x: -Float(wallThickness), y: 0, z: 0)
        
        let middle = SCNBox(width: wallThickness, height: height - 3 * wallThickness, length: width - 4 * wallThickness, chamferRadius: 0)
        let middleNode = createNodeFrom(geometry: middle, withColor: Wall.middleColors[number])
        middleNode.position = SCNVector3(x: 0, y: yPosition, z: 0)
        
        let inside = SCNBox(width: wallThickness, height: height - 5 * wallThickness, length: width - 2 * wallThickness, chamferRadius: 0)
        let insideNode = createNodeFrom(geometry: inside, withColor: Wall.insideColors[number])
        insideNode.position = SCNVector3(x: Float(wallThickness), y: yPosition, z: 0)
    }
    
    private func createNodeFrom(geometry: SCNGeometry, withColor color: UIColor) -> SCNNode {
        geometry.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        node.physicsBody = SCNPhysicsBody.kinematic()
        addChildNode(node)
        return node
    }
    
    func highlightColor() {
        outside.firstMaterial?.diffuse.contents = Wall.highlightColor
    }
    
    func resetColor() {
        outside.firstMaterial?.diffuse.contents = Wall.outsideColors[number]
    }
}
