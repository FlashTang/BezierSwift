//
//  Bezier+extensions.swift
//  Bezier
//
//  Created by tang on 2020/9/23.
//  Copyright © 2020 Tangweichun. All rights reserved.
//

import UIKit

extension Bezier {
    func offset(t:CGFloat, d:CGFloat? = nil) -> Any{
 
      if d != nil {
        var c = self.get(t: t);
        var n = self.normal(t: t);
        var ret:[String:Any] = [
              "c": c,
              "n": n,
              "x": c.x + n.x * d!,
              "y": c.y + n.y * d!
         ]
        if (self._3d) {
          ret["z"] = c.z! + n.z! * d!
        }
        return ret
      }
      if (self._linear) { //
        var nv = self.normal(t: 0);
        var coords = self.points.map { (p) -> Coordinate in
            var ret = Coordinate(x: p.x + t * nv.x, y: p.y + t * nv.y)
             //此处原来js版本bug, n.z != nil
            if (p.z != nil && nv.z != nil) {
              ret.z = p.z! + t * nv.z!
            }
            return ret
        }
       
        return [Bezier(coords: coords)]
      }
      var reduced = self.reduce()
    
        return reduced.map { (s) -> Bezier in
            if s._linear {
                return ((s.offset(t: t) as? [Bezier])?[0])!
            }
            else{
                return s.scale(d: t)
            }
        }
//      return reduced.map(function(s) {
//        if (s._linear) {
//          return s.offset(t)[0];
//        }
//        return s.scale(t);
//      });
    }
    
    func reduce() -> [Bezier] {
        var i:Int = 0,
        t1:CGFloat = 0,
        t2:CGFloat = 0,
        step:CGFloat = 0.01,
        segment:Bezier!,
        pass1:[Bezier] = [],
        pass2:[Bezier] = [];
      // first pass: split on extrema
      var _extrema = self.extrema()["values"]!
        
        if _extrema.firstIndex(of: 0) == nil{
            _extrema = [0] + _extrema
        }
        
        if _extrema.firstIndex(of: 1) == nil{
            _extrema = _extrema + [1]
        }
 
       t1 = _extrema[0]
        i = 1
        while i < _extrema.count {
            t2 = _extrema[i]
            segment = self.split(t1: t1, t2: t2) as? Bezier
            segment._t1 = t1
            segment._t2 = t2
            pass1.append(segment!)
            t1 = t2
            i += 1
        }
        
       
      // second pass: further reduce these segments to simple segments
        
        pass1.forEach { (p1) in
            t1 = 0
            t2 = 0
            while (t2 <= 1) {
              t2 = t1 + step
              while t2 <= 1 + step {
                segment = p1.split(t1: t1, t2: t2) as? Bezier
                if (!segment.simple()) {
                  t2 -= step;
                  if (abs(t1 - t2) < step) {
                    // we can never form a reduction
                    //怀疑处 值得关注
                    //return // []
                  }
                    segment = p1.split(t1: t1, t2: t2) as? Bezier
                    segment._t1 = utils.map(v: t1, ds: 0, de: 1, ts: p1._t1, te: p1._t2);
                    segment._t2 = utils.map(v: t2, ds: 0, de: 1, ts: p1._t1, te: p1._t2);
                    pass2.append(segment!)
                  t1 = t2;
                  break;
                }
                t2 += step
              }
            }
            if (t1 < 1) {
                segment = p1.split(t1: t1, t2: 1) as? Bezier;
                segment._t1 = utils.map(v: t1, ds: 0, de: 1, ts: p1._t1, te: p1._t2);
              segment._t2 = p1._t2;
                pass2.append(segment!)
            }
        }
       
      return pass2
    }
    
    func simple() -> Bool {
      if (self.order == 3) {
        let a1 = utils.angle(o: self.points[0], v1: self.points[3], v2: self.points[1]);
        let a2 = utils.angle(o: self.points[0], v1: self.points[3], v2: self.points[2]);
        if ((a1 > 0 && a2 < 0) || (a1 < 0 && a2 > 0)) {
            return false
        }
      }
        let n1 = self.normal(t: 0)
        let n2 = self.normal(t: 1)
      var s = n1.x * n2.x + n1.y * n2.y
      if (self._3d) {
        s += n1.z! * n2.z!
      }
      let angle = abs(acos(s))
        return angle < CGFloat.pi / 3
    }
    
 
}
