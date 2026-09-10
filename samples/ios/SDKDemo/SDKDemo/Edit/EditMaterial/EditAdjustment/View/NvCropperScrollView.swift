//
//  NvCropperView.swift
//  MYVideo
//
//  Created by 美摄 on 2020/4/21.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import Photos
import NvStreamingSdkCore
@objc enum NvVideoEditAspectRatioMode : Int {
    case NvVideoEditAspectRatioMode_Free = 0
    case NvVideoEditAspectRatioMode_9v16
    case NvVideoEditAspectRatioMode_3v4
    case NvVideoEditAspectRatioMode_9v18
    case NvVideoEditAspectRatioMode_9v21
    case NvVideoEditAspectRatioMode_1v1
    case NvVideoEditAspectRatioMode_16v9
    case NvVideoEditAspectRatioMode_4v3
    case NvVideoEditAspectRatioMode_18v9
    case NvVideoEditAspectRatioMode_21v9

}

class NvCropperScrollView: UIView ,UIScrollViewDelegate, UIGestureRecognizerDelegate {
    /// 
    private let operateEdge:CGFloat = 0
    private let contentView:UIView = UIView()
    private let bottomControl = NvCropperBottomView()
    
    private let streamingContext = NvsStreamingContext.sharedInstance(withFlags: NvsStreamingContextFlag(NvsStreamingContextFlag_Support4KEdit.rawValue | NvsStreamingContextFlag_InterruptStopForInternalStop.rawValue))!
    private var liveWindow: NvsLiveWindow!
    
    private var liveWindowContentScrollView: UIScrollView!
    
    private var calculateMaterialRectView:UIView = UIView()
    
    /// 自由比例下计算/调试view
    /// Calculate/debug view in free scale
    private var calculateMaterialLiveWindowView:UIView = UIView()
    
    @objc public var cropperTimeline: NvsTimeline!
    
    
    private var cropperRectView:NvCropperRectView!
    
    /// 素材宽高
    /// Width and height of material
    private var originImageSize:CGSize = .zero
    private var originImageFrame:CGRect = .zero
    private var originRectFrame:CGRect = .zero

    
    private var transRate:CGFloat = 1
    
    private var minScale:CGFloat = 1
    private let maxScale:CGFloat = 5
    
    private var shapeLayer:CAShapeLayer = CAShapeLayer()
    private var tapGes:UITapGestureRecognizer!
    private var clipModelSourceInfo:NvSourceInfo!
    public var crpperModel:NvCropperModel!
    
    private var videoClip: NvsVideoClip?
    private var transFx: NvsVideoFx?
    private var storeCurrentImageRectPoints:(leftTop:CGPoint,
    leftBottom:CGPoint,
    rightTop:CGPoint,
    rightBottom:CGPoint,
    imageCenter:CGPoint)!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews(bounds: bounds)
        tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tapMethod))
        self.liveWindowContentScrollView.addGestureRecognizer(tapGes)
        tapGes.delegate = self
        streamingContext.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews(bounds: CGRect){
        clipsToBounds = true
        backgroundColor = .clear
        
        let bottomControlHeight = 40*Cropper_SCREENSCALE
        
        addSubview(contentView)
        contentView.frame = CGRect(x: operateEdge, y: operateEdge, width: bounds.width - 2*operateEdge, height: bounds.height - 2*operateEdge)
        contentView.clipsToBounds = true
        
        liveWindow = NvsLiveWindow(frame: contentView.bounds)
        liveWindow.fillMode = NvsLiveWindowFillModePreserveAspectFit
        liveWindow.isUserInteractionEnabled = false
        
        liveWindow.hdrDisplayMode = self.getLiveWindowModel()
        
        calculateMaterialLiveWindowView.alpha = 0
        calculateMaterialLiveWindowView.backgroundColor = .red
        liveWindow.addSubview(calculateMaterialLiveWindowView)
        
        liveWindowContentScrollView = UIScrollView(frame: contentView.bounds)
        liveWindowContentScrollView.backgroundColor = .clear
        liveWindowContentScrollView.maximumZoomScale = maxScale
        liveWindowContentScrollView.minimumZoomScale = 1.0
        liveWindowContentScrollView.bounces = false
        liveWindowContentScrollView.delegate = self
        liveWindowContentScrollView.clipsToBounds = false
        liveWindowContentScrollView.showsVerticalScrollIndicator = false
        liveWindowContentScrollView.showsHorizontalScrollIndicator = false
        liveWindowContentScrollView.addSubview(liveWindow)
        
        calculateMaterialRectView.alpha = 0
        contentView.addSubview(calculateMaterialRectView)
        contentView.addSubview(liveWindowContentScrollView)
        
        cropperRectView = NvCropperRectView(frame: contentView.bounds)
        cropperRectView.delegate = self
        contentView.addSubview(cropperRectView)
        
        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        bottomControl.delegate = self
        addSubview(bottomControl)
        bottomControl.frame = CGRect(x: 0, y: frame.size.height - bottomControlHeight, width: frame.size.width, height: bottomControlHeight)
        
        bottomControl.isHidden = false
        delayHidden()
    }
    
    fileprivate func delayHidden() ->Void {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(delayAction), object: nil)
        perform(#selector(delayAction), with: nil, afterDelay: 3.0)
    }
    
    @objc fileprivate func delayAction() ->Void {
        self.bottomControl.isHidden = true
    }
    
    @objc private func tapMethod() ->Void {
        bottomControl.isHidden = false
        delayHidden()
    }
    
    @objc public func setupExtraScaleX(_ scaleX:CGFloat) {
        transFx?.setFloatVal("Scale X", val: Double(scaleX))
        self.crpperModel.extraScaleX = scaleX
    }
    
    @objc public func setupExtraScaleY(_ scaleY:CGFloat) {
        transFx?.setFloatVal("Scale Y", val: Double(scaleY))
        self.crpperModel.extraScaleY = scaleY
    }
    
    @objc public func setupExtraRotation(_ rotation:CGFloat) {
        self.crpperModel.extraRotation = rotation/180*CGFloat(Double.pi)
        resetRotateAngle(angle: CGFloat(self.crpperModel.rotation))
    }

    func getLiveWindowModel() -> NvsLiveWindowHDRDisplayMode {
        var liveWindowModel = NvsLiveWindowHDRDisplayMode_SDR
        let number :NSNumber? = UserDefaults.standard.object(forKey: "NvLiveWindowModel") as? NSNumber
        if (number?.intValue == 1) {
            liveWindowModel = NvsLiveWindowHDRDisplayMode_SDR
        }else if (number?.intValue == 3){
            liveWindowModel = NvsLiveWindowHDRDisplayMode_TONE_MAP_SDR
        }else if (number?.intValue == 4){
            liveWindowModel = NvsLiveWindowHDRDisplayMode_Device
        }
        
        return liveWindowModel
    }
    
    func getVideoResolution() -> NvsVideoResolutionBitDepth {
        var bitDepth = NvsVideoResolutionBitDepth_8Bit
        let number :NSNumber? = UserDefaults.standard.object(forKey: "NvResolutionConfiguration") as? NSNumber
        if (number?.intValue == 1) {
            bitDepth = NvsVideoResolutionBitDepth_8Bit
        }else if (number?.intValue == 2){
            bitDepth = NvsVideoResolutionBitDepth_16Bit_Float
        }else if(number?.intValue == 3){
            bitDepth = NvsVideoResolutionBitDepth_Auto
        }
        
        return bitDepth
    }
    
    /// 设置页面数据
    /// Set page data
    /// - Parameters:
    ///   - clipModel: 片段
    ///   clip
    ///   - timelineVideoRes: 预览timeline宽高
    ///   Preview the timeline width height
    ///   - liveWindowSize: 预览窗口宽高
    ///   Preview window width and height
    @objc public func setupData(sourceInfo:NvSourceInfo,currentTime:Int64,crpperModel:NvCropperModel,timelineVideoRes:NvsVideoResolution,editViewLiveWindow:NvsLiveWindow){
        
        let assetAspectRatio = CGFloat(sourceInfo.pixelWidth)/CGFloat(sourceInfo.pixelHeight)
        
        liveWindowContentScrollView.transform = .identity
        
        cropperRectView.aspectRatio = crpperModel.cropperRatio
        cropperRectView.assetAspectRatio = crpperModel.cropperAssetAspectRatio
        cropperRectView.updateCropperFrame()
        originRectFrame = cropperRectView.rectFrame()
        
        self.clipModelSourceInfo = sourceInfo
        self.crpperModel = crpperModel.modelCopy()
        
        self.crpperModel.rotation = -crpperModel.rotation/180*Double.pi
        
        self.crpperModel.extraRotation = -crpperModel.extraRotation/CGFloat(180)*CGFloat(Double.pi)
        
        
        
        let videoSize:NvsSize = NvCropperHelper.calculateTimelineSize(editMode: .NvVideoEditAspectRatioMode_Free,originAspectRatio:assetAspectRatio)
        
        originImageSize = CGSize(width: CGFloat(videoSize.width), height: CGFloat(videoSize.height))
        
        originImageFrame = originFrameForLiveWindow(videoRes:originImageSize,rectViewRect: originRectFrame,scale: 1)
        
        liveWindowContentScrollView.transform = .identity
        calculateMaterialRectView.transform = .identity
        
        calculateMaterialRectView.frame = originRectFrame
        let cRectTransform = CGAffineTransform(rotationAngle: CGFloat(-self.crpperModel.rotation)-self.crpperModel.extraRotation)
        calculateMaterialRectView.transform = cRectTransform
        let transRectFrame = calculateMaterialRectView.frame
        let preBoundsSize = originFrameForLiveWindow(videoRes:originImageSize,rectViewRect: originRectFrame,scale: 1).size
        let frame = originFrameForLiveWindow(videoRes:originImageSize,rectViewRect: transRectFrame,scale: 1)
        let frameChangeRate = frame.width/preBoundsSize.width
        self.crpperModel.scaleX = self.crpperModel.scaleX/Double(frameChangeRate)
        
        resetScrollViewState(rotation: CGFloat(self.crpperModel.rotation) + self.crpperModel.extraRotation, zoomScale: CGFloat(self.crpperModel.scaleX), contentOffset: .zero, preBoundsSize: preBoundsSize)
        
        let contentCenter = CGPoint(x: contentView.frame.width*0.5,y: contentView.frame.height*0.5)
        var nImageCenter = CGPoint.zero
        let transRateX = originImageFrame.width*0.5
        let transRateY = originImageFrame.height*0.5
        nImageCenter.x = CGFloat(crpperModel.transformX)*transRateX + contentCenter.x
        nImageCenter.y = contentCenter.y - CGFloat(crpperModel.transformY)*transRateY
        
        let pointInScrollView = liveWindowContentScrollView.convert(nImageCenter, from: contentView)
        let liveWindowCenter = liveWindow.center
        let contentOffset = CGPoint(x:liveWindowCenter.x - pointInScrollView.x, y: liveWindowCenter.y - pointInScrollView.y)

        liveWindowContentScrollView.setContentOffset(contentOffset, animated: false)
        
        if cropperTimeline != nil {
            streamingContext.remove(cropperTimeline)
            cropperTimeline = nil
        }
        var videoEditRes : NvsVideoResolution = NvsVideoResolution ()
        videoEditRes.imageWidth = UInt32(videoSize.width)
        videoEditRes.imageHeight = UInt32(videoSize.height)
        videoEditRes.imagePAR = NvsRational.init(num: 1, den: 1)

        var videoFps : NvsRational = NvsRational.init(num: 25, den: 1)
        var audioEditRes : NvsAudioResolution = NvsAudioResolution()
        audioEditRes.sampleRate = 48000;
        audioEditRes.channelCount = 2;
        audioEditRes.sampleFormat = NvsAudSmpFmt_S16
        cropperTimeline = streamingContext.createTimeline(&videoEditRes, videoFps: &videoFps, audioEditRes: &audioEditRes, bitDepth: self.getVideoResolution(), flags: 0)
        
        streamingContext.connect(cropperTimeline, with: liveWindow)
        let videotrack = cropperTimeline?.appendVideoTrack()
        videoClip = videotrack?.appendClip(sourceInfo.mediaFilePath,trimIn: sourceInfo.trimIn,trimOut: sourceInfo.trimOut)
        transFx = (videoClip?.appendBuiltinFx("Transform 2D"))
        guard transFx != nil else {
            return
        }
        if videoClip?.videoType == NvsVideoClipType_Image {
            videoClip?.imageMotionMode = NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn
            videoClip?.imageMotionAnimationEnabled = false
        }
        
        ///seek到和编辑页位置一致
        ///seek to the same location as the edit page
        var sTime:Int64 = currentTime
        if sTime > cropperTimeline.duration {
            sTime = 0
        }else{
            bottomControl.leftLabel.text = NvCropperHelper.convertTimecode(time: sTime)
            bottomControl.slider.value = Float(sTime)/Float(cropperTimeline.duration)
        }
        
        streamingContext.seekTimeline(cropperTimeline, timestamp: sTime, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize,flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        
        bottomControl.rightLabel.text = NvCropperHelper.convertTimecode(time: cropperTimeline.duration)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return liveWindow
    }
    
    
    public func resetScrollViewState(rotation:CGFloat,
                                     zoomScale:CGFloat,
                                     contentOffset:CGPoint,
                                     preBoundsSize:CGSize){
        liveWindowContentScrollView.transform = .identity
        calculateMaterialRectView.transform = .identity
        
        calculateMaterialRectView.frame = originRectFrame
        let cRectTransform = CGAffineTransform(rotationAngle: -rotation)
        calculateMaterialRectView.transform = cRectTransform
        let transRectFrame = calculateMaterialRectView.frame
        
        let frame = originFrameForLiveWindow(videoRes:originImageSize,rectViewRect: transRectFrame,scale: 1)
        let hLength = (frame.width - transRectFrame.width)*0.5
        let vLength = (frame.height - transRectFrame.height)*0.5
        
        liveWindowContentScrollView.contentInset = UIEdgeInsets(top: vLength, left: hLength, bottom: vLength, right: hLength)
        liveWindowContentScrollView.setZoomScale(zoomScale, animated: false)
        liveWindow.frame = CGRect(x: 0, y: 0, width: frame.size.width*zoomScale, height: frame.size.height*zoomScale)
        liveWindowContentScrollView.contentSize = CGSize(width: frame.size.width*zoomScale, height: frame.size.height*zoomScale)
        
        liveWindowContentScrollView.frame = frame
    
        let frameChangeRate = frame.width/preBoundsSize.width
        
        var nContentOffset = CGPoint(x: contentOffset.x*frameChangeRate, y: contentOffset.y*frameChangeRate)
        
        let nHLength = hLength
        let nHChange = frame.width*(zoomScale-1)
        let nVLength = vLength
        let nVChange = frame.height*(zoomScale-1)
        if nContentOffset.x > (nHLength+nHChange) {
            nContentOffset.x = nHLength+nHChange
        }else if(nContentOffset.x < -nHLength){
            nContentOffset.x = -nHLength
        }
        if nContentOffset.y > (nVLength+nVChange) {
            nContentOffset.y = nVLength+nVChange
        }else if(nContentOffset.y < -nVLength){
            nContentOffset.y = -nVLength
        }
        
        liveWindowContentScrollView.contentOffset = nContentOffset

        let transform = CGAffineTransform(rotationAngle: rotation)
        liveWindowContentScrollView.transform = transform
    }
    
    /// 重置裁剪区域宽高比
    /// Reset the clipping area aspect ratio
    /// - Parameter aspectRatio: 比例模式
    /// Proportional model
    @objc public func resetRatio(aspectRatio:NvVideoEditAspectRatioMode){
        if cropperRectView.aspectRatio == aspectRatio {
            return
        }
        let videoSize:NvsSize = NvCropperHelper.calculateTimelineSize(editMode: aspectRatio,originAspectRatio:cropperRectView.assetAspectRatio)
        let nFrame = cropperRectView.frameForRectView(videoSize:CGSize(width: CGFloat(videoSize.width), height: CGFloat(videoSize.height)))
        
        cropperRectView.aspectRatio = aspectRatio
        originRectFrame = nFrame
        
        let zoomScale = liveWindowContentScrollView.zoomScale
        let contentOffset = liveWindowContentScrollView.contentOffset
        let preBoundsSize = liveWindowContentScrollView.bounds.size
        
        self.cropperRectView.resetCropperRectFrame(nFrame: nFrame)
        self.resetScrollViewState(rotation: CGFloat(self.crpperModel.rotation)+self.crpperModel.extraRotation,zoomScale: zoomScale,contentOffset: contentOffset,preBoundsSize: preBoundsSize)
    }
    
    @objc public func currentRransformData(editViewLiveWindow:NvsLiveWindow,timelineVideoRes:NvsVideoResolution) -> NvCropperModel {
        let result = currentTransformState(editViewLiveWindow: editViewLiveWindow, timelineVideoRes: timelineVideoRes)
        let data = result.cropperModel
        data.rectLeftTop = result.rect.rectLeftTop
        data.rectLeftBottom = result.rect.rectLeftBottom
        data.rectRightTop = result.rect.rectRightTop
        data.rectRightBottom = result.rect.rectRightBottom
        return data
    }
    
    /// - Parameters:
    /// - editViewLiveWindow:编辑页面LiveWindow
    /// Edit page LiveWindow
    /// - Returns: 结果合集
    /// Result set
    private func currentTransformState(editViewLiveWindow:NvsLiveWindow,timelineVideoRes:NvsVideoResolution) ->
    (cropperModel:NvCropperModel,
     playTime:Int64,
     rect:(rectLeftTop:CGPoint,
           rectLeftBottom:CGPoint,
           rectRightBottom:CGPoint,
           rectRightTop:CGPoint))
    {
        /// 素材画幅比
        /// Material picture ratio
        let assetAspectRatio = CGFloat(clipModelSourceInfo.pixelWidth)/CGFloat(clipModelSourceInfo.pixelHeight)
        /// 裁剪框frame
        /// Crop frame
        let rectFrame = cropperRectView.rectFrame()
        /// liveWindow中心点在contentView上的位置   用于计算偏移
        /// The location of the liveWindow center point on the contentView is used to calculate the offset
        let imageCenter = liveWindowContentScrollView.convert(liveWindow.center, to: contentView)
        
        let contentCenter = CGPoint(x: contentView.frame.width*0.5,y: contentView.frame.height*0.5)
        
        let crpModel = NvCropperModel(assetAspectRatio: assetAspectRatio)
        
        crpModel.cropperRatio = cropperRectView.aspectRatio
        
        crpModel.cropperAssetAspectRatio = rectFrame.width/rectFrame.height
        
        let nonrotationliveWindowContentScrollViewSize = originFrameForLiveWindow(videoRes:originImageSize,rectViewRect: rectFrame,scale: 1).size
        let scale = liveWindowContentScrollView.zoomScale * (liveWindowContentScrollView.bounds.width/nonrotationliveWindowContentScrollViewSize.width)
        crpModel.scaleX = Double(scale)
        crpModel.scaleY = Double(scale)
        
        crpModel.extraScaleX = self.crpperModel.extraScaleX
        crpModel.extraScaleY = self.crpperModel.extraScaleY
        
        crpModel.rotation = -Double(self.crpperModel.rotation)*180/Double.pi
        crpModel.extraRotation = -self.crpperModel.extraRotation*CGFloat(180)/CGFloat(Double.pi)
        
        crpModel.cropperRatio = cropperRectView.aspectRatio
        crpModel.cropperAssetAspectRatio = rectFrame.width/rectFrame.height
        
        /// 裁剪区域
        /// Clipping area
        let cResult = NvCropperHelper.cropperRegion(cropperRatio:crpModel.cropperRatio,
        cropperAssetAspectRatio:crpModel.cropperAssetAspectRatio, liveWindow: editViewLiveWindow, assetAspectRatio: assetAspectRatio)
        crpModel.regionPointArray = [NSValue(cgPoint: cResult.leftTop), NSValue(cgPoint: cResult.leftBottom), NSValue(cgPoint: cResult.rightBottom), NSValue(cgPoint: cResult.rightTop)]
        ///基于中心点，计算偏移量。    偏移量*（裁剪框在timeline中宽度/ 裁剪框宽度*(timeline和livewindow的比例)
        ///Calculate the offset based on the center point. Offset *(Width of cropping box in timeline/width of cropping box *(ratio of timeline to livewindow)
        
        let transx = (imageCenter.x - contentCenter.x)/(nonrotationliveWindowContentScrollViewSize.width*0.5)
        let transy = -(imageCenter.y - contentCenter.y)/(nonrotationliveWindowContentScrollViewSize.height*0.5)
        crpModel.transformX = Double(transx)
        crpModel.transformY = Double(transy)
        let contentOffset = liveWindowContentScrollView.contentOffset
        print("get content offsetX:  offsetY:",contentOffset.x,contentOffset.y)
        /// 返回值： timeline上标示区域的四个点。 缩放值。偏移值。旋转值   rect为测试用数据
        /// Return value: The four points that mark the region on the timeline. Scale value. The offset value. The rotation value rect is the test data
        return (
            cropperModel:crpModel,
            playTime:streamingContext.getTimelineCurrentPosition(cropperTimeline),
            rect:(rectLeftTop:cResult.leftTop,
                  rectLeftBottom:cResult.leftBottom,
                  rectRightBottom:cResult.rightBottom,
                  rectRightTop:cResult.rightTop))
    }
    
    private func  cropperRegion() -> (regionSize:CGSize,
        leftTop:CGPoint,
        leftBottom:CGPoint,
        rightBottom:CGPoint,
        rightTop:CGPoint)
    {
        let rectFrame = cropperRectView.rectFrame()
        let leftTop = cropperRectView.convert(rectFrame.leftTop(), to: liveWindowContentScrollView)
        let leftBottom = cropperRectView.convert(rectFrame.leftBottom(), to: liveWindowContentScrollView)
        let rightBottom = cropperRectView.convert(rectFrame.rightBottom(), to: liveWindowContentScrollView)
        let rightTop = cropperRectView.convert(rectFrame.rightTop(), to: liveWindowContentScrollView)
        
        
        return (regionSize:rectFrame.size,leftTop:leftTop,leftBottom:leftBottom,rightBottom:rightBottom,rightTop:rightTop)
    }
    
    
    private func getRegionValue(_ value:Float) ->(Float) {
        let maxValue:Float = 1.0
        let minValue:Float = -1.0
        if value > maxValue {
            return maxValue
        }else if value < minValue {
            return minValue
        }
        return value
    }
    
    private func originFrameForLiveWindow(videoRes:CGSize,rectViewRect:CGRect,scale:CGFloat) -> CGRect {
        let rectRate = rectViewRect.size.height / rectViewRect.size.width
        let imageRate = videoRes.height/videoRes.width
        var frame:CGRect = CGRect()
        if rectRate > imageRate {
            /// rectView 比 视频 高
            /// rectView is higher than video
            frame.size.height = rectViewRect.size.height * scale
            frame.size.width = frame.size.height / imageRate
            frame.origin.x = rectViewRect.origin.x - (frame.size.width - rectViewRect.size.width) / 2
            frame.origin.y = rectViewRect.origin.y - (frame.size.height - rectViewRect.size.height) / 2
        }else{
            frame.size.width = rectViewRect.size.width * scale
            frame.size.height = frame.size.width * imageRate
            frame.origin.x = rectViewRect.origin.x - (frame.size.width - rectViewRect.size.width) / 2
            frame.origin.y = rectViewRect.origin.y - (frame.size.height - rectViewRect.size.height) / 2
        }
        return frame
    }
    
    //MARK: 旋转 rotation
    
    /// 旋转方法
    /// Rotation method
    /// - Parameter angle: 总旋转角度
    /// Total rotation Angle
    @objc public func resetRotateAngle(angle:CGFloat) {
        crpperModel.rotation = Double(angle)
        
        let zoomScale = liveWindowContentScrollView.zoomScale
        let contentOffset = liveWindowContentScrollView.contentOffset
        let preBoundsSize = liveWindowContentScrollView.bounds.size
        resetScrollViewState(rotation: CGFloat(crpperModel.rotation) + self.crpperModel.extraRotation,zoomScale: zoomScale,contentOffset: contentOffset,preBoundsSize: preBoundsSize)
    }
}

//MARK: NvCropperRectViewDelegete

extension NvCropperScrollView: NvCropperRectViewDelegete {
    
    /// 裁剪框移动后，计算缩放值和移动
    /// After the crop box is moved, calculate the scale value and move
    /// - Parameters:
    ///   - cropperRectView: 裁剪区域view
    ///   Clipping area view
    ///   - cropperRectViewCenter: 裁剪框父视图中心
    ///   Clipping box superview center
    ///   - cropperRectCenter: 裁剪区域中心
    ///   Clipping area center
    ///   - scale: 缩放值
    ///   Scale value
    func cropperRectViewTouchEnd(cropperRectView: NvCropperRectView, cropperRectViewCenter: CGPoint, cropperRectCenter: CGPoint, scale: CGFloat) {
        var willSetScale = self.liveWindowContentScrollView.zoomScale * scale
        if willSetScale < minScale || willSetScale > maxScale {
            print("willSetScale range error")
        }
        willSetScale = willSetScale < minScale ? minScale : willSetScale
        willSetScale = willSetScale > maxScale ? maxScale : willSetScale
        willSetScale = willSetScale < 1 ? 1 : willSetScale
        
        
        var videoSize:NvsSize = NvCropperHelper.calculateTimelineSize(editMode: cropperRectView.aspectRatio,originAspectRatio:cropperRectView.assetAspectRatio)
        if cropperRectView.aspectRatio == .NvVideoEditAspectRatioMode_Free {
            videoSize = NvCropperHelper.calculateTimelineSize(editMode: .NvVideoEditAspectRatioMode_Free,originAspectRatio:cropperRectView.clipperRect.frame.width/cropperRectView.clipperRect.frame.height)
        }
        let nFrame = cropperRectView.frameForRectView(videoSize:CGSize(width: CGFloat(videoSize.width), height: CGFloat(videoSize.height)))
        originRectFrame = nFrame
        
        let preBoundsSize = liveWindowContentScrollView.bounds.size
        var insets:UIEdgeInsets = liveWindowContentScrollView.contentInset
        
        var calRect = CGRect(x: 0, y: 0, width: cropperRectView.clipperRect.frame.width/self.liveWindowContentScrollView.zoomScale, height: cropperRectView.clipperRect.frame.height/self.liveWindowContentScrollView.zoomScale)
        
        
        var point = liveWindow.convert(cropperRectCenter, from: cropperRectView)
        
        var frameChangeRate:CGFloat = 1
        
        if cropperRectView.aspectRatio == .NvVideoEditAspectRatioMode_Free {
            calculateMaterialRectView.transform = .identity
            calculateMaterialRectView.frame = nFrame
            let cRectTransform = CGAffineTransform(rotationAngle: CGFloat(-crpperModel.rotation)-self.crpperModel.extraRotation)
            calculateMaterialRectView.transform = cRectTransform
            let transRectFrame = calculateMaterialRectView.frame
            let frame = originFrameForLiveWindow(videoRes:originImageSize,rectViewRect: transRectFrame,scale: 1)
            let hLength = (frame.width - transRectFrame.width)*0.5
            let vLength = (frame.height - transRectFrame.height)*0.5
            insets = UIEdgeInsets(top: vLength, left: hLength, bottom: vLength, right: hLength)
            
            frameChangeRate = (frame.width/preBoundsSize.width)
            
            calRect.size.width *= frameChangeRate
            calRect.size.height *= frameChangeRate
            point = CGPoint(x: point.x*frameChangeRate, y: point.y*frameChangeRate)
            
            willSetScale /= frameChangeRate
            if  willSetScale < 1 {
                willSetScale = 1
            }
        }
        
        if willSetScale > maxScale {
            willSetScale = maxScale
        }
        
        if willSetScale < minScale {
            willSetScale = minScale
        }
        
        let cRectTransform = CGAffineTransform(rotationAngle: CGFloat(-self.crpperModel.rotation)-self.crpperModel.extraRotation)
        let calculateMaterialFrame = calRect.applying(cRectTransform)
        calculateMaterialLiveWindowView.frame = calculateMaterialFrame
        calculateMaterialLiveWindowView.center = CGPoint(x: point.x, y: point.y)
        
        let rectX = calculateMaterialLiveWindowView.frame.minX
        let rectY = calculateMaterialLiveWindowView.frame.minY
        
        var sContentOffset = CGPoint(x: rectX*willSetScale - insets.left, y: rectY*willSetScale - insets.top)
        if cropperRectView.aspectRatio == .NvVideoEditAspectRatioMode_Free {
            ///resetScrollViewState 方法中会*frameChangeRate
            ///The resetScrollViewState method does frameChangeRate
            sContentOffset = CGPoint(x: sContentOffset.x/frameChangeRate, y: sContentOffset.y/frameChangeRate)
        }
        self.resetScrollViewState(rotation: CGFloat(self.crpperModel.rotation)+self.crpperModel.extraRotation,zoomScale: willSetScale,contentOffset: sContentOffset,preBoundsSize: preBoundsSize)
    }
    
    /// 裁剪框内计算需要
    /// Clipping box in the calculation needs
    /// - Parameter cropperRectView: 裁剪框视图
    /// Clipping frame view
    /// - Returns: 当前片段4个点坐标
    /// Current fragment 4 point coordinates
    func cropperRectViewPointEdge(cropperRectView: NvCropperRectView) ->
    (leftTop:CGPoint,leftBottom:CGPoint,rightTop:CGPoint,rightBottom:CGPoint,imageCenter:CGPoint) {
        return storeCurrentImageRectPoints
    }
    
    /// 拖拽裁剪框动画结束，需要重置片段初始值
    /// The drag and drop crop box animation is over, and needs to reset the fragment's initial value
    /// - Parameter cropperRectView: 裁剪框视图
    /// Clipping frame view
    func cropperRectViewMoveEnd(cropperRectView: NvCropperRectView?) {
            
    }
    
    func cropperRectViewMoving(cropperRectView: NvCropperRectView?, rect:CGRect) -> Bool {
        return true
    }
}

/// 播放控制相关
/// Play control correlation
extension NvCropperScrollView: NvCropperBottomViewDelegate {
    func cropperBottomView(cropperBottomView: NvCropperBottomView, playButtonClicked: UIButton) {
        delayHidden()
        if streamingContext.getStreamingEngineState() == NvsStreamingEngineState_Playback {
            streamingContext.stop()
        }else{
            streamingContext.playbackTimeline(cropperTimeline, startTime: streamingContext.getTimelineCurrentPosition(cropperTimeline), endTime: cropperTimeline.duration,videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize,preload: true,flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
    
    func cropperBottomView(cropperBottomView: NvCropperBottomView, valueChanged: Float) {
        delayHidden()
        let position = Int64(Double(cropperTimeline.duration)*Double(valueChanged))
        streamingContext.seekTimeline(cropperTimeline, timestamp: position, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        bottomControl.leftLabel.text = NvCropperHelper.convertTimecode(time: position)
    }
}

extension NvCropperScrollView: NvsStreamingContextDelegate {
    
    func didPlaybackTimelinePosition(_ timeline: NvsTimeline!, position: Int64) {
        let per = Double(position)/Double(timeline.duration)
        bottomControl.slider.value = Float(per)
        bottomControl.leftLabel.text = NvCropperHelper.convertTimecode(time: position)
    }
    
    func didPlaybackStopped(_ timeline: NvsTimeline!) {
        
    }
    
    func didPlaybackEOF(_ timeline: NvsTimeline!) {
        streamingContext.seekTimeline(cropperTimeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        streamingContext.playbackTimeline(cropperTimeline, startTime: 0, endTime: cropperTimeline.duration,videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize,preload: true,flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue))
    }
    
    func didStreamingEngineStateChanged(_ state: NvsStreamingEngineState) {
        if state == NvsStreamingEngineState_Playback {
            bottomControl.playButton.setImage(UIImage(named: "NvPause"), for: .normal)
        } else {
            bottomControl.playButton.setImage(UIImage(named: "NvPlayback"), for: .normal)
        }
    }
}
