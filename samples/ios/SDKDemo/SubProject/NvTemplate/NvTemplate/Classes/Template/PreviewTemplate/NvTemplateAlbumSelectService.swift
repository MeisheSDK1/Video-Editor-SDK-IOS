//
//  NvTemplateAlbumSelectService.swift
//  NvTemplate
//
//  Created by meishe20241218 on 2025/6/30.
//

import UIKit
import NvAlbum
import NvStreamingSdkCore

@objc protocol NvTemplateAlbumSelectServiceDelegate {
    @objc optional func nvTemplateAlbumSelectService(service: NvTemplateAlbumSelectService, toast: NSString)
    
    @objc optional func nvTemplateAlbumSelectService(service: NvTemplateAlbumSelectService, controller : NvAlbumViewController, selectTemplates templates: Array<NvAlbumTemplateItem>, supportedRatio: Int)
}

class NvTemplateAlbumSelectService: NSObject, NvAlbumViewControllerSelectStrategy {
    weak var delegate : NvTemplateAlbumSelectServiceDelegate?
    
    public var categoryTemplate : Int = 1

    public var templateClips: [NvAlbumTemplateItem] = []
    /// 支持的比例
    /// Proportion of support
    public var templateSupportRations: [String] = []
    /// 默认支持的比例
    /// The default supported ratio
    public var templateDefaultRation: String = ""
    /// 是否含有编组
    /// Whether it contains marshalling
    public var templateGrouped: Bool = false
    /// 模版视图
    /// Template view
    public var templateView: NvAlbumTemplateView?
    
    private(set) var selectAssetSource : Array<NvAlbumAsset> = Array<NvAlbumAsset>()
    
    private var albumViewController: NvAlbumViewController?
    
    func enable(_ albumViewController: NvAlbumViewController!) -> Bool {
        self.albumViewController = albumViewController
        selectAssetSource.removeAll()
        return true
    }
    
    func nvAlbumViewController(_ albumViewController: NvAlbumViewController!, selectAssetOnSelectStrategy asset: PHAsset!) {
        var selectAsset = NvAlbumAsset()
        selectAsset.asset = asset
        selectAsset.isShowLayer = false
        processSelectedAsset(selectAsset: selectAsset)
    }
    
    func processSelectedAsset(selectAsset: NvAlbumAsset) {
        if self.categoryTemplate == 2 {
            let item = self.templateView?.dataSource.first
            if item != nil && item!.isAdaptationDuration{
                if item!.asset == nil {
                    //                    self.selectAsset(selectAsset)
                    selectAssetSource.append(selectAsset)
                    item!.asset = selectAsset.asset
                    if selectAsset.asset?.mediaType == PHAssetMediaType.image {
                        item!.duration = 4000000
                    }else{
                        item!.duration = Int64(selectAsset.asset!.duration*1000000)
                    }
                }
            }else{
                //                self.selectAsset(selectAsset)
                selectAssetSource.append(selectAsset)
                let templateItem = NvAlbumTemplateItem.init()
                templateItem.asset = selectAsset.asset
                if selectAsset.asset?.mediaType == PHAssetMediaType.image {
                    templateItem.duration = 4000000
                }else{
                    templateItem.duration = Int64(selectAsset.asset!.duration*1000000)
                }
                self.templateView?.dataSource.append(templateItem)
            }
            self.templateView?.nv_reloadData()
            
            return
        }
        /// 模版限制选中个数和时长(可以导入相同的素材)
        /// Template limit number and duration of selection (can import the same material)
        
        /// 编组，图片统一导入
        /// Grouping, unified import of pictures
        var isImage = false
        
        if selectAssetSource.count >= templateClips.count {
            selectAsset.isShowLayer = !selectAsset.isShowLayer
            return
        }else {
            /// 时长判断
            /// Duration judgment
            if let item = self.templateView?.dataSource.first(where: { $0.asset == nil }), let asset = selectAsset.asset {
                if asset.mediaType == .video {
                    /// 素材类型 0：不限，1：视频 2：图片
                    /// Material type 0: unlimited 1: video 2: picture
                    if item.type == 2 {
                        selectAsset.isShowLayer = !selectAsset.isShowLayer
                        
                        self.delegate?.nvTemplateAlbumSelectService?(service: self, toast: NvLocalProvider.String(key: "Support only image export", comment: "仅支持图片导入") as NSString)
                        return
                    }else {
                        if let avInfo = NvsStreamingContext.sharedInstance()?.getAVFileInfo(asset.localIdentifier), item.duration > avInfo.duration {
                            selectAsset.isShowLayer = !selectAsset.isShowLayer
                            
                            self.delegate?.nvTemplateAlbumSelectService?(service: self, toast: NvLocalProvider.String(key: "VideoClip duration lower", comment: "视频片段过短") as NSString)
                            return
                        }
                    }
                }else if asset.mediaType == .image {
                    /// 素材类型 0：不限，1：视频 2：图片
                    /// Material type 0: unlimited 1: video 2: picture
                    if item.type == 1 {
                        selectAsset.isShowLayer = !selectAsset.isShowLayer
                        
                        self.delegate?.nvTemplateAlbumSelectService?(service: self, toast: NvLocalProvider.String(key: "Support only video export", comment: "仅支持视频导入") as NSString)
                        return
                    }
                    isImage = true
                }
            }
        }
        
        if let item = self.templateView?.dataSource.first(where: { $0.asset == nil }) {
            if templateGrouped && isImage {
                self.templateView?.dataSource.forEach({
                    if $0.footageId == item.footageId && $0.asset == nil {
//                        self.selectAsset(selectAsset)
                        selectAssetSource.append(selectAsset)
                        $0.asset = selectAsset.asset
                        $0.isImage = isImage
                    }
                })
                self.templateView?.nv_reloadData()
            }else {
//                self.selectAsset(selectAsset)
                selectAssetSource.append(selectAsset)
                item.asset = selectAsset.asset
                item.isImage = isImage
                self.templateView?.nv_reloadData()
            }
        }
        
    }
    
}

//MARK: -  模版
///template
extension NvTemplateAlbumSelectService : NvAlbumTemplateViewDelegate {
    private func fetchTemplateModels() -> [NvAlbumTemplateItem] {
        var templates: [NvAlbumTemplateItem] = []
        if self.categoryTemplate == 2 {
            if templateClips.count >= 1 {
                let clip = templateClips[0]
                if clip.isAdaptationDuration {
                    let copyClip = clip.copy() as! NvAlbumTemplateItem
                    copyClip.index = 0
                    copyClip.isSelected = true
                    templates.append(copyClip)
                }
            }
            return templates
        }
        
        for index in 0..<templateClips.count {
            let clip = templateClips[index]
            let copyClip = clip.copy() as! NvAlbumTemplateItem
            copyClip.index = index
            copyClip.isSelected = index == 0 ? true : false
            templates.append(copyClip)
        }
        return templates
    }
    
    public func initTemplateView() -> NvAlbumTemplateView {
        let templateView: NvAlbumTemplateView = NvAlbumTemplateView.init(frame: CGRect.init(x: 0, y: SCREENHEIGHT - NV_STATUSBARHEIGHT - 44 - 142 * SCREENSCALE - SafeAreaBottomHeight, width: SCREENWIDTH, height: 142 * SCREENSCALE + SafeAreaBottomHeight), hasGrouped: self.templateGrouped)
        templateView.dataSource = NSMutableArray.init() as! [NvAlbumTemplateItem]
        templateView.delegate = self
        templateView.categoryTemplate = categoryTemplate
        templateView.dataSource = fetchTemplateModels()
        return templateView
    }
    
    func templateView(_ templateView: NvAlbumTemplateView, didReceive nextEvent: Bool) {
        if nextEvent {
            if self.templateSupportRations.count > 1 {
                NvAspectRatioView.nv_fadeIn(supportedRatios: self.templateSupportRations, defaultRatio: templateDefaultRation, completeHandle: { (ratio) in
                    self.delegate?.nvTemplateAlbumSelectService?(service: self, controller: self.albumViewController!, selectTemplates: templateView.dataSource, supportedRatio: ratio)
                })
            }else {
                if self.categoryTemplate == 2, !templateView.dataSource.isEmpty {
                    self.delegate?.nvTemplateAlbumSelectService?(service: self, controller: self.albumViewController!, selectTemplates: templateView.dataSource, supportedRatio: Int(NvUtils.getAspectRatioRawValue(for: templateDefaultRation)))
                }else if self.categoryTemplate != 2{
                    
                    self.delegate?.nvTemplateAlbumSelectService?(service: self, controller: self.albumViewController!, selectTemplates: templateView.dataSource, supportedRatio: 0)
                }
                
            }
        }
    }
    
    func templateView(_ templateView: NvAlbumTemplateView, didDeleteTemplate index: Int) {
        /// 刷新相册数据
        /// Refresh album data
        let item = templateView.dataSource[index]
        guard let selectAsset = selectAssetSource.first(where: { $0.asset?.localIdentifier == item.asset?.localIdentifier }) else { return }
        
        if selectAssetSource.contains(selectAsset) {
            let index = selectAssetSource.firstIndex(of: selectAsset)
            selectAssetSource.remove(at: index!)
        }
        if selectAssetSource.contains(selectAsset) {
            selectAsset.isShowLayer = true
        }else {
            selectAsset.isShowLayer = false
        }
        //                reloadData()
        if self.categoryTemplate == 2 {
            if item.isAdaptationDuration {
                /// 重置数据
                /// Reset data
                templateView.dataSource[index].asset = nil
                templateView.dataSource[index].isReversed = false
            }else{
                templateView.dataSource.remove(at: index)
            }
        }else{
            /// 重置数据
            /// Reset data
            templateView.dataSource[index].asset = nil
            templateView.dataSource[index].isReversed = false
        }
        
        templateView.nv_reloadData()
    }
    
}

