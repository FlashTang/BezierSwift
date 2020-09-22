//
//  Bezier+Static.swift
//  Bezier
//
//  Created by tang on 2020/9/22.
//  Copyright © 2020 Tangweichun. All rights reserved.
//

import UIKit

extension Bezier{
    //verified
    static func quadraticFromPoints(p1:Coordinate, p2:Coordinate, p3:Coordinate, t:CGFloat = 0.5) -> Bezier{
        // shortcuts, although they're really dumb
        if (t == 0) {
            return Bezier(coords: p2, p2, p3)
        }
        else if (t == 1) {
            return Bezier(coords: p1, p2, p2)
        }
        // real fitting.
        let abc = Bezier.getABC(n: 2, S: p1, B: p2, E: p3, t: t)
        //print(abc)
        return Bezier(coords: p1, abc.A, p3)
    }
    //verified
    static func cubicFromPoints(S:Coordinate, B:Coordinate, E:Coordinate, t:CGFloat = 0.5, d1:CGFloat? = nil) -> Bezier{
     
        let abc = Bezier.getABC(n: 3, S: S, B: B, E: E, t: t)
        let _d1 = d1 != nil ? d1! : utils.dist(p1: B, p2: abc.C)
       
        let d2 = _d1 * (1 - t) / t

        let selen = utils.dist(p1: S, p2: E),
        lx = (E.x - S.x) / selen,
        ly = (E.y - S.y) / selen,
        bx1 = _d1 * lx,
        by1 = _d1 * ly,
        bx2 = d2 * lx,
        by2 = d2 * ly;
        // derivation of new hull coordinates
        let e1 = Coordinate(x:  B.x - bx1, y: B.y - by1),
        e2 = Coordinate(x:  B.x + bx2, y: B.y + by2),
        A = abc.A,
        v1 = Coordinate(x: A.x + (e1.x - A.x) / (1 - t), y: A.y + (e1.y - A.y) / (1 - t)),
        v2 = Coordinate(x: A.x + (e2.x - A.x) / t, y: A.y + (e2.y - A.y) / t),
        nc1 = Coordinate(x:S.x + (v1.x - S.x) / t,y:S.y + (v1.y - S.y) / t),
        nc2 = Coordinate(x:E.x + (v2.x - E.x) / (1 - t),y:E.y + (v2.y - E.y) / (1 - t))
        // ...done
        return Bezier(coords: S, nc1, nc2, E)
    }
    //verified
    class func getABC(n:Int, S:Coordinate, B:Coordinate, E:Coordinate, t:CGFloat = 0.5) -> ABC{
        
        let u = utils.projectionratio(t: t, n: n),
        um = 1 - u,
        C = Coordinate(x: u * S.x + um * E.x, y: u * S.y + um * E.y, z: nil),
        s = utils.abcratio(t: t, n: n),
        A = Coordinate(x: B.x + (B.x - C.x) / s, y: B.y + (B.y - C.y) / s, z: nil)

        return ABC(A: A, B: B, C: C)
    }
    
    //verified
    class func getXYZNumbersArrayFrom(arr:[Any]) -> [CGFloat] {
        var numArr:[CGFloat] = []
        arr.forEach { (any) in
            if let S_Any = any as? [String:Any] {
                ["x","y","z"].forEach { (d) in
                    if let n_any = S_Any[d] {
                        let n_str = "\(n_any)"
                        if let num = NumberFormatter().number(from: n_str) {
                            let cg_num = CGFloat(truncating: num)
                            numArr.append(cg_num)
                        }
                    }
                }
            }
            else {
                let n_str = "\(any)"
                if let num = NumberFormatter().number(from: n_str) {
                    let cg_num = CGFloat(truncating: num)
                    numArr.append(cg_num)
                }
            }
        }
        return numArr
    }
}
