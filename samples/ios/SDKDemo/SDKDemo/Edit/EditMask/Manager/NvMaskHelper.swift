//
//  NvBezierHelper.swift
//  MYVideo
//
//  蒙版 mask
//
//  Created by 美摄 on 2020/7/17.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore


class NvMaskHelper: NSObject {
    
    //MARK: ---- 字幕 caption
    class func textPath(center: CGPoint,maskSize: CGSize) -> UIBezierPath {
        let halfWidth = maskSize.width*0.5
        let halfHeight = maskSize.height*0.5
        
        let leftTop = CGPoint(x: center.x - halfWidth, y: center.y - halfHeight)
        let rightTop = CGPoint(x: center.x + halfWidth, y: center.y - halfHeight)
        let rightBottom = CGPoint(x: center.x + halfWidth, y: center.y + halfHeight)
        let leftBottom = CGPoint(x: center.x - halfWidth, y: center.y + halfHeight)
        let bezierPath = UIBezierPath()
        bezierPath.move(to: leftTop)
        bezierPath.addLine(to: rightTop)
        bezierPath.addLine(to: rightBottom)
        bezierPath.addLine(to: leftBottom)
        bezierPath.addLine(to: leftTop)
        
        /// 添加中间圆圈
        /// Add middle circle
        bezierPath.append(centerPointPath(point: center))
        return bezierPath
    }
        
    //MARK: ---- 矩形 rectangle
    public class func rectPath(center:CGPoint,maskSize:CGSize,cornerRadiusRate:CGFloat) -> UIBezierPath {

        var cornerRadius = cornerRadiusRate * maskSize.height * 0.5
        if maskSize.width < maskSize.height {
            cornerRadius = cornerRadiusRate * maskSize.width * 0.5
        }
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: center.x - maskSize.width*0.5, y: center.y - maskSize.height*0.5 + cornerRadius))
        bezierPath.addLine(to: CGPoint(x: center.x - maskSize.width*0.5, y: center.y + maskSize.height*0.5 - cornerRadius))

        bezierPath.addArc(withCenter:  CGPoint(x: center.x - maskSize.width*0.5 + cornerRadius, y: center.y + maskSize.height*0.5 - cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi/2), clockwise: false)

        bezierPath.addLine(to: CGPoint(x: center.x + maskSize.width*0.5 - cornerRadius, y: center.y + maskSize.height*0.5))

        bezierPath.addArc(withCenter:  CGPoint(x: center.x + maskSize.width*0.5 - cornerRadius, y: center.y + maskSize.height*0.5 - cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi/2), endAngle: 0, clockwise: false)

        bezierPath.addLine(to: CGPoint(x: center.x + maskSize.width*0.5, y: center.y - maskSize.height*0.5 + cornerRadius))

        bezierPath.addArc(withCenter:  CGPoint(x: center.x + maskSize.width*0.5 - cornerRadius, y: center.y - maskSize.height*0.5 + cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat(-Double.pi/2), clockwise: false)

        bezierPath.addLine(to: CGPoint(x: center.x - maskSize.width*0.5 + cornerRadius, y: center.y - maskSize.height*0.5))

        bezierPath.addArc(withCenter:  CGPoint(x: center.x - maskSize.width*0.5 + cornerRadius, y: center.y - maskSize.height*0.5 + cornerRadius), radius: cornerRadius, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(-Double.pi), clockwise: false)
        /// 添加中间圆圈
        /// Add middle circle
        bezierPath.append(centerPointPath(point: center))
        
        return bezierPath
    }
    
    public class func centerPointPath(point:CGPoint) -> UIBezierPath {
        let centerPathRadius:CGFloat = 5
        let centerPath = UIBezierPath(roundedRect: CGRect(x: point.x - centerPathRadius, y: point.y - centerPathRadius, width: centerPathRadius*2, height: centerPathRadius*2), cornerRadius: centerPathRadius)
        return centerPath
    }
    
    public class func rectRegionInfo(center:CGPoint,maskSize:CGSize,cornerRadiusRate:CGFloat) -> NvMaskRegionInfo {
        
        var cornerRadius = cornerRadiusRate * maskSize.height * 0.5
        if maskSize.width < maskSize.height {
            cornerRadius = cornerRadiusRate * maskSize.width * 0.5
        }
        
        let controlPointDis = cornerRadius * 0.45
        
        let info = NvMaskRegionInfo()
        let type = UInt32(NvsMaskRegionType_CubicCurve.rawValue)
        info.type = NvsMaskRegionType(rawValue: type);
        var prePoint:CGPoint  = CGPoint(x: center.x - maskSize.width*0.5, y: center.y + maskSize.height*0.5 - cornerRadius)
        var curPoint:CGPoint  = CGPoint(x: center.x - maskSize.width*0.5, y: center.y - maskSize.height*0.5 + cornerRadius)
        var nextPoint:CGPoint = CGPoint(x: center.x - maskSize.width*0.5, y: center.y - maskSize.height*0.5 + controlPointDis)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)


        nextPoint = curPoint
        curPoint = prePoint
        prePoint = CGPoint(x: center.x - maskSize.width*0.5, y: center.y + maskSize.height*0.5 - controlPointDis)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)

        nextPoint = CGPoint(x: center.x - maskSize.width*0.5 + controlPointDis, y: center.y + maskSize.height*0.5)
        curPoint = CGPoint(x: center.x - maskSize.width*0.5 + cornerRadius, y: center.y + maskSize.height*0.5)
        prePoint = CGPoint(x: center.x + maskSize.width*0.5 - cornerRadius, y: center.y + maskSize.height*0.5)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)

        nextPoint = curPoint
        curPoint = prePoint
        prePoint = CGPoint(x: center.x + maskSize.width*0.5 - controlPointDis, y: center.y + maskSize.height*0.5)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)

        nextPoint = CGPoint(x: center.x + maskSize.width*0.5, y: center.y + maskSize.height*0.5 - controlPointDis)
        curPoint = CGPoint(x: center.x + maskSize.width*0.5, y: center.y + maskSize.height*0.5 - cornerRadius)
        prePoint = CGPoint(x: center.x + maskSize.width*0.5, y: center.y - maskSize.height*0.5 + cornerRadius)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)

        nextPoint = curPoint
        curPoint = prePoint
        prePoint = CGPoint(x: center.x + maskSize.width*0.5, y: center.y - maskSize.height*0.5 + controlPointDis)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)

        nextPoint = CGPoint(x: center.x + maskSize.width*0.5 - controlPointDis, y: center.y - maskSize.height*0.5)
        curPoint = CGPoint(x: center.x + maskSize.width*0.5 - cornerRadius, y: center.y - maskSize.height*0.5)
        prePoint = CGPoint(x: center.x - maskSize.width*0.5 + cornerRadius, y: center.y - maskSize.height*0.5)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)

        nextPoint = curPoint
        curPoint = prePoint
        prePoint = CGPoint(x: center.x - maskSize.width*0.5 + controlPointDis, y: center.y - maskSize.height*0.5)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)
        
        return info
    }
    
    private class func maskRegionInfoAddPoints(info: NvMaskRegionInfo,prePoint: CGPoint,curPoint: CGPoint,nextPoint: CGPoint,center: CGPoint){
        /// 点，后置，前置, (3阶贝塞尔曲线，需要同时传入当前点，后置，前置)
        /// Point, back, front, (Order 3 Bessel curve, need to pass the current point, back, front at the same time)
        info.points.append(NvCodingPoint(cgPoint: curPoint))
        info.points.append(NvCodingPoint(cgPoint: nextPoint))
        info.points.append(NvCodingPoint(cgPoint: prePoint))
    }
    
    //MARK: ---- 圆形 circle
    public class func circlePath(center:CGPoint,maskSize:CGSize,rotation:CGFloat) -> UIBezierPath {
        let rect = CGRect(x: center.x - maskSize.width*0.5, y: center.y - maskSize.height*0.5, width: maskSize.width, height: maskSize.height)
        let bezierPath = UIBezierPath(ovalIn: rect)
        if rotation != 0 {
            bezierPath.apply(CGAffineTransform(rotationAngle: rotation/180*CGFloat(Double.pi)))
        }
        
        /// 添加中间圆圈
        /// Add middle circle
        bezierPath.append(centerPointPath(point: center))
        
        return bezierPath
    }
    
    public class func circleRegionInfo(center: CGPoint,maskSize: CGSize,assetSize: CGSize) -> NvMaskRegionInfo {
        let info = NvMaskRegionInfo()
        let type = UInt32(NvsMaskRegionType_Ellipse2D.rawValue)
        info.type = NvsMaskRegionType(rawValue: type)
        
        let size = assetSize
        
        info.a = maskSize.width/size.width
        info.b = maskSize.height/size.height
//        info.theta = -rotation/CGFloat(Double.pi)
        return info
    }
    
    //MARK: ---- 心形 Heart shape
    public class func heartRegionInfo(center:CGPoint,width:CGFloat) -> NvMaskRegionInfo {
        let info = NvMaskRegionInfo()
        let type = UInt32(NvsMaskRegionType_CubicCurve.rawValue)
        info.type = NvsMaskRegionType(rawValue: type)
        
        let radius:CGFloat = width / 2
        let topIntersectionPoint = CGPoint(x: center.x, y: center.y-radius*(2/6))
        let bottomIntersectionPoint = CGPoint(x: center.x, y: center.y+radius)
        
        var prePoint:CGPoint  = CGPoint(x: center.x+5/7*radius, y: center.y-0.8*radius)
        var curPoint:CGPoint  = topIntersectionPoint
        var nextPoint:CGPoint = CGPoint(x: center.x-5/7*radius, y: center.y-0.8*radius)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)
        
        prePoint = CGPoint(x: center.x-16/13*radius, y: center.y+0.1*radius)
        curPoint = bottomIntersectionPoint
        nextPoint = CGPoint(x: center.x+16/13*radius, y: center.y+0.1*radius)
        maskRegionInfoAddPoints(info: info, prePoint: prePoint, curPoint: curPoint, nextPoint: nextPoint, center: center)
        
        return info
    }
    
    /// 心形path
    /// Heart-shaped path
    /// - Parameters:
    ///   - center: mask中心点
    ///   - width: mask 宽度
    ///   - rotation: 旋转角度
    /// - Returns: 心形path
    /// Heart-shaped path
    public class func heartPath(center:CGPoint,width:CGFloat,rotation:CGFloat) -> UIBezierPath {
        let radius:CGFloat = width / 2
        let intersectionPoint = CGPoint(x: center.x, y: center.y-radius*(2/6))
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: intersectionPoint)
        
        var prePoint:CGPoint  = CGPoint(x: center.x+5/7*radius, y: center.y-0.8*radius)
        var curPoint:CGPoint  = CGPoint(x: center.x, y: center.y+radius)
        var nextPoint:CGPoint = CGPoint(x: center.x+16/13*radius, y: center.y+0.1*radius)
        bezierPath.addCurve(to: curPoint, controlPoint1: prePoint, controlPoint2: nextPoint)
        
        prePoint = CGPoint(x: center.x-16/13*radius, y: center.y+0.1*radius)
        curPoint = CGPoint(x: center.x, y: center.y-radius*(2/6))
        nextPoint = CGPoint(x: center.x-5/7*radius, y: center.y-0.8*radius)
        bezierPath.addCurve(to: curPoint, controlPoint1: prePoint, controlPoint2: nextPoint)
        
        /// 添加中间圆圈
        /// Add middle circle
        bezierPath.append(centerPointPath(point: center))
        
        return bezierPath
    }
    
    
    //MARK: ---- 五角星 pentagram
    /// 星型 mask 点集合 Star mask point set
    /// - Parameters:
    ///   - center: mask中心点
    ///   - width: 星型宽度
    ///   - rotation: 旋转角度
    /// - Returns: 星型 mask 点集合
    /// Star mask point set
    public class func starRegionInfo(center:CGPoint,width:CGFloat) -> NvMaskRegionInfo {
        /// 外圆
        /// Outer circle
        let radius = Float(width / 2)
        let angel = Double.pi * 2 / 5
        var points: [CGPoint] = []
        for i in 1...5 {
            /// 这里是获取五角星的五个定点的坐标点位置
            /// Here are the five points of the five-pointed star
            let x = Float(center.x) - sinf(Float(i) * Float(angel)) * radius
            let y = Float(center.y) - cosf(Float(i) * Float(angel)) * radius
            points.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }
        
        /// 越大越胖
        /// Bigger and fatter
        let radiusRate:Float = 5/10
        /// 内圆
        /// Inner circle
        let internalRadius = Float(width / 2) * radiusRate
        let internalAngel = Double.pi * 2 / 5
        var internalPoints: [CGPoint] = []
        for i in 1...5 {
            /// 这里是获取五角星的五个定点的坐标点位置
            /// Here are the five points of the five-pointed star
            let x = Float(center.x) - sinf(Float(i) * Float(internalAngel) + Float(Double.pi/2 - Double.pi*3/10)) * internalRadius
            let y = Float(center.y) - cosf(Float(i) * Float(internalAngel) + Float(Double.pi/2 - Double.pi*3/10)) * internalRadius
            internalPoints.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }
        
        let info = NvMaskRegionInfo()
        
        var rotationPoint:CGPoint = .zero
        for i in 0...4 {
            info.points.append(NvCodingPoint(cgPoint: points[i]))
            info.points.append(NvCodingPoint(cgPoint: internalPoints[i]))
        }
        
        return info
    }
    
    /// 星型path
    /// Star path
    /// - Parameters:
    ///   - center: mask中心点
    ///   - width: 星型宽度
    ///   - rotation: 旋转角度
    /// - Returns: path
    public class func startPath(center: CGPoint,width: CGFloat,rotation: CGFloat) -> UIBezierPath {
        let regionInfo = starRegionInfo(center:center,width:width)
        let bezierPath = UIBezierPath()
        if regionInfo.points.count < 10 {
            return bezierPath
        }
        let firstValue = regionInfo.points.first!
        let firstPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: firstValue.cgPointValue, anchorPoint: center, angle: rotation)
        bezierPath.move(to: firstPoint)
        for i in 1..<regionInfo.points.count {
            let pointValue = regionInfo.points[i]
            let point = NvLineTool.pointRotatedAroundAnchorPoint(point: pointValue.cgPointValue, anchorPoint: center, angle: rotation)
            bezierPath.addLine(to: point)
        }
        bezierPath.addLine(to: firstPoint)
        
        /// 添加中间圆圈
        /// Add middle circle
        bezierPath.append(centerPointPath(point: center))
        return bezierPath
    }
    
    //MARK: --  线性  linearity
    
    /// 线性mask 点集合
    /// Linear mask point set
    /// - Parameters:
    ///   - center: mask中心点
    ///   - aSize: 素材原始比例 Raw ratio of material
    ///   - liveWindowSize: liveWindowSize
    ///   - rotation: 旋转角度
    /// - Returns: 线性mask 点集合
    /// Linear mask point set
    class func lineRegionInfo(center: CGPoint,aSize: CGSize,maskBoxSize: CGSize) -> NvMaskRegionInfo
    {
        let boxWidth:CGFloat = maskBoxSize.width * 3
        let boxHeight:CGFloat = maskBoxSize.height * 3
        
        let leftTopPoint:CGPoint = CGPoint(x: center.x - boxWidth, y: -(center.y + boxHeight))
        let rightTopPoint:CGPoint = CGPoint(x: center.x + boxWidth, y: -(center.y + boxHeight))
        let rightBottomPoint:CGPoint = CGPoint(x: center.x + boxWidth, y: center.y)
        let leftBottomPoint:CGPoint = CGPoint(x: center.x - boxWidth, y: center.y)
        
        let info = NvMaskRegionInfo()
        info.points.append(NvCodingPoint(cgPoint: leftTopPoint))
        info.points.append(NvCodingPoint(cgPoint: rightTopPoint))
        info.points.append(NvCodingPoint(cgPoint: rightBottomPoint))
        info.points.append(NvCodingPoint(cgPoint: leftBottomPoint))
        
        return info
    }
    
    /// 线性mask path
    /// Linear mask path
    /// - Parameters:
    ///   - center: mask中心点
    ///   - aSize: 素材原始比例 Raw ratio of material
    ///   - liveWindowSize: liveWindowSize
    ///   - rotation: 旋转角度
    /// - Returns: path
    class func linePath(center: CGPoint,aSize: CGSize,liveWindowSize: CGSize,rotation: CGFloat) -> UIBezierPath
    {
        /// 添加中间圆圈
        /// Add middle circle
        let centerPathRadius:CGFloat = 5
        
        let boxWidth:CGFloat = liveWindowSize.width * 3
        let boxHeight:CGFloat = liveWindowSize.height * 3
        
        let bezierPath = UIBezierPath()
        
        var leftBottomPoint:CGPoint = CGPoint(x: center.x - boxWidth, y: center.y)
        leftBottomPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: leftBottomPoint, anchorPoint: center, angle: rotation)
        bezierPath.move(to: leftBottomPoint)
        var leftPoint = CGPoint(x: center.x - centerPathRadius, y: center.y)
        leftPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: leftPoint, anchorPoint: center, angle: rotation)
        bezierPath.addLine(to: leftPoint)
        
        var rightBottomPoint:CGPoint = CGPoint(x: center.x + boxWidth, y: center.y)
        rightBottomPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: rightBottomPoint, anchorPoint: center, angle: rotation)
        var rightPoint = CGPoint(x: center.x + centerPathRadius, y: center.y)
        rightPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: rightPoint, anchorPoint: center, angle: rotation)
        bezierPath.move(to: rightPoint)
        bezierPath.addLine(to: rightBottomPoint)
        
        bezierPath.append(centerPointPath(point: center))
        return bezierPath
    }
    
    //MARK: --  镜像  Mirror image
    
    /// 镜像mask 点集合
    /// Image mask point set
    /// - Parameters:
    ///   - center: mask 中心点
    ///   - aSize: 素材原始比例 Raw ratio of material
    ///   - liveWindowSize: liveWindowSize
    ///   - rotation: 旋转角度
    ///   - scale: 缩放
    /// - Returns: 镜像mask 点集合 Mirror image mask point set
    public class func mirrorRegionInfo(center: CGPoint,aSize: CGSize) -> NvMaskRegionInfo
    {
        let boxWidth:CGFloat = aSize.width * 4
        let boxHeight:CGFloat = aSize.height*0.5
        let leftTopPoint:CGPoint = CGPoint(x: center.x - boxWidth, y: center.y - boxHeight*0.5)
        
        let rightTopPoint:CGPoint = CGPoint(x: center.x + boxWidth, y: center.y - boxHeight*0.5)
        let rightBottomPoint:CGPoint = CGPoint(x: center.x + boxWidth, y: center.y + boxHeight*0.5)
        
        let leftBottomPoint:CGPoint = CGPoint(x: center.x - boxWidth, y: center.y + boxHeight*0.5)
        
        let info = NvMaskRegionInfo()
        info.points.append(NvCodingPoint(cgPoint: leftTopPoint))
        info.points.append(NvCodingPoint(cgPoint: rightTopPoint))
        info.points.append(NvCodingPoint(cgPoint: rightBottomPoint))
        info.points.append(NvCodingPoint(cgPoint: leftBottomPoint))
        
        return info
    }
    
    /// 镜像path
    /// Mirror path
    /// - Parameters:
    ///   - center: mask 中心点
    ///   - aSize: 素材原始size Raw ratio of material
    ///   - liveWindowSize: liveWindowSize
    ///   - rotation: 旋转角度
    ///   - scale: 缩放
    /// - Returns: path
    public class func mirrorPath(center:CGPoint,aSize:CGSize,liveWindowSize:CGSize,rotation:CGFloat,scale:CGFloat) -> UIBezierPath
    {
        let boxWidth:CGFloat = aSize.width * 4
        let boxHeight:CGFloat = aSize.height*0.5 * scale
        var leftTopPoint:CGPoint = CGPoint(x: center.x - boxWidth, y: center.y - boxHeight*0.5)
        leftTopPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: leftTopPoint, anchorPoint: center, angle: rotation)
        var rightTopPoint:CGPoint = CGPoint(x: center.x + boxWidth, y: center.y - boxHeight*0.5)
        rightTopPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: rightTopPoint, anchorPoint: center, angle: rotation)
        var rightBottomPoint:CGPoint = CGPoint(x: center.x + boxWidth, y: center.y + boxHeight*0.5)
        rightBottomPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: rightBottomPoint, anchorPoint: center, angle: rotation)
        var leftBottomPoint:CGPoint = CGPoint(x: center.x - boxWidth, y: center.y + boxHeight*0.5)
        leftBottomPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: leftBottomPoint, anchorPoint: center, angle: rotation)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: leftTopPoint)
        bezierPath.addLine(to: rightTopPoint)
        bezierPath.move(to: rightBottomPoint)
        bezierPath.addLine(to: leftBottomPoint)
        bezierPath.addLine(to: leftTopPoint)
        
        /// 添加中间圆圈
        /// Add middle circle
        bezierPath.append(centerPointPath(point: center))
        return bezierPath
    }
    
    //MARK: --- mask区域size mask area size
    
    /// mask 区域size
    /// - Parameters:
    ///   - maskModel: maskModel
    ///   - liveWindowSize: liveWindowSize
    ///   - assetResolution: 素材宽高 Width and height of material
    ///   - assetSize: 素材在liveWindow 上宽高 The material is wide and tall on the liveWindow
    /// - Returns: mask 区域size
    public class func boxMaskSize(maskModel:NvMaskModel,liveWindowSize:CGSize,assetResolution:CGSize,assetSize:CGSize) -> CGSize {
        if maskModel.maskType == .none {
            return .zero
        }
        if maskModel.maskType == .line {
            var boxWidth:CGFloat = liveWindowSize.width * 2
            /// 只是让boxWidth 更大一些
            /// I'm just going to make boxWidth bigger
            let rate = assetSize.width/assetResolution.width
            boxWidth += (CGFloat(maskModel.transform.transformX)*rate)*2
            boxWidth += (CGFloat(maskModel.transform.transformY)*rate)*2
            return CGSize(width: boxWidth, height: 1)
        }else if maskModel.maskType == .mirror {
            var boxWidth:CGFloat = liveWindowSize.width * 2
            /// 只是让boxWidth 更大一些
            /// I'm just going to make boxWidth bigger
            let rate = assetSize.width/assetResolution.width
            boxWidth += (CGFloat(maskModel.transform.transformX)*rate)*2
            boxWidth += (CGFloat(maskModel.transform.transformY)*rate)*2
            return CGSize(width: boxWidth, height: assetSize.height*0.5*CGFloat(maskModel.transform.scaleX))
        }else{
            let assetAspectRatio = assetResolution.width/assetResolution.height
            var maskSquareWidth:CGFloat = assetAspectRatio >= 1 ? assetSize.height : assetSize.width
            
            maskSquareWidth = maskModel.maskType == .circle ? maskSquareWidth*CGFloat(maskModel.circleRate) : maskSquareWidth
            
            let maskSquareHeight:CGFloat = maskModel.maskType == .rect ? maskSquareWidth/CGFloat(maskModel.rectRate) : maskSquareWidth
            return CGSize(width: maskSquareWidth * CGFloat(maskModel.horizontalScale) * CGFloat(maskModel.transform.scaleX), height: maskSquareHeight * CGFloat(maskModel.verticalScale) * CGFloat(maskModel.transform.scaleX))
        }
    }
    
    public class func boxMaskSizeForInfo(maskModel: NvMaskModel,assetResolution: CGSize) -> CGSize {
        if maskModel.maskType == .none {
            return .zero
        }
        if maskModel.maskType == .line {
            let boxWidth:CGFloat = assetResolution.width * 2
            return CGSize(width: boxWidth, height: 1)
        }else if maskModel.maskType == .mirror {
            let boxWidth:CGFloat = assetResolution.width * 2
            return CGSize(width: boxWidth, height: assetResolution.height*0.5)
        }else{
            let assetAspectRatio = assetResolution.width/assetResolution.height
            var maskSquareWidth:CGFloat = assetAspectRatio >= 1 ? assetResolution.height : assetResolution.width
            
            maskSquareWidth = maskModel.maskType == .circle ? maskSquareWidth*CGFloat(maskModel.circleRate) : maskSquareWidth
            
            let maskSquareHeight:CGFloat = maskModel.maskType == .rect ? maskSquareWidth/CGFloat(maskModel.rectRate) : maskSquareWidth
            return CGSize(width: maskSquareWidth * CGFloat(maskModel.horizontalScale), height: maskSquareHeight * CGFloat(maskModel.verticalScale))
        }
    }
    
    //MARK:  --- 素材在livewindow 展示的size
    //The size of the footage displayed in livewindow
    /// 素材在livewinodw上原始size
    /// 素材在livewinodw上原始size
    /// - Parameters:
    ///   - liveWindowSize: liveWindowSize
    ///   - assetAspectRatio: 素材宽高比 Material aspect ratio
    /// - Returns: 素材size Material size
    class func assetSizeInBox(boxSize:CGSize,assetAspectRatio:CGFloat) -> CGSize {
        var assetWidth:CGFloat = 0
        var assetHeight:CGFloat = 0
        
        let boxSizeRate = boxSize.width/boxSize.height
        if boxSizeRate > assetAspectRatio {
            assetHeight = boxSize.height
            assetWidth = assetHeight*assetAspectRatio
        }else{
            assetWidth = boxSize.width
            assetHeight = assetWidth/assetAspectRatio
        }
        return CGSize(width: assetWidth, height: assetHeight)
    }
    
    /// 装载mask点
    /// Loading mask point
    /// - Parameters:
    ///   - maskModel: maskModel
    ///   - liveWindow: liveWindow
    ///   - assetAspectRatio: 素材宽高比 Material aspect ratio
    @objc public class func prepareMaskRegionPoints(maskModel: NvMaskModel,
                                              assetResolution: CGSize) {
        let size = boxMaskSizeForInfo(maskModel: maskModel,assetResolution: assetResolution)

        var maskCenter = CGPoint(x: assetResolution.width*0.5, y: assetResolution.height*0.5)
        
        switch maskModel.maskType {
        case .line:
            let regionInfo = lineRegionInfo(center: maskCenter,aSize: assetResolution,maskBoxSize: size)
            for value in regionInfo.points {
                let lPoint = NvMaskHelper.mapViewtoNormalized(point: value.cgPointValue, size: assetResolution)
                regionInfo.normalizedPoints.append(NvCodingPoint(cgPoint: lPoint))
            }
            maskModel.regionInfo = regionInfo
            break
        case .mirror:
            let regionInfo = mirrorRegionInfo(center: maskCenter, aSize: assetResolution)
            for value in regionInfo.points {
                let lPoint = NvMaskHelper.mapViewtoNormalized(point: value.cgPointValue, size: assetResolution)
                regionInfo.normalizedPoints.append(NvCodingPoint(cgPoint: lPoint))
            }
            maskModel.regionInfo = regionInfo
            break
        case .circle:
            let regionInfo = circleRegionInfo(center: maskCenter, maskSize: size,assetSize: assetResolution)
            maskModel.regionInfo = regionInfo
            break
        case .rect:
            let regionInfo = rectRegionInfo(center:maskCenter,maskSize:size,cornerRadiusRate:CGFloat(maskModel.cornerRadiusRate))
            for value in regionInfo.points {
                let lPoint = NvMaskHelper.mapViewtoNormalized(point: value.cgPointValue, size: assetResolution)
                regionInfo.normalizedPoints.append(NvCodingPoint(cgPoint: lPoint))
            }
            maskModel.regionInfo = regionInfo
            break
        case .heart:
            let regionInfo = heartRegionInfo(center:maskCenter,width: size.width)
            for value in regionInfo.points {
                let lPoint = NvMaskHelper.mapViewtoNormalized(point: value.cgPointValue, size: assetResolution)
                regionInfo.normalizedPoints.append(NvCodingPoint(cgPoint: lPoint))
            }
            maskModel.regionInfo = regionInfo
        case .star:
            let regionInfo = starRegionInfo(center: maskCenter, width: size.width)
            for value in regionInfo.points {
                let lPoint = NvMaskHelper.mapViewtoNormalized(point: value.cgPointValue, size: assetResolution)
                regionInfo.normalizedPoints.append(NvCodingPoint(cgPoint: lPoint))
            }
            maskModel.regionInfo = regionInfo
            break
        default: break
        }
    }
    
    public static func mapNormalizedToTimeline(point: NvCodingPoint,size: CGSize) -> NvCodingPoint {
        let halfWidth = size.width*0.5
        let halfHeight = size.height*0.5
        return NvCodingPoint(x: CGFloat(point.x) * halfWidth, y: CGFloat(point.y) * halfHeight)
    }
    
    public class func mapViewtoNormalized(point: CGPoint,size:CGSize) -> CGPoint {
        let center = CGPoint(x: size.width*0.5, y: size.height*0.5)
        let halfWidth = center.x
        let halfHeight = center.y
        let xValue = (point.x - center.x)/halfWidth
        let yValue = -(point.y - center.y)/halfHeight
        return CGPoint(x: xValue, y: yValue)
    }
    
    public static func mapTimelineToNormalized(point: CGPoint,size: CGSize) -> CGPoint {
        let halfWidth = size.width*0.5
        let halfHeight = size.height*0.5
        return CGPoint(x: point.x / halfWidth , y: point.y / halfHeight)
    }
    
}
