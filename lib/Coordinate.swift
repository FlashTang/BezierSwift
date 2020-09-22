//
//  Coordinate.swift
//  Bezier
//
//  Created by tang on 2020/9/22.
//  Copyright © 2020 Tangweichun. All rights reserved.
//

import UIKit

struct Coordinate {
    var x:CGFloat
    var y:CGFloat
    var z:CGFloat?
    
    var t:CGFloat?
    var d:CGFloat?
    
    init(x:CGFloat,y:CGFloat,z:CGFloat? = nil) {
        self.x = x
        self.y = y
    }
    
    static var zero:Coordinate{
        get{
            return Coordinate(x: 0, y: 0, z: 0)
        }
    }
    
    func get(str:String) -> CGFloat? {
        if str == "x" {
            return self.x
        }
        else if str == "y" {
            return self.y
        }
        else if str == "z" {
            return self.z
        }
        return nil
    }
    
    func toDic() -> [String:Any] {
        if self.z != nil {
            return ["x":self.x,"y":self.y,"z":self.z!]
        }
        else{
            return ["x":self.x,"y":self.y]
        }
    }
    func cgPoint() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }

    
}

struct ABC {
    var A:Coordinate
    var B:Coordinate
    var C:Coordinate
}

struct Line {
    var p1:Coordinate
    var p2:Coordinate
}
