//
//  NvsVideoClip+Transform2D.swift
//  MYVideo
//
//
//  Created by 美摄 on 2020/7/20.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore

///通过对特效的attachment值来区分特效的种类，videoFxType是attachment的key
///The type of special effects can be distinguished by the attachment value of the special effects. videoFxType is the key of the attachment
public let TransformVideoFxType = "videoFxType"

public let clipTransformFxAttachment: String = "clipTransformFxAttachment"

public class NvTransformModel:NSObject{
    ///clip的旋转
    ///Rotation of clip
    @objc var transformX: Double = 0
    @objc var transformY: Double = 0
    @objc var scaleX: Double = 1
    @objc var scaleY: Double = 1
    @objc var rotation: Double = 0
    @objc var opacity: Double = 1
    @objc var anchorX: Double = 0
    @objc var anchorY: Double = 0
    
    ///额外的放大及旋转
    ///Additional magnification and rotation
    @objc var extraScaleX:CGFloat = 1
    @objc var extraScaleY:CGFloat = 1
    @objc var extraRotation:CGFloat = 0
    
    ///rect 四个点位置
    ///rect four point positions
    @objc var rectLeftTop: CGPoint = .zero
    @objc var rectLeftBottom: CGPoint = .zero
    @objc var rectRightBottom: CGPoint = .zero
    @objc var rectRightTop: CGPoint = .zero

    
    func copy() -> NvTransformModel {
        let model = NvTransformModel()
        model.transformX = transformX
        model.transformY = transformY
        model.scaleX = scaleX
        model.scaleY = scaleY
        model.rotation = rotation
        model.opacity = opacity
        model.anchorX = anchorX
        model.anchorY = anchorY
        
        model.extraScaleX = extraScaleX
        model.extraScaleY = extraScaleY
        model.extraRotation = extraRotation
        
        model.rectLeftTop = rectLeftTop
        model.rectLeftBottom = rectLeftBottom
        model.rectRightTop = rectRightTop
        model.rectRightBottom = rectRightBottom
        return model
    }
}


extension NvsVideoClip {
    
    /// Set transform property and update the fx of mask
    ///
    /// - Remark: 设置 Transform 特效，同时更新蒙版
    ///
    /// - Parameter model: the data for Transform fx
    ///
    func setTransform(model:NvTransformModel){
        var transformFx:NvsVideoFx?
            let rawFxCount = getRawFxCount()
            if  rawFxCount > 0 {
                for i in 0..<rawFxCount {
                    let fx = getRawFx(by: i)
                    let object = fx?.getAttachment(TransformVideoFxType) as? String
                    if object == clipTransformFxAttachment {
                        transformFx = fx
                        break
                    }
                }
            }
        if transformFx == nil {
            transformFx = insertRawBuiltinFx("Transform 2D", fxIndex: 0)
            transformFx?.setBooleanVal("Is Normalized Coord", val: true)
            transformFx?.setBooleanVal("Force Identical Position", val: true)
            transformFx?.setAttachment(clipTransformFxAttachment as NSString, forKey: TransformVideoFxType)
        }
        transformFx?.setFloatVal("Trans X", val: model.transformX)
        transformFx?.setFloatVal("Trans Y", val: model.transformY)
        transformFx?.setFloatVal("Scale X", val: model.scaleX*Double(model.extraScaleX))
        transformFx?.setFloatVal("Scale Y", val: fabs(model.scaleY)*Double(model.extraScaleY))
        transformFx?.setFloatVal("Rotation", val: model.rotation+Double(model.extraRotation))
        transformFx?.setFloatVal("Opacity", val: model.opacity)
        transformFx?.setFloatVal("Anchor X", val: Double(model.anchorX))
        transformFx?.setFloatVal("Anchor Y", val: Double(model.anchorY))
    }
}

