//
//  utils+extensions.swift
//  Bezier
//
//  Created by tang on 2020/9/23.
//  Copyright © 2020 Tangweichun. All rights reserved.
//

import UIKit

extension utils {
    class func roots(points:[Coordinate], _line:Line? = nil) -> [CGFloat] {
          let line = _line ?? Line(p1: Coordinate(x: 0, y: 0), p2: Coordinate(x: 1, y: 0))// { p1: { x: 0, y: 0 }, p2: { x: 1, y: 0 } };
            let order = points.count - 1
            let _p = utils.align(points: points, line: line)
    //      var reduce = function(t) {
    //        return 0 <= t && t <= 1;
    //      };
    //
            func __reduce (t:CGFloat) -> Bool {
                return 0 <= t && t <= 1
            }
            

          if (order == 2) {
            let a = _p[0].y,
              b = _p[1].y,
              c = _p[2].y,
              d = a - 2 * b + c
            if (d != 0) {
              let m1 = -sqrt(b * b - a * c),
                m2 = -a + b,
                v1 = -(m1 + m2) / d,
                v2 = -(-m1 + m2) / d;
              return [v1, v2].filter(__reduce)
            } else if (b != c && d == 0) {
              return [(2*b - c)/(2*b - 2*c)].filter(__reduce);
            }
            return [];
          }

          // see http://www.trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm
          var pa = _p[0].y,
            pb = _p[1].y,
            pc = _p[2].y,
            pd = _p[3].y,
            d = -pa + 3 * pb - 3 * pc + pd,
            a = 3 * pa - 6 * pb + 3 * pc,
            b = -3 * pa + 3 * pb,
            c = pa;

            if (utils.approximately(a: d, b: 0)) {
            // this is not a cubic curve.
                if (utils.approximately(a: a, b: 0)) {
              // in fact, this is not a quadratic curve either.
                    if (utils.approximately(a: b, b: 0)) {
                // in fact in fact, there are no solutions.
                return []
              }
              // linear solution:
              return [-c / b].filter(__reduce);
            }
            // quadratic solution:
            let q = sqrt(b * b - 4 * a * c),
              a2 = 2 * a;
            return [(q - b) / a2, (-b - q) / a2].filter(__reduce);
          }

          // at this point, we know we need a cubic solution:

          a /= d
          b /= d
          c /= d

            var p = (3 * b - a * a) / 3,
            p3 = p / 3,
            q = (2 * a * a * a - 9 * a * b + 27 * c) / 27,
            q2 = q / 2,
            discriminant = q2 * q2 + p3 * p3 * p3,
            u1:CGFloat,
            v1:CGFloat,
            x1:CGFloat,
            x2:CGFloat,
            x3:CGFloat
          if (discriminant < 0) {
            let mp3 = -p / 3,
              mp33 = mp3 * mp3 * mp3,
              r = sqrt(mp33),
              t = -q / (2 * r),
              cosphi = t < -1 ? -1 : t > 1 ? 1 : t,
              phi = acos(cosphi),
            crtr = crt(v: r),
              t1 = 2 * crtr;
            x1 = t1 * cos(phi / 3) - a / 3;
            x2 = t1 * cos((phi + tau) / 3) - a / 3;
            x3 = t1 * cos((phi + 2 * tau) / 3) - a / 3;
            return [x1, x2, x3].filter(__reduce);
          } else if (discriminant == 0) {
            u1 = q2 < 0 ? crt(v: -q2) : -crt(v: q2);
            x1 = 2 * u1 - a / 3;
            x2 = -u1 - a / 3;
            return [x1, x2].filter(__reduce);
          } else {
            let sd = sqrt(discriminant);
            u1 = crt(v: -q2 + sd);
            v1 = crt(v: q2 + sd);
            return [u1 - v1 - a / 3].filter(__reduce);
          }
        }
      
        class func crt(v:CGFloat) -> CGFloat {
          return v < 0 ? -pow(-v, 1 / 3) : pow(v, 1 / 3)
        }
}
