//
//  NvSourceInfo.swift
//  NvCropperDemo
//
//  Created by 美摄 on 2020/12/9.
//

import UIKit

class NvSourceInfo: NSObject {
    @objc var mediaFilePath:String = ""
    @objc var stillImageHint:Bool = false
    @objc var duration:Int64 = 0
    @objc var pixelWidth:Int = 0
    @objc var pixelHeight:Int = 0
    
    @objc var trimIn:Int64 = 0
    @objc var trimOut:Int64 = 0
    
    override func copy() -> Any {
        let model = NvSourceInfo()
        model.mediaFilePath = self.mediaFilePath
        model.stillImageHint = stillImageHint
        model.duration = duration
        model.pixelWidth = pixelWidth
        model.pixelHeight = pixelHeight
        model.trimIn = trimIn
        model.trimOut = trimOut
        return model
    }
}
