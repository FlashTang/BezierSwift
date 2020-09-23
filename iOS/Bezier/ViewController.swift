//
//  ViewController.swift
//  Bezier
//
//  Created by tang on 2020/9/20.
//  Copyright © 2020 Tangweichun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Bezier(coords:["x":4,"y":4],["x":2,"y":0],["x":1,"y":8])
        //Bezier(coords:[["x":4,"y":4],["x":2,"y":0],["x":1,"y":8]])
        //_ = Bezier(coords:10,50,0,80,10,0,32,0,0,20,0,0)
        //_ = Bezier(coords:Coordinate(x: 0, y: 0, z: 0),Coordinate(x: 0, y: 0, z: 0),Coordinate(x: 0, y: 0, z: 0))
        
        //print(Bezier.quadraticFromPoints(p1: Coordinate(x:10, y: 0, z: nil), p2: Coordinate(x:50, y:0, z: nil), p3: Coordinate(x: 0, y: 0, z: nil)).points)
        let qp = Bezier(coords: Coordinate(x: 50, y: 200),
                                Coordinate(x: 50, y: 50),
                                Coordinate(x: 200, y: 50),
                                Coordinate(x: 200, y: 200)).points
        
      
        let qps = Bezier(coords: Coordinate(x: 50, y: 200),
        Coordinate(x: 50, y: 50),
        Coordinate(x: 200, y: 50),
            Coordinate(x: 200, y: 200)).offset(t: -80) as! [Bezier]
         
        let shape = CAShapeLayer()
        shape.strokeColor = UIColor.red.cgColor
        shape.fillColor = UIColor.clear.cgColor
        self.view.layer.addSublayer(shape)
        let bp  = UIBezierPath()
        bp.move(to: qp[0].cgPoint())
        
        bp.addCurve(to: qp[3].cgPoint(), controlPoint1: qp[1].cgPoint(), controlPoint2: qp[2].cgPoint())
        //据说BD也差不多，摧残人性的地方，
        shape.path = bp.cgPath
        
        
        let shape2 = CAShapeLayer()
        shape2.strokeColor = UIColor.red.cgColor
        shape2.fillColor = UIColor.clear.cgColor
        self.view.layer.addSublayer(shape2)
        let bp2  = UIBezierPath()
         
        bp2.move(to: qps[0].points[0].cgPoint())
        for (i,b) in qps.enumerated() {
            
            bp2.addCurve(to: b.points[3].cgPoint(), controlPoint1: b.points[1].cgPoint(), controlPoint2: b.points[2].cgPoint())
            
        }
        
        shape2.path = bp2.cgPath
        
    }


}

