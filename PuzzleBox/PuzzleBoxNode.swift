//
//  PuzzleBoxNode.swift
//  PuzzleBox
//
//  Created by Phil Stern on 5/16/22.
//
//                       y
//              _________|___________
//            /          |           /|
//    length /           |          / |
//          /                      /  |
//         /_____________________ /   |
//         |                     |  ---- x
//         |                     |   /
//  height |          /          |  /
//         |         /           | /
//         |________/____________|/
//                 z
//                 width
//
//  Side orientations after rotating (front and back are parts of inner box):
//
//                     top
//                      ____ y
//                     /|
//         y          z |            y
//         |            x            | z
//    left |____ x             x ____|/ right
//        /             x
//       z              |
//                y ____|
//                     /
//                    z
//                    bottom
//
//  Note: each side node only needs to move along its local y-axis to solve the puzzle
//

import UIKit
import SceneKit

class PuzzleBoxNode: SCNNode {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(length: Double, height: Double, width: Double, wallThickness: Double) {
        super.init()
        name = "Puzzle Box"
        let horizontalOffset = Box.width / 2 - 1.5 * Box.wallThickness
        let verticalOffset = Box.height / 2 - 1.5 * Box.wallThickness
        
        // left and right sides are same, except left outer wall overhangs more (handled inside MovableSideWall with isLeft flag)
        // bottom side is a scaled version of right side ("height" is wallThickness smaller)
        
        let leftSideNode = MovableSideNode(length: Box.length, height: Box.height, wallThickness: Box.wallThickness, isLeft: true)
        leftSideNode.position = SCNVector3(-horizontalOffset - Box.gap, 0, 0)
        addChildNode(leftSideNode)
        
        let rightSideNode = MovableSideNode(length: Box.length, height: Box.height, wallThickness: Box.wallThickness, isLeft: false)
        rightSideNode.transform = SCNMatrix4Rotate(rightSideNode.transform, .pi, 0, 1, 0)  // rotate before setting position, to work on iPad device
        rightSideNode.position = SCNVector3(horizontalOffset + Box.gap, -Box.wallThickness / 2, 0)
        addChildNode(rightSideNode)
        
        let topSideNode = MovableSideNode(length: Box.length, height: Box.width, wallThickness: Box.wallThickness, isLeft: false)
        topSideNode.transform = SCNMatrix4Rotate(topSideNode.transform, -.pi / 2, 0, 0, 1)
        topSideNode.position = SCNVector3(Box.wallThickness / 2, verticalOffset + Box.gap, 0)
        addChildNode(topSideNode)
        
        let bottomSideNode = MovableSideNode(length: Box.length, height: Box.width - Box.wallThickness, wallThickness: Box.wallThickness, isLeft: false)
        bottomSideNode.transform = SCNMatrix4Rotate(bottomSideNode.transform, .pi / 2, 0, 0, 1)
        bottomSideNode.position = SCNVector3(0, -verticalOffset - Box.gap, 0)
        addChildNode(bottomSideNode)
        
        let innerBoxNode = InnerBoxNode(width: Box.width, height: Box.height, depth: Box.length, wallThickness: Box.wallThickness)
        innerBoxNode.position = SCNVector3(0, 0, 0)
        addChildNode(innerBoxNode)
    }
}
