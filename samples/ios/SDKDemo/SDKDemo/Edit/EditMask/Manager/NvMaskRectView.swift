//
//  NvMaskRectView.swift
//  MYVideo
//
//  Created by 美摄 on 2020/7/14.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore

@objc protocol NvMaskRectViewDelegate : NSObjectProtocol {
    func maskModelChanged(maskModel: NvMaskModel)
    func maskTap(maskModel: NvMaskModel)
}

class NvMaskRectView: UIView {
    
    @objc weak var delegate:NvMaskRectViewDelegate?
    
    let minMaskScale:CGFloat = 0.1
    let maxMaskScale:CGFloat = 10
    
    let minMaskDirectionScale:CGFloat = 0.5
    let maxMaskDirectionScale:CGFloat = 2
    
    let maxFeather:CGFloat = 1000
    
    ///按钮到线的距离
    ///Distance from button to line
    let btInterval:CGFloat = 60
    let featherDistance:CGFloat = 60
    
    let shapeLayer:CAShapeLayer = CAShapeLayer()
    
    var assetResolution:CGSize = .zero
    var timelineResolution:NvsVideoResolution = NvsVideoResolution(imageWidth: 0, imageHeight: 0, imagePAR: NvsRational(num: 1, den: 1), bitDepth: NvsVideoResolutionBitDepth_8Bit)
    
    var textSize:CGSize = .zero
    
    var liveWindow:NvsLiveWindow!
    
    let featherImageView = UIImageView()
    let cornerRadiusImageView = UIImageView()
    let horizontalScaleImageView = UIImageView()
    let verticalScaleImageView = UIImageView()
    
    private var pinchGesture:UIPinchGestureRecognizer!
    private var rotationGesture:UIRotationGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
    private var propertyBackgroundTransformModel:NvTransformModel?
    
    var videoClip:NvsVideoClip?

    override init(frame: CGRect) {
        super.init(frame: frame)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGester(pinch:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(rotation:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1).cgColor
        shapeLayer.lineWidth = 1
        layer.addSublayer(shapeLayer)
        
        featherImageView.image = UIImage(named: "mask_feather")
        featherImageView.contentMode = .center
        featherImageView.isUserInteractionEnabled = true
        let btPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleButtonPan(gesture:)))
        featherImageView.addGestureRecognizer(btPanGesture)
        self.addSubview(featherImageView)
        cornerRadiusImageView.image = UIImage(named: "mask_cornerRadius")
        cornerRadiusImageView.contentMode = .center
        cornerRadiusImageView.isUserInteractionEnabled = true
        let cornerRadiusPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleButtonPan(gesture:)))
        cornerRadiusImageView.addGestureRecognizer(cornerRadiusPanGesture)
        cornerRadiusImageView.isHidden = true
        self.addSubview(cornerRadiusImageView)
        horizontalScaleImageView.image = UIImage(named: "mask_hscale")
        horizontalScaleImageView.contentMode = .center
        horizontalScaleImageView.isUserInteractionEnabled = true
        let horizontalScalePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleButtonPan(gesture:)))
        horizontalScaleImageView.addGestureRecognizer(horizontalScalePanGesture)
        horizontalScaleImageView.isHidden = true
        self.addSubview(horizontalScaleImageView)
        verticalScaleImageView.image = UIImage(named: "mask_vscale")
        verticalScaleImageView.contentMode = .center
        verticalScaleImageView.isUserInteractionEnabled = true
        let verticalScalePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleButtonPan(gesture:)))
        verticalScaleImageView.addGestureRecognizer(verticalScalePanGesture)
        verticalScaleImageView.isHidden = true
        self.addSubview(verticalScaleImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func refreshTimelinePreview(){
        var maskModel:NvMaskModel? = videoClip?.maskModel
        if maskModel == nil {
            maskModel = NvMaskModel()
        }
        delegate?.maskModelChanged(maskModel: maskModel!)
    }
    
    @objc public func loadMaskModel(videoClip:NvsVideoClip,
                              liveWindow:NvsLiveWindow,
                              timelineResolution:NvsVideoResolution,
                              assetResolution:CGSize,
                              transformModel:NvTransformModel?){
        
        textSize = .zero
        let assetAspectRatio = assetResolution.width/assetResolution.height
        self.assetResolution = assetResolution
        self.timelineResolution = timelineResolution
        self.propertyBackgroundTransformModel = transformModel
        self.videoClip = videoClip
        self.liveWindow = liveWindow
        let maskModel:NvMaskModel = videoClip.maskModel
        if maskModel.maskType == .none {
            self.isHidden = true
        }else{
            self.isHidden = false
            // 素材 未经属性特技移动缩放时，在livewindow（UI）上的大小
            // The size of the material on the livewindow (UI) without the property effects
            let assetSize = NvMaskHelper.assetSizeInBox(boxSize: liveWindow.frame.size, assetAspectRatio: assetAspectRatio)
            loadMaskModel(maskModel: maskModel, liveWindow: liveWindow, assetResolution: assetResolution, assetSize: assetSize,transformModel:transformModel)
        }
    }
    
    private func refreshMaskLinePreview(){
        if videoClip != nil {
            let maskModel:NvMaskModel = videoClip!.maskModel
            let assetAspectRatio = assetResolution.width/assetResolution.height
            // 素材 未经属性特技移动缩放时，在livewindow（UI）上的大小
            // The size of the material on the livewindow (UI) without the property effects
            let assetSize = NvMaskHelper.assetSizeInBox(boxSize: liveWindow.frame.size, assetAspectRatio: assetAspectRatio)
            loadMaskModel(maskModel: maskModel, liveWindow: liveWindow, assetResolution: assetResolution, assetSize: assetSize,transformModel:propertyBackgroundTransformModel)
        }
    }
    
    /// 画蒙版线
    /// Draw a mask line
    ///
    /// - Parameters:
    ///   - maskModel: 蒙版数据
    ///   - liveWindow: liveWindow
    ///   - assetResolution: 素材宽高
    ///   - assetSize: 素材在livewindow（UI）上的大小 The size of the material on the livewindow (UI)
    ///   - transformModel: 属性特技transform的数据 Property Stunt transform data
    private func loadMaskModel(maskModel:NvMaskModel,
                               liveWindow:NvsLiveWindow,
                               assetResolution:CGSize,
                               assetSize:CGSize,
                               transformModel:NvTransformModel?){
        self.liveWindow = liveWindow
        self.transform = .identity
        
        cornerRadiusImageView.isHidden = true
        horizontalScaleImageView.isHidden = true
        verticalScaleImageView.isHidden = true
        
        if maskModel.maskType == .none {
            featherImageView.isHidden = true
            shapeLayer.path = nil
            return
        }else{
            featherImageView.isHidden = false
        }
        
        /// 蒙版初始可绘制区域（UI）大小
        /// The mask's initial paintable area (UI) size
        var size:CGSize = .zero
        if maskModel.maskType == .text {
            if textSize == .zero {
                textSize = getTextSize()
            }
            size = CGSize(width: textSize.width * CGFloat(maskModel.transform.scaleX), height: textSize.height * CGFloat(maskModel.transform.scaleY))
        }else{
            size = NvMaskHelper.boxMaskSize(maskModel: maskModel, liveWindowSize: liveWindow.frame.size, assetResolution: assetResolution,assetSize:assetSize)
        }
        let displayWidth = size.width + 2*btInterval + 2*featherDistance
        let displayHeight = size.height + 2*btInterval + 2*featherDistance
        self.frame = CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight)

        featherImageView.frame = CGRect(x: 0, y: 0, width: btInterval, height: btInterval)
        featherImageView.center = CGPoint(x: displayWidth*0.5, y: (displayHeight+size.height+btInterval)*0.5 + featherDistance*(maskModel.feather / maxFeather))
        featherImageView.transform = .identity
        featherImageView.isHidden = false
        horizontalScaleImageView.frame = CGRect(x: 0, y: 0, width: btInterval, height: btInterval)
        verticalScaleImageView.frame = CGRect(x: 0, y: 0, width: btInterval, height: btInterval)
        
        verticalScaleImageView.center = CGPoint(x: displayWidth*0.5, y: (displayHeight-size.height-btInterval)*0.5)
        horizontalScaleImageView.center = CGPoint(x: (displayWidth+size.width+btInterval)*0.5, y: displayHeight*0.5)
        
        let pathCenter = CGPoint(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5)
        if maskModel.maskType == .line {
            let path = NvMaskHelper.linePath(center: pathCenter, aSize: assetSize, liveWindowSize: liveWindow.frame.size, rotation: 0)
            shapeLayer.path = path.cgPath
        }else if maskModel.maskType == .mirror {
            let path = NvMaskHelper.mirrorPath(center: pathCenter, aSize: assetSize, liveWindowSize: liveWindow.frame.size, rotation: 0, scale: CGFloat(maskModel.transform.scaleX))
            shapeLayer.path = path.cgPath
        }else if maskModel.maskType == .rect {
            cornerRadiusImageView.isHidden = false
            horizontalScaleImageView.isHidden = false
            verticalScaleImageView.isHidden = false
            
            let path = NvMaskHelper.rectPath(center: pathCenter,maskSize: size,cornerRadiusRate: maskModel.cornerRadiusRate)
            shapeLayer.path = path.cgPath
            
            let maxCorner = size.height * 0.5
            let cornerRadius = maskModel.cornerRadiusRate*size.height*0.5
            var length:CGFloat = cornerRadius / maxCorner * featherDistance
            length = CGFloat(sqrtf(Float(length*length/2)))
            cornerRadiusImageView.frame = CGRect(x: 0, y: 0, width: btInterval, height: btInterval)
            cornerRadiusImageView.center = CGPoint(x: (displayWidth-size.width)*0.5-btInterval*0.3 - length, y: (displayHeight-size.height)*0.5-btInterval*0.3 - length)
        }else if maskModel.maskType == .circle {
            horizontalScaleImageView.isHidden = false
            verticalScaleImageView.isHidden = false
            let path = NvMaskHelper.circlePath(center:pathCenter,maskSize:size,rotation:0)
            shapeLayer.path = path.cgPath
        }else if maskModel.maskType == .star {
            let path = NvMaskHelper.startPath(center: pathCenter, width: size.width,rotation:0)
            shapeLayer.path = path.cgPath
        }else if maskModel.maskType == .text {
            featherImageView.isHidden = true
            let path = NvMaskHelper.textPath(center: pathCenter,maskSize: size)
            shapeLayer.path = path.cgPath
            
        }else{
            let path = NvMaskHelper.heartPath(center: pathCenter, width: size.width,rotation:0)
            shapeLayer.path = path.cgPath
        }
        
        //INFO: 处理镜像 导致移动方向相反
        //INFO: Processing image causes movement in opposite direction
        var maskTransformX = CGFloat(maskModel.transform.transformX)
        if let tModel = transformModel {
            if tModel.scaleX < 0 {
                maskTransformX *= -1
            }
        }
        self.center = getMaskCenterPoint(liveWindow: liveWindow,
                                         maskTransformX: maskTransformX,
                                         maskTransformY: CGFloat(maskModel.transform.transformY),
                                         assetResolution: assetResolution,
                                         assetSize: assetSize,
                                         timelineVideoRes: timelineResolution,
                                         transformModel: propertyBackgroundTransformModel)
        
        
        self.transform = CGAffineTransform(rotationAngle: CGFloat(maskModel.transform.rotation) - CGFloat(transformModel?.rotation ?? 0)/180*CGFloat(Double.pi))
        self.transform = self.transform.scaledBy(x: abs(CGFloat(transformModel?.scaleX ?? 1)), y: CGFloat(transformModel?.scaleY ?? 1))
    }
    
    func getTextSize() -> CGSize {
        let maskModel:NvMaskModel? = videoClip?.maskModel
        if maskModel == nil || maskModel!.maskType != .text {
            return .zero
        }
        let messtr = maskModel!.text as NSString
        let fontSize = liveWindow.frame.size.width*maskModel!.heightRateOfWidth
        let textSize = messtr.size(withAttributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: fontSize)])
        
        let textInterval:CGFloat = 10
        return CGSize(width: textSize.width + textInterval, height: textSize.height + textInterval)
    }
    
    /// 获取蒙版在UI上的中心点
    /// Gets the center point of the mask on the UI
    /// - Parameters:
    ///   - liveWindow: liveWindow
    ///   - maskTransformX: 蒙版的移动值X
    ///   - maskTransformY: 蒙版的移动值Y
    ///   - assetResolution: 素材的宽高
    ///   - assetSize: 素材在livewindow（UI）上的大小 The size of the material on the livewindow (UI)
    ///   - timelineVideoRes: timeline的宽高
    ///   - transformModel: 属性特技的transform的值 The value of the transform of the property stunt
    /// - Returns: 蒙版在UI上的中心点 The mask is at the center of the UI
    func getMaskCenterPoint(liveWindow:NvsLiveWindow,
                            maskTransformX:CGFloat,
                            maskTransformY:CGFloat,
                            assetResolution:CGSize,
                            assetSize:CGSize,
                            timelineVideoRes:NvsVideoResolution,
                            transformModel:NvTransformModel?) -> CGPoint {
        
        let transformRate:CGFloat = liveWindow.frame.size.width/CGFloat(timelineVideoRes.imageWidth)
        let transform:CGPoint = CGPoint(x: CGFloat(transformModel?.transformX ?? 0)*transformRate, y: CGFloat(transformModel?.transformY ?? 0)*transformRate)
        
        let rate = assetSize.width/assetResolution.width
        let tmpPoint = CGPoint(x: maskTransformX*rate*abs(CGFloat(transformModel?.scaleX ?? 1)), y: maskTransformY*rate*CGFloat(transformModel?.scaleY ?? 1))
        let tmpPoint2 = NvLineTool.pointRotatedAroundAnchorPoint(point: tmpPoint, anchorPoint: CGPoint(x: 0, y: 0), angle: CGFloat(-(transformModel?.rotation ?? 0)/180*Double.pi))
        var maskCenter = liveWindow.center
        maskCenter.x += transform.x + tmpPoint2.x
        maskCenter.y += -transform.y + tmpPoint2.y
        return maskCenter
    }
    
    @objc private func handlePinchGester(pinch:UIPinchGestureRecognizer){
        switch pinch.state {
        case .changed:
            if pinch.numberOfTouches < 2 {
                break
            }else{
                let scaleChange = pinch.scale - 1
                pinch.scale = 1
                let maskModel:NvMaskModel? = videoClip?.maskModel
                if maskModel == nil || maskModel!.maskType == .none || maskModel!.maskType == .line {
                    return
                }
                maskModel?.transform.scaleX += Double(scaleChange)
                if maskModel != nil{
                    maskModel!.transform.scaleX = maskModel!.transform.scaleX > Double(maxMaskScale) ? Double(maxMaskScale) : maskModel!.transform.scaleX
                    maskModel!.transform.scaleX = maskModel!.transform.scaleX < Double(minMaskScale) ? Double(minMaskScale) : maskModel!.transform.scaleX
                    maskModel!.transform.scaleY = maskModel!.transform.scaleX
                    NvMaskHelper.prepareMaskRegionPoints(maskModel: maskModel!, assetResolution: assetResolution)
                    videoClip?.setMask(maskModel: maskModel!, resolution: assetResolution)
                    refreshMaskLinePreview()
                    refreshTimelinePreview()
                }
                
            }
            break
        default:
            break
        }
    }
    
    @objc private func handleRotationGesture(rotation:UIRotationGestureRecognizer){
        switch rotation.state {
        case .changed:
            let maskModel:NvMaskModel? = videoClip?.maskModel
            maskModel?.transform.rotation += Double(rotation.rotation)
            rotation.rotation = 0
            if maskModel != nil {
                NvMaskHelper.prepareMaskRegionPoints(maskModel: maskModel!, assetResolution: assetResolution)
                videoClip?.setMask(maskModel: maskModel!, resolution: assetResolution)
                refreshMaskLinePreview()
                refreshTimelinePreview()
            }
            break
        default:
            break
        }
    }
    
    
    @objc private func handleTap(gesture:UITapGestureRecognizer){
        delegate?.maskTap(maskModel: videoClip!.maskModel)
    }
    
    @objc private func handlePan(gesture:UIPanGestureRecognizer){
        switch gesture.state {
        case .changed:
            var translation = gesture.translation(in: self.superview)
            gesture.setTranslation(.zero, in: self.superview)
            
            let maskModel:NvMaskModel? = videoClip?.maskModel
            if maskModel == nil {
                return
            }
            
            let assetAspectRatio = assetResolution.width/assetResolution.height
            let assetSize = NvMaskHelper.assetSizeInBox(boxSize: liveWindow.frame.size, assetAspectRatio: assetAspectRatio)
            //INFO: 处理镜像 导致移动方向相反
            //INFO: Processing images causes movement in the opposite direction
            if let transformModel = propertyBackgroundTransformModel {
                if transformModel.scaleX < 0 {
                    translation.x *= -1
                }
            }
            
            let rotationTranslationPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: translation, anchorPoint: CGPoint(x: 0, y: 0), angle:CGFloat((propertyBackgroundTransformModel?.rotation ?? 0)/180*Double.pi))
             
            let rate = assetSize.width/assetResolution.width
            let transX = CGFloat(maskModel!.transform.transformX) + rotationTranslationPoint.x/rate
            let transY = CGFloat(maskModel!.transform.transformY) + rotationTranslationPoint.y/rate
            
            let nCenter = getMaskCenterPoint(liveWindow: liveWindow, maskTransformX: transX, maskTransformY: transY, assetResolution: assetResolution, assetSize: assetSize, timelineVideoRes: timelineResolution, transformModel: propertyBackgroundTransformModel)
            if liveWindow.frame.contains(nCenter) == false {
                return
            }

            maskModel?.move(translation: translation, assetSize: liveWindow.frame.size, assetResolution: CGSize(width: CGFloat(timelineResolution.imageWidth), height: CGFloat(timelineResolution.imageHeight)), transformModel: propertyBackgroundTransformModel)
            
            if maskModel != nil {
                NvMaskHelper.prepareMaskRegionPoints(maskModel: maskModel!, assetResolution: assetResolution)
                videoClip?.setMask(maskModel: maskModel!, resolution: assetResolution)
                refreshMaskLinePreview()
                refreshTimelinePreview()
            }
            break
        default:
            break
        }
    }
    
    
    @objc private func handleButtonPan(gesture:UIPanGestureRecognizer){
    switch gesture.state {
    case .changed:
        let translation = gesture.translation(in: self)
        gesture.setTranslation(.zero, in: self)
        
        let maskModel:NvMaskModel? = videoClip?.maskModel
        if maskModel != nil {
            let assetAspectRatio = assetResolution.width/assetResolution.height
            let assetSize = NvMaskHelper.assetSizeInBox(boxSize: liveWindow.frame.size, assetAspectRatio: assetAspectRatio)
            let size = NvMaskHelper.boxMaskSize(maskModel: maskModel!, liveWindowSize: liveWindow.frame.size, assetResolution: assetResolution,assetSize:assetSize)
            if gesture.view == featherImageView {
                if translation.y == 0 {
                    return
                }
                maskModel!.feather += translation.y/featherDistance*maxFeather
                maskModel!.feather = maskModel!.feather < 0 ? 0 : maskModel!.feather
                maskModel!.feather = maskModel!.feather > maxFeather ? maxFeather : maskModel!.feather
            }else if gesture.view == horizontalScaleImageView {
                if translation.x == 0 {
                    return
                }
                maskModel!.horizontalScale += translation.x/size.width
                maskModel!.horizontalScale = maskModel!.horizontalScale < minMaskDirectionScale ? minMaskDirectionScale : maskModel!.horizontalScale
                maskModel!.horizontalScale = maskModel!.horizontalScale > maxMaskDirectionScale ? maxMaskDirectionScale : maskModel!.horizontalScale
            }else if gesture.view == verticalScaleImageView {
                if translation.y == 0 {
                    return
                }
                maskModel!.verticalScale -= translation.y/size.height
                maskModel!.verticalScale = maskModel!.verticalScale < minMaskDirectionScale ? minMaskDirectionScale : maskModel!.verticalScale
                maskModel!.verticalScale = maskModel!.verticalScale > maxMaskDirectionScale ? maxMaskDirectionScale : maskModel!.verticalScale
            }else if gesture.view == cornerRadiusImageView {
                let maxCorner = size.height * 0.5
                let trans = CGFloat(sqrtf(Float(translation.x*translation.x+translation.y*translation.y)))*(translation.x>0 ? -1 : 1)
                var cornerRadius = maskModel!.cornerRadiusRate*maxCorner
                cornerRadius += trans/featherDistance*maxCorner
                cornerRadius = cornerRadius < 0 ? 0 : cornerRadius
                cornerRadius = cornerRadius > maxCorner ? maxCorner : cornerRadius
                maskModel!.cornerRadiusRate = cornerRadius/maxCorner
            }
            NvMaskHelper.prepareMaskRegionPoints(maskModel: maskModel!, assetResolution: assetResolution)
            videoClip?.setMask(maskModel: maskModel!, resolution: assetResolution)
            refreshMaskLinePreview()
            refreshTimelinePreview()
        }
        
    break
        default:
            break
        }
    }
}

/// 手势代理
/// Gesture agent
extension NvMaskRectView:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == rotationGesture && otherGestureRecognizer == pinchGesture {
            return true
        }
        if gestureRecognizer == pinchGesture && otherGestureRecognizer == rotationGesture {
            return true
        }
        return false
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pinchGesture && gestureRecognizer.numberOfTouches < 2 {
            return false
        }
        if gestureRecognizer == panGesture {
            let views = [featherImageView,horizontalScaleImageView,verticalScaleImageView,cornerRadiusImageView]
            let location = gestureRecognizer.location(in: self)
            for view in views {
                if view.frame.contains(location) {
                    return false
                }
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
