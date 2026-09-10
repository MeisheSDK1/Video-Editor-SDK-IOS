//
//  NvTemplateEditerOperator.swift
//  NvTemplate
//
//  Created by chengww on 2022/8/25.
//

import UIKit
import NvStreamingSdkCore

//MARK: - 获取模板字幕信息
///MARK: - Obtain template subtitle information
extension NvTemplateEditerOperator {
    func fetchCaptionList(templateId: String) -> [NvTemplateEditItem] {
        let captionFootages = streamingContext.assetPackageManager.getTemplateCaptions(templateId) ?? []
        var captionItems: [NvTemplateEditItem] = []
        ///编组信息
        ///Marshalling information
        var groupInfo: NvTemplateGroupInfo = .init()
        var timelineCaptionInfos: [NvTemplateTimelineClipInfo] = []
        for index in 0..<captionFootages.count {
            ///清空footage序列嵌套信息
            ///Clears footage sequence nested information
            timelineCaptionInfos.removeAll()
            ///获取当前的footage
            ///Gets the current footage
            let footage = captionFootages[index]
            if footage.replaceId.isEmpty && !footage.subCaptions.isEmpty { // 嵌套字幕
                ///查询序列嵌套的子节点footage
                ///Query footage of child node nested in sequence
                fetchCaptionInfo(timelineFootages: footage.subCaptions, trackIndex: footage.trackIndex, clipIndex: footage.clipIndex)
                func fetchCaptionInfo(timelineFootages: [NvsTemplateCaptionDesc], trackIndex: Int32, clipIndex: Int32) {
                    ///缓存嵌套的timeline字幕
                    ///Cache nested timeline subtitles
                    let timelineCaptionInfo = NvTemplateTimelineClipInfo.init(trackIndex: trackIndex, clipIndex: clipIndex, inPoint: 0, isEmptyDesc: false)
                    timelineCaptionInfos.append(timelineCaptionInfo)
                    ///遍历嵌套的片段信息
                    ///Iterate over the nested fragment information
                    for (idx, timelineFootage) in timelineFootages.enumerated() {
                        if timelineFootage.replaceId.isEmpty && !timelineFootage.subCaptions.isEmpty {
                            ///嵌套的字幕
                            ///Nested subtitles
                            fetchCaptionInfo(timelineFootages: timelineFootage.subCaptions, trackIndex: timelineFootage.trackIndex, clipIndex: timelineFootage.clipIndex)
                        }else {
                            configEditCaptionInfo(timelineFootage, infos: timelineCaptionInfos, groupInfo: &groupInfo, target: &captionItems)
                        }
                        if idx == timelineFootages.count - 1 {
                            timelineCaptionInfos.removeLast()
                        }
                    }
                }
            } else {
                ///主timeline的字幕
                ///Subtitles for the main timeline
                configEditCaptionInfo(footage, infos: timelineCaptionInfos, groupInfo: &groupInfo, target: &captionItems)
            }
        }
        return captionItems
    }
    
    private func configEditCaptionInfo(_ footage: NvsTemplateCaptionDesc, infos: [NvTemplateTimelineClipInfo], groupInfo: inout NvTemplateGroupInfo, target: inout [NvTemplateEditItem])  {
        ///1. 轨道信息
        ///1. Orbital information
        var timelineClipinfos: [NvTemplateTimelineClipInfo] = []
        infos.forEach { timelineClipinfos.append($0.copyItem()) }
        ///2. 创建编辑的item
        ///2. Create the edited item
        var item = NvTemplateEditItem.init()
        item.isCaption = true
        item.isCompoundCaption = false
        item.isCanReplace = true
        item.footageId = footage.replaceId
        item.captionContent = footage.text
        if footage.trackIndex >= 0{
            item.trackIndex = UInt32(footage.trackIndex)
        }

        item.isTrackCaption = footage.trackIndex >= 0 && footage.clipIndex < 0
        
        ///3. 获取字幕的seek时间
        ///3. seek time to obtain subtitles
        let result = queryInternalTimeline(timelineClipinfos)
        
        if footage.trackIndex < 0 && footage.clipIndex < 0 {
            /// 时间线字幕
            /// Timeline subtitle
            if let caption = queryTimelineCaption(result.timeline, item: item) {
                item.duration = caption.outPoint - caption.inPoint
                configCaptionFxGroup(caption: caption, inPoint: caption.inPoint, offset: result.offset, groupInfo: &groupInfo, item: &item)
            }
        }
        
        if footage.trackIndex >= 0 && footage.clipIndex < 0 {
            /// 轨道字幕
            /// Track subtitle
            if let caption = queryTrackCaption(result.timeline, item: item) {
                item.duration = caption.outPoint - caption.inPoint
                configCaptionFxGroup(caption: caption, inPoint: caption.inPoint, offset: result.offset, groupInfo: &groupInfo, item: &item)
            }
        }
        
        if footage.trackIndex >= 0 && footage.clipIndex >= 0 {
            /// 片段字幕
            /// Segment captioning
            
        }
        if item.bestSeekTime > cTimeline.duration {
            item.bestSeekTime = cTimeline.duration
        }
        timelineClipinfos.append(NvTemplateTimelineClipInfo.init(trackIndex: footage.trackIndex, clipIndex: footage.clipIndex, inPoint: item.bestSeekTime, isEmptyDesc: true))
        item.timelineNestInfos = timelineClipinfos
        /// 获取缩略图
        /// Get thumbnail
        if item.isCanReplace {
            self.group.addSubWoekItem { [weak self] (group) in
                guard let self = self else { return }
                NvTimelineIcon.asyncGrab(self.streamingContext, timeline: self.cTimeline, timestamp: item.bestSeekTime, completeHandle: {
                    if let image = $0 {
                        item.coverImage = image
                    }
                    group.leave()
                })
            }
        }
        target.append(item)
    }
    
    private func configCaptionFxGroup(caption: NvsCaption, inPoint: Int64, offset: Int64, groupInfo: inout NvTemplateGroupInfo, item: inout NvTemplateEditItem) {
        if let attachTime = caption.getTemplateAttachment(NVS_TEMPLATE_ASSET_KEY_BEST_SEEK_TIME) as? String {
            let seekTime = attachTime.toInt64()
            if seekTime < 0 {
                item.bestSeekTime = offset + inPoint + item.duration / 2
            }else {
                item.bestSeekTime = seekTime
            }
        }else {
            item.bestSeekTime = offset + inPoint + item.duration / 2
        }
        
        if let fxGroup = caption.getTemplateAttachment(NVS_TEMPLATE_KEY_FX_GROUP) as? String, !fxGroup.isEmpty {
            item.isGrouped = true
            if groupInfo.info.keys.contains(fxGroup), let id = groupInfo.info[fxGroup] as? Int {
                item.groupId = id
            }else {
                groupInfo.groupId += 1
                groupInfo.info[fxGroup] = groupInfo.groupId
                item.groupId = groupInfo.groupId
            }
        }
    }
}


///MARK: - 获取模板组合字幕信息
///Gets template composition subtitle information
extension NvTemplateEditerOperator {
    func fetchComCaptionList(templateId: String) -> [NvTemplateEditItem] {
        let comCaptionFootages = streamingContext.assetPackageManager.getTemplateCampoundCaptions(templateId) ?? []
        var comCaptionItems: [NvTemplateEditItem] = []
        ///编组信息
        ///Marshalling information
        var groupInfo: NvTemplateGroupInfo = .init()
        var timelineCaptionInfos: [NvTemplateTimelineClipInfo] = []
        for index in 0..<comCaptionFootages.count {
            ///清空footage序列嵌套信息
            ///Clears footage sequence nested information
            timelineCaptionInfos.removeAll()
            ///获取当前的footage
            ///Gets the current footage
            let footage = comCaptionFootages[index]
            if footage.replaceId.isEmpty && !footage.subCaptions.isEmpty {
                ///嵌套字幕
                ///Nested subtitles
                ///查询序列嵌套的子节点footage
                ///Query footage of child node nested in sequence
                fetchComCaptionInfo(timelineFootages: footage.subCaptions, trackIndex: footage.trackIndex, clipIndex: footage.clipIndex)
                func fetchComCaptionInfo(timelineFootages: [NvsTemplateCompoundCaptionDesc], trackIndex: Int32, clipIndex: Int32) {
                    ///缓存嵌套的timeline字幕
                    ///Cache nested timeline subtitles
                    let timelineCaptionInfo = NvTemplateTimelineClipInfo.init(trackIndex: trackIndex, clipIndex: clipIndex, inPoint: 0, isEmptyDesc: false)
                    timelineCaptionInfos.append(timelineCaptionInfo)
                    ///遍历嵌套的片段信息
                    ///Iterate over the nested fragment information
                    for (idx, timelineFootage) in timelineFootages.enumerated() {
                        if timelineFootage.replaceId.isEmpty && !timelineFootage.subCaptions.isEmpty {
                            ///嵌套的字幕
                            ///Nested subtitles
                            fetchComCaptionInfo(timelineFootages: timelineFootage.subCaptions, trackIndex: timelineFootage.trackIndex, clipIndex: timelineFootage.clipIndex)
                        }else {
                            configEditComCaptionInfo(timelineFootage, infos: timelineCaptionInfos, groupInfo: &groupInfo, target: &comCaptionItems)
                        }
                        if idx == timelineFootages.count - 1 {
                            timelineCaptionInfos.removeLast()
                        }
                    }
                }
            } else {
                ///主timeline的组合字幕
                ///Composite subtitles for the main timeline
                configEditComCaptionInfo(footage, infos: timelineCaptionInfos, groupInfo: &groupInfo, target: &comCaptionItems)
            }
        }
        return comCaptionItems
    }
    
    private func configEditComCaptionInfo(_ footage: NvsTemplateCompoundCaptionDesc, infos: [NvTemplateTimelineClipInfo], groupInfo: inout NvTemplateGroupInfo, target: inout [NvTemplateEditItem])  {
        ///1. 轨道信息
        ///1. Orbital information
        var timelineClipinfos: [NvTemplateTimelineClipInfo] = []
        var comCaptionInfos: [NvTemplateEditItem] = []
        infos.forEach { timelineClipinfos.append($0.copyItem()) }
        ///2. 创建编辑的item
        ///2. Create the edited item
        var item = NvTemplateEditItem.init()
        item.isCaption = false
        item.isCompoundCaption = true
        item.isCanReplace = true
        item.footageId = footage.replaceId
        if footage.trackIndex >= 0{
            item.trackIndex = UInt32(footage.trackIndex)
        }
        item.isTrackCaption = footage.trackIndex >= 0 && footage.clipIndex < 0
        ///3. 获取字幕的seek时间
        ///3. seek time to obtain subtitles
        let result = queryInternalTimeline( timelineClipinfos)
        
        if footage.trackIndex < 0 && footage.clipIndex < 0 {
            ///时间线字幕
            ///Timeline subtitle
            if let caption = queryTimelineComCaption(result.timeline, item: item) {
                item.duration = caption.outPoint - caption.inPoint
                item.captionContent = caption.getText(0)
                configComCaptionFxGroup(caption: caption, inPoint: caption.inPoint, offset: result.offset, groupInfo: &groupInfo, item: &item)
            }
        }
        
        if footage.trackIndex >= 0 && footage.clipIndex < 0 {
            ///轨道字幕
            ///Track subtitle
            if let caption = queryTrackComCaption(result.timeline, item: item) {
                item.duration = caption.outPoint - caption.inPoint
                item.captionContent = caption.getText(0)
                configComCaptionFxGroup(caption: caption, inPoint: caption.inPoint, offset: result.offset, groupInfo: &groupInfo, item: &item)
            }
        }
        
        if footage.trackIndex >= 0 && footage.clipIndex >= 0 {
            ///片段字幕
            ///Segment captioning
            
        }
        if item.bestSeekTime > cTimeline.duration {
            item.bestSeekTime = cTimeline.duration
        }
        timelineClipinfos.append(NvTemplateTimelineClipInfo.init(trackIndex: footage.trackIndex, clipIndex: footage.clipIndex, inPoint: item.bestSeekTime, isEmptyDesc: true))
        item.timelineNestInfos = timelineClipinfos
        
        if footage.trackIndex < 0 && footage.clipIndex < 0 {
            if let caption = queryTimelineComCaption(result.timeline, item: item) {
                self.creatComCaption(item: item, array: &comCaptionInfos, caption: caption)
            }
        }
        
        if footage.trackIndex >= 0 && footage.clipIndex < 0 {
            if let caption = queryTrackComCaption(result.timeline, item: item) {
                self.creatComCaption(item: item, array: &comCaptionInfos, caption: caption)
            }
        }
        
        for tempitem in comCaptionInfos {
            target.append(tempitem)
        }
    }
    
    func creatComCaption(item:NvTemplateEditItem, array:inout Array<NvTemplateEditItem>,caption:NvsCompoundCaption) {
        for i in 0...(caption.captionCount-1){
            var tempItem:NvTemplateEditItem = item.copyItem()
            tempItem.captionContent = caption.getText(i)
            tempItem.compoundCaptionIndex = i
            array.append(tempItem)
            ///获取缩略图
            ///Get thumbnail
            if tempItem.isCanReplace {
                self.group.addSubWoekItem { [weak self] (group) in
                    guard let self = self else { return }
                    NvTimelineIcon.syncGrab(self.streamingContext, timeline: self.cTimeline, timestamp: item.bestSeekTime, completeHandle: {
                        if let image = $0 {
                            tempItem.coverImage = image
                        }
                        group.leave()
                    })
                }
            }
        }
    }
    
    private func configComCaptionFxGroup(caption: NvsCompoundCaption, inPoint: Int64, offset: Int64, groupInfo: inout NvTemplateGroupInfo, item: inout NvTemplateEditItem) {
        if let attachTime = caption.getTemplateAttachment(NVS_TEMPLATE_ASSET_KEY_BEST_SEEK_TIME) as? String {
            let seekTime = attachTime.toInt64()
            if seekTime < 0 {
                item.bestSeekTime = offset + inPoint + item.duration / 2
            }else {
                item.bestSeekTime = seekTime
            }
        }else {
            item.bestSeekTime = offset + inPoint + item.duration / 2
        }
        if let fxGroup = caption.getTemplateAttachment(NVS_TEMPLATE_KEY_FX_GROUP) as? String, !fxGroup.isEmpty {
            item.isGrouped = true
            if groupInfo.info.keys.contains(fxGroup), let id = groupInfo.info[fxGroup] as? Int {
                item.groupId = id
            }else {
                groupInfo.groupId += 1
                groupInfo.info[fxGroup] = groupInfo.groupId
                item.groupId = groupInfo.groupId
            }
        }
    }
}


extension NvTemplateEditerOperator {
    /// 获取嵌套的timeline
    /// Gets the nested timeline
    /// - Parameter clipInfos: 嵌套的轨道信息
    /// Nested orbital information
    func queryInternalTimeline(_ clipInfos: [NvTemplateTimelineClipInfo]) -> (timeline: NvsTimeline, offset: Int64) {
        var tempTimeline: NvsTimeline? = nil
        var tempInPoint: Int64 = 0
        for clipInfo in clipInfos where clipInfo.isEmptyDesc == false {
            if let timeline = tempTimeline {
                if let videoTrack = timeline.getVideoTrack(by: UInt32(clipInfo.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(clipInfo.clipIndex)) {
                    tempTimeline = videoClip.getInternalTimeline()
                    tempInPoint += videoClip.inPoint
                }
            }else {
                if let videoTrack = cTimeline.getVideoTrack(by: UInt32(clipInfo.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(clipInfo.clipIndex)) {
                    tempTimeline = videoClip.getInternalTimeline()
                    tempInPoint += videoClip.inPoint
                }
            }
        }
        if let timeline = tempTimeline {
            return (timeline, tempInPoint)
        }else {
            return (cTimeline, tempInPoint)
        }
    }
    func queryVideoClip(_ timeline: NvsTimeline, item: NvTemplateEditItem) -> NvsVideoClip? {
        var tempVideoClip: NvsVideoClip? = nil
        if item.trackIndex >= 0, item.clipIndex >= 0, let videoTrack = timeline.getVideoTrack(by: UInt32(item.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(item.clipIndex)) {
            tempVideoClip = videoClip
        }
        return tempVideoClip
    }
    func queryTimelineCaption(_ timeline: NvsTimeline, item: NvTemplateEditItem) -> NvsTimelineCaption? {
        var caption = timeline.getFirstCaption()
        while caption != nil {
            let captionId = caption!.getTemplateAttachment(NVS_TEMPLATE_KEY_REPLACE_ID)
            if captionId == item.footageId {
                return caption
            }
            caption = timeline.getNextCaption(caption)
        }
        return nil
    }
    
    func queryTrackCaption(_ timeline: NvsTimeline, item: NvTemplateEditItem) -> NvsTrackCaption? {
        if item.trackIndex >= 0, let videoTrack = timeline.getVideoTrack(by: UInt32(item.trackIndex)) {
            var caption = videoTrack.getFirstCaption()
            while caption != nil {
                let captionId = caption!.getTemplateAttachment(NVS_TEMPLATE_KEY_REPLACE_ID)
                if captionId == item.footageId {
                    return caption
                }
                caption = videoTrack.getNextCaption(caption)
            }
        }
        return nil
    }
    
    func queryTimelineComCaption(_ timeline: NvsTimeline, item: NvTemplateEditItem) -> NvsTimelineCompoundCaption? {
        var caption = timeline.getFirstCompoundCaption()
        while caption != nil {
            let captionId = caption!.getTemplateAttachment(NVS_TEMPLATE_KEY_REPLACE_ID)
            if captionId == item.footageId {
                return caption
            }
            caption = timeline.getNextCompoundCaption(caption)
        }
        return nil
    }
    
    func queryTrackComCaption(_ timeline: NvsTimeline, item: NvTemplateEditItem) -> NvsTrackCompoundCaption? {
        if item.trackIndex >= 0, let videoTrack = timeline.getVideoTrack(by: UInt32(item.trackIndex)) {
            var caption = videoTrack.getFirstCompoundCaption()
            while caption != nil {
                let captionId = caption!.getTemplateAttachment(NVS_TEMPLATE_KEY_REPLACE_ID)
                if captionId == item.footageId {
                    return caption
                }
                caption = videoTrack.getNextCompoundCaption(caption)
            }
        }
        return nil
    }
    
    func sortedEditFootages(editItems: [NvTemplateEditItem]) -> [NvTemplateEditItem] {
        let sortedFootages = editItems.sorted { lhs, rhs in
            var flags = false
            if lhs.bestSeekTime == rhs.bestSeekTime {
                ///入点相同
                ///Same entry point
                let clipInfo1 = lhs.timelineNestInfos
                let clipInfo2 = rhs.timelineNestInfos
                let count = min(clipInfo1.count, clipInfo2.count)
                for index in 0..<count {
                    let info1 = clipInfo1[index]
                    let info2 = clipInfo2[index]
                    if info1.trackIndex == info2.trackIndex {
                        if index == count - 1 {
                            flags = clipInfo1.count < clipInfo2.count
                        }
                    }else {
                        flags = info1.trackIndex < info2.trackIndex
                    }
                }
            }else {
                flags = lhs.bestSeekTime < rhs.bestSeekTime
            }
            return flags
        }
        return sortedFootages
    }
}

public class NvTemplateEditerOperator {
    let streamingContext: NvsStreamingContext
    let cTimeline: NvsTimeline
    var group: NvGCDGroup = NvGCDGroup.init()
    
    func startGrabIcon(complete: @escaping (_ finished: Bool) -> Void) {
        self.group.start(completion: {
            complete(true)
        })
    }
    
    init(timeline: NvsTimeline, context: NvsStreamingContext) {
        self.streamingContext = context
        self.cTimeline = timeline
    }
}
