//
//  NvCropperRectView.swift
//  MYVideo
//
//  Created by 刘东旭 on 2020/3/18.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore

class NvCropperRect: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
}


protocol NvCropperRectViewDelegete: AnyObject {
    func cropperRectViewTouchEnd(cropperRectView: NvCropperRectView, cropperRectViewCenter: CGPoint, cropperRectCenter: CGPoint, scale: CGFloat)
    func cropperRectViewPointEdge(cropperRectView: NvCropperRectView) ->
    (leftTop:CGPoint,
     leftBottom:CGPoint,
     rightTop:CGPoint,
     rightBottom:CGPoint,
     imageCenter:CGPoint)
    
    func cropperRectViewMoving(cropperRectView: NvCropperRectView?, rect:CGRect) -> Bool
    
    func cropperRectViewMoveEnd(cropperRectView: NvCropperRectView?)
    
    
    
}

class NvCropperRectView: UIView {
    
    let pointViewWidth:CGFloat = 60
    
    var leftTopPointPanBeyond:Bool = false
    
    //    var clipperRectPanGesture: UIPanGestureRecognizer!
    
    let leftTopPoint:UIView = UIView()
    var leftTopPointPanGesture:UIPanGestureRecognizer!
    
    let leftBottomPoint:UIView = UIView()
    var leftBottomPointPanGesture:UIPanGestureRecognizer!
    
    let rightTopPoint:UIView = UIView()
    var rightTopPointPanGesture:UIPanGestureRecognizer!
    
    let rightBottomPoint:UIView = UIView()
    var rightBottomPointPanGesture:UIPanGestureRecognizer!
    
    let clipperRect:NvCropperRect = NvCropperRect()
    var aspectRatio: NvVideoEditAspectRatioMode = .NvVideoEditAspectRatioMode_Free
    var assetAspectRatio:CGFloat = 1
    weak var delegate: NvCropperRectViewDelegete?
    private var prePonit:CGPoint?
    private var dragPoint:CGPoint?
    private var dragPointOpposite:CGPoint?
    private var rectLayer: CAShapeLayer = CAShapeLayer()
    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipperRect.frame = bounds
        drawRectLayer()
        drawShapeLayer()
        leftTopPoint.frame = CGRect(x: -pointViewWidth*0.5, y: -pointViewWidth*0.5, width: pointViewWidth, height: pointViewWidth)
        leftBottomPoint.frame = CGRect(x: 0, y: bounds.height-pointViewWidth*0.5, width: pointViewWidth, height: pointViewWidth)
        rightTopPoint.frame = CGRect(x: bounds.width-pointViewWidth*0.5, y: 0, width: pointViewWidth, height: pointViewWidth)
        rightBottomPoint.frame = CGRect(x: bounds.width-pointViewWidth*0.5, y: bounds.height-pointViewWidth*0.5, width: pointViewWidth, height: pointViewWidth)
        self.addSubview(clipperRect)
        self.addSubview(leftTopPoint)
        self.addSubview(leftBottomPoint)
        self.addSubview(rightTopPoint)
        self.addSubview(rightBottomPoint)
        leftTopPointPanGesture = UIPanGestureRecognizer(target: self, action: #selector(leftTopPointPan(pan:)))
        self.leftTopPoint.addGestureRecognizer(leftTopPointPanGesture)
        leftTopPointPanGesture.delegate = self
        leftBottomPointPanGesture = UIPanGestureRecognizer(target: self, action: #selector(leftBottomPointPan(pan:)))
        self.leftBottomPoint.addGestureRecognizer(leftBottomPointPanGesture)
        leftBottomPointPanGesture.delegate = self
        rightTopPointPanGesture = UIPanGestureRecognizer(target: self, action: #selector(rightTopPointPan(pan:)))
        self.rightTopPoint.addGestureRecognizer(rightTopPointPanGesture)
        rightTopPointPanGesture.delegate = self
        rightBottomPointPanGesture = UIPanGestureRecognizer(target: self, action: #selector(rightBottomPointPan(pan:)))
        self.rightBottomPoint.addGestureRecognizer(rightBottomPointPanGesture)
        rightBottomPointPanGesture.delegate = self
        
        rectLayer.fillColor = UIColor.clear.cgColor
        rectLayer.strokeColor = UIColor.init(red: 0, green: 1.0, blue: 1.0, alpha: 1).cgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCropperFrame() {
        let videoSize:NvsSize = NvCropperHelper.calculateTimelineSize(editMode: aspectRatio,originAspectRatio:assetAspectRatio)
        let nFrame = frameForRectView(videoSize:CGSize(width: CGFloat(videoSize.width), height: CGFloat(videoSize.height)))
        resetCropperRectFrame(nFrame: nFrame)
    }
    
    func resetCropperRectFrame(nFrame:CGRect){
        clipperRect.frame = nFrame
        clipperRect.center = self.center
        drawRectLayer()
        drawShapeLayer()
        leftTopPoint.center = clipperRect.frame.leftTop()
        leftBottomPoint.center = clipperRect.frame.leftBottom()
        rightTopPoint.center = clipperRect.frame.rightTop()
        rightBottomPoint.center = clipperRect.frame.rightBottom()
    }
    
    func frameForRectView(videoSize:CGSize) -> CGRect {
        let maxWidth = frame.width
        let maxHeight = frame.height
        var rect:CGRect = CGRect()
        if videoSize.width >= videoSize.height {
            rect.size.width = maxWidth
            rect.size.height = rect.size.width * CGFloat(videoSize.height) / CGFloat(videoSize.width)
            rect.origin.x = 0
            rect.origin.y = (maxHeight - rect.size.height) / 2
            if rect.size.height > maxHeight {
                rect.size.height = maxHeight
                rect.size.width = maxHeight / CGFloat(videoSize.height) * CGFloat(videoSize.width)
                rect.origin.y = 0
                rect.origin.x = (maxWidth - rect.size.width) / 2
            }
        }else{
            rect.size.width = maxHeight * CGFloat(videoSize.width) / CGFloat(videoSize.height)
            rect.size.height = maxHeight
            rect.origin.x = (maxWidth - rect.size.width) / 2
            rect.origin.y = 0
            if rect.size.width > maxWidth {
                rect.size.width = maxWidth
                rect.size.height = maxWidth * CGFloat(videoSize.height) / CGFloat(videoSize.width)
                rect.origin.x = 0
                rect.origin.y = (maxHeight - rect.size.height) / 2
            }
        }
        return rect
    }
    
    func rectFrame() -> CGRect {
        if leftTopPointPanGesture.state == .changed || leftBottomPointPanGesture.state == .changed || rightTopPointPanGesture.state == .changed || rightBottomPointPanGesture.state == .changed {
            return clipperRect.frame
        }
        let rectFrame = clipperRect.frame
        if rectFrame.width != frame.width && rectFrame.height != frame.height {
            return frameForRectView(videoSize:rectFrame.size)
        }
        return clipperRect.frame
    }
    
    func checkPointPosition(point: CGPoint, otherPoint: CGPoint) -> Bool {
        var result :Bool = false
        let width = abs(point.x - otherPoint.x)
        let height = abs(point.y - otherPoint.y)
        var originPoint = point
        if point.x > otherPoint.x {
            originPoint = otherPoint
        }
        let rect = CGRect(x: originPoint.x, y: originPoint.y, width: width, height: height)
        result = ((delegate?.cropperRectViewMoving(cropperRectView: self, rect: rect)) == true)
        return result
    }
    
    func getPanPoints(location:CGPoint, oppositePoint:CGPoint) -> (p1:CGPoint, p2:CGPoint) {
        var location1 = location
        var otherPoint1 = oppositePoint
        let result = checkPointPosition(point: location1, otherPoint: otherPoint1)
        if result == false {
            location1 = dragPoint ?? location1
            otherPoint1 = dragPointOpposite ?? otherPoint1
        }
        dragPoint = location1
        dragPointOpposite = otherPoint1
        return (p1:location1,p2:otherPoint1)
    }
    
    func doAnimation(block: @escaping (_ finish: Bool)->Void) -> Void {
        let scale: CGFloat = clipperRect.frame.width/clipperRect.frame.height
        UIView.animate(withDuration: 0.25, animations: {
            ///宽大于高
            ///Larger than tall
            if scale >= self.frame.width/self.frame.height {
                ///宽撑满屏幕
                ///Fill the screen with width
                ///高自动计算
                ///High automatic computing
                let minx: CGFloat = 0
                let miny = (self.bounds.height - self.bounds.width/scale)/2
                let width = self.bounds.width
                let height = self.bounds.width/scale
                self.clipperRect.frame = CGRect(x: minx, y: miny, width: width, height: height)
                self.drawRectLayer()
                self.drawShapeLayer()
                self.leftTopPoint.center = CGPoint(x: minx, y: miny)
                self.leftBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
                self.rightTopPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y)
                self.rightBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
                self.clipperRect.setNeedsDisplay()
            } else {
                ///宽撑满屏幕
                ///Fill the screen with width
                ///高自动计算
                ///High automatic computing
                let minx: CGFloat = (self.bounds.width - self.bounds.height/self.clipperRect.frame.height*self.clipperRect.frame.width)/2
                let miny: CGFloat = 0
                let width = self.bounds.height/self.clipperRect.frame.height*self.clipperRect.frame.width
                let height = self.bounds.height
                self.clipperRect.frame = CGRect(x: minx, y: miny, width: width, height: height)
                self.drawRectLayer()
                self.drawShapeLayer()
                self.leftTopPoint.center = CGPoint(x: minx, y: miny)
                self.leftBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
                self.rightTopPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y)
                self.rightBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
                self.clipperRect.setNeedsDisplay()
            }
        }) { (finish) in
            block(finish)
        }
    }
    
    @objc func leftTopPointPan(pan:UIPanGestureRecognizer) -> Void {
        switch pan.state {
        case .changed:
            var location = pan.location(in: self)
            var otherPoint: CGPoint = rightBottomPoint.center
            
            location = getPanPoints(location: location, oppositePoint: otherPoint).p1
            otherPoint = getPanPoints(location: location, oppositePoint: otherPoint).p2
            var ratioNum: CGFloat = 1
            var point = CGPoint(x: 0, y: 0)
            var curPoint: CGPoint = location
            
            if location.x < 0 {
                curPoint = CGPoint(x: 0, y: curPoint.y)
            }
            if location.y < 0 {
                curPoint = CGPoint(x: curPoint.x, y: 0)
            }
            if location.x > frame.width {
                curPoint = CGPoint(x: frame.width, y: curPoint.y)
            }
            if location.y > frame.height {
                curPoint = CGPoint(x: curPoint.x, y: frame.height)
            }
            
            switch aspectRatio {
            case .NvVideoEditAspectRatioMode_Free:
                point = curPoint
                break
            default:
                let videoSize:NvsSize = NvCropperHelper.calculateTimelineSize(editMode: aspectRatio,originAspectRatio:assetAspectRatio)
                ratioNum = CGFloat(videoSize.width)/CGFloat(videoSize.height)
                break
            }
            let scale: CGFloat = abs(curPoint.x - otherPoint.x)/abs(curPoint.y - otherPoint.y)
            if scale >= self.frame.width/self.frame.height {
                let w = curPoint.x - otherPoint.x
                let h = w/ratioNum
                point = CGPoint(x: otherPoint.x+w, y: otherPoint.y+h)
            } else {
                let h = curPoint.y - otherPoint.y
                let w = h*ratioNum
                point = CGPoint(x: otherPoint.x+w, y: otherPoint.y+h)
            }
            if aspectRatio == .NvVideoEditAspectRatioMode_Free {
                point = curPoint
            }
            self.leftTopPoint.center = CGPoint(x: point.x, y: point.y)
            self.clipperRect.frame = CGRect(x: point.x, y: point.y, width: self.rightTopPoint.center.x - point.x, height: self.leftBottomPoint.center.y - point.y)
            drawRectLayer()
            drawShapeLayer()
            self.leftBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
            self.rightTopPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y)
            self.rightBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
            self.clipperRect.setNeedsDisplay()
            
            break
        case .ended:
            ///做动画、给回调
            ///Make animations, give callbacks
            let r: CGFloat = clipperRect.frame.width/clipperRect.frame.height
            var scale: CGFloat = 1
            if r >= self.frame.width/self.frame.height {
                scale = self.frame.width / clipperRect.frame.width
            } else {
                scale = self.frame.height / clipperRect.frame.height
            }
            
            delegate?.cropperRectViewTouchEnd(cropperRectView: self, cropperRectViewCenter: self.center,cropperRectCenter: clipperRect.center,scale: scale)
            weak var weakSelf = self
            doAnimation { (finish) in
                if finish {
                    weakSelf?.delegate?.cropperRectViewMoveEnd(cropperRectView: self)
                }
            }
            break
        default:
            break
        }
    }
    
    @objc func leftBottomPointPan(pan:UIPanGestureRecognizer) -> Void {
        
        var location = pan.location(in: self)
        var otherPoint: CGPoint = rightTopPoint.center
        
        location = getPanPoints(location: location, oppositePoint: otherPoint).p1
        otherPoint = getPanPoints(location: location, oppositePoint: otherPoint).p2
        var ratioNum: CGFloat = 1
        var point = CGPoint(x: 0, y: 0)
        var curPoint: CGPoint = location
        
        if location.x < 0 {
            curPoint = CGPoint(x: 0, y: curPoint.y)
        }
        if location.y < 0 {
            curPoint = CGPoint(x: curPoint.x, y: 0)
        }
        if location.x > frame.width {
            curPoint = CGPoint(x: frame.width, y: curPoint.y)
        }
        if location.y > frame.height {
            curPoint = CGPoint(x: curPoint.x, y: frame.height)
        }
        
        switch aspectRatio {
        case .NvVideoEditAspectRatioMode_Free:
            point = curPoint
            break
        case .NvVideoEditAspectRatioMode_9v16:
            ratioNum = 9.0/16.0
            break
        case .NvVideoEditAspectRatioMode_3v4:
            ratioNum = 3.0/4.0
            break
        case .NvVideoEditAspectRatioMode_9v18:
            ratioNum = 9.0/18.0
            break
        case .NvVideoEditAspectRatioMode_9v21:
            ratioNum = 9.0/21.0
            break
        case .NvVideoEditAspectRatioMode_1v1:
            ratioNum = 1.0
            break
        case .NvVideoEditAspectRatioMode_16v9:
            ratioNum = 16.0/9.0
            break
        case .NvVideoEditAspectRatioMode_4v3:
            ratioNum = 4.0/3.0
            break
        case .NvVideoEditAspectRatioMode_18v9:
            ratioNum = 18.0/9.0
            break
        case .NvVideoEditAspectRatioMode_21v9:
            ratioNum = 21.0/9.0
            break
        }
        let scale: CGFloat = abs(curPoint.x - otherPoint.x)/abs(curPoint.y - otherPoint.y)
        if scale >= self.frame.width/self.frame.height {
            let w = curPoint.x - otherPoint.x
            let h = w/ratioNum
            point = CGPoint(x: otherPoint.x+w, y: otherPoint.y-h)
        } else {
            let h = curPoint.y - otherPoint.y
            let w = h*ratioNum
            point = CGPoint(x: otherPoint.x-w, y: otherPoint.y-h)
        }
        if aspectRatio == .NvVideoEditAspectRatioMode_Free {
            point = curPoint
        }
        
        
        switch pan.state {
        case .changed:
            self.leftBottomPoint.center = CGPoint(x: point.x, y: point.y)
            self.clipperRect.frame = CGRect(x: point.x, y: self.clipperRect.frame.origin.y, width: self.rightBottomPoint.center.x - point.x, height: point.y - self.clipperRect.frame.origin.y)
            drawRectLayer()
            drawShapeLayer()
            self.leftTopPoint.center = CGPoint(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y)
            self.rightTopPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y)
            self.rightBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
            self.clipperRect.setNeedsDisplay()
            break
        case .ended:
            ///做动画、给回调
            ///Make animations, give callbacks
            let r: CGFloat = clipperRect.frame.width/clipperRect.frame.height
            var scale: CGFloat = 1
            if r >= self.frame.width/self.frame.height {
                scale = self.frame.width / clipperRect.frame.width
            } else {
                scale = self.frame.height / clipperRect.frame.height
            }
            
            delegate?.cropperRectViewTouchEnd(cropperRectView: self, cropperRectViewCenter: self.center,cropperRectCenter: clipperRect.center,scale: scale)
            weak var weakSelf = self
            doAnimation { (finish) in
                if finish {
                    weakSelf?.delegate?.cropperRectViewMoveEnd(cropperRectView: self)
                }
            }
            break
        default:
            break
        }
    }
    
    @objc func rightTopPointPan(pan:UIPanGestureRecognizer) -> Void {
        
        var location = pan.location(in: self)
        var otherPoint: CGPoint = leftBottomPoint.center
        
        
        location = getPanPoints(location: location, oppositePoint: otherPoint).p1
        otherPoint = getPanPoints(location: location, oppositePoint: otherPoint).p2
        var ratioNum: CGFloat = 1
        var point = CGPoint(x: 0, y: 0)
        var curPoint: CGPoint = location
        
        if location.x < 0 {
            curPoint = CGPoint(x: 0, y: curPoint.y)
        }
        if location.y < 0 {
            curPoint = CGPoint(x: curPoint.x, y: 0)
        }
        if location.x > frame.width {
            curPoint = CGPoint(x: frame.width, y: curPoint.y)
        }
        if location.y > frame.height {
            curPoint = CGPoint(x: curPoint.x, y: frame.height)
        }
        
        switch aspectRatio {
        case .NvVideoEditAspectRatioMode_Free:
            point = curPoint
            break
        case .NvVideoEditAspectRatioMode_9v16:
            ratioNum = 9.0/16.0
            break
        case .NvVideoEditAspectRatioMode_3v4:
            ratioNum = 3.0/4.0
            break
        case .NvVideoEditAspectRatioMode_9v18:
            ratioNum = 9.0/18.0
            break
        case .NvVideoEditAspectRatioMode_9v21:
            ratioNum = 9.0/21.0
            break
        case .NvVideoEditAspectRatioMode_1v1:
            ratioNum = 1.0
            break
        case .NvVideoEditAspectRatioMode_16v9:
            ratioNum = 16.0/9.0
            break
        case .NvVideoEditAspectRatioMode_4v3:
            ratioNum = 4.0/3.0
            break
        case .NvVideoEditAspectRatioMode_18v9:
            ratioNum = 18.0/9.0
            break
        case .NvVideoEditAspectRatioMode_21v9:
            ratioNum = 21.0/9.0
            break
        }
        let scale: CGFloat = abs(curPoint.x - otherPoint.x)/abs(curPoint.y - otherPoint.y)
        if scale >= self.frame.width/self.frame.height {
            let w = curPoint.x - otherPoint.x
            let h = w/ratioNum
            point = CGPoint(x: otherPoint.x+w, y: otherPoint.y-h)
        } else {
            let h = curPoint.y - otherPoint.y
            let w = h*ratioNum
            point = CGPoint(x: otherPoint.x-w, y: otherPoint.y+h)
        }
        if aspectRatio == .NvVideoEditAspectRatioMode_Free {
            point = curPoint
        }
        
        
        switch pan.state {
        case .changed:
            self.rightTopPoint.center = CGPoint(x: point.x, y: point.y)
            self.clipperRect.frame = CGRect(x: self.clipperRect.frame.origin.x, y: point.y, width: point.x - self.clipperRect.frame.origin.x, height: self.rightBottomPoint.center.y - point.y)
            drawRectLayer()
            drawShapeLayer()
            self.leftTopPoint.center = CGPoint(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y)
            self.leftBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
            self.rightBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
            self.clipperRect.setNeedsDisplay()
            break
        case .ended:
            ///做动画、给回调
            ///Make animations, give callbacks
            let r: CGFloat = clipperRect.frame.width/clipperRect.frame.height
            var scale: CGFloat = 1
            if r >= self.frame.width/self.frame.height {
                scale = self.frame.width / clipperRect.frame.width
            } else {
                scale = self.frame.height / clipperRect.frame.height
            }
            delegate?.cropperRectViewTouchEnd(cropperRectView: self, cropperRectViewCenter: self.center,cropperRectCenter: clipperRect.center,scale: scale)
            weak var weakSelf = self
            doAnimation { (finish) in
                if finish {
                    weakSelf?.delegate?.cropperRectViewMoveEnd(cropperRectView: weakSelf)
                }
            }
            break
        default:
            break
        }
    }
    
    
    @objc func rightBottomPointPan(pan:UIPanGestureRecognizer) -> Void {
        var location = pan.location(in: self)
        var otherPoint: CGPoint = leftTopPoint.center
        
        location = getPanPoints(location: location, oppositePoint: otherPoint).p1
        otherPoint = getPanPoints(location: location, oppositePoint: otherPoint).p2
        var ratioNum: CGFloat = 1
        var point = CGPoint(x: 0, y: 0)
        var curPoint: CGPoint = location
        
        if location.x < 0 {
            curPoint = CGPoint(x: 0, y: curPoint.y)
        }
        if location.y < 0 {
            curPoint = CGPoint(x: curPoint.x, y: 0)
        }
        if location.x > frame.width {
            curPoint = CGPoint(x: frame.width, y: curPoint.y)
        }
        if location.y > frame.height {
            curPoint = CGPoint(x: curPoint.x, y: frame.height)
        }
        
        switch aspectRatio {
        case .NvVideoEditAspectRatioMode_Free:
            point = curPoint
            break
        case .NvVideoEditAspectRatioMode_9v16:
            ratioNum = 9.0/16.0
            break
        case .NvVideoEditAspectRatioMode_3v4:
            ratioNum = 3.0/4.0
            break
        case .NvVideoEditAspectRatioMode_9v18:
            ratioNum = 9.0/18.0
            break
        case .NvVideoEditAspectRatioMode_9v21:
            ratioNum = 9.0/21.0
            break
        case .NvVideoEditAspectRatioMode_1v1:
            ratioNum = 1.0
            break
        case .NvVideoEditAspectRatioMode_16v9:
            ratioNum = 16.0/9.0
            break
        case .NvVideoEditAspectRatioMode_4v3:
            ratioNum = 4.0/3.0
            break
        case .NvVideoEditAspectRatioMode_18v9:
            ratioNum = 18.0/9.0
            break
        case .NvVideoEditAspectRatioMode_21v9:
            ratioNum = 21.0/9.0
            break
        }
        let scale: CGFloat = abs(curPoint.x - otherPoint.x)/abs(curPoint.y - otherPoint.y)
        if scale >= self.frame.width/self.frame.height {
            let w = curPoint.x - otherPoint.x
            let h = w/ratioNum
            point = CGPoint(x: otherPoint.x+w, y: otherPoint.y+h)
        } else {
            let h = curPoint.y - otherPoint.y
            let w = h*ratioNum
            point = CGPoint(x: otherPoint.x+w, y: otherPoint.y+h)
        }
        if aspectRatio == .NvVideoEditAspectRatioMode_Free {
            point = curPoint
        }
        
        switch pan.state {
        case .changed:
            self.rightBottomPoint.center = CGPoint(x: point.x, y: point.y)
            self.clipperRect.frame = CGRect(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y, width: point.x - self.clipperRect.frame.origin.x, height: point.y - self.clipperRect.frame.origin.y)
            drawRectLayer()
            drawShapeLayer()
            self.leftTopPoint.center = CGPoint(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y)
            self.leftBottomPoint.center = CGPoint(x: self.clipperRect.frame.origin.x, y: self.clipperRect.frame.origin.y + self.clipperRect.frame.size.height)
            self.rightTopPoint.center = CGPoint(x: self.clipperRect.frame.origin.x + self.clipperRect.frame.size.width, y: self.clipperRect.frame.origin.y)
            self.clipperRect.setNeedsDisplay()
            break
        case .ended:
            ///做动画、给回调
            ///Make animations, give callbacks
            let r: CGFloat = clipperRect.frame.width/clipperRect.frame.height
            var scale: CGFloat = 1
            if r >= self.frame.width/self.frame.height {
                scale = self.frame.width / clipperRect.frame.width
            } else {
                scale = self.frame.height / clipperRect.frame.height
            }
            weak var weakSelf = self
            delegate?.cropperRectViewTouchEnd(cropperRectView: self, cropperRectViewCenter: self.center,cropperRectCenter: clipperRect.center,scale: scale)
            doAnimation { (finish) in
                if finish {
                    weakSelf?.delegate?.cropperRectViewMoveEnd(cropperRectView: weakSelf)
                }
            }
            break
        default:
            break
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if point.y < self.frame.minY || point.y > self.frame.maxY {
            return false
        }
        
        if leftTopPoint.frame.contains(point) ||
            leftBottomPoint.frame.contains(point) ||
            rightTopPoint.frame.contains(point) ||
            rightBottomPoint.frame.contains(point) {
            return true
        }
        
        return false//super.point(inside: point, with: event)
    }
    
    private func drawRectLayer() {
        rectLayer.removeFromSuperlayer()
        let rect:CGRect = clipperRect.frame
        let path:UIBezierPath = UIBezierPath.init(rect: rect)
        let points:[CGPoint] = [rect.leftTop(),rect.rightTop(),rect.rightBottom(),rect.leftBottom()]
        addVerticalSepLines(points: points, lineNumber: 3, path: path)
        addHorizontalSepLines(points: points, lineNumber: 3, path: path)
        rectLayer.path = path.cgPath
        self.layer.addSublayer(rectLayer)
    }
    
    private func drawShapeLayer() {
        shapeLayer.removeFromSuperlayer()
        let rect:CGRect = clipperRect.frame
        let path:UIBezierPath = UIBezierPath.init(rect: bounds)
        let innerPath = UIBezierPath.init(rect: rect)
        path.append(innerPath)
        
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.opacity = 0.5
        self.layer.addSublayer(shapeLayer)
    }
    
    private func addVerticalSepLines(points:[CGPoint], lineNumber:Int, path:UIBezierPath) {
        if points.count < 4 {
            return
        }
        let sepCount:CGFloat = CGFloat(lineNumber)
        let leftTopPoint = points[0]
        let rightBottomPoint = points[2]
        let top = leftTopPoint.y
        let left = leftTopPoint.x
        let bottom = rightBottomPoint.y
        let right = rightBottomPoint.x
        
        let xSep = (right - left)/sepCount
        for i in 1..<lineNumber {
            let xValue = left + xSep*CGFloat(i)
            let upperPoint = CGPoint(x: xValue, y: top)
            let bottomPoint = CGPoint(x: xValue, y: bottom)
            path.move(to: upperPoint)
            path.addLine(to: bottomPoint)
        }
        
    }
    
    private func addHorizontalSepLines(points:[CGPoint], lineNumber:Int, path:UIBezierPath) {
        if points.count < 4 {
            return
        }
        let sepCount:CGFloat = CGFloat(lineNumber)
        let leftTopPoint = points[0]
        let rightBottomPoint = points[2]
        let top = leftTopPoint.y
        let left = leftTopPoint.x
        let bottom = rightBottomPoint.y
        let right = rightBottomPoint.x
        
        let ySep = (bottom - top)/sepCount
        for i in 1..<lineNumber {
            let yValue = top + ySep*CGFloat(i)
            let leftPoint = CGPoint(x: left, y: yValue)
            let rightPoint = CGPoint(x: right, y: yValue)
            path.move(to: leftPoint)
            path.addLine(to: rightPoint)
        }
        
    }
}

extension NvCropperRectView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
