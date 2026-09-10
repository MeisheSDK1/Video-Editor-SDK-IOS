//
//  NvsVideoClip+Mask.swift
//  MYVideo
//
//  蒙版
//
//  Created by 美摄 on 2020/7/14.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore

@objc enum NvClipMaskType : Int {
    case none
    case line
    case mirror
    case circle
    case rect
    case heart
    case star
    case text
}

public class NvCodingPoint : NSObject{
    @objc public var x:CGFloat = 0
    @objc public var y:CGFloat = 0
    public init(cgPoint:CGPoint){
        x = cgPoint.x
        y = cgPoint.y
    }
    
    public init(x: CGFloat,y: CGFloat){
        self.x = x
        self.y = y
    }
    
    public override init() {
        super.init()
        x = 0
        y = 0
    }
    
    public var cgPointValue:CGPoint{
        get{
            return CGPoint(x: x, y: y)
        }
    }
}

public class NvMaskRegionInfo:NSObject{
    
    @objc public var type:NvsMaskRegionType = NvsMaskRegionType_Polygon
    
    public var points:[NvCodingPoint] = [NvCodingPoint]()
    
    @objc public var normalizedPoints:[NvCodingPoint] = [NvCodingPoint]()
    
    
    @objc public var normalizedCenter:NvCodingPoint = NvCodingPoint(cgPoint: .zero)
    @objc public var a:CGFloat                         = 0
    @objc public var b:CGFloat                         = 0

    
    @objc public class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["normalizedPoints":NvCodingPoint.self]
    }
    
}

public class NvMaskModel:NSObject{
    
    @objc var maskType:NvClipMaskType = .none
    
    @objc var transform:NvTransformModel = NvTransformModel()
    
    @objc var inverseRegion:Bool = false
    @objc var feather:CGFloat = 0
    
    @objc var horizontalScale: CGFloat = 1
    @objc var verticalScale: CGFloat = 1
    //圆角 和短边的比例
    //The ratio of rounded corners to short edges
    @objc public var cornerRadiusRate: CGFloat = 0
    
    @objc public var text: String = "VIDEO"
    
    
    /*
     固定参数,字幕高度和宽度的比例
     Fixed parameter, ratio of subtitles height to width
     */
    
    public let heightRateOfWidth: CGFloat = 9/10/5.0
    public let maxNumberWords: CGFloat = 10
    
    
    
    public let rectRate: CGFloat = 2
    
    /*
     矩形特有,矩形默认宽高比
     Rectangle is unique, rectangle default aspect ratio
     */
   
    public let circleRate: CGFloat = 0.7
    
    
    @objc public var regionInfo:NvMaskRegionInfo?
    
    public func move(translation:CGPoint,assetSize:CGSize,assetResolution:CGSize,transformModel:NvTransformModel?){
        let rotationTranslationPoint = NvLineTool.pointRotatedAroundAnchorPoint(point: translation, anchorPoint: .zero, angle:CGFloat((transformModel?.rotation ?? 0)/180*Double.pi))
        let rate = assetSize.width/assetResolution.width
        transform.transformX += Double(rotationTranslationPoint.x/rate)
        transform.transformY += Double(rotationTranslationPoint.y/rate)
    }
    
    @objc public func copyModel() -> NvMaskModel {
        let jsonData = self.yy_modelToJSONData()
        let copyObj:NvMaskModel = NvMaskModel.yy_model(withJSON: jsonData!)!
        return copyObj
    }
    
    public func nvMaskInfo(assetResolution: CGSize) -> NvsMaskRegionInfo? {
        if regionInfo == nil || maskType == .none {
            return nil
        }
        guard let info = regionInfo else { return nil }
        
        let subRegionInfo = NvsMaskSubRegionInfo()
        if maskType == .mirror {
            subRegionInfo.type = Int32(NvsMaskRegionType_Mirror.rawValue)
            subRegionInfo.mirror.center.x = 0
            subRegionInfo.mirror.center.y = 0
            subRegionInfo.mirror.theta = 0
            subRegionInfo.mirror.distance = 0.5
        }else if maskType == .circle {
            subRegionInfo.type = Int32(NvsMaskRegionType_Ellipse2D.rawValue)
            var ellipse2d: NvsMaskEllipse2D = NvsMaskEllipse2D()
            ellipse2d.a = Float(info.a)
            ellipse2d.b = Float(info.b)
            subRegionInfo.ellipse2d = ellipse2d
        }else{
            subRegionInfo.type = Int32(info.type.rawValue)
            subRegionInfo.points = NSMutableArray()
            var values = [NSValue]()
            for cPoint in info.normalizedPoints {
                values.append(NSValue(cgPoint: cPoint.cgPointValue))
            }
            subRegionInfo.points.addObjects(from: values)
        }
        subRegionInfo.transform2d.rotation = -Float(transform.rotation)*180/Float(Double.pi)
        let normalizedTrans = NvMaskHelper.mapTimelineToNormalized(point: CGPoint(x: transform.transformX, y: transform.transformY), size: assetResolution)
        subRegionInfo.transform2d.translation.x = Float(normalizedTrans.x)
        subRegionInfo.transform2d.translation.y = -Float(normalizedTrans.y)
        subRegionInfo.transform2d.scale.x = Float(transform.scaleX)
        subRegionInfo.transform2d.scale.y = Float(transform.scaleY)
        
        let maskInfo:NvsMaskRegionInfo = NvsMaskRegionInfo()
        maskInfo.regionInfoArray = NSMutableArray()
        maskInfo.regionInfoArray.add(subRegionInfo)
        return maskInfo
    }
    
    public func captionXmlString(sceneWidth:Int64,
                                 sceneHeight:Int64,
                                 heightRate:CGFloat,
                                 text:String,
                                 clipDuration:Int64,
                                 scale:CGFloat,
                                 rotation:CGFloat,
                                 transX:CGFloat,
                                 transY:CGFloat) -> String {
        let escapeString = text.replacingOccurrences(of: "\n", with: "&#10;")
        return String(format: captionXmlFormat(),
                      sceneWidth,
                      sceneHeight,
                      Int64(CGFloat(sceneHeight)*heightRate),
                      escapeString,
                      clipDuration,
                      scale,
                      scale,
                      rotation,
                      transX,
                      transY)
    }
    
    private func captionXmlFormat() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <storyboard sceneWidth="%lld" sceneHeight="%lld">
            <textTrack height="%lld" bold="1" posterTimeHint="0" clipStart="0" source="%@" clipDuration="%lld">
                <effect name="transform">
                    <param name="scaleX" value="%.5f"/>
                    <param name="scaleY" value="%.5f"/>
                    <param name="rotationZ" value="%.5f"/>
                    <param name="transX" value="%.5f"/>
                    <param name="transY" value="%.5f"/>
                </effect>
            </textTrack>
        </storyboard>
        """
    }
}

extension NvsVideoClip {
    /// Set/Get the type of mask
    ///
    /// - Remark: 当前蒙版类型
    ///
    private(set) var maskType:NvClipMaskType {
        get{
            let number:NSNumber? = getAttachment("MaskType") as? NSNumber
            return NvClipMaskType(rawValue: number?.intValue ?? 0) ?? .none
        }
        set{
            setAttachment(NSNumber(value: newValue.rawValue), forKey: "MaskType")
        }
    }
    
    /// Set/Get the data of model
    ///
    /// - Remark: 当前蒙版数据
    ///
    @objc public var maskModel:NvMaskModel {
        get{
            return maskModelFor(type: maskType)
        }
        set{
            self.maskType = newValue.maskType
            setMaskModel(maskModel: newValue, type: newValue.maskType)
        }
    }
    
    /// Get the data of mask base on the mask type
    ///
    /// - Remark: 根据蒙版类型获取蒙版的数据模型
    ///
    func maskModelFor(type:NvClipMaskType) -> NvMaskModel {
        let attachMentKey = "MaskModel" + String(format: "%d", type.rawValue)
        var model = getAttachment(attachMentKey) as? NvMaskModel
        if model == nil {
            model = NvMaskModel()
            model?.maskType = type
        }else{
            let copyObj:NvMaskModel = model!.copyModel()
            model = copyObj
        }
        return model!
    }
    
    private func setMaskModel(maskModel:NvMaskModel,type:NvClipMaskType){
        let attachMentKey = "MaskModel" + String(format: "%d", type.rawValue)
        setAttachment(maskModel, forKey: attachMentKey)
    }
    
    /// Set the mask fx
    ///
    /// - Remark: 设置蒙版
    ///
    @objc public func setMask(maskModel:NvMaskModel, resolution:CGSize){
        self.maskModel = maskModel
        setMaskEffect(maskModel: maskModel, resolution:resolution)
    }
    
    private func setMaskEffect(maskModel:NvMaskModel, resolution:CGSize){
        var maskFx:NvsVideoFx?
            let rawFxCount = getRawFxCount()
            if  rawFxCount > 0 {
                for i in 0..<rawFxCount {
                    let fx = getRawFx(by: i)
                    let object = fx?.getAttachment("mask")
                    if object != nil {
                        maskFx = fx
                    }
                }
            }
        if maskModel.maskType == .none {
            if maskFx != nil {
                    removeRawFx(maskFx!.index)
            }
            return
        }
        if maskFx == nil {
            var fx:NvsVideoFx?
            fx = appendRawBuiltinFx("Mask Generator")
            fx?.setAttachment("mask" as NSObject, forKey: "mask")
            fx?.setBooleanVal("Keep RGB", val: true)
            maskFx = fx
        }
        
        //区域反转 Regional inversion
        maskFx?.setBooleanVal("Inverse Region", val: maskModel.inverseRegion)
        //设置羽化 Set feather
        maskFx?.setFloatVal("Feather Width", val: Double(maskModel.feather))
        //设置区域 Set area
        if maskModel.maskType == .text {
            let transAdjust:CGFloat = 1
            let heightRate = resolution.width*maskModel.heightRateOfWidth/resolution.height*CGFloat(maskModel.transform.scaleX)
            
            let scale:CGFloat = 1
            let des = maskModel.captionXmlString(sceneWidth: Int64(resolution.width),
                                                 sceneHeight: Int64(resolution.height),
                                                 heightRate: heightRate,
                                                 text: maskModel.text,
                                                 clipDuration: outPoint - inPoint,
                                                 scale: scale,
                                                 rotation: CGFloat(-Float(maskModel.transform.rotation)*180/Float(Double.pi)),
                                                 transX: CGFloat(maskModel.transform.transformX) * transAdjust,
                                                 transY: -CGFloat(maskModel.transform.transformY) * transAdjust)
            maskFx?.setArbDataVal("Region Info", val: nil)
            maskFx?.setStringVal("Text Mask Description String", val: des)
        }else{
            maskFx?.setStringVal("Text Mask Description String", val: "")
            let info = maskModel.nvMaskInfo(assetResolution: resolution)
            maskFx?.setArbDataVal("Region Info", val: info)
        }
    }
    
    /// Remove the fx of mask
    ///
    /// - Remark: 移除蒙版特效
    ///
    public func removeMaskFx() -> NvMaskModel {
        let mModel:NvMaskModel = maskModel
        let rawFxCount = getRawFxCount()
        if  rawFxCount > 0 {
            for i in 0..<rawFxCount {
                if let fx = getRawFx(by: i), fx.getAttachment("mask") != nil {
                    removeRawFx(fx.index)
                }
            }
        }
        return mModel
    }
}
