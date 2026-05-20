//
//  NvRectView.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit

@objc protocol NvRectViewDelegate: AnyObject {
    
    /// 某个点是否包含贴纸、字幕、水印
    /// Whether a point contains stickers, subtitles, or watermarks
    /// - Parameter point: 点
    func containObjectForPoint(point: CGPoint) -> Bool
    
    /// 手指按住的两个点是否是一个贴纸、字幕、水印
    /// Whether the finger holds two points is a sticker, subtitles, watermark
    /// - Parameters:
    ///   - point: 点
    ///   - otherPoint: 点
    func containSameObjectForPoint(point: CGPoint, otherPoint: CGPoint) -> Bool
    
    /// 手势缩放
    /// Gesture zoom
    /// - Parameter scale: 缩放值
    @objc optional func gestureRectViewPinchScale(scale: CGFloat)
    
    /// 手势旋转
    /// Gesture rotation
    /// - Parameter rotation: 旋转值
    @objc optional func gestureRectViewRotation(rotation: CGFloat)
    
    /// 手势平移
    /// Gesture translation
    /// - Parameters:
    ///   - rectView: 当前对象 rectView
    ///   - currentPoint: 当前点
    ///   - previousPoint: 以前点
    @objc optional func rectView(rectView: NvRectView, currentPoint: CGPoint, previousPoint: CGPoint)
    
    /// 开始点击
    /// Start clicking
    /// - Parameters:
    ///   - rectView: 当前对象 rectView
    ///   - began: 点 Point
    @objc optional func rectView(rectView: NvRectView, began: CGPoint)
    
    /// 开始点击抬起
    /// Start click Lift
    /// - Parameters:
    ///   - rectView: 当前对象 rectView
    ///   - began: 点 Point
    @objc optional func rectView(rectView: NvRectView, touchUpInside: CGPoint)
    
    /// Tap手势
    /// Tap gesture
    /// - Parameters:
    ///   - rectView: 当前对象 rectView
    ///   - upInside: 点 point
    @objc optional func rectView(rectView: NvRectView, touchNone point: CGPoint)
    
    /// 点击结束
    /// Click end
    /// - Parameters:
    ///   - rectView: 当前对象 rectView
    ///   - ended: 点 point
    @objc optional func rectView(rectView: NvRectView, ended: CGPoint)
    
    /// 同时触发所有手势，点击结束时触发的回调，同时结束触发，只会触发一次回调
    /// Trigger all gestures at the same time. Click the callback that is triggered at the end of the trigger, and only one callback is triggered at the end of the trigger
    /// - Parameters:
    ///   - rectView: 当前对象 rectView
    ///   - ended: 点 point
    @objc optional func rectView(rectView: NvRectView?, gesEnded: CGPoint)
    
    /// NvRectView是否被隐藏
    /// Whether NvRectView is hidden
    /// - Parameters:
    ///   - rectView: 当前对象 rectView
    ///   - isHidden: 是否被隐藏
    ///   Be hidden or not
    @objc optional func rectView(rectView: NvRectView, isHidden: Bool)
}

typealias NvTask = (_ cancel : Bool) -> Void

func Nv_Delay(_ time: TimeInterval, task: @escaping ()->()) ->  NvTask? {

    func dispatch_later(block: @escaping ()->()) {
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    var closure: (()->Void)? = task
    var result: NvTask?

    let delayedClosure: NvTask = {
        cancel in
      if let internalClosure = closure {
            if (cancel == false) {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }

    result = delayedClosure

    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
  return result
}

func Nv_Cancel(_ task: NvTask?) {
    task?(true)
}

class NvRectView: UIView {
    
    var hiddenRectLine : Bool!
    weak var delegate: NvRectViewDelegate?
    
    var strokeColor:UIColor = UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1)
    
    private var leftTopPoint:CGPoint = CGPoint(x: 0, y: 0)
    private var rightTopPoint:CGPoint = CGPoint(x: 0, y: 0)
    var rightBottompPoint:CGPoint = CGPoint(x: 0, y: 0)
    private var leftBottomPoint:CGPoint = CGPoint(x: 0, y: 0)
    private var preRotation:CGFloat = 0
    private var prePonit:CGPoint?
    
    private var subRectsPoint: Array<Array<CGPoint>> = Array<Array<CGPoint>>()
    
    private var tap: UITapGestureRecognizer!
    private var pan: UIPanGestureRecognizer!
    private var task: NvTask?
    ///pinch、rotation、pan这些时间同时触发的时候，当手指抬起来的那一刻，手势的end方法会都调用一遍。
    ///When pinch, rotation, and pan are triggered at the same time, the end method of the gesture is invoked the moment the finger is raised.
    ///这个用延迟0.1s调用，当下次调用end的时候取消上次的，使的同时触发时只调用一次end
    ///This is called with a delay of 0.1s, cancelling the last call at the end of the next call, and only calling end once when it is triggered simultaneously
    private var endTask: NvTask?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(self.pinch(gesture:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
        let rotation = UIRotationGestureRecognizer.init(target: self, action: #selector(self.rotation(gesture:)))
        rotation.delegate = self
        self.addGestureRecognizer(rotation)
        pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.pan(gesture:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
        tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tap(gesture:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        tap.require(toFail: pan)
        hiddenRectLine = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 模版，删除手势
    /// Templates, remove gestures
    public func removeGesture() {
        self.removeGestureRecognizer(pan)
        self.removeGestureRecognizer(tap)
    }
    
    ///子类重写这个方法要调用[super setPoints:array];
    ///Subclasses override this method by calling [super setPoints:array];
    ///MARK:重新绘制
    ///MARK: Redraw
    public func setPoints(array: Array<CGPoint>) {
        let pointObj:NSValue = array[0] as NSValue
        self.leftTopPoint = pointObj.cgPointValue
        let pointObj1:NSValue = array[1] as NSValue
        self.leftBottomPoint = pointObj1.cgPointValue
        let pointObj2:NSValue = array[2] as NSValue
        self.rightBottompPoint = pointObj2.cgPointValue
        let pointObj3:NSValue = array[3] as NSValue
        self.rightTopPoint = pointObj3.cgPointValue
        self.subRectsPoint.removeAll()
        setNeedsDisplay()
    }
    
    ///子类重写这个方法要调用[super setPoints:array];
    ///Subclasses override this method by calling [super setPoints:array];
    ///MARK:重新绘制
    ///MARK: Redraw
    public func setPoints(array: Array<CGPoint>, subRectsPoint: Array<Array<CGPoint>>) {
        let pointObj:NSValue = array[0] as NSValue
        self.leftTopPoint = pointObj.cgPointValue
        let pointObj1:NSValue = array[1] as NSValue
        self.leftBottomPoint = pointObj1.cgPointValue
        let pointObj2:NSValue = array[2] as NSValue
        self.rightBottompPoint = pointObj2.cgPointValue
        let pointObj3:NSValue = array[3] as NSValue
        self.rightTopPoint = pointObj3.cgPointValue
        self.subRectsPoint = subRectsPoint
        setNeedsDisplay()
    }
    
    public func getCenter() -> CGPoint {
        return CGPoint.init(x: (self.leftTopPoint.x+self.rightBottompPoint.x)/2, y: (self.leftTopPoint.y+self.rightBottompPoint.y)/2)
    }

    ///MARK:判断点是否在四点围城rect之内
    ///MARK: Determine if the point is within the four-point Siege rect
    public func isInRect(p: CGPoint) ->Bool {
        let pathRef = CGMutablePath()
        pathRef.move(to: CGPoint.init(x: self.leftTopPoint.x, y: self.leftTopPoint.y))
        pathRef.addLine(to: CGPoint.init(x: self.leftBottomPoint.x, y: self.leftBottomPoint.y))
        pathRef.addLine(to: CGPoint.init(x: self.rightBottompPoint.x, y: self.rightBottompPoint.y))
        pathRef.addLine(to: CGPoint.init(x: self.rightTopPoint.x, y: self.rightTopPoint.y))
        let isIn = pathRef.contains(p)
        return isIn
    }
    
    public func setHiddenRectLine(hiddenRectLine: Bool){
        self.hiddenRectLine = hiddenRectLine
        setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        Nv_Cancel(task)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        Nv_Cancel(task)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
//    UIGraphicsGetCurrentContext();
    override func draw(_ rect: CGRect) {
        if self.hiddenRectLine == false {
            let contextRef = UIGraphicsGetCurrentContext()
            contextRef?.setLineCap(CGLineCap.round)
            
            contextRef?.setLineWidth(2)
            contextRef?.setAllowsAntialiasing(true)
            contextRef?.setStrokeColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1)
//            contextRef?.setStrokeColor(strokeColor.cgColor)
            contextRef?.beginPath()
            contextRef?.move(to: CGPoint.init(x: self.leftTopPoint.x, y: self.leftTopPoint.y))
            contextRef?.addLine(to: CGPoint.init(x: self.leftBottomPoint.x, y: self.leftBottomPoint.y))
            contextRef?.addLine(to: CGPoint.init(x: self.rightBottompPoint.x, y: self.rightBottompPoint.y))
            contextRef?.addLine(to: CGPoint.init(x: self.rightTopPoint.x, y: self.rightTopPoint.y))
            contextRef?.addLine(to: CGPoint.init(x: self.leftTopPoint.x, y: self.leftTopPoint.y))
            contextRef?.strokePath()
            
            for points: Array<CGPoint> in subRectsPoint {
                if points.count == 4 {
                    
                    contextRef?.setLineWidth(1)
                    contextRef?.setAllowsAntialiasing(true)
                    contextRef?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                    contextRef?.beginPath()
                    contextRef?.move(to: points[0])
                    contextRef?.addLine(to: points[1])
                    contextRef?.addLine(to: points[2])
                    contextRef?.addLine(to: points[3])
                    contextRef?.addLine(to: points[0])
                    contextRef?.setLineDash(phase: 0, lengths: [2, 2])
                    contextRef?.strokePath()
                }
            }
        }
    }
}

extension NvRectView {
    ///MARK:捏合手势
    ///MARK: PinchGesture
    @objc func pinch(gesture: UIPinchGestureRecognizer) {
        var scale:CGFloat = 1
        switch gesture.state {
        case UIGestureRecognizer.State.began:
            scale = 1
            let point:CGPoint = gesture.location(in: self)
            delegate?.rectView?(rectView: self, began: point)
        case UIGestureRecognizer.State.changed:
            scale = gesture.scale
            delegate?.gestureRectViewPinchScale?(scale: scale)
            gesture.scale = 1
        case UIGestureRecognizer.State.cancelled:break
        case UIGestureRecognizer.State.failed:break
        case UIGestureRecognizer.State.ended:
            let point:CGPoint = gesture.location(in: self)
            delegate?.rectView?(rectView: self, ended: point)
            scale = 1
            if endTask != nil {
                Nv_Cancel(endTask)
            }
            weak var weakSelf = self
            endTask = Nv_Delay(0.1) {
                weakSelf?.delegate?.rectView?(rectView: weakSelf, gesEnded: point)
                weakSelf?.endTask = nil
            }
        default: break
        }
    }
    ///MARK:旋转手势
    ///MARK:RotationGesture
    @objc func rotation(gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizer.State.began:
            let point:CGPoint = gesture.location(in: self)
            delegate?.rectView?(rectView: self, began: point)
        case UIGestureRecognizer.State.changed:
            let angle:CGFloat = -(gesture.rotation-self.preRotation)*180/CGFloat(Double.pi)
            delegate?.gestureRectViewRotation?(rotation: angle)
            self.preRotation = gesture.rotation
        case UIGestureRecognizer.State.cancelled: break
        case UIGestureRecognizer.State.failed: break
        case UIGestureRecognizer.State.ended:
            self.preRotation = 0
            let point:CGPoint = gesture.location(in: self)
            delegate?.rectView?(rectView: self, ended: point)
            if endTask != nil {
                Nv_Cancel(endTask)
            }
            weak var weakSelf = self
            endTask = Nv_Delay(0.1) {
                weakSelf?.delegate?.rectView?(rectView: weakSelf, gesEnded: point)
                weakSelf?.endTask = nil
            }
        default: break
        }
    }
    ///MARK:平移手势
    ///MARK:PanGesture
    @objc func pan(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        let pointP = gesture.translation(in: self)
        ///点击空白处
        ///Click on the blank space
        let contain = delegate?.containObjectForPoint(point: point)
        if !contain! {
//            delegate?.rectView?(rectView: self, touchNone: point)
            return
        }
        
        if !self.bounds.contains(point) {
//            gesture.isEnabled = false
        }
        switch gesture.state {
        case UIGestureRecognizer.State.began:
            self.prePonit = point
            let pointbegin = gesture.location(in: self)
            delegate?.rectView?(rectView: self, began: pointbegin)
        case UIGestureRecognizer.State.changed:
            delegate?.rectView?(rectView: self, currentPoint: point, previousPoint: CGPoint.init(x: point.x-pointP.x, y: point.y-pointP.y))
            gesture.setTranslation(CGPoint.zero, in: self)
            self.prePonit = point;
        case UIGestureRecognizer.State.cancelled: break
        case UIGestureRecognizer.State.failed: break
        case UIGestureRecognizer.State.ended:
            delegate?.rectView?(rectView: self, ended: point)
            if endTask != nil {
                Nv_Cancel(endTask)
            }
            weak var weakSelf = self
            endTask = Nv_Delay(0.1) {
                weakSelf?.delegate?.rectView?(rectView: weakSelf, gesEnded: point)
                weakSelf?.endTask = nil
            }
        default: break
        }
    }
    ///MARK:点击手势
    ///MARK:TapGesture
    @objc func tap(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        ///点击空白处
        ///Click on the blank space
        let contain = delegate?.containObjectForPoint(point: point)
        if !contain! {
            delegate?.rectView?(rectView: self, touchNone: point)
            return
        }
        
        delegate?.rectView?(rectView: self, began: point)
        delegate?.rectView?(rectView: self, ended: point)
        
        task = Nv_Delay(0.25) {
            self.delegate?.rectView?(rectView: self, touchUpInside: point)
        }
        switch gesture.state {
        case .began:
            break
        case .ended:
            break
        default:
            break
        }
    }
    
}

extension NvRectView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let num = gestureRecognizer.numberOfTouches
        if num == 1 {
            if gestureRecognizer == self.tap {
                return true
            }
            if gestureRecognizer == self.pan {
                let firstPonit = gestureRecognizer.location(ofTouch: 0, in: self)
                let containFirst:Bool? = delegate?.containObjectForPoint(point: firstPonit)
                ///判断是否包含右下角让缩放旋转更灵敏
                ///Determine if the lower right corner is included to make the zoom rotation more sensitive
                let contains = CGRect(x: rightBottompPoint.x - 10, y: rightBottompPoint.y - 10, width: 30, height: 30).contains(firstPonit)
                if containFirst != nil && containFirst! && !contains {
                    return true
                }else{
                    return false
                }
            }
            return true
        }else if num == 2{
            let firstPonit = gestureRecognizer.location(ofTouch: 0, in: self)
            let lastPonit = gestureRecognizer.location(ofTouch: 1, in: self)
            return delegate?.containSameObjectForPoint(point: firstPonit, otherPoint: lastPonit) ?? false
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}
