//
//  Bezier.swift
//  Bezier
//
//  Created by tang on 2020/9/20.
//  Copyright © 2020 Tangweichun. All rights reserved.
//

import UIKit

class Bezier {
    
    // a zero coordinate, which is surprisingly useful
    static let ZERO:Coordinate = .zero
     
    var points:[Coordinate] = [],order:Int = 0
    var dims:[String] = [],dimlen:Int = 0
    var _linear:Bool = false,_3d:Bool = false
    var _t1:CGFloat = 0,_t2:CGFloat = 1
    var _lut:[Coordinate] = []
    var dpoints:[[Coordinate]] = []
    var clockwise:Bool = false
    /**
    * Bezier curve constructor. The constructor argument can be one of three things:
    *
    * 1. array/4 of {x:..., y:..., z:...}, z optional
    * 2. numerical array/8 ordered x1,y1,x2,y2,x3,y3,x4,y4
    * 3. numerical array/12 ordered x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4
    *
    */
    
    //verified
    init(coords:Any...) {
        var coordlen:Int? = nil
        var _coords:[Any] = coords
        var _coords_:[[String:Any]] = []
        var _CoordinateInArrayOfFirstArg = false
        var _CoordinateInArg:Bool = false
        if let _ = coords as? [Coordinate] {
            _CoordinateInArg = true
            _coords = []
            coords.forEach { (cd) in
                if let _cd = cd as? Coordinate {
                    _coords.append(_cd.toDic())
                }
            }
        }
        else if let _coords0 = _coords[0] as? [Coordinate] {
            _coords_ = [[String:Any]]()
            _coords0.forEach { (cd) in
                _coords = []
                
                _coords_.append(cd.toDic())
            }
            coordlen = _coords0.count
            _CoordinateInArrayOfFirstArg = true
        }
        
        let ori_args = _CoordinateInArrayOfFirstArg  ? _coords_ : (_CoordinateInArg ? _coords : coords)
        
      
        var args = [CGFloat]()
        
        if let _ = ori_args[0] as? [String:Any] {
            coordlen = ori_args.count
            args += Bezier.getXYZNumbersArrayFrom(arr: ori_args)
        }
        else if let args0 = ori_args[0] as? [Any] {
            if let _ = args0[0] as? [String:Any] {
                coordlen = args0.count
                args += Bezier.getXYZNumbersArrayFrom(arr: args0)
            }
        }
        else {
            args += Bezier.getXYZNumbersArrayFrom(arr: ori_args)
        }
       
        var higher:Bool = false
        let len:Int = args.count
        
        if (coordlen != nil) {
          if (coordlen! > 4) {
            if (ori_args.count != 1) {
              print("Only new Bezier(point[]) is accepted for 4th and higher order curves")
            }
            higher = true
          }
        } else {
            
            if (len != 6 && len != 8 && len != 9 && len != 12) {
                if (ori_args.count != 1) {
                    print("Only new Bezier(point[]) is accepted for 4th and higher order curves")
                }
            }
        }
        var z_Undefined:Bool = false
        if let c0 = ori_args[0] as? [String:Any] {
             z_Undefined = c0["z"] == nil
        }
        else if let c0 = ori_args[0] as? [Any] {
            if let c00 = c0[0] as? [String:Any] {
                z_Undefined = c00["z"] == nil
            }
        }
        self._3d = (!higher && (len == 9 || len == 12)) || (!z_Undefined)
        var _points:[Coordinate] = []
        var idx = 0,step = _3d ? 3 : 2
        while idx < len {
            let point = Coordinate(x: args[idx], y: args[idx + 1], z: self._3d ? args[idx + 2] : nil )
            _points.append(point)
            idx += step
        }
       
        self.order = _points.count - 1
        self.points = _points
        
        self.dims = _3d ? ["x", "y","z"] : ["x","y"]
        self.dimlen = self.dims.count

        ({(curve:Bezier) -> () in
            let _order = curve.order
            let the_points = curve.points
            let a = utils.align(points: the_points, line: Line(p1: the_points[0], p2: the_points[_order]))
            for i in 0..<a.count {
                if (abs(a[i].y) > 0.0001) {
                    curve._linear = false
                    return
                }
            }
            curve._linear = true
        }(self))
        
        self._t1 = 0
        self._t2 = 1
        self.update()
    }
    //verified
    func update(newprint:Any? = nil) {
        // invalidate any precomputed LUT
        self._lut = []
        print(utils.derive(points: self.points, _3d: self._3d))
        self.dpoints = utils.derive(points: self.points, _3d: self._3d)
        self.computedirection()
    }
    //verified
    func computedirection() {
        let _points = self.points
        let angle = utils.angle(o: _points[0], v1: _points[self.order], v2: _points[1])
        self.clockwise = angle > 0
    }
    //verified
    func length() -> CGFloat {
        return utils.length(derivativeFn: self.derivative)
    }
    //verified
    func derivative(t:CGFloat) -> Coordinate {
        print(self.dpoints.count)
        var mt = 1 - t,
        a:CGFloat = 0,
        b:CGFloat = 0,
        c:CGFloat = 0,
        p:[Coordinate] = self.dpoints[0]
        if self.order == 2 {
            p = [p[0], p[1], Bezier.ZERO]
            a = mt
            b = t
        }
        else if (self.order == 3) {
            a = mt * mt
            b = mt * t * 2
            c = t * t
        }
        
        var ret = Coordinate(x: a * p[0].x + b * p[1].x + c * p[2].x, y: a * p[0].y + b * p[1].y + c * p[2].y)
        if self._3d {
            //MARK: -- 值得怀疑
            if let p0z:CGFloat = p[0].z,let p1z:CGFloat = p[1].z,let p2z:CGFloat = p[2].z {
                ret.z = (a * p0z) + b * (p1z + c * p2z)
            }
            else{
                print("z:Error from func derivative !")
                ret.z = 0.0
            }
            
        }
        return ret
    }
    //verified(存疑)
    func extrema() -> [String:[CGFloat]] {
      var dims = self.dims,
        result:[String:[CGFloat]] = [:],
        roots:[CGFloat] = [],
        p:[CGFloat] = [],
        mfn:((_ v:Coordinate) -> CGFloat)?;
        
        dims.forEach { (dim) in
 
            mfn  = { (v) -> CGFloat in
                return v.get(str: dim)!
            }
            
            p = self.dpoints[0].map(mfn!)
            result[dim] = utils.droots(p:p)
            if (self.order == 3) {
                p = self.dpoints[1].map(mfn!)
                result[dim] = result[dim]! + utils.droots(p: p)
            }
            result[dim] = result[dim]!.filter { (t) -> Bool in
                return t >= 0 && t <= 1
            }
            //MARK: -- 怀疑，是否100%正确
            //result[dim] = result[dim]!.sorted(by: <)
            result[dim]!.sort(by: <)
            roots = roots + result[dim]!
        }
 
        
        roots = Array(Set(roots))
        roots = roots.sorted(by: <)
        
        result["values"] = roots
        return result
    }
    //verified 孤立的，未使用
    func toSVG(relative:Any? = nil) -> String? {
        if (self._3d) {
            return nil
        }
        var p = self.points,
        x = p[0].x,
        y = p[0].y,
        s:[String] = ["M", "\(x)", "\(y)", "\(self.order == 2 ? "Q" : "C")"],
        last = p.count
        for i in 1..<last {
            s.append("\(p[i].x)")
            s.append("\(p[i].y)")
        }
        return s.joined(separator: " ")
    }
}

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
    static func getABC(n:Int, S:Coordinate, B:Coordinate, E:Coordinate, t:CGFloat = 0.5) -> ABC{
        
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

struct ABC {
    var A:Coordinate
    var B:Coordinate
    var C:Coordinate
}

 
struct Coordinate {
    var x:CGFloat
    var y:CGFloat
    var z:CGFloat?
    
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


