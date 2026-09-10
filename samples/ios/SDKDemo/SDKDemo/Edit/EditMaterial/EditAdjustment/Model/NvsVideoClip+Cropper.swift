//
//  NvsVideoClip+Cropper.swift
//  MYVideo
//
//  Created by 美摄 on 2020/7/23.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore

public let CropperVideoFxType = "videoFxTypeSwift"

fileprivate let clipCropperAttachment:String = "clipCropperAttachment"

enum AspectRatio : Int {
    case AspectRatio_Origin = 0
    case AspectRatio_9v16
    case AspectRatio_3v4
    case AspectRatio_9v18
    case AspectRatio_9v21
    case AspectRatio_1v1
    case AspectRatio_16v9
    case AspectRatio_4v3
    case AspectRatio_18v9
    case AspectRatio_21v9
}

public class NvCropperModel: NvTransformModel{
    
    @objc public var cropSize: CGSize = .zero
    
    public override init() {
        super.init()
    }
    
    init(assetAspectRatio:CGFloat) {
        super.init()
        self.cropperAssetAspectRatio = assetAspectRatio
    }
    
    @objc var cropperRatio:NvVideoEditAspectRatioMode = .NvVideoEditAspectRatioMode_Free
    @objc var cropperAssetAspectRatio:CGFloat = 1
    
    @objc var region:String = ""
    
    @objc var regionPointArray:[NSValue] = [NSValue]()
    
    @objc public func modelCopy() -> NvCropperModel {
        let model = NvCropperModel(assetAspectRatio:self.cropperAssetAspectRatio)
        model.transformX = transformX
        model.transformY = transformY
        model.scaleX = scaleX
        model.scaleY = scaleY
        model.rotation = rotation
        model.opacity = opacity
        model.anchorX = anchorX
        model.anchorY = anchorY
        model.cropperRatio = cropperRatio
        model.cropperAssetAspectRatio = cropperAssetAspectRatio
        model.extraRotation = extraRotation
        model.extraScaleX = extraScaleX
        model.extraScaleY = extraScaleY
        model.region = region
        model.regionPointArray = regionPointArray
        model.cropSize = CGSize(width: cropSize.width, height: cropSize.height)
        return model
    }
    
    /// 是否为初始状态， 移除裁剪相关特效
    /// Whether it is in the initial state, remove clipping effects
    public func isInitial() -> Bool {
        if regionPointArray.isEmpty{
            return true
        }
        for value in regionPointArray {
            let point = value.cgPointValue
            if (1 - abs(point.x)) > 0.01 {
                return false
            }else if (1 - abs(point.y)) > 0.01 {
                return false
            }
        }
        ///检查移动缩放
        ///Check movement scaling
        if transformX == 0,transformY == 0,scaleX == 1,extraScaleX == 1,
           extraScaleY == 1,
           extraRotation == 0 {
            return true
        }else{
            return false
        }
    }
    
    public func maskXmlString(timelineVideoRes:NvsVideoResolution) -> String {
        return String(format: maskGeneratorFormat(),
                      timelineVideoRes.imageWidth,
                      timelineVideoRes.imageHeight,region)
    }
    
    private func maskGeneratorFormat() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <storyboard sceneWidth="%u" sceneHeight="%u">
            <track source=":1" clipStart="0" clipDuration="1" repeat="true">
                <effect name="maskGenerator">
                    <param name="keepRGB" value="true"/>
                    <param name="featherWidth" value="0"/>
                    <param name="region" value="%@"/>
                </effect>
            </track>
        </storyboard>
        """
    }
}

public class NvCropperHelper:NSObject{
    
    /// 素材在livewinodw上原始size
    /// Raw material size on livewinodw
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
    
    ///计算裁剪区域
    ///Gets the region of crop
    class func cropperRegion(cropperRatio:NvVideoEditAspectRatioMode,
                             cropperAssetAspectRatio:CGFloat,
                             liveWindow:NvsLiveWindow,
                             assetAspectRatio: CGFloat) -> (regionSize:CGSize,
                                                            leftTop:CGPoint,
                                                            leftBottom:CGPoint,
                                                            rightBottom:CGPoint,
                                                            rightTop:CGPoint)
    {
        
        let liveWindowSize = liveWindow.frame.size
        /// 视频 在视图上原 宽高
        /// The video is the original width and height on the view
        let assetSize = NvCropperHelper.assetSizeInBox(boxSize: liveWindowSize, assetAspectRatio: assetAspectRatio)
        
        var rectRate = cropperAssetAspectRatio
        if cropperRatio != .NvVideoEditAspectRatioMode_Free {
            let size = NvCropperHelper.calculateTimelineSize(editMode: cropperRatio, originAspectRatio: rectRate)
            rectRate = CGFloat(size.width)/CGFloat(size.height)
        }
        let rectSize = NvCropperHelper.assetSizeInBox(boxSize: assetSize, assetAspectRatio: rectRate)
        
        let xValue = rectSize.width/assetSize.width
        let yValue = rectSize.height/assetSize.height
        
        let leftTop = CGPoint(x: -xValue, y: yValue)
        let rightTop = CGPoint(x: xValue, y: yValue)
        let rightBottom = CGPoint(x: xValue, y: -yValue)
        let leftBottom = CGPoint(x: -xValue, y: -yValue)
        return (regionSize:rectSize,
                leftTop:leftTop,
                leftBottom:leftBottom,
                rightBottom:rightBottom,
                rightTop:rightTop)
    }
    
    @objc class func calculateTimelineSize(editMode:NvVideoEditAspectRatioMode,originAspectRatio:CGFloat) -> NvsSize {
        var size:NvsSize = NvsSize()
        //        let compileRes:Int32 = 1080
        let compileRes:Int32 = (UserDefaults.standard.value(forKey: "NvCompileResolution") != nil) ? UserDefaults.standard.value(forKey: "NvCompileResolution") as! Int32 : 720
        ///如果根据第一素材创建的话，这块需要改
        ///This one needs to be changed if it is created from the first source
        if (editMode == .NvVideoEditAspectRatioMode_Free) {
            if originAspectRatio > 1 {
                var w = Int32(CGFloat(compileRes)*originAspectRatio)
                var h = Int32(compileRes)
                if w > 3840 {
                    w = 3840
                    h = Int32(3840.0 / originAspectRatio)
                }
                w = (w + 3) & ~3
                h = (h + 1) & ~1
                size.width = Int32(w)
                size.height = Int32(h)
            }else{
                var w = Int32(compileRes)
                var h = Int32(CGFloat(compileRes)/originAspectRatio)
                if h > 3840 {
                    h = 3840
                    w = Int32(3840.0 * originAspectRatio)
                }
                w = (w + 3) & ~3
                h = (h + 1) & ~1
                size.width = Int32(w)
                size.height = Int32(h)
            }
        } else if (editMode == .NvVideoEditAspectRatioMode_16v9) {
            size.height = compileRes;
            size.width = compileRes * 16 / 9
        } else if (editMode == .NvVideoEditAspectRatioMode_1v1) {
            size.height = compileRes;
            size.width = compileRes;
        } else if (editMode == .NvVideoEditAspectRatioMode_9v16) {
            size.width = compileRes;
            size.height = compileRes * 16 / 9
        } else if (editMode == .NvVideoEditAspectRatioMode_3v4) {
            size.width = compileRes;
            size.height = compileRes * 4 / 3
        } else if (editMode == .NvVideoEditAspectRatioMode_4v3) {
            size.width = compileRes * 4 / 3
            size.height = compileRes
        } else if (editMode == .NvVideoEditAspectRatioMode_9v18) {
            size.width = compileRes;
            size.height = compileRes * 18 / 9
        } else if (editMode == .NvVideoEditAspectRatioMode_9v21) {
            size.width = compileRes;
            size.height = compileRes * 21 / 9
        } else if (editMode == .NvVideoEditAspectRatioMode_21v9) {
            size.height = compileRes;
            size.width = compileRes * 21 / 9
        } else if (editMode == .NvVideoEditAspectRatioMode_18v9) {
            size.height = compileRes;
            size.width = compileRes * 18 / 9
        }
        else {
            size.width = 1280
            size.height = 720
        }
        return size
    }
    
    class func convertTimecode(time: Int64) -> String {
        let sec = Int(time/1000000)
        let minutes = sec/60
        let hour = minutes/60
        if hour == 0 {
            return String(format: "%02.0f:%02.0f", round(Float(minutes).truncatingRemainder(dividingBy: 60)),round(Float(sec).truncatingRemainder(dividingBy: 60)))
        }else{
            return String(format: "%02.0f:%02.0f:%02.0f", Float(hour).truncatingRemainder(dividingBy: 60),Float(minutes).truncatingRemainder(dividingBy: 60),Float(sec).truncatingRemainder(dividingBy: 60))
        }
    }
}



extension NvsVideoClip {
    
    @objc public func clipSizeWithCrop() -> CGSize {
        let model = getAttachment("NvCropperModel") as? NvCropperModel
        if let cModel = model {
            return cModel.cropSize
        }
        return .zero
    }
    
    /// Gets the data of current cropper region
    ///
    /// - Remark: 获取裁剪区域的数据模型
    ///
    /// - Returns: the data of cropper
    ///
    func currentCropperModel() -> NvCropperModel? {
        var model = getAttachment("NvCropperModel") as? NvCropperModel
        if model == nil {
            //            model = NvCropperModel()
        }else{
            model = model!.modelCopy()
        }
        return model
    }
    /// Add the fx of cropper and update the fx of mask
    ///
    /// - Remark: 设置和更新, 同时更新蒙版
    ///
    /// - Parameters:
    ///   - model: the data of cropper
    ///   - timelineVideoRes: the video resolution of timeline
    ///
    @objc public func setCropper(model:NvCropperModel,timelineVideoRes: NvsVideoResolution,assetSize: CGSize){
        setAttachment(model, forKey: "NvCropperModel")
        if model.isInitial() {
            ///清理特效
            ///Cleaning effect
            
            return;
        }
        setTransform(model: model)
        var cropFx:NvsVideoFx?
        let rawFxCount = getRawFxCount()
        if  rawFxCount > 0 {
            for i in 0..<rawFxCount {
                let fx = getRawFx(by: i)
                let object = fx?.getAttachment(TransformVideoFxType) as? String
                if object == clipCropperAttachment {
                    cropFx = fx
                    break
                }
            }
        }
        if cropFx == nil {
            cropFx = insertRawBuiltinFx("Crop", fxIndex: 1)
            cropFx?.setAttachment(clipCropperAttachment as NSString, forKey: TransformVideoFxType)
        }
        
        enableRawSourceMode(true)
        rawFilterProcessesMode = .varSizeWithFillModeUsed
        
        var pointArray = [CGPoint]()
        for item in model.regionPointArray {
            var point = item.cgPointValue
            point = mapCToTimeline(point: point, assetSize: assetSize)
            pointArray.append(point)
        }
        
        cropFx?.setAttachment("\(model.cropperRatio.rawValue)" as NSObject, forKey: "CropAspectRatioMode")
        
        cropFx?.setFloatVal("Bounding Left", val: pointArray[0].x)
        cropFx?.setFloatVal("Bounding Right", val: pointArray[2].x)
        cropFx?.setFloatVal("Bounding Top", val: pointArray[0].y)
        cropFx?.setFloatVal("Bounding Bottom", val: pointArray[2].y)
        
        ///裁剪后的视频短边充满
        ///Cropped video with short edges full
        let videoWidth = pointArray[2].x*2
        let videoHeght = pointArray[0].y*2
        let assetRate = videoWidth/videoHeght
        let cSize = NvMaskHelper.assetSizeInBox(boxSize: CGSize(width: CGFloat(timelineVideoRes.imageWidth), height: CGFloat(timelineVideoRes.imageHeight)), assetAspectRatio: assetRate)
        
        model.cropSize = cSize
    }
    
    private func mapCToTimeline(point: CGPoint,assetSize: CGSize) -> CGPoint {
        return CGPoint(x: point.x * assetSize.width * 0.5, y: assetSize.height * 0.5 * point.y)
    }
    
    private func cleanCropFx() {
        enableRawSourceMode(false)
        rawFilterProcessesMode = .none
        let rawFxCount = getRawFxCount()
        if  rawFxCount > 0 {
            for i in 0..<rawFxCount {
                let index = rawFxCount - i - 1
                let fx = getRawFx(by: index)
                let object = fx?.getAttachment(TransformVideoFxType) as? String
                if object == clipCropperAttachment {
                    removeRawFx(index)
                }else if object == "CropScaleFXType" {
                    removeRawFx(index)
                }else if object == clipTransformFxAttachment {
                    removeRawFx(index)
                }
            }
        }
    }
    
}
