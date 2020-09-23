//
//  Bezier+extensions_2.swift
//  Bezier
//
//  Created by tang on 2020/9/24.
//  Copyright © 2020 Tangweichun. All rights reserved.
//

import UIKit

extension Bezier {
        func scale(d:Any? = nil) -> Bezier {
          var _order = self.order
            var distanceFn:Any? = false
            var d_float:CGFloat = 0
            if let _df = d as? CGFloat {
                d_float = _df
            }
            else if let _d_int = d as? Int {
                d_float = CGFloat(_d_int)
            }
            else{
               distanceFn = d!
            }
          if d != nil {
              distanceFn = d!
          }
            if (distanceFn != nil && _order == 2) {
                let r = self.raise()
                return r.scale(d: distanceFn)
          }

          // TODO: add special handling for degenerate (=linear) curves.
          var _clockwise = self.clockwise
            var _distanceFn =  distanceFn as? (_ v:CGFloat) -> CGFloat
          var r1 = _distanceFn != nil ? _distanceFn!(0) : d_float
          var r2 = _distanceFn != nil ? _distanceFn!(1) : d_float
            var v:[[String:Any]] = [self.offset(t: 0, d: 10) as! [String:Any], self.offset(t: 1, d: 10) as! [String:Any]]
            var p_1 = CGPoint(x: v[0]["x"] as! CGFloat, y: v[0]["y"] as! CGFloat)
            var p_2_c = (v[0]["c"] as! Coordinate).cgPoint()
            var p_2 = CGPoint(x: v[1]["x"] as! CGFloat, y: v[1]["y"] as! CGFloat)
            var p_4_c = (v[1]["c"] as! Coordinate).cgPoint()
            var o = utils.lli4(p1: p_1, p2: p_2_c, p3: p_2, p4: p_4_c)
          if (o == nil) {
            print("cannot scale this curve. Try reducing it first.")
          }
          // move all points by distance 'd' wrt the origin 'o'
          var _points = self.points,
            np:[Coordinate] = [.zero,.zero,.zero,.zero]
    
          // move end points by fixed distance along normal.
            [0,1].forEach { (t) in
                np[t * order] = _points[t * order]
                let _vt_n = (v[t]["n"] as! Coordinate).cgPoint()
                np[t * order].x += (t > 0 ? r2 : r1) * _vt_n.x
                np[t * order].y += (t > 0 ? r2 : r1) * _vt_n.y
            }
          
    
          if ("\(distanceFn!)" != "false") {
            // move control points to lie on the intersection of the offset
            // derivative vector, and the origin-through-control vector
            [0,1].forEach { (t) in
                if (self.order == 2 && t != 0) {
                    return
                }
                var p = np[t * order]
                var d = self.derivative(t: CGFloat(t));
                var p2 = CGPoint(x: p.x + d.x, y:  p.y + d.y)
                np[t + 1] = utils.lli4(p1: p.cgPoint(), p2: p2, p3: o!, p4: _points[t + 1].cgPoint())!.toCoordinate()
            }
           
            return Bezier(coords: np)
          }
    
          // move control points by "however much necessary to
          // ensure the correct tangent to endpoint".
            [0,1].forEach { (t) in
                if (self.order == 2 && t != 0) {
                    return
                }
                var p = points[t + 1]
                var ov = Coordinate(x: p.x - o!.x, y: p.y - o!.y)// {
                
                var rc = _distanceFn != nil ? _distanceFn!(CGFloat((t + 1) / order)) : d_float
                if ("\(distanceFn!)" != "false" && !self.clockwise) {
                    rc = -rc
                }
                var m = sqrt(ov.x * ov.x + ov.y * ov.y)
                ov.x /= m;
                ov.y /= m;
                np[t + 1] = Coordinate(x: p.x + rc * ov.x, y: p.y + rc * ov.y)
            }
          
            return Bezier(coords: np);
        }
        
        func raise() -> Bezier{
          var p = self.points,
            np = [p[0]],
            i:Int = 1,
            k:Int = p.count
           
            
            while i < k {
               
                let k_i:CGFloat = CGFloat(k - 1)
                let pi_x = p[i].x
                let pi_y = p[i].y
                let pim_x = p[i - 1].x
                let pim_y = p[i - 1].y
                let k_pi_x = CGFloat(k) * pi_x
                let k_pi_y = CGFloat(k) * pi_y
                let k_pim_x = CGFloat(k) * pim_x
                let k_pim_y = CGFloat(k) * pim_y
                let __x = (k_i / k_pi_x) + (CGFloat(i) / k_pim_x)
                let __y = (k_i / k_pi_y) + (CGFloat(i) / k_pim_y)
                np.append(Coordinate(x: __x, y: __y))
               //np[i] = Coordinate(x: (k - i) / k * pi.x + i / k * pim.x, y: (k - i) / k * pi.y + i / k * pim.y)
                i += 1
            }
            np.append(p[k - 1])
          //np[k] = p[k - 1]
            return Bezier(coords:np)
        }
}
