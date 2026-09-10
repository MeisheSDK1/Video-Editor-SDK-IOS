//
//  NvLineTool.swift
//  NvLineTool
//
//  Created by 美摄 on 2020/4/22.
//  Copyright © 2020 美摄. All rights reserved.
//

import UIKit

class NvLineTool: NSObject {
    /// 点旋转后的值
    /// The value of the rotated point
    class func pointRotatedAroundAnchorPoint(point:CGPoint,anchorPoint:CGPoint,angle:CGFloat) -> CGPoint {
        return CGPoint(x:(point.x-anchorPoint.x)*cos(angle) - (point.y-anchorPoint.y)*sin(angle) + anchorPoint.x,y: (point.x-anchorPoint.x)*sin(angle) + (point.y-anchorPoint.y)*cos(angle)+anchorPoint.y)
    }
    
    /// 点 连成线
    /// The dots make a line
    class func pathWithPoints(pointArray:[CGPoint]) -> UIBezierPath {
        let bezierPath:UIBezierPath = UIBezierPath()
        for index in 0..<pointArray.count {
            let point = pointArray[index]
            if index == 0 {
                bezierPath.move(to: point)
            }else{
                bezierPath.addLine(to:point)
            }
        }
        let startPoint = pointArray.first!
        bezierPath.addLine(to:startPoint)
        return bezierPath
    }
    
    ///垂直交点
    ///Vertical intersection
    class func pedalPoint(p1 :CGPoint ,p2:CGPoint ,x0:CGPoint) -> CGPoint{
        let A:CGFloat = p2.y-p1.y
        let B:CGFloat = p1.x-p2.x
        let C:CGFloat = p2.x*p1.y-p1.x*p2.y
        
        let x:CGFloat = (B*B*x0.x-A*B*x0.y-A*C)/(A*A+B*B)
        let y:CGFloat = (-A*B*x0.x+A*A*x0.y-B*C)/(A*A+B*B)
        let ptCross = CGPoint(x: x,y: y)
        return ptCross
    }
    
    /// 点到线水平距离
    /// Horizontal distance from point to line
    class func pointToLineHorizontalDistance(p1 :CGPoint ,p2:CGPoint ,x0:CGPoint) -> CGFloat {
        let A:CGFloat = p2.y-p1.y
        let B:CGFloat = p1.x-p2.x
        return x0.x - p1.x + (x0.y - p1.y)/A*B
    }
    /// 点到线竖直距离
    /// Vertical distance from point to line
    class func pointToLineVerticalDistance(p1 :CGPoint ,p2:CGPoint ,x0:CGPoint) -> CGFloat {
        let A:CGFloat = p2.y-p1.y
        let B:CGFloat = p1.x-p2.x
        return x0.y - p1.y + (x0.x - p1.x)/B*A
    }
    
    /// 两点间距离
    /// Distance between two points
    class func twoPointDistance(p1:CGPoint,p2:CGPoint) -> CGFloat {
        let A:CGFloat = p2.y-p1.y
        let B:CGFloat = p1.x-p2.x
        let C:CGFloat = sqrt(A*A+B*B)
        return C
    }
    /// 两直线交点
    /// The intersection of two lines
    class func twoLinePointOfIntersection(point1:CGPoint,point2:CGPoint, point3:CGPoint, point4:CGPoint) -> CGPoint {
        let x1=point1.x
        let y1=point1.y
        let x2=point2.x
        let y2=point2.y
        let x3=point3.x
        let y3=point3.y
        let x4=point4.x
        let y4=point4.y
        let k1 = (y1-y2)/(x1-x2)
        let k2 = (y3-y4)/(x3-x4)
        
        let b1 = y1-k1*x1
        let b2 = y4-k2*x4
        if (x1==x2&&y3==y4) {
            return CGPoint(x: x1,y: y3)
        }else if (x3==x4&&y1==y2) {
            return CGPoint(x: x3,y: y1)
        }else if (x1==x2&&x3 != x4) {
            return CGPoint(x: x1,y: k2*x1+b2)
        }else if (x3==x4&&x1 != x2){
            return CGPoint(x: x3,y: k1*x3+b1)
        }else if (x3==x4&&x1==x2) {
            return .zero
        }else{
            if (y1==y2&&y3 != y4) {
                return CGPoint(x: (y1-b2)/k2,y: y1)
            }else if (y3==y4 && y1 != y2){
                return CGPoint(x: (y4-b1)/k1,y: y4)
            }else if (y3==y4&&y1==y2) {
                return .zero
            }else{
                if (k1==k2){
                    return .zero
                }else{
                    let x = (b2-b1)/(k1-k2)
                    let y = k2*x+b2
                    return CGPoint(x: x,y: y)
                }
            }
        }
    }
}
