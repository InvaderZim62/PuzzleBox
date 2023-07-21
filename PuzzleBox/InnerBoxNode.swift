//
//  InnerBoxNode.swift
//  PuzzleBox
//
//  Created by Phil Stern on 5/9/22.
//            ________________   __
//           ----------------|  -- thickness     ---------------------------
//           |              ||                   | ===================  || |
//         ________________ ||                   |                      || |
//        ----------------| |/  __               | ||       rails       || |
//        |              ||--    /               | ||   (inside face)   || |
// height |     front    ||     / depth          | ||                      |
//        |              |/    /                 | ||  ==================  |
//        ----------------   --                  ---------------------------
//             width
//

import UIKit
import SceneKit

class InnerBoxNode: SCNNode {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(width: Double, height: Double, depth: Double, wallThickness: Double) {
        super.init()
        name = "Inner Box"
        createSideWithRails(width: width, height: height, depth: depth, wallThickness: wallThickness, isFront: true)
        createSideWithRails(width: width, height: height, depth: depth, wallThickness: wallThickness, isFront: false)
    }
    
    // Note: sideNode is added to InnerBoxNode, railNodes are added to sideNode
    private func createSideWithRails(width: Double, height: Double, depth: Double, wallThickness: Double, isFront: Bool) {
        let sign: Float = isFront ? 1 : -1
//        let color = isFront ? Box.sideColors[4].withAlphaComponent(0.4) : Box.sideColors[4]  // make front panel see-through
        let color: UIColor = isFront ? Box.sideColors[4] : Box.sideColors[5]

        let side = SCNBox(width: width, height: height, length: wallThickness, chamferRadius: 0)
        let sideNode = createNodeFrom(geometry: side, withColor: color)
        sideNode.position = SCNVector3(x: 0, y: 0, z: sign * Float((depth - wallThickness) / 2 + Box.gap))
        addChildNode(sideNode)

        let topRail = SCNBox(width: width - 4 * wallThickness, height: Box.tolerance * wallThickness, length: Box.tolerance * wallThickness, chamferRadius: 0)
        let topRailNode = createNodeFrom(geometry: topRail, withColor: Box.railColor)
        topRailNode.position = SCNVector3(x: -Float(wallThickness),
                                          y: Float((height - 3 * wallThickness) / 2 + Box.gap),
                                          z: -sign * Float(Box.tolerance * wallThickness))
        sideNode.addChildNode(topRailNode)

        let bottomRail = SCNBox(width: width - 4 * wallThickness, height: Box.tolerance * wallThickness, length: Box.tolerance * wallThickness, chamferRadius: 0)
        let bottomRailNode = createNodeFrom(geometry: bottomRail, withColor: Box.railColor)
        bottomRailNode.position = SCNVector3(x: Float(wallThickness),
                                             y: -Float((height - 3 * wallThickness) / 2 + Box.gap),
                                             z: -sign * Float(Box.tolerance * wallThickness))
        sideNode.addChildNode(bottomRailNode)

        let rightRail = SCNBox(width: Box.tolerance * wallThickness, height: height - 4 * wallThickness, length: Box.tolerance * wallThickness, chamferRadius: 0)
        let rightRailNode = createNodeFrom(geometry: rightRail, withColor: Box.railColor)
        rightRailNode.position = SCNVector3(x: Float((width - 3 * wallThickness) / 2 + Box.gap),
                                            y: Float(wallThickness),
                                            z: -sign * Float(Box.tolerance * wallThickness))
        sideNode.addChildNode(rightRailNode)

        let leftRail = SCNBox(width: Box.tolerance * wallThickness, height: height - 4 * wallThickness, length: Box.tolerance * wallThickness, chamferRadius: 0)
        let leftRailNode = createNodeFrom(geometry: leftRail, withColor: Box.railColor)
        leftRailNode.position = SCNVector3(x: -Float((width - 3 * wallThickness) / 2 + Box.gap),
                                           y: -Float(wallThickness),
                                           z: -sign * Float(Box.tolerance * wallThickness))
        sideNode.addChildNode(leftRailNode)
    }
    
    private func createNodeFrom(geometry: SCNGeometry, withColor color: UIColor) -> SCNNode {
        geometry.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        node.physicsBody = SCNPhysicsBody.kinematic()
        return node
    }
}
