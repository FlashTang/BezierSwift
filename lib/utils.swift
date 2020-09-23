//
//  utils.swift
//  Bezier
//
//  Created by tang on 2020/9/21.
//  Copyright © 2020 Tangweichun. All rights reserved.
//

import UIKit

class utils {
    static let Tvalues:[CGFloat] = [
      -0.0640568928626056260850430826247450385909,
      0.0640568928626056260850430826247450385909,
      -0.1911188674736163091586398207570696318404,
      0.1911188674736163091586398207570696318404,
      -0.3150426796961633743867932913198102407864,
      0.3150426796961633743867932913198102407864,
      -0.4337935076260451384870842319133497124524,
      0.4337935076260451384870842319133497124524,
      -0.5454214713888395356583756172183723700107,
      0.5454214713888395356583756172183723700107,
      -0.6480936519369755692524957869107476266696,
      0.6480936519369755692524957869107476266696,
      -0.7401241915785543642438281030999784255232,
      0.7401241915785543642438281030999784255232,
      -0.8200019859739029219539498726697452080761,
      0.8200019859739029219539498726697452080761,
      -0.8864155270044010342131543419821967550873,
      0.8864155270044010342131543419821967550873,
      -0.9382745520027327585236490017087214496548,
      0.9382745520027327585236490017087214496548,
      -0.9747285559713094981983919930081690617411,
      0.9747285559713094981983919930081690617411,
      -0.9951872199970213601799974097007368118745,
      0.9951872199970213601799974097007368118745
    ]

    // Legendre-Gauss weights with n=24 (w_i values, defined by a function linked to in the Bezier primer article)
    static let Cvalues:[CGFloat]  = [
      0.1279381953467521569740561652246953718517,
      0.1279381953467521569740561652246953718517,
      0.1258374563468282961213753825111836887264,
      0.1258374563468282961213753825111836887264,
      0.121670472927803391204463153476262425607,
      0.121670472927803391204463153476262425607,
      0.1155056680537256013533444839067835598622,
      0.1155056680537256013533444839067835598622,
      0.1074442701159656347825773424466062227946,
      0.1074442701159656347825773424466062227946,
      0.0976186521041138882698806644642471544279,
      0.0976186521041138882698806644642471544279,
      0.086190161531953275917185202983742667185,
      0.086190161531953275917185202983742667185,
      0.0733464814110803057340336152531165181193,
      0.0733464814110803057340336152531165181193,
      0.0592985849154367807463677585001085845412,
      0.0592985849154367807463677585001085845412,
      0.0442774388174198061686027482113382288593,
      0.0442774388174198061686027482113382288593,
      0.0285313886289336631813078159518782864491,
      0.0285313886289336631813078159518782864491,
      0.0123412297999871995468056670700372915759,
      0.0123412297999871995468056670700372915759
    ]
    
    static let epsilon:CGFloat = 0.000001
    static let tau:CGFloat = 2 * CGFloat.pi
    
    class func align(points:[Coordinate], line:Line) -> [Coordinate] {
        let tx = line.p1.x
        let ty = line.p1.y
        let a = -atan2(line.p2.y - ty, line.p2.x - tx)

        return points.map { (v) -> Coordinate in
            let _x  = (v.x - tx) * cos(a) - (v.y - ty) * sin(a)
            let _y = (v.x - tx) * sin(a) + (v.y - ty) * cos(a)
            return Coordinate(x: _x, y: _y, z: v.z)
        }

    }
    
    class func derive(points:[Coordinate], _3d:Bool = false) -> [[Coordinate]]{
        var dpoints:[[Coordinate]] = []
        var p:[Coordinate] = points,d = p.count,c = d - 1
        while d > 1 {
            var list:[Coordinate] = []
            var j = 0
            var dpt:Coordinate?
            while j < c {
                let fc:CGFloat = CGFloat(c)
                dpt = Coordinate(x: fc * (p[j + 1].x - p[j].x), y: fc * (p[j + 1].y - p[j].y), z: nil)
                 
                if (_3d) {
                  dpt?.z = fc * (p[j + 1].z! - p[j].z!);
                }
                list.append(dpt!)
                j += 1
            }
           
            dpoints.append(list)
            p = list;
            d -= 1
            c -= 1
        }
      return dpoints
    }
    
    class func angle(o:Coordinate, v1:Coordinate, v2:Coordinate) -> CGFloat {
        let dx1 = v1.x - o.x,
            dy1 = v1.y - o.y,
            dx2 = v2.x - o.x,
            dy2 = v2.y - o.y,
            cross = dx1 * dy2 - dy1 * dx2,
            dot = dx1 * dx2 + dy1 * dy2
        return atan2(cross, dot)
    }
    
    class func projectionratio(t:CGFloat = 0.5, n:Int) -> CGFloat{
        // see u(t) note on http://pomax.github.io/bezierinfo/#abc
        if (n != 2 && n != 3) {
            return -1
        }
        if (t == 0 || t == 1) {
            return t
        }
        let top = pow(1 - t, CGFloat(n))
        let bottom = pow(t, CGFloat(n)) + top
        return top / bottom
    }
    
    class func length (derivativeFn:(_ t:CGFloat) -> Coordinate) -> CGFloat {
        var z:CGFloat = 0.5,
        sum:CGFloat = 0,
        len:Int = utils.Tvalues.count,
        t:CGFloat;
        for i in 0..<len {
            t = z * utils.Tvalues[i] + z
            sum += utils.Cvalues[i] * utils.arcfn(t: t, derivativeFn: derivativeFn)
        }
      
      return z * sum
    }
    
    class func arcfn(t:CGFloat, derivativeFn:(_ t:CGFloat) -> Coordinate) -> CGFloat{
      let d = derivativeFn(t)
      var l = d.x * d.x + d.y * d.y;
      if (d.z != nil) {
        l += d.z! * d.z!
      }
      return sqrt(l)
    }
     
    class func abcratio(t:CGFloat?, n:Int) -> CGFloat{
        // see ratio(t) note on http://pomax.github.io/bezierinfo/#abc
        if (n != 2 && n != 3) {
            return -1
        }
        var _t:CGFloat = 0
        if (t == nil) {
            _t = 0.5
        }else{
            if (t == 0 || t == 1) {
                return t!
            }
            _t = t!
        }
        let bottom = pow(_t, CGFloat(n)) + pow(1 - _t, CGFloat(n))
        let top = bottom - 1
        return abs(top / bottom)
    }
    
    class func dist(p1:Coordinate, p2:Coordinate) -> CGFloat{
        let dx = p1.x - p2.x,
        dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    class func droots(p:[CGFloat]) -> [CGFloat]{
        // quadratic roots are easy
        if (p.count == 3) {
            let a = p[0],
                b = p[1],
                c = p[2],
                d = a - 2 * b + c;
            if (d != 0) {
                let m1 = -sqrt(b * b - a * c),
                m2 = -a + b,
                v1 = -(m1 + m2) / d,
                v2 = -(-m1 + m2) / d;
                return [v1, v2]
            } else if (b != c && d == 0) {
                return [(2 * b - c) / (2 * (b - c))]
            }
                return []
        }

        // linear roots are even easier
        else if (p.count == 2) {
            let a = p[0],
                b = p[1]
            if (a != b) {
                return [a / (a - b)];
            }
            return []
        }
        print("Error from utils.droots,p.count is not 2 or 3")
        return []
    }
    //unused
    class func numberSort(a:CGFloat, b:CGFloat) -> CGFloat{
      return a - b
    }
    
    class func compute(t:CGFloat, points:[Coordinate], _3d:Bool = false) -> Coordinate {
      // shortcuts
      if (t == 0) {
        return points[0]
      }

      let order = points.count - 1

      if (t == 1) {
        return points[order]
      }

      var p = points
      let mt = 1 - t

      // constant?
      if (order == 0) {
        return points[0]
      }
     // var p0 = p[0]
      //var p1 = p[1]
      // linear?
      if (order == 1) {
        
       var ret = Coordinate(x: mt * p[0].x + t * p[1].x, y: mt * p[0].y + t * p[1].y)
        if (_3d) {
          ret.z = mt * p[0].z! + t * p[1].z!
        }
        return ret
      }

//      // quadratic/cubic curve?
        if (order < 4) {
        var mt2 = mt * mt,
            t2 = t * t,
            a:CGFloat = 0,
            b:CGFloat = 0,
            c:CGFloat = 0,
            d:CGFloat = 0
        if (order == 2) {
            p = [p[0], p[1], p[2], Bezier.ZERO]
          a = mt2
          b = mt * t * 2
          c = t2
        }  else if (order == 3) {
          a = mt2 * mt
          b = mt2 * t * 3
          c = mt * t2 * 3
          d = t * t2
        }
        let p0 = p[0],p1 = p[1],p2 = p[2],p3 = p[3]
        let __x = a * p0.x + b * p1.x + c * p2.x + d * p3.x
        let __y = a * p0.y + b * p1.y + c * p2.y + d * p3.y
        var ret = Coordinate(x:__x , y: __y)
        if (_3d) {
        
          ret.z = a * p0.z! + b * p1.z! + c * p2.z! + d * p3.z!
        }
        return ret
       }

      // higher order curves: use de Casteljau's computation
      var dCpts = points //don't need to copy , since it's struct //JSON.parse(JSON.stringify(points));
      while (dCpts.count > 1) {
        for i in 0..<(dCpts.count-1) {
         
            let diZ = dCpts[i].z
          dCpts[i] = Coordinate(x: dCpts[i].x + (dCpts[i + 1].x - dCpts[i].x) * t, y: dCpts[i].y + (dCpts[i + 1].y - dCpts[i].y) * t)
            //MARK: -- 非常值得怀疑，这里js的好像逻辑不对
            if  diZ != nil {
                dCpts[i].z = diZ! + (dCpts[i + 1].z! - diZ!) * t
            }
//          if (typeof dCpts[i].z !== "undefined") {
//            dCpts[i] = dCpts[i].z + (dCpts[i + 1].z - dCpts[i].z) * t;
//          }
        }
        dCpts.removeLast() //dCpts.splice(dCpts.count - 1, 1);
      }
      return dCpts[0]
 
    }
    
    class func computeWithRatios (t:CGFloat, points:[Coordinate], ratios:[CGFloat], _3d:Bool) -> Coordinate{
        var mt = 1 - t, r = ratios, p = points, d:CGFloat
      var f1 = r[0], f2 = r[1], f3 = r[2], f4 = r[3]

      // spec for linear
      f1 *= mt
      f2 *= t

      if (p.count == 2) {
        d = f1 + f2
      
        return  Coordinate(x: (f1 * p[0].x + f2 * p[1].x)/d,y: (f1 * p[0].y + f2 * p[1].y)/d,z: !_3d ? nil : (f1 * p[0].z! + f2 * p[1].z!)/d)
         
      }

      // upgrade to quadratic
      f1 *= mt
      f2 *= 2 * mt
      f3 *= t * t

      if (p.count == 3) {
        d = f1 + f2 + f3
        return Coordinate(x: (f1 * p[0].x + f2 * p[1].x + f3 * p[2].x)/d, y: (f1 * p[0].y + f2 * p[1].y + f3 * p[2].y)/d, z: !_3d ? nil : (f1 * p[0].z! + f2 * p[1].z! + f3 * p[2].z!)/d)

      }

      // upgrade to cubic
      f1 *= mt;
      f2 *= 1.5 * mt
      f3 *= 3 * mt
      f4 *= t * t * t

      if (p.count == 4) {
        d = f1 + f2 + f3 + f4
        return Coordinate(x:(f1 * p[0].x + f2 * p[1].x + f3 * p[2].x + f4 * p[3].x)/d,y:(f1 * p[0].y + f2 * p[1].y + f3 * p[2].y + f4 * p[3].y)/d,z:!_3d ? nil : (f1 * p[0].z! + f2 * p[1].z! + f3 * p[2].z! + f4 * p[3].z!)/d)

      }
       print("错误：来自 computeWithRatios")
       return .zero
    }
    
    class func closest(LUT:[Coordinate], point:Coordinate) -> Closest {
        var mdist:CGFloat = pow(2, 63),
        mpos:CGFloat = 0,
        d:CGFloat = 0
        
        var idx = 0
        LUT.forEach { (p) in
            d = utils.dist(p1: point, p2: p)
            if (d < mdist) {
              mdist = d;
              mpos = CGFloat(idx)
            }
            idx += 1
        }
 
      return Closest(mdist: mdist, mpos: mpos) // { mdist: mdist, mpos: mpos };
    }
    
    class func curvature(t:CGFloat, points:[Coordinate], _3d:Bool, kOnly:Bool = false) -> Curvature {
        let dpoints = utils.derive(points: points)
      let d1 = dpoints[0]
      let d2 = dpoints[1]
        var num:CGFloat,dnm:CGFloat, adk:CGFloat = 0, dk:CGFloat = 0, k:CGFloat=0, r:CGFloat=0

      //
      // We're using the following formula for curvature:
      //
      //              x'y" - y'x"
      //   k(t) = ------------------
      //           (x'² + y'²)^(3/2)
      //
      // from https://en.wikipedia.org/wiki/Radius_of_curvature#Definition
      //
      // With it corresponding 3D counterpart:
      //
      //          sqrt( (y'z" - y"z')² + (z'x" - z"x')² + (x'y" - x"y')²)
      //   k(t) = -------------------------------------------------------
      //                     (x'² + y'² + z'²)^(3/2)
      //

        let d = utils.compute(t: t, points: d1)
        let dd = utils.compute(t: t, points: d2)
      let qdsum = d.x*d.x + d.y*d.y
      if (_3d) {
        num = sqrt(
          pow(d.y * dd.z! - dd.y * d.z!, 2) +
          pow(d.z! * dd.x - dd.z! * d.x, 2) +
          pow(d.x*dd.y - dd.x*d.y, 2)
        )
        dnm = pow(qdsum + d.z! * d.z!, 3/2)
      } else {
        num = d.x*dd.y - d.y*dd.x
        dnm = pow(qdsum, 3/2)
      }

      if (num == 0 || dnm == 0) {
        return Curvature(k: 0, r: 0) //{ k:0, r:0 };
      }

      k = num/dnm
      r = dnm/num

      // We're also computing the derivative of kappa, because
      // there is value in knowing the rate of change for the
      // curvature along the curve. And we're just going to
      // ballpark it based on an epsilon.
      if (!kOnly) {
        // compute k'(t) based on the interval before, and after it,
        // to at least try to not introduce forward/backward pass bias.
        let pk = utils.curvature(t: t-0.001, points: points, _3d: _3d, kOnly: true).k
        let nk = utils.curvature(t: t+0.001, points: points, _3d: _3d, kOnly: true).k
        dk = ((nk-k) + (k-pk))/2
        adk = (abs(nk-k) + abs(k-pk))/2
      }

      return Curvature(k: k, r: r, dk: dk, adk: adk)//{ k: k, r: r, dk: dk, adk:adk, };
    }
    
    class func lerp(r:CGFloat, v1:Coordinate, v2:Coordinate) -> Coordinate {
        var ret = Coordinate(x:v1.x + r * (v2.x - v1.x),y:v1.y + r * (v2.y - v1.y)) // = {
        
        
        //怀疑处
        if v1.z != nil && v2.z != nil {
            ret.z = v1.z! + r * (v2.z! - v1.z!)
        }
//      if (!!v1.z && !!v2.z) {
//        ret.z = v1.z + r * (v2.z - v1.z);
//      }
      return ret
    }
    
    class func map(v:CGFloat, ds:CGFloat, de:CGFloat, ts:CGFloat, te:CGFloat) -> CGFloat {
        let d1 = de - ds,
        d2 = te - ts,
        v2 = v - ds,
        r = v2 / d1
        return ts + d2 * r
    }
    
    class func between(v:CGFloat, m:CGFloat, M:CGFloat) -> Bool {
      return ((m <= v && v <= M) || utils.approximately(a: v, b: m) || utils.approximately(a: v, b: M))
    }
    
    class func approximately(a:CGFloat, b:CGFloat, precision:CGFloat? = nil) -> Bool{
         
        return abs(a - b) <= (precision != nil ? precision! : epsilon)
    }
    
    class func lli8(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat, x3:CGFloat, y3:CGFloat, x4:CGFloat, y4:CGFloat) -> CGPoint?{
      let nx =
          (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4),
        ny = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4),
        d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
      if (d == 0) {
        return nil
      }
      return CGPoint(x: nx / d, y: ny / d)
    }
    
    class func lli4(p1:CGPoint,p2:CGPoint, p3:CGPoint, p4:CGPoint) -> CGPoint? {
      let x1 = p1.x,
        y1 = p1.y,
        x2 = p2.x,
        y2 = p2.y,
        x3 = p3.x,
        y3 = p3.y,
        x4 = p4.x,
        y4 = p4.y;
        return utils.lli8(x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3, x4: x4, y4: y4);
    }
    
    class func lli(v1:Coordinate, v2:Coordinate) -> CGPoint? {
        if let v1c = v1.c,let v2c = v2.c {
            return utils.lli4(p1: v1.cgPoint(), p2: v1c, p3: v2.cgPoint(), p4: v2c)
        }
        else{
            return nil
        }
        
    }
    
    class func makeline(p1:CGPoint, p2:CGPoint) -> Bezier {
      let x1 = p1.x,
        y1 = p1.y,
        x2 = p2.x,
        y2 = p2.y,
        dx = (x2 - x1) / 3,
        dy = (y2 - y1) / 3
        return Bezier(coords: x1,y1,x1 + dx,y1 + dy,x1 + 2 * dx,y1 + 2 * dy,x2,y2)
    }
    
    
    
}


struct Closest {
    
    var mdist:CGFloat
    var mpos:CGFloat
}


struct Curvature {
    var k:CGFloat
    var r:CGFloat
    var dk:CGFloat? = nil
    var adk:CGFloat? = nil
}
