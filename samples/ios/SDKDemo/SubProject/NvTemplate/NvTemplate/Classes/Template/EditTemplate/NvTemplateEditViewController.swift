//
//  NvTemplateEditViewController.swift
//  MYVideo
//
//  Created by meicam on 2020/11/4.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import Photos
import NvStreamingSdkCore
import NvAlbum

class NvTemplateEditViewController: NvTemplateBaseViewController {
    let albumSelectService = NvTemplateAlbumSelectService()
    /// 替换素材集
    /// Alternate material set
    public var replaceAssets: [NvAlbumTemplateItem] = []
    
    init(withTemplate tid: String, pid: String!, cTimeline: NvsTimeline) {
        super.init(nibName: nil, bundle: nil)
        self.timeline = cTimeline
        self.templateId = tid
        self.packageId = pid
        self.templateOperator = NvTemplateEditerOperator.init(timeline: self.timeline, context: self.streamingContext)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 设置导航栏
        /// Set the navigation bar
        nv_setupNavigationBar()
        /// 配置数据
        /// Configuration data
        nv_configData()
        albumSelectService.delegate = self
        /// 设置UI
        /// Set the UI
        nv_setupUI()
        /// 设置代理
        /// Set up agent
        clipListView.delegate = self
        streamingContext.delegate = self
        /// 开启预览
        /// Open preview
        guard timeline.duration > 0 else { return }
        streamingContext.connect(timeline, with: liveWindow)
        streamingContext.playbackTimeline(timeline, startTime: 0, endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.leftItem.setImage(NvUtils.imageWithName( "template_edit_back"), for: .normal)
        self.leftItem.setImage(NvUtils.imageWithName( "template_edit_back"), for: .highlighted)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func popEvent() {
        streamingContext.stop()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ComeToPreview"), object: nil, userInfo: nil)
        super.popEvent()
    }
    
    private var templateEditIndex: Int = 0
    private var packageId: String!
    private var templateId: String!
    private var templateVideoDescs: [NvsTemplateFootageDesc] = []
    private var templateCaptionDescs: [NvsTemplateCaptionDesc] = []
    
    private var trackCaption: NvsTrackCaption!
    private var trackComCaption: NvsTrackCompoundCaption!
    private var currentCaption: NvsTimelineCaption!
    private var currentCompoundCaption: NvsTimelineCompoundCaption!
    private var currentClipCaption: NvsClipCaption!
    private var currentClipCompoundCaption: NvsClipCompoundCaption!
    private var currentClipIndex: UInt32 = 0
    private var currentCompoundCaptionIndex: Int = 0
    private var currentVideoClip: NvsVideoClip!
    private var currentCapitonItem: NvTemplateEditItem!
    
    private var videoTemplates: [NvTemplateEditItem] = [NvTemplateEditItem]()
    private var textTemplates: [NvTemplateEditItem] = [NvTemplateEditItem]()
    private var currentEditType: NvTemplateEditType = .video
    private var willRaplaceAsset: PHAsset? = nil
    
    private let streamingContext: NvsStreamingContext = NvsStreamingContext.sharedInstance()!
    private let liveWindow: NvsLiveWindow = NvsLiveWindow(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
    private var timeline: NvsTimeline!
    private var templateOperator: NvTemplateEditerOperator!
//    private var rectView: NvRectView!
    private let playBtn = UIButton(type: .custom)
    private let timeLabel = UILabel.init()
    private let slider = NvSlider.init()
    private let totalTimeLabel = UILabel.init()
    private var clipListView: NvTemplateListView!
    private var editClip:NvEditClipItemView!
    private var templateInputView:NvTemplateInputView?
    public var templateInfo: NvTemplateInfo?
    /// 这里和网络请求的分类一致，1=标准模版，2=自适应时长模版，3=AE转换模版
    /// This is consistent with the classification of network requests, 1= standard template, 2= adaptive duration template, 3=AE conversion template
    public var categoryTemplate : Int = 1
    
    public var scaleForSeek: Float = 0.0
}

extension NvTemplateEditViewController {
    /// Video player progress bar scrolling callback
    ///
    /// - Remark: 视频播放器进度条滚动回调
    ///
    /// - Parameter value: slider
    ///
    @objc
    
    private func valueChanged(value: UISlider) {
        var flags = Int32(NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_AllowFastScrubbing.rawValue)
        self.scaleForSeek = Float(CGFloat(timeline.duration)/1000000.0/self.slider.frame.size.width/UIScreen.main.scale)
        streamingContext.setTimeline(timeline, scaleForSeek: Double(self.scaleForSeek))
        streamingContext.seekTimeline(timeline, timestamp: Int64(slider.value), videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: flags)
    }
    
    @objc
    
    private func sliderValueEnd(value: UISlider) {
        streamingContext.seekTimeline(timeline, timestamp: Int64(slider.value), videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
    }
    
    @objc
    private func playClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if streamingContext.getStreamingEngineState() == NvsStreamingEngineState_Playback {
            streamingContext.stop()
        } else {
            streamingContext.playbackTimeline(timeline, startTime: streamingContext.getTimelineCurrentPosition(timeline), endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
            clipListView.resetTemplateState(for: self.currentEditType)
        }
    }
    
    @objc
    private func exportClick() {
        if self.isPackagingTemplate {
            let template = self.videoTemplates[0]
            let coverImage = streamingContext.grabImage(from: timeline, timestamp: 100000, proxyScale: nil)
            let useInfo = ["timeline":timeline, "cover":coverImage]
            
            if let vc:NvTemplatePreviewViewController = self.navigationController!.viewControllers[4] as? NvTemplatePreviewViewController {
                vc.endOfplay()
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toPackagingTemplateViewController"), object: nil, userInfo: useInfo)
            self.navigationController?.popToViewController(self.navigationController!.viewControllers[2], animated: true)
        }else{
            NvTemplateCompileView.compileTimeline(cTimeline: timeline, tid: self.templateId, delegate: self, defaultAspectRatio: UInt32(self.templateInfo?.defaultAspectRatio ?? Int32(NvsAssetPackageAspectRatio_16v9.rawValue)))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (templateInputView != nil && templateInputView!.backButton.isEnabled) {
            templateInputView?.textView.resignFirstResponder()
        }
    }
}

//MARK: - NvTemplateListViewDelegate
extension NvTemplateEditViewController: NvTemplateListViewDelegate {
    func templateListView(_ listView: NvTemplateListView, didChangeEditType type: NvTemplateEditType) {
        self.currentEditType = type
        if type == .video {
//            self.rectView.isHidden = true
        }else {
//            self.rectView.isHidden = false
        }
    }
    
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
                if let videoTrack = self.timeline.getVideoTrack(by: UInt32(clipInfo.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(clipInfo.clipIndex)) {
                    tempTimeline = videoClip.getInternalTimeline()
                    tempInPoint += videoClip.inPoint
                }
            }
        }
        if let timeline = tempTimeline {
            return (timeline, tempInPoint)
        }else {
            return (self.timeline, tempInPoint)
        }
    }
    
    func queryVideoClip(_ timeline: NvsTimeline, item: NvTemplateEditItem) -> NvsVideoClip? {
        var tempVideoClip: NvsVideoClip? = nil
        if item.trackIndex >= 0, item.clipIndex >= 0, let videoTrack = timeline.getVideoTrack(by: UInt32(item.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(item.clipIndex)) {
            tempVideoClip = videoClip
        }
        return tempVideoClip
    }
    
    /// Template fragment click event
    ///
    /// - Remark: 模版片段点击事件
    ///
    /// - Parameters:
    ///   - listView: clip list
    ///   - index: click index
    ///   - type: video or caption
    ///
    func templateListView(_ listView: NvTemplateListView, didSelectAtIndex index: Int, templateEdit type: NvTemplateEditType) {
        if type == .video {
            /// 点击视频编辑videoTemplates
            /// Click on Video Edit videoTemplates
            if index < self.videoTemplates.count {
                let item = self.videoTemplates[index]
                if let videoTrack = timeline.getVideoTrack(by: UInt32(item.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(item.clipIndex)) {
                    self.currentVideoClip = videoClip
                    if self.categoryTemplate == 3{
                        slider.value = Float(item.bestSeekTime)
                        streamingContext.seekTimeline(timeline, timestamp: item.bestSeekTime, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                    }else{
                        slider.value = Float(videoClip.inPoint)
                        streamingContext.seekTimeline(timeline, timestamp: videoClip.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                    }
                }
            }
        }else if type == .text {
            /// 点击文本编辑
            /// Click text edit
            if self.categoryTemplate == 1 || self.categoryTemplate == 3 {
                guard self.textTemplates.count > index else { return }
                let textItem = self.textTemplates[index]
                self.currentCaption = nil
                self.currentCompoundCaption = nil
                self.currentClipCaption = nil
                self.currentClipCompoundCaption = nil
                self.trackCaption = nil
                self.trackComCaption = nil
                self.currentCompoundCaptionIndex = 0
                let result = templateOperator.queryInternalTimeline(textItem.timelineNestInfos)
                if textItem.isCaption {
                    /// 字幕
                    /// subtitle
                    if textItem.isTrackCaption {
                        /// 轨道字幕
                        /// Track subtitle
                        self.trackCaption = templateOperator.queryTrackCaption(result.timeline, item: textItem)
                    }else {
                        /// 时间线字幕
                        /// Timeline subtitle
                        self.currentCaption = templateOperator.queryTimelineCaption(result.timeline, item: textItem)
                    }
                }else {
                    ///组合字幕
                    ///Combined captioning
                    if textItem.isTrackCaption {
                        ///轨道字幕
                        ///Track subtitle
                        self.trackComCaption = templateOperator.queryTrackComCaption(result.timeline, item: textItem)
                    }else {
                        ///时间线字幕
                        ///Timeline subtitle
                        self.currentCompoundCaption = templateOperator.queryTimelineComCaption(result.timeline, item: textItem)
                    }
                    
                    self.currentCompoundCaptionIndex = textItem.compoundCaptionIndex
                }
                
                slider.value = Float(textItem.bestSeekTime)
                streamingContext.seekTimeline(timeline, timestamp: textItem.bestSeekTime, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
            }else if self.categoryTemplate == 2{
                self.currentCaption = nil
                self.currentCompoundCaption = nil
                self.currentClipCaption = nil
                self.currentClipCompoundCaption = nil
                
                if index < self.textTemplates.count {
                    let item = self.textTemplates[index]
                    if item.isClipCaption {
                        let videoTrack = self.timeline.getVideoTrack(by: 0)
                        let clip = videoTrack!.getClipWith(item.clipIndex)
                        if item.isCompoundCaption {
                            var compoundCaption = clip?.getFirstCompoundCaption()
                            while compoundCaption != nil {
                                let captionItem:NvTemplateEditItem = compoundCaption!.getAttachment("item\(item.compoundCaptionIndex)") as! NvTemplateEditItem
                                if captionItem.isEqual(item) {
                                    self.currentClipCompoundCaption = compoundCaption
                                    self.currentCompoundCaptionIndex = item.compoundCaptionIndex
                                    slider.value = Float(compoundCaption!.inPoint+clip!.inPoint)
                                    streamingContext.seekTimeline(timeline, timestamp: compoundCaption!.inPoint+clip!.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                                    break
                                }
                                compoundCaption = clip?.getNextCompoundCaption(compoundCaption)
                            }
                        }else{
                            var caption = clip?.getFirstCaption()
                            while caption != nil {
                                let captionItem:NvTemplateEditItem = caption!.getAttachment("item") as! NvTemplateEditItem
                                if captionItem.isEqual(item) {
                                    self.currentClipCaption = caption;
                                    slider.value = Float(caption!.inPoint+clip!.inPoint)
                                    streamingContext.seekTimeline(timeline, timestamp: caption!.inPoint+clip!.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                                    break
                                }
                                caption = clip?.getNextCaption(caption)
                            }
                        }
                    }else{
                        if item.isCompoundCaption {
                            var compoundCaption = timeline.getFirstCompoundCaption()
                            while compoundCaption != nil {
                                let captionItem:NvTemplateEditItem = compoundCaption!.getAttachment("item\(item.compoundCaptionIndex)") as! NvTemplateEditItem
                                if captionItem.isEqual(item) {
                                    self.currentCaption = nil
                                    self.currentCompoundCaption = compoundCaption
                                    self.currentCompoundCaptionIndex = item.compoundCaptionIndex
                                    slider.value = Float(compoundCaption!.inPoint)
                                    streamingContext.seekTimeline(timeline, timestamp: compoundCaption!.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                                    break
                                }
                                compoundCaption = timeline.getNextCompoundCaption(compoundCaption)
                            }
                        }else{
                            var caption = timeline.getFirstCaption()
                            while caption != nil {
                                let captionItem:NvTemplateEditItem = caption!.getAttachment("item") as! NvTemplateEditItem
                                if captionItem.isEqual(item) {
                                    self.currentCaption = caption
                                    self.currentCompoundCaption = nil
                                    slider.value = Float(caption!.inPoint)
                                    streamingContext.seekTimeline(timeline, timestamp: caption!.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                                    break
                                }
                                caption = timeline.getNextCaption(caption)
                            }
                        }
                    }
                }
            }
        }
    }
    func pointArrayForValues(array:Array<NSValue>) -> [CGPoint] {
        let leftTopValue = array[0]
        let leftBottomValue = array[1]
        let rightBottomValue = array[2]
        let rightTopValue = array[3]
        var topLeftCorner = leftTopValue.cgPointValue
        var bottomLeftCorner = leftBottomValue.cgPointValue
        var rightBottomCorner = rightBottomValue.cgPointValue
        var rightTopCorner = rightTopValue.cgPointValue
        topLeftCorner = liveWindow.mapCanonical(toView: topLeftCorner)
        rightBottomCorner = liveWindow.mapCanonical(toView: rightBottomCorner)
        bottomLeftCorner = liveWindow.mapCanonical(toView: bottomLeftCorner)
        rightTopCorner = liveWindow.mapCanonical(toView: rightTopCorner)
        return  [topLeftCorner,bottomLeftCorner,rightBottomCorner,rightTopCorner]
    }
    
    /// Template fragment editing events
    ///
    /// - Remark: 模版片段编辑事件
    ///
    /// - Parameters:
    ///   - listView: clip list
    ///   - index: click index
    ///   - type: video or caption
    ///
    func templateListView(_ listView: NvTemplateListView, willEditTemplateAtIndex index: Int, templateEdit type: NvTemplateEditType) {
        templateEditIndex = index
        if type == .video {
            /// 点击视频编辑
            /// Click on Video Edit
            editClip = NvEditClipItemView.init(frame: UIScreen.main.bounds)
            editClip.delegate = self
            if self.categoryTemplate == 3{
                editClip.tailorBtn.isEnabled = false
                editClip.tailorBtn.setTitleColor(UIColor.init(hex: "#C0C0C0"), for: .normal)
            }
            editClip.show()
        }else if type == .text {
            /// 点击文本编辑
            /// Click text edit
            templateInputView = NvTemplateInputView(frame:CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 292*SCREENSCALE))
            if self.currentCompoundCaption != nil {
                templateInputView?.textView.text = self.currentCompoundCaption.getText(self.currentCompoundCaptionIndex)
            }else if(self.currentCaption != nil){
                templateInputView?.textView.text = self.currentCaption.getText()
            }else if (self.currentClipCaption != nil){
                templateInputView?.textView.text = self.currentClipCaption.getText()
            }else if (self.currentClipCompoundCaption != nil){
                templateInputView?.textView.text = self.currentClipCompoundCaption.getText(self.currentCompoundCaptionIndex)
            }else if(self.trackCaption != nil){
                templateInputView?.textView.text = self.trackCaption.getText()
            }else if(self.trackComCaption != nil){
                templateInputView?.textView.text = self.trackComCaption.getText(self.currentCompoundCaptionIndex)
            }
            
            self.currentCapitonItem = self.textTemplates[index]
            templateInputView?.delegate = self
            view.addSubview(templateInputView!)
        }
    }
}

//MARK: - NvTemplateInputViewDelegate
extension NvTemplateEditViewController: NvTemplateInputViewDelegate {
    
    
    /// Correction of subtitle
    ///
    /// - Remark: 修该字幕回调
    /// - Parameter word: text
    ///
    func editTextview(word: String) {
        if self.currentCompoundCaption != nil {
            self.currentCompoundCaption.setText(self.currentCompoundCaptionIndex, text: word)
        }else if(self.currentCaption != nil){
            self.currentCaption?.setText(word)
        }else if (self.currentClipCaption != nil){
            self.currentClipCaption?.setText(word)
        }else if (self.currentClipCompoundCaption != nil){
            self.currentClipCompoundCaption.setText(self.currentCompoundCaptionIndex, text: word)
        }else if(self.trackCaption != nil){
            self.trackCaption?.setText(word)
        }else if (self.trackComCaption != nil){
            self.trackComCaption.setText(self.currentCompoundCaptionIndex, text: word)
        }
        self.streamingContext.seekTimeline(timeline, timestamp: streamingContext.getTimelineCurrentPosition(timeline), videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        
        self.currentCapitonItem.captionContent = word
        self.clipListView.resetTemplateState(for: self.currentEditType)
    
    }
}

//MARK: - NvEditClipItemViewDelegate
extension NvTemplateEditViewController: NvEditClipItemViewDelegate {
    private func nv_queryAsset(for index: Int) -> NvAlbumTemplateItem? {
        let desc = videoTemplates[index]
        if let item = self.replaceAssets.first(where: { $0.trackIndex == desc.trackIndex && $0.clipIndex == desc.clipIndex && $0.footageId == desc.footageId }) {
            return item
        }
        return nil
    }
    
    /// Edit clip callback
    ///
    /// - Remark: 编辑片段回调
    /// - Parameter item: Edit Event
    ///
    func selectedEditItem(item: NvTemplateEditClip) {
        if item == .Replace {
            editClip.dismiss()
            if templateEditIndex < videoTemplates.count {
                let albumVC = NvAlbumViewController.init()
                albumVC.delegate = self
//                albumVC.bottomLineWidth = 20
//                albumVC.categoryTemplate = self.categoryTemplate
                guard let item = nv_queryAsset(for: templateEditIndex) else { return }
                self.willRaplaceAsset = item.asset
                item.asset = nil
                item.isAdaptationDuration = self.categoryTemplate == 2 ? true : false
                albumSelectService.categoryTemplate = self.categoryTemplate
                albumSelectService.templateClips = [item]
                albumSelectService.templateGrouped = false
                albumVC.selectStrategy = albumSelectService
                albumVC.alwaysShowCustomBottom = true
                
                albumVC.hiddenSelectAll = true
                albumVC.mutableSelect = true
                let navi = UINavigationController.init(rootViewController: albumVC)
                navi.modalPresentationStyle = .overCurrentContext
                navi.navigationBar.backgroundColor = UIColor.black
                self.present(navi, animated: true, completion: nil)
            }
        }else if item == .Tailor{
            editClip.dismiss()
            guard let item = nv_queryAsset(for: templateEditIndex) else { return }
            guard let assetPath = item.asset?.localIdentifier else { return }
            if self.categoryTemplate == 2{
                let editClip = NvTemplateAdaptiveEditClipViewController.init(for: assetPath, trimIn: self.currentVideoClip.trimIn, trimOut: self.currentVideoClip.trimOut, resolution: timeline.videoRes, offset: self.currentVideoClip.trimIn)
                editClip.delegate = self
                navigationController?.pushViewController(editClip, animated: false)
            }else{
                let editClip = NvTemplateEditClipViewController.init(for: assetPath, trimIn: self.currentVideoClip.trimIn, trimOut: self.currentVideoClip.trimOut, resolution: timeline.videoRes, offset: self.currentVideoClip.trimIn)
                editClip.delegate = self
                navigationController?.pushViewController(editClip, animated: false)
            }
        }else if item == .Volumn{
            
        }
    }
}

//MARK: - NvAlbumViewControllerDelegate, NvTemplateEditClipViewControllerDelegate
//
extension NvTemplateEditViewController: NvAlbumViewControllerDelegate, NvTemplateEditClipViewControllerDelegate {
    
    /// Material clipping callback
    ///
    /// - Remark: 素材裁剪回调
    /// - Parameters:
    ///   - offset: Clipping offset
    ///   - isChnaged: Offset or not
    ///
    func templateTailorDidEnded(offset: Int64, isChnaged: Bool) {
        streamingContext.delegate = self
        self.streamingContext.connect(self.timeline, with: self.liveWindow)
        self.streamingContext.seekTimeline(self.timeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        if isChnaged {
            self.currentVideoClip.moveTrimPoint(offset - self.currentVideoClip.trimIn)
            /// 更新素材
            /// Update material
            let coverImage = streamingContext.grabImage(from: timeline, timestamp: self.currentVideoClip.inPoint, proxyScale: nil)
            self.clipListView.reloadVideoTemplate(for: nil, image: coverImage, atIndex: self.templateEditIndex)
            self.streamingContext.seekTimeline(self.timeline, timestamp: self.currentVideoClip.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
    /// Material replacement callback
    ///
    /// - Remark: 素材替换回调
    /// - Parameters:
    ///   - controller: Albun VC
    ///   - templates: Replace footage
    ///
    func nvAlbumViewController(controller : NvAlbumViewController, selectTemplates templates: Array<NvAlbumTemplateItem>, supportedRatio: Int) {
        self.dismiss(animated: true, completion: {
            if let assetItem = templates.first, self.templateEditIndex < self.videoTemplates.count {
                if let oldItem = self.replaceAssets.first(where: { $0.trackIndex == assetItem.trackIndex && $0.clipIndex == assetItem.clipIndex && $0.footageId == assetItem.footageId }) {
                    oldItem.asset = assetItem.asset
                }
                
                let editItem = self.clipListView.templateClips[self.templateEditIndex]
                if self.categoryTemplate == 2 {
                    editItem.duration = assetItem.duration
                }
                
                self.clipListView.reloadVideoTemplate(for: assetItem.asset!, image: nil, atIndex: self.templateEditIndex)
                
                let template = self.videoTemplates[self.templateEditIndex]
                if self.categoryTemplate == 1{
                    if let videoTrack = self.timeline.getVideoTrack(by: template.trackIndex), let videoClip = videoTrack.getClipWith(template.clipIndex) {
                        videoClip.changeFilePath(assetItem.asset?.localIdentifier)
                        /// seek
                        self.currentVideoClip = videoClip
                        self.slider.value = Float(videoClip.inPoint)
                        self.streamingContext.seekTimeline(self.timeline, timestamp: videoClip.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                    }
                    self.currentVideoClip.moveTrimPoint(0)
                }else if self.categoryTemplate == 2 {
                    let videoTrack = self.timeline.getVideoTrack(by: template.trackIndex)
                    let videoClip = videoTrack!.getClipWith(template.clipIndex)
                    videoClip!.changeFilePath(assetItem.asset?.localIdentifier)
                    
                    let info = self.streamingContext.getAVFileInfo(videoClip!.filePath)
                    videoClip!.changeTrim(inPoint: 0, affectSibling: true)
                    if info!.avFileType == NvsAVFileType_Image{
                        videoClip!.changeTrimOutPoint(4000000, affectSibling: true)
                    }else{
                        videoClip!.changeTrimOutPoint(info!.duration, affectSibling: true)
                    }
                    
                    self.slider.maximumValue = Float(self.timeline.duration)
                    self.totalTimeLabel.text = NvUtils.convertTimecode(time: self.timeline?.duration ?? 0)
                    self.currentVideoClip = videoClip
                    self.slider.value = Float(videoClip!.inPoint)
                    self.streamingContext.seekTimeline(self.timeline, timestamp: videoClip!.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                }else{
                    let result = self.queryInternalTimeline(template.timelineNestInfos)
                    if let videoClip = self.queryVideoClip(result.timeline, item: template) {
                        ///修改片段路径
                        ///Modify fragment path
                        videoClip.changeFilePath(assetItem.asset?.localIdentifier)
                        videoClip.moveTrimPoint(0)
                        
                        self.streamingContext.seekTimeline(self.timeline, timestamp: template.bestSeekTime, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
                    }
                }
            }else {
                guard let item = self.nv_queryAsset(for: self.templateEditIndex) else { return }
                item.asset = self.willRaplaceAsset
                self.willRaplaceAsset = nil
            }
        })
    }
    
    func nvAlbumViewControllerAdjustAlbumCollectionFrameAsCustomBottomViewHeight(atInitialization albumViewController: NvAlbumViewController!) -> Bool {
        return true
    }
    
    func nvAlbumViewControllerUsefulCustomBottomHeight() -> CGFloat {
        return 142 * SCREENSCALE
    }
    
    func nvAlbumViewControllerCustomBottomButton() -> UIView! {
        
        albumSelectService.templateView = albumSelectService.initTemplateView()
        albumSelectService.templateView!.nv_reloadData()
        return albumSelectService.templateView
    }
}

extension NvTemplateEditViewController: NvTemplateAdaptiveEditClipViewControllerDelegate {
    func templateTailorDidEnded(trimIn: Int64, trimOut: Int64, isChnaged: Bool) {
        streamingContext.delegate = self
        self.streamingContext.connect(self.timeline, with: self.liveWindow)
        self.streamingContext.seekTimeline(self.timeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        if isChnaged {
            self.currentVideoClip.changeTrim(inPoint: trimIn, affectSibling: true)
            self.currentVideoClip.changeTrimOutPoint(trimOut, affectSibling: true)
            let coverImage = streamingContext.grabImage(from: timeline, timestamp: self.currentVideoClip.inPoint, proxyScale: nil)
            let item = self.clipListView.templateClips[self.templateEditIndex]
            item.duration = self.currentVideoClip.trimOut - self.currentVideoClip.trimIn
            self.clipListView.reloadVideoTemplate(for: nil, image: coverImage, atIndex: self.templateEditIndex)
            self.streamingContext.seekTimeline(self.timeline, timestamp: self.currentVideoClip.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
            self.slider.maximumValue = Float(self.timeline.duration)
            self.totalTimeLabel.text = NvUtils.convertTimecode(time: self.timeline?.duration ?? 0)
            self.slider.value = Float(self.currentVideoClip.inPoint)
        }
    }
}

//MARK: - NvsStreamingContextDelegate
extension NvTemplateEditViewController: NvsStreamingContextDelegate {
    
    
    /// Timeline playback progress
    ///
    /// - Remark: 时间线播放进度
    ///
    /// - Parameters:
    ///   - timeline: timeline
    ///   - position: play position
    ///
    func didPlaybackTimelinePosition(_ timeline: NvsTimeline!, position: Int64) {
        timeLabel.text = NvUtils.convertTimecode(time: position)
        slider.value = Float(position)
    }
    
    
    /// Timeline playback progress
    ///
    /// - Remark: 引擎状态变化
    ///
    /// - Parameter state: Engine status
    ///
    func didStreamingEngineStateChanged(_ state: NvsStreamingEngineState) {
        if state == NvsStreamingEngineState_Playback {
            playBtn.isSelected = true
        } else {
            playBtn.isSelected = false
        }
    }
    
    
    /// Timeline play over
    ///
    /// - Remark: 时间线播放完毕
    ///
    /// - Parameter timeline: timeline
    ///
    func didPlaybackEOF(_ timeline: NvsTimeline!) {
        DispatchQueue.main.async {
            self.streamingContext.playbackTimeline(timeline, startTime: 0, endTime: self.timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
    func didSeekingTimelinePosition(_ timeline: NvsTimeline!, position: Int64) {
        timeLabel.text = NvUtils.convertTimecode(time: position)
    }
}
//MARK: - NvTemplateCompileViewDelegate
extension NvTemplateEditViewController: NvTemplateCompileViewDelegate {
    func templateCompileViewRemoved() {
        streamingContext.delegate = self
        streamingContext.seekTimeline(timeline, timestamp: streamingContext.getTimelineCurrentPosition(timeline), videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
    }
}

extension NvTemplateEditViewController {
    private func nv_configData() {
        self.templateVideoDescs = streamingContext.assetPackageManager.getTemplateFootages(self.packageId)
        self.templateCaptionDescs = streamingContext.assetPackageManager.getTemplateCaptions(self.packageId)
        var templateClips: [NvTemplateEditItem] = [NvTemplateEditItem]()
        if self.categoryTemplate == 2{
            getTemplateFromArray(templateClips: &templateClips)
            var tempIndex:Int = 0
            var caption = timeline.getFirstCaption()
            while caption != nil {
                let item = NvTemplateEditItem.init()
                item.isSelected = false
                item.duration = 0
                item.isCaption = true
                item.isCanReplace = true
                let grabImage = streamingContext.grabImage(from: timeline, timestamp: caption!.inPoint, proxyScale: nil)
                if let grabbedImg = grabImage {
                    item.coverImage = grabbedImg
                }
                item.captionContent = (caption?.getText())!
                textTemplates.append(item)
                caption?.setAttachment(item as! NSObject, forKey: "item")
                caption = timeline.getNextCaption(caption)
            }
            
            var compoundCaption = timeline.getFirstCompoundCaption()
            while compoundCaption != nil {
                for i in 0..<compoundCaption!.captionCount {
                    let item = NvTemplateEditItem.init()
                    item.isSelected = false
                    item.duration = 0
                    item.isCaption = true
                    item.isCompoundCaption = true
                    item.isCanReplace = true

                    let grabImage = streamingContext.grabImage(from: timeline, timestamp: compoundCaption!.inPoint, proxyScale: nil)
                    if let grabbedImg = grabImage {
                        item.coverImage = grabbedImg
                    }
                    item.captionContent = compoundCaption!.getText(i)
                    item.compoundCaptionIndex = i
                    textTemplates.append(item)
                    compoundCaption?.setAttachment(item as! NSObject, forKey: "item\(item.compoundCaptionIndex)")
                }
                compoundCaption = timeline.getNextCompoundCaption(compoundCaption)
            }
            
            var clipCaption:NvsClipCaption? = nil
            var clipCompoundCaption:NvsClipCompoundCaption? = nil
            
            let videoTrack = self.timeline.getVideoTrack(by: 0)
            for i in 0..<videoTrack!.clipCount {
                let clip = videoTrack!.getClipWith(i)
                clipCaption = clip?.getFirstCaption()
                while clipCaption != nil {
                    let item = NvTemplateEditItem.init()
                    item.isClipCaption = true
                    item.isSelected = false
                    item.clipIndex = clip!.index
                    item.duration = 0
                    item.isCaption = true
                    item.isCanReplace = true

                    let grabImage = streamingContext.grabImage(from: timeline, timestamp: clipCaption!.inPoint+clip!.inPoint, proxyScale: nil)
                    if let grabbedImg = grabImage {
                        item.coverImage = grabbedImg
                    }
                    item.captionContent = (clipCaption?.getText())!
                    textTemplates.append(item)
                    clipCaption?.setAttachment(item as! NSObject, forKey: "item")
                    clipCaption = clip!.getNextCaption(clipCaption)
                }

                clipCompoundCaption = clip?.getFirstCompoundCaption()
                while clipCompoundCaption != nil {
                    for i in 0..<clipCompoundCaption!.captionCount {
                        let item = NvTemplateEditItem.init()
                        item.isSelected = false
                        item.isClipCaption = true
                        item.duration = 0
                        item.clipIndex = clip!.index
                        item.isCaption = true
                        item.isCompoundCaption = true
                        item.isCanReplace = true

                        let grabImage = streamingContext.grabImage(from: timeline, timestamp: clipCompoundCaption!.inPoint+clip!.inPoint, proxyScale: nil)
                        if let grabbedImg = grabImage {
                            item.coverImage = grabbedImg
                        }
                        item.captionContent = clipCompoundCaption!.getText(i)
                        item.compoundCaptionIndex = i
                        textTemplates.append(item)
                        clipCompoundCaption?.setAttachment(item as! NSObject, forKey: "item\(item.compoundCaptionIndex)")
                    }
                    clipCompoundCaption = clip!.getNextCompoundCaption(clipCompoundCaption)
                }
            }
            
            /*
            caption = timeline.getFirstCaption()
            if (caption != nil) {
                slider.value = Float(caption!.inPoint)
                streamingContext.seekTimeline(timeline, timestamp: caption!.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue))
                self.currentCaption = caption
                self.currentCompoundCaption = nil
            }else{
                compoundCaption = timeline.getFirstCompoundCaption()
                if compoundCaption != nil {
                    slider.value = Float(compoundCaption!.inPoint)
                    streamingContext.seekTimeline(timeline, timestamp: compoundCaption!.inPoint, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue))
                    self.currentCompoundCaption = compoundCaption
                    self.currentCaption = nil
                }
            }
             */
        }else{
            getAETemplateFootageFromArray(self.templateVideoDescs, templateClips: &templateClips)
            ///获取字幕和组合字幕
            ///Get subtitles and combined subtitles
            var templateTexts: [NvTemplateEditItem] = []
            templateTexts.append(contentsOf: templateOperator.fetchCaptionList(templateId: self.templateId))
            templateTexts.append(contentsOf: templateOperator.fetchComCaptionList(templateId: self.templateId))
            ///字幕显示排序
            ///Subtitle display sort
            let sortedDescs = templateOperator.sortedEditFootages(editItems: templateTexts)
            for index in 0..<sortedDescs.count {
                let item = sortedDescs[index]
                item.index = index
                textTemplates.append(item)
            }
            templateOperator.startGrabIcon { finished in
                
            }
        }
        
        /// 排序
        /// sort
        let array = templateClips.sorted { (clip1, clip2) -> Bool in
            if self.categoryTemplate == 3{
                if clip1.bestSeekTime == clip2.bestSeekTime {
                    return clip1.trackIndex < clip2.trackIndex
                }else {
                    return clip1.bestSeekTime < clip2.bestSeekTime
                }
            }else{
                if clip1.clipInPoint == clip2.clipInPoint {
                    return clip1.trackIndex < clip2.trackIndex
                }else {
                    return clip1.clipInPoint < clip2.clipInPoint
                }
            }
        }
        for index in 0..<array.count {
            let item = array[index]
            item.index = index
            videoTemplates.append(item)
        }
    }
    
    private func getAETemplateFootageFromArray(_ templateFootages: [NvsTemplateFootageDesc], templateClips: inout [NvTemplateEditItem]) {
        ///序列嵌套信息
        ///Sequence nesting information
        var timelineClipInfos: [NvTemplateTimelineClipInfo] = []
        ///编组信息
        ///Marshalling information
        var groupInfo: NvTemplateGroupInfo = .init()
        
        for index in 0..<templateFootages.count {
            ///清空footage序列嵌套信息
            ///Clears footage sequence nested information
            timelineClipInfos.removeAll()
            ///获取当前的footage
            ///Gets the current footage
            let footage = templateFootages[index]
            if footage.timelineClipFootages.isEmpty { // 不存在序列嵌套
                configEditVideoClipInfo(footage, infos: timelineClipInfos, groupInfo: &groupInfo, target: &templateClips, assets: replaceAssets)
            }else {
                ///获取父节点的信息
                ///Gets information about the parent node
                guard let clipInfo = footage.correspondingClipInfos.first else { continue }
                ///查询序列嵌套的子节点footage
                ///Query footage of child node nested in sequence
                fetchFootageInfo(timelineFootages: footage.timelineClipFootages, superClipInfo: clipInfo)
                func fetchFootageInfo(timelineFootages: [NvsTemplateFootageDesc], superClipInfo: NvsTemplateFootageCorrespondingClipInfo) {
                    ///缓存嵌套的timeline片段
                    ///Cache nested timeline fragments
                    let timelineClipInfo = NvTemplateTimelineClipInfo.init(trackIndex: superClipInfo.trackIndex, clipIndex: superClipInfo.clipIndex, inPoint: superClipInfo.inPoint, isEmptyDesc: false)
                    timelineClipInfos.append(timelineClipInfo)
                    ///遍历嵌套的片段信息
                    ///Iterate over the nested fragment information
                    for (idx, timelineFootage) in timelineFootages.enumerated() {
                        ///查找是否仍是序列嵌套
                        ///Finds if the sequence is still nested
                        if timelineFootage.timelineClipFootages.isEmpty {
                            configEditVideoClipInfo(timelineFootage, infos: timelineClipInfos, groupInfo: &groupInfo, target: &templateClips, assets: replaceAssets)
                        }else {
                            if let timelineClipInfo = timelineFootage.correspondingClipInfos.first {
                                fetchFootageInfo(timelineFootages: timelineFootage.timelineClipFootages, superClipInfo: timelineClipInfo)
                            }
                        }
                        if idx == timelineFootages.count - 1 {
                            timelineClipInfos.removeLast()
                        }
                    }
                }
            }
        }
    }
    
    private func configEditVideoClipInfo(_ footage: NvsTemplateFootageDesc, infos: [NvTemplateTimelineClipInfo], groupInfo: inout NvTemplateGroupInfo, target: inout [NvTemplateEditItem], assets: [NvAlbumTemplateItem]) {
        if footage.type == NvsTemplateFootageTypeAudio || footage.footageId == "footageEmpty" {
            return
        }
        if footage.tags.contains(where: { $0 == "paddingTag" }) {
            return
        }
        
        var isGrouped: Bool = false
        var groupId: Int = -1
        ///检查编组信息
        ///Check the marshalling information
        if footage.correspondingClipInfos.count > 1 || groupInfo.footages.contains(footage.footageId) {
            isGrouped = true
            if groupInfo.info.keys.contains(footage.footageId), let id = groupInfo.info[footage.footageId] as? Int {
                groupId = id
            }else {
                groupInfo.groupId += 1
                ///序列嵌套，检查到编组信息，修改相同footageid的编组信息
                ///Sequence nesting, check marshalling information, modify marshalling information with the same footageid
                target.filter { $0.footageId == footage.footageId && $0.isGrouped == false }.forEach {
                    $0.isGrouped = true
                    $0.groupId = groupInfo.groupId
                }
                groupInfo.info[footage.footageId] = groupInfo.groupId
                groupId = groupInfo.groupId
            }
        }
        
        if !groupInfo.footages.contains(footage.footageId) {
            groupInfo.footages.append(footage.footageId)
        }
  
        ///添加footage信息
        ///Add footage
        footage.correspondingClipInfos.forEach { clipInfo in
            var timelineClipinfos: [NvTemplateTimelineClipInfo] = []
            infos.forEach { timelineClipinfos.append($0.copyItem()) }
            ///配置分镜编辑信息
            ///Configure the mirror editing information
            let item = NvTemplateEditItem.init()
            item.isSelected = false
            item.footageId = footage.footageId
            item.isGrouped = isGrouped
            item.groupId = groupId
            item.isCaption = false
            item.clipInPoint = clipInfo.inPoint
            item.isCanReplace = footage.canReplace
            item.trackIndex = UInt32(clipInfo.trackIndex)
            item.clipIndex = UInt32(clipInfo.clipIndex)
            item.clipType = footage.type.rawValue
            item.duration = clipInfo.trimOut - clipInfo.trimIn
            item.bestDuration = clipInfo.trimOut
            let result = queryInternalTimeline(timelineClipinfos)
            if item.trackIndex >= 0, item.clipIndex >= 0, let videoTrack = result.timeline.getVideoTrack(by: UInt32(item.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(item.clipIndex)) {
                if let attachTime = videoClip.getTemplateAttachment(NVS_TEMPLATE_ASSET_KEY_BEST_SEEK_TIME) as? String {
                    let seekTime = Int64(Double(attachTime) ?? 0)
                    if seekTime < 0 {
                        item.bestSeekTime = result.offset + videoClip.inPoint
                    }else {
                        item.bestSeekTime = seekTime
                    }
                }else {
                    item.bestSeekTime = result.offset + videoClip.inPoint
                }
            }
            if item.bestSeekTime > timeline.duration {
                item.bestSeekTime = timeline.duration
            }
            timelineClipinfos.append(NvTemplateTimelineClipInfo.init(trackIndex: clipInfo.trackIndex, clipIndex: clipInfo.clipIndex, inPoint: item.bestSeekTime, isEmptyDesc: true))
            item.timelineNestInfos = timelineClipinfos
            /// 获取缩略图
            /// Get thumbnail
            if footage.canReplace && !clipInfo.needReverse {
                if let source = replaceAssets.first(where: { $0.trackIndex == clipInfo.trackIndex && $0.clipIndex == clipInfo.clipIndex && $0.footageId == footage.footageId }) {
                    item.asset = source.asset
                }
            }else {
                if let videoTrack = timeline.getVideoTrack(by: UInt32(clipInfo.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(clipInfo.clipIndex)) {
                    let grabImage = streamingContext.grabImage(from: timeline, timestamp: videoClip.inPoint, proxyScale: nil)
                    if let grabbedImg = grabImage {
                        item.coverImage = grabbedImg
                    }
                    
                }
            }
            
            target.append(item)
        }
    }
    
    private func getTemplateFootageFromArray(_ templateFootages: [NvsTemplateFootageDesc], templateClips: inout [NvTemplateEditItem]) {
    
        for index in 0..<templateFootages.count {
            let desc = templateFootages[index]
            if desc.type == NvsTemplateFootageTypeAudio || desc.footageId == "footageEmpty" {
                continue
            }
            if desc.timelineClipFootages.count > 0 {
                getTemplateFootageFromArray(desc.timelineClipFootages, templateClips: &templateClips)
            }else{
                for clipInfo in desc.correspondingClipInfos{
                    let item = NvTemplateEditItem.init()
                    item.isSelected = false
                    item.duration = clipInfo.outPoint - clipInfo.inPoint
                    item.isCanReplace = desc.canReplace
                    item.isCaption = false
                    item.trackIndex = UInt32(clipInfo.trackIndex)
                    item.clipIndex  = UInt32(clipInfo.clipIndex)
                    item.clipInPoint = clipInfo.inPoint
                    item.clipType = desc.type.rawValue
                    item.footageId = desc.footageId
                    /// 获取缩略图
                    /// Get thumbnail
                    if desc.canReplace && !clipInfo.needReverse {
                        if let source = replaceAssets.first(where: { $0.trackIndex == clipInfo.trackIndex && $0.clipIndex == clipInfo.clipIndex && $0.footageId == desc.footageId }) {
                            item.asset = source.asset
                        }
                    }else {
                        if let videoTrack = timeline.getVideoTrack(by: UInt32(clipInfo.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(clipInfo.clipIndex)) {

                            let grabImage = streamingContext.grabImage(from: timeline, timestamp: videoClip.inPoint, proxyScale: nil)
                            if let grabbedImg = grabImage {
                                item.coverImage = grabbedImg
                            }
                        }
                    }
                    templateClips.append(item)
                }
            }

        }
    }
    
    private func getTemplateFromArray(templateClips: inout [NvTemplateEditItem]) {
        let videoTrack = self.timeline.getVideoTrack(by: 0)
        
        for i in 0..<videoTrack!.clipCount {
            let clip = videoTrack!.getClipWith(i)
            var asset:NvAlbumTemplateItem? = nil
            let item = NvTemplateEditItem.init()
            for tempItem in self.replaceAssets {
                if tempItem.asset?.localIdentifier == clip?.filePath {
                    asset = tempItem
                    item.asset = asset!.asset
                }
            }
            
            item.isSelected = false
            item.duration = clip!.trimOut - clip!.trimIn
            item.isCanReplace = true
            item.trackIndex = 0
            item.clipIndex  = clip!.index
            item.clipInPoint = clip!.inPoint
            item.clipType = UInt32(0)
            if item.asset == nil {
                item.isCanReplace = false
                let grabImage = streamingContext.grabImage(from: timeline, timestamp: clip!.inPoint, proxyScale: nil)
                if let grabbedImg = grabImage {
                    item.coverImage = grabbedImg
                }
            }
            templateClips.append(item)
        }
    }
    
    private func nv_setupUI() {
        view.addSubview(liveWindow)
        view.addSubview(playBtn)
        view.addSubview(timeLabel)
        view.addSubview(slider)
        view.addSubview(totalTimeLabel)
        
        let bottomH = 190 * SCREENSCALE + SafeAreaBottomHeight + 22 * SCREENSCALE
        let naviH = NV_NAV_BAR_HEIGHT + NV_STATUSBARHEIGHT
        let maxH = SCREENWIDTH * CGFloat(timeline.videoRes.imageHeight) / CGFloat(timeline.videoRes.imageWidth)
        if maxH < SCREENHEIGHT - naviH - bottomH {
            liveWindow.frame = CGRect.init(x: 0, y: (SCREENHEIGHT - naviH - bottomH - maxH) * 0.5, width: SCREENWIDTH, height: maxH)
        }else {
            let maxW = (SCREENHEIGHT - naviH - bottomH) * CGFloat(timeline.videoRes.imageWidth) / CGFloat(timeline.videoRes.imageHeight)
            liveWindow.frame = CGRect.init(x: (SCREENWIDTH - maxW) * 0.5, y: 0, width: maxW, height: SCREENHEIGHT - naviH - bottomH)
        }

        clipListView = NvTemplateListView.init(frame: CGRect.init(x: 0, y: SCREENHEIGHT - 190 * SCREENSCALE - SafeAreaBottomHeight - naviH, width: SCREENWIDTH, height: 190 * SCREENSCALE + SafeAreaBottomHeight), clips: videoTemplates, captions: textTemplates)
        
        view.addSubview(clipListView)
        
        playBtn.frame = CGRect(x: 20 * SCREENSCALE, y: clipListView.frame.minY - 20 * SCREENSCALE, width: 20 * SCREENSCALE, height: 20 * SCREENSCALE)
        playBtn.setImage(NvUtils.imageWithName("template_play"), for: .normal)
        playBtn.setImage(NvUtils.imageWithName("template_pause"), for: .selected)
        playBtn.addTarget(self, action: #selector(playClick(sender:)), for: .touchUpInside)
        
        timeLabel.frame = CGRect(x: playBtn.frame.maxX + 2 * SCREENSCALE, y: playBtn.frame.minY, width: 40 * SCREENSCALE, height: 20 * SCREENSCALE)
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .right
        timeLabel.textColor = .white
        timeLabel.font = NvUtils.fontWithSize(size: 9 * SCREENSCALE)
        
        slider.frame = CGRect(x: 90 * SCREENSCALE, y: timeLabel.frame.minY, width: SCREENWIDTH - 160 * SCREENSCALE, height: 20 * SCREENSCALE)
        slider.minimumValue = 0
        slider.maximumValue = Float(timeline.duration)
        slider.maximumTrackTintColor = UIColor.init(hex: "#4B4B4B")
        slider.minimumTrackTintColor = UIColor(white: 1, alpha: 1)
        slider.setThumbImage(NvUtils.imageWithName("mosaic_slider"), for: .normal)
        slider.setThumbImage(NvUtils.imageWithName("mosaic_slider"), for: .highlighted)
        slider.addTarget(self, action: #selector(valueChanged(value:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderValueEnd(value:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderValueEnd(value:)), for: .touchUpOutside)
        
        totalTimeLabel.frame = CGRect(x: SCREENWIDTH - 55 * SCREENSCALE, y: slider.frame.minY , width: 50 * SCREENSCALE, height: 20 * SCREENSCALE)
        totalTimeLabel.text = NvUtils.convertTimecode(time: timeline?.duration ?? 0)
        totalTimeLabel.textColor = .white
        totalTimeLabel.textAlignment = .left
        totalTimeLabel.font = NvUtils.fontWithSize(size: 9 * SCREENSCALE)
    }
    private func nv_setupNavigationBar() {
        self.title = NvLocalProvider.String(key: "Edit", comment: "编辑")
        self.leftItem.setImage(NvUtils.imageWithName( "template_edit_close"), for: .normal)
        self.leftItem.setImage(NvUtils.imageWithName( "template_edit_close"), for: .highlighted)
        let exportView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 44))
        exportView.backgroundColor = .black
        let export = UIButton(frame: CGRect(x: 0, y: 10, width: 50, height: 24))
        if self.isPackagingTemplate {
            export.setTitle(NvLocalProvider.String(key: "Confirm", comment: "确认"), for: .normal)
        }else{
            export.setTitle(NvLocalProvider.String(key: "Compile", comment: "导出"), for: .normal)
        }
        export.titleLabel?.font = NvUtils.fontWithSize(size: 11)
        export.titleLabel?.textColor = .white
        export.backgroundColor = UIColor.init(hex: "#FC2B55")
        export.isExclusiveTouch = true
        export.layer.cornerRadius = 12
        export.layer.masksToBounds = true
        exportView.addSubview(export)
        export.addTarget(self, action: #selector(exportClick), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem.init(customView: exportView)
        if #available(iOS 26.0, *) {
            rightBarButtonItem.hidesSharedBackground = true
        }
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}

extension NvTemplateEditViewController: NvTemplateAlbumSelectServiceDelegate {
    func nvTemplateAlbumSelectService(service: NvTemplateAlbumSelectService, toast: NSString) {
        NvToast.showToastAction(message: toast)
    }
    
    func nvTemplateAlbumSelectService(service: NvTemplateAlbumSelectService, controller: NvAlbumViewController, selectTemplates templates: Array<NvAlbumTemplateItem>, supportedRatio: Int) {
        nvAlbumViewController(controller: controller, selectTemplates: templates, supportedRatio: supportedRatio)
    }
}
