//
//  NvTemplateCompileModel.swift
//  MYVideo
//
//  Created by chengww on 2020/12/28.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import Photos

typealias NvTemplateTrack = (key: String, source: [NvTemplateCompileModel])

class NvTemplateCompileModel {
    public enum Option: Int {
        case all
        case onlyImage
        case onlyVideo
        func toString() -> String {
            switch self {
            case .onlyImage:
                return "image"
            case .onlyVideo:
                return "video"
            default:
                return "videoImage"
            }
        }
    }
    var clipCopyPath: String = ""
    var clipPath: String = ""
    var clipName: String = ""
    var clipType: Option = .all
    /// 是否需要倒放
    /// Whether to play it backwards
    var isReversed: Bool = false
    /// 是否正在进行编组
    /// Whether a group is being marshaled
    var isGrouped: Bool = false
    /// 编组中是否选中
    /// Whether to select a group
    var groupSelected: Bool = false
    /// 可替换，非锁定状态
    /// Replaceable, non-locked state
    var enableReplace: Bool = true
    var groupNumber: Int = 0
    var inPoint: Int64 = 0
    var outPoint: Int64 = 0
    var isSelected: Bool = false
    /// 标记是否是编辑字幕
    /// Flag whether to edit subtitles
    var isCaption: Bool = false
    /// 查询轨道和片段
    /// Query tracks and segments
    var trackIndex: UInt32 = 0
    var clipIndex: UInt32 = 0
    /// 查询字幕
    /// Query subtitles
    var captionId: String = ""
    var coverImage: UIImage? = nil
    var trimIn: Int64 = 0 {
        didSet {
            if coverImage == nil {
                coverImage = nv_getImage()
            }
        }
    }
    init() { }
    
    public func nv_getSourceType() -> String {
        switch clipType {
        case .all:
            return NvLocalProvider.String(key: "Unlimited", comment: "不限")
        case .onlyImage:
            return NvLocalProvider.String(key: "Only Image", comment: "仅图片")
        case .onlyVideo:
            return NvLocalProvider.String(key: "Only Video", comment: "仅视频")
        }
    }
        
    public func nv_getImage() -> UIImage? {
        guard let fileSuff = clipPath.split(separator: ".").map(String.init).last else { return nil }
        let fileType = NvUtils.nv_fileType(ext: fileSuff)
        if fileType == .image {
            return UIImage.init(contentsOfFile: clipPath)
        }else if fileType == .video {
            let generator = AVAssetImageGenerator.init(asset: AVAsset.init(url: URL.init(fileURLWithPath: clipPath)))
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize.init(width: 100, height: 100)
            let time = CMTimeMake(value: trimIn, timescale: 1000000)
            var actualTime: CMTime = CMTimeMake(value: 0, timescale: 0)
            do {
                let imageRef = try generator.copyCGImage(at: time, actualTime: &actualTime)
                return UIImage.init(cgImage: imageRef)
            } catch {
                return nil
            }
        }else {
            return nil
        }
    }
}

extension NvTemplateCompileModel: NSCopying{
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = NvTemplateCompileModel()
        copyObj.clipCopyPath = clipCopyPath
        copyObj.clipPath = clipPath
        copyObj.clipName = clipName
        copyObj.clipType = clipType
        copyObj.isGrouped = isGrouped
        copyObj.groupSelected = groupSelected
        copyObj.enableReplace = enableReplace
        copyObj.groupNumber = groupNumber
        copyObj.trimIn = trimIn
        copyObj.inPoint = inPoint
        copyObj.outPoint = outPoint
        copyObj.isCaption = isCaption
        copyObj.isReversed = isReversed
        copyObj.isSelected = isSelected
        copyObj.trackIndex = trackIndex
        copyObj.clipIndex = clipIndex
        copyObj.captionId = captionId
        copyObj.coverImage = coverImage
        return copyObj
    }
}
