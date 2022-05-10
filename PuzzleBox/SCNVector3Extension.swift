//
//  SCNVector3Extension.swift
//  DominoDraw
//
//  Created by Phil Stern on 4/30/21.
//

import SceneKit

extension SCNVector3 {
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    static func *(lhs: SCNVector3, rhs: Double) -> SCNVector3 {
        return SCNVector3(x: lhs.x * Float(rhs), y: lhs.y * Float(rhs), z: lhs.z * Float(rhs))
    }
    
    // dot product
    static func *(lhs: SCNVector3, rhs: SCNVector3) -> Float {
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
    }

    func distance(from: SCNVector3) -> Float {
        return sqrt(pow(from.x - self.x, 2) + pow(from.y - self.y, 2) + pow(from.z - self.z, 2))
    }
    
    func bearing(from: SCNVector3) -> Double {
        let deltaLat = self.z - from.z
        let deltaLon = self.x - from.x
        return Double(atan2(-deltaLat, deltaLon))
    }
}
