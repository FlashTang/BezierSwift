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
    var ratios:[CGFloat]?
    var _print:String = ""
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
    
    //孤立的，未使用
    func setRatios(ratios:[CGFloat]) {
        if (ratios.count != self.points.count) {
            print("incorrect number of ratio values")
        }
        self.ratios = ratios
        self._lut = [] //  invalidate any precomputed LUT
    }
    //verified
    func compute(t:CGFloat) -> Coordinate {
        if (self.ratios != nil && self.ratios!.count > 0) {
            return utils.computeWithRatios(t: t, points: self.points, ratios: self.ratios!, _3d: self._3d)
        }
        return utils.compute(t: t, points: self.points, _3d: self._3d)
        
    }
    func coordDigest() -> String {
      
        var pri = ""
        for (i,c) in self.points.enumerated() {
            pri = "\(pri)\(i)\(c.x)\(c.y)\(c.z != nil ? c.z! : 0)"
        }
        return pri
//      return this.points.map(function(c,pos) {
//        return '' + pos + c.x + c.y + (c.z?c.z:0);
//      }).join('');
    }
    func verify() {
      let print = self.coordDigest()
      if (print != self._print) {
        self._print = print
        self.update()
      }
    }
    func getLUT(steps:Int = 100) -> [Coordinate] {
      self.verify()
      var _steps = steps
      if (self._lut.count == _steps) {
        return self._lut
      }
      self._lut = []
      // We want a range from 0 to 1 inclusive, so
      // we decrement and then use <= rather than <:
      _steps -= 1
        var __t:Int = 0
        while __t <= _steps {
            self._lut.append(self.compute(t: CGFloat(__t) / CGFloat(_steps)))
            __t += 1
      }
      return self._lut
    }
    func project(point:Coordinate) -> Coordinate {
      // step 1: coarse check
      var LUT = self.getLUT(),
        l:CGFloat = CGFloat(LUT.count - 1),
        closest = utils.closest(LUT: LUT, point: point),
        mdist = closest.mdist,
        mpos = closest.mpos

      // step 2: fine check
        var ft:CGFloat,
        t:CGFloat,
        p:Coordinate,
        d:CGFloat,
        t1:CGFloat = (mpos - 1) / l,
        t2:CGFloat = (mpos + 1) / l,
        step:CGFloat = 0.1 / l;
      mdist += 1;
        t = t1
        ft = t
        while t < t2 + step {
            p = self.compute(t: t)
            d = utils.dist(p1: point, p2: p)
                   if (d < mdist) {
                     mdist = d
                     ft = t
                   }
            t += step
        }
     
        p = self.compute(t: ft)
      p.t = ft
      p.d = mdist
      return p
    }
    
    
}





 


