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
    
    class func derive(points:[Coordinate], _3d:Bool) -> [[Coordinate]]{
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
//      for (var p = points, d = p.length, c = d - 1; d > 1; d--, c--) {
//
//      }
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
    
    
//    function projectionratio(t, n) {
//      // see u(t) note on http://pomax.github.io/bezierinfo/#abc
//      if (n !== 2 && n !== 3) {
//        return false;
//      }
//      if (typeof t === "undefined") {
//        t = 0.5;
//      } else if (t === 0 || t === 1) {
//        return t;
//      }
//      var top = Math.pow(1 - t, n),
//        bottom = Math.pow(t, n) + top;
//      return top / bottom;
//    }
    
    
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
    class func numberSort(a:CGFloat, b:CGFloat) -> CGFloat{
      return a - b
    }
}


struct Line {
    var p1:Coordinate
    var p2:Coordinate
}
