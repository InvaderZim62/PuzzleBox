//
//  InnerBoxNode.swift
//  PuzzleBox
//
//  Created by Phil Stern on 5/9/22.
//

import UIKit
import SceneKit

class InnerBoxNode: SCNNode {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(width: Double, height: Double, depth: Double, wallThickness: Double) {
        super.init()
        name = "Box"
        createSideWithRails(width: width, height: height, depth: depth, wallThickness: wallThickness, isFront: true)
        createSideWithRails(width: width, height: height, depth: depth, wallThickness: wallThickness, isFront: false)
    }
    
    private func createSideWithRails(width: Double, height: Double, depth: Double, wallThickness: Double, isFront: Bool) {
        let tolerance = 0.9
        let sign: Float = isFront ? 1 : -1
//        let color = isFront ? Wall.outsideColors.last!.withAlphaComponent(0.4) : Wall.outsideColors.last!  // make front panel see-through
        let color = Wall.outsideColors.last!

        let side = SCNBox(width: width, height: height, length: wallThickness, chamferRadius: 0)
        let sideNode = createNodeFrom(geometry: side, withColor: color)
        sideNode.position = SCNVector3(x: 0, y: 0, z: sign * Float((depth - wallThickness) / 2 + Box.gap))
        addChildNode(sideNode)

        let topRail = SCNBox(width: width - 4 * wallThickness, height: tolerance * wallThickness, length: tolerance * wallThickness, chamferRadius: 0)
        let topRailNode = createNodeFrom(geometry: topRail, withColor: Wall.middleColors.last!)
        topRailNode.position = SCNVector3(x: -Float(wallThickness),
                                          y: Float((height - 3 * wallThickness) / 2 + Box.gap),
                                          z: -sign * Float(tolerance * wallThickness))
        sideNode.addChildNode(topRailNode)

        let bottomRail = SCNBox(width: width - 4 * wallThickness, height: tolerance * wallThickness, length: tolerance * wallThickness, chamferRadius: 0)
        let bottomRailNode = createNodeFrom(geometry: bottomRail, withColor: Wall.middleColors.last!)
        bottomRailNode.position = SCNVector3(x: Float(wallThickness),
                                             y: -Float((height - 3 * wallThickness) / 2 + Box.gap),
                                             z: -sign * Float(tolerance * wallThickness))
        sideNode.addChildNode(bottomRailNode)

        let rightRail = SCNBox(width: tolerance * wallThickness, height: height - 4 * wallThickness, length: tolerance * wallThickness, chamferRadius: 0)
        let rightRailNode = createNodeFrom(geometry: rightRail, withColor: Wall.middleColors.last!)
        rightRailNode.position = SCNVector3(x: Float((width - 3 * wallThickness) / 2 + Box.gap),
                                            y: Float(wallThickness),
                                            z: -sign * Float(tolerance * wallThickness))
        sideNode.addChildNode(rightRailNode)

        let leftRail = SCNBox(width: tolerance * wallThickness, height: height - 4 * wallThickness, length: tolerance * wallThickness, chamferRadius: 0)
        let leftRailNode = createNodeFrom(geometry: leftRail, withColor: Wall.middleColors.last!)
        leftRailNode.position = SCNVector3(x: -Float((width - 3 * wallThickness) / 2 + Box.gap),
                                           y: -Float(wallThickness),
                                           z: -sign * Float(tolerance * wallThickness))
        sideNode.addChildNode(leftRailNode)
    }
    
    private func createNodeFrom(geometry: SCNGeometry, withColor color: UIColor) -> SCNNode {
        geometry.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        node.physicsBody = SCNPhysicsBody.kinematic()
        return node
    }
}
