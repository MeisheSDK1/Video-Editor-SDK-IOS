//
//  NvAlbumItem.swift
//  SDKDemo
//
//  Created by 刘东旭 on 2019/11/28.
//  Copyright © 2019 meishe. All rights reserved.
//

import Foundation
import Photos
class NvAlbumAsset: NSObject {
    ///是否需要展示蒙层
    ///Whether the mask needs to be displayed
    var isShowLayer = false
    ///被选择的个数
    ///The number of selections
    var number = 0
    var asset: PHAsset?
    ///显示cell的时候被赋值
    ///Is assigned when the cell is displayed
    var indexPath: IndexPath?
}
class NvAlbumItem: NSObject {
    var collectionList: [NvAlbumAsset] = []
    var startDate: Date?
    var isSelectAll = false
}

class NvAlbumTemplateItem: NSObject {
    var asset: PHAsset?
    var trackIndex: Int32 = 0
    var clipIndex: Int32 = 0
    var footageId: String = ""
    var duration: Int64 = 0
    var index: Int = 0
    var isSelected: Bool = false
    var isGrouped: Bool = false
    var groupId: Int = 0
    var needReverse: Bool = false
    var isReversed: Bool = false
    var reversePath: String = ""
    /// 素材类型 0：不限，1：视频 2：图片
    /// Material type 0: unlimited 1: video 2: picture
    var type: UInt32 = 0
    var isImage: Bool = false
    /// 是否是自适应模板的片段
    /// Whether it is a fragment of an adaptive template
    var isAdaptationDuration: Bool = false
}

extension NvAlbumTemplateItem: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let objc = NvAlbumTemplateItem.init()
        objc.asset       = asset
        objc.trackIndex  = trackIndex
        objc.clipIndex   = clipIndex
        objc.footageId   = footageId
        objc.duration    = duration
        objc.index       = index
        objc.groupId     = groupId
        objc.isSelected  = isSelected
        objc.isGrouped   = isGrouped
        objc.needReverse = needReverse
        objc.isReversed  = isReversed
        objc.reversePath = reversePath
        objc.type        = type
        objc.isAdaptationDuration        = isAdaptationDuration
        return objc
    }
}
