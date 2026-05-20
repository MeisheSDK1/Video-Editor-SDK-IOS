//
//  NvTemplatePreviewViewController.swift
//  MYVideo
//
//  Created by meicam on 2020/11/3.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import Photos
import AFNetworking
import NvStreamingSdkCore
import NvSDKCommon
import NvAlbum
import SnapKit

class NvInfoView: UIView {
    let userLabel = UILabel()
    let titleLabel = UILabel()
    let infoLabel = NvLabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(userLabel)
        addSubview(titleLabel)
        addSubview(infoLabel)
        
        userLabel.text = "@user"
        userLabel.textColor = .white
        userLabel.font = NvUtils.fontWithSize(size: 15 * SCREENSCALE)
        userLabel.numberOfLines = 2
        userLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(0)
            make.height.greaterThanOrEqualTo(28 * SCREENSCALE)
        }
        
        titleLabel.text = ""
        titleLabel.numberOfLines = 0
        titleLabel.font = NvUtils.fontWithSize(size: 12 * SCREENSCALE)
        titleLabel.textColor = .white
        
        infoLabel.text = ""
        infoLabel.textColor = .white
        infoLabel.insets = UIEdgeInsets(top: 5, left:  5, bottom: 5, right: 5)
        infoLabel.font = NvUtils.fontWithSize(size: 9 * SCREENSCALE)
        infoLabel.backgroundColor = UIColor.init(hex: "#4B4B4B", alpha: 0.5)
        infoLabel.layer.cornerRadius = 13 * SCREENSCALE * 0.5
        infoLabel.layer.masksToBounds = true
        infoLabel.numberOfLines = 2
        infoLabel.isHidden = true
        infoLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        infoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.bottom.equalTo(0)
            make.height.greaterThanOrEqualTo(13 * SCREENSCALE).priorityHigh()
            make.right.lessThanOrEqualTo(self.snp.right).offset(-100 * SCREENSCALE)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(userLabel.snp.bottom)
            make.bottom.lessThanOrEqualTo(infoLabel.snp.top)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(info:NvTemplateInfo) {
        var sec:Int = Int(info.duration / 1000)
        let min:Int = sec / 60
        sec = sec - min * 60
        
        let duration = String.init(format: "%02d:%02d", min, sec)
        let num = getNumber(info.useNum)
        var text = ""
        if info.isCompiled {
            
            text = NvLocalProvider.String(key: "Duration", comment: "时长")+"：\(duration)"+NvLocalProvider.String(key: "Clip", comment: "片段")+"\(info.canReplaceShotsNumber != 0 ? info.canReplaceShotsNumber : info.shotsNumber)"
        }else {
            text = NvLocalProvider.String(key: "Duration", comment: "时长")+"：\(duration) "+NvLocalProvider.String(key: "Usage amount", comment: "使用量")+"：\(num) "+NvLocalProvider.String(key: "Clip", comment: "片段")+"：\(info.canReplaceShotsNumber != 0 ? info.canReplaceShotsNumber : info.shotsNumber)"
        }
        if info.category_Id == "2" {
            text = NvLocalProvider.String(key: "Duration: Auto Usage amount：", comment: "时长：自适时长 使用量：")+"\(num) "+NvLocalProvider.String(key: "Clip： unlimited", comment: "片段： 不限数量")
        }
        infoLabel.text = text
        infoLabel.isHidden = text.isEmpty
    }
    private func getNumber(_ num: Int) -> String {
        if num > 10000 {
            let numStr = NvUtils.numberToString(num, den: 10000, afterPoint: 1)
            return "\(numStr) 万"
        }else {
            return "\(num)"
        }
    }
    private func textWidth(for string: String) -> CGFloat {
        let text = string as NSString
        let rect = text.boundingRect(with: CGSize.init(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: NvUtils.fontWithSize(size: 9 * SCREENSCALE)], context: nil)
        return rect.size.width
    }
}

class NvPlayInfo {
    var payerUrl: String?
}

class NvTemplatePreviewViewController: NvTemplateBaseViewController {
    let albumSelectService = NvTemplateAlbumSelectService()
    var templateRatio: Int32 = 0
    var localTemplateInfo: NvTemplateInfo?
    var isComeInToAlbum:Bool = false
    init(for tid: String, compiled: Bool) {
        super.init(nibName: nil, bundle: nil)
        templateId = tid
        isCompiled = compiled
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        albumSelectService.delegate = self
        /// 初始化UI
        /// Initialize the UI
        nv_setupUI()
        if isCompiled {
            /// 导出本地的
            /// Exported local
            guard let localTemplate = localTemplateInfo else { return }
            
            let packageUrlStr = localTemplate.packageUrl
            if packageUrlStr.contains(self.templateId),
               let packageURL = URL(string: packageUrlStr) {
                
                templatePath = "\(TEMPLATE_URL)/\(self.templateId)/\(packageURL.lastPathComponent)"
            }else{
                
                templatePath = "\(TEMPLATE_URL)/\(self.templateId)/\(self.templateId)" + (localTemplate.version > 0 ? ".\(localTemplate.version)" : "") + ".template"
            }
            templateLicPath = "\(TEMPLATE_URL)/\(self.templateId)/\(self.templateId).lic"
            self.templateInfo = localTemplate
            self.infoView.userLabel.text = "@\(localTemplate.producer.nickname)"
            self.infoView.titleLabel.text = localTemplate.description
            /// 开始安装
            /// Start installation
            self.isDownloaded = true
            /// 开始播放
            /// Start playing
            if let videoUrl = nv_convertURL(urlPath: localTemplate.previewVideoUrl) {
                if self.avplayer != nil {
                    self.avplayer?.urlPath = videoUrl
                }else {
                    self.avplayer = NvPlayer.init(urlPath: videoUrl)
                }
                self.nv_playTemplate()
            }
        }else {
            /// 后台获取的
            /// Background acquired
            guard let localTemplate = localTemplateInfo else { return }
            self.templateInfo = localTemplate
            let user = localTemplate.producer.nickname.count > 0 ? localTemplate.producer.nickname : NvLocalStringFromTableInBundle(key: "Created by Meishe", tableName: "NvTemplate", bundle: Bundle(for: self.classForCoder), comment: "Meishe原创")
            self.infoView.userLabel.text = "@\(user)"
            self.infoView.titleLabel.text = localTemplate.description
            /// 开始播放并监听网络
            /// Start playing and listening to the network
            self.nv_preparePlayer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.avplayer?.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.networkmanager != nil {
            self.networkmanager.stopMonitoring()
            self.networkmanager = nil
        }
        avplayer?.pause()
    }
    
    public func endOfplay() {
        avplayer?.pause()
        avplayer?.urlPath = nil
    }

    override func popEvent() {
        avplayer?.pause()
        avplayer?.urlPath = nil
        self.navigationController?.popViewController(animated: true)
    }
    /// 是否是导出的模版
    /// Whether the template is exported
    private var isCompiled: Bool = false
    /// 网络请求的id
    /// id of the network request
    private var templateId: String = ""
    private var templatePath: String = ""
    private var templateLicPath: String = ""
    private var networkmanager: AFNetworkReachabilityManager!
    let player = NvSamePlayerView()
    private lazy var coverImageView: UIImageView = {
        let view = UIImageView.init()
        view.contentMode = .scaleAspectFit
        return view
    }()
    var playInfo: NvPlayInfo?
    var avplayer: NvPlayer?
    let enterButton = UIButton(type: .custom)
    let infoView = NvInfoView()
    private var isDownloaded: Bool = false {
        didSet {
            installTemplate()
        }
    }
    private var installState: NvsAssetPackageManagerError = NvsAssetPackageManagerError_NotInstalled
    private var packageId: String!
    private var templateInfo: NvTemplateInfo?
    private var footages: [(id: String, type: UInt32, isGrouped: Bool, groupId: Int, clipInfo: NvsTemplateFootageCorrespondingClipInfo)] = []
}

extension NvTemplatePreviewViewController : NvAlbumViewControllerDelegate
{
    
    
    /// handle the event of cutting the same item
    ///
    /// - Remark: 剪同款事件
    ///
    @objc
    private func didTouchEditEvent() {
        /// 点击剪同款
        /// Click to cut the same style
        if self.isDownloaded == false {
            NvToast.showToastAction(message: NvLocalProvider.String(key: "Template Downloading", comment: "模版下载中") as NSString)
            return
        }
        if installState == NvsAssetPackageManagerError_NoError || installState == NvsAssetPackageManagerError_AlreadyInstalled  {
            /// 已经安装成功
            /// The installation is successful.
            var clipInfos: [NvAlbumTemplateItem] = []
            var hasGrouped: Bool = false
            /// 解决排序
            /// Resolution sort
            var tempInfos: [(trackIndex: Int32,clipIndex: Int32,inPoint: Int64, clipInfo: (isGrouped: Bool,groupId: Int, needReverse: Bool,type: UInt32,duration: Int64,footageId: String))] = []
            for index in 0..<footages.count {
                let footage = footages[index]
                let type = footage.type
                let clipInfo = footage.clipInfo
                if footage.isGrouped {
                    hasGrouped = true
                }
                tempInfos.append((clipInfo.trackIndex, clipInfo.clipIndex, clipInfo.inPoint, (footage.isGrouped, footage.groupId, clipInfo.needReverse, type, clipInfo.trimOut - clipInfo.trimIn, footage.id)))
            }
            
            let array = tempInfos.sorted { (clip1, clip2) -> Bool in
                if clip1.inPoint == clip2.inPoint {
                    /// 判断入点
                    /// Judging entry point
                    return clip1.trackIndex < clip2.trackIndex
                }else {
                    return clip1.inPoint < clip2.inPoint
                }
            }
            for index in 0..<array.count {
                let templateFootage = array[index]
                let item = NvAlbumTemplateItem.init()
                item.asset = nil
                item.trackIndex = templateFootage.trackIndex
                item.clipIndex = templateFootage.clipIndex
                item.groupId = templateFootage.clipInfo.groupId
                item.isGrouped = templateFootage.clipInfo.isGrouped
                item.needReverse = templateFootage.clipInfo.needReverse
                item.type = templateFootage.clipInfo.type
                item.duration = templateFootage.clipInfo.duration
                item.footageId = templateFootage.clipInfo.footageId
                clipInfos.append(item)
            }
            
            if templateInfo?.category_Id == "1" {
                if self.footages.count > 0 {
                    let albumVC = NvAlbumViewController.init()
                    albumSelectService.categoryTemplate = Int(self.templateInfo?.category_Id ?? "1") ?? 1
                    
                    albumVC.delegate = self
//                    albumSelectService.bottomLineWidth = 20
                    albumSelectService.templateClips = clipInfos
                    albumSelectService.templateSupportRations = templateInfo?.getSupportedAspectRatios() ?? []
                    albumSelectService.templateDefaultRation = templateInfo?.getAspectRatioStr(for: self.templateRatio) ?? ""
                    albumSelectService.templateGrouped = hasGrouped
                    
                    albumVC.hiddenSelectAll = true
                    albumVC.mutableSelect = true
                    albumVC.selectStrategy = albumSelectService
                    albumVC.alwaysShowCustomBottom = true
                    let navi = UINavigationController.init(rootViewController: albumVC)
                    navi.modalPresentationStyle = .fullScreen
                    avplayer?.pause()
                    self.isComeInToAlbum = true
                    self.present(navi, animated: true, completion: nil)
                }else {
                    /// 没有可替换的素材，直接进入编辑页面
                    /// With no alternate material, go straight to the edit page
                    if let context = NvsStreamingContext.sharedInstance() {
                        if let cTimeline = context.createTimeline(packageId, templateFootages: nil) {
                            guard cTimeline.duration > 0 else {
                                NvToast.showToastAction(message: "timeline create failed." as NSString)
                                return
                            }
                            let vc = NvTemplateEditViewController.init(withTemplate: self.templateId, pid: self.packageId, cTimeline: cTimeline)
                            vc.templateInfo = self.templateInfo
                            vc.categoryTemplate = Int(self.templateInfo?.category_Id ?? "1") ?? 1
                            vc.isPackagingTemplate = self.isPackagingTemplate
                            self.navigationController?.pushViewController(vc, animated: false)
                        }
                    }
                }
            }else if(templateInfo?.category_Id == "2"){
                let context = NvsStreamingContext.sharedInstance()
                var tempString:String = Bundle.main.bundlePath+"/templateFont/沐瑶软笔手写体(Muyao-Softbrush).ttf"
                context?.registerFont(byFilePath: tempString)
                
                tempString = Bundle.main.bundlePath+"/templateFont/点点像素体-方形.ttf"
                context?.registerFont(byFilePath: tempString)
                let albumVC = NvAlbumViewController.init()
                albumSelectService.categoryTemplate = Int(self.templateInfo?.category_Id ?? "1") ?? 1
                albumVC.maxSelectCount = 100
                albumVC.delegate = self
                albumSelectService.templateClips = clipInfos
                albumSelectService.templateSupportRations = templateInfo?.getSupportedAspectRatios() ?? []
                albumSelectService.templateDefaultRation = templateInfo?.getAspectRatioStr(for: self.templateRatio) ?? ""
                albumSelectService.templateGrouped = hasGrouped
                albumVC.selectStrategy = albumSelectService
                albumVC.alwaysShowCustomBottom = true
                albumVC.hiddenSelectAll = true
                albumVC.mutableSelect = true
                let navi = UINavigationController.init(rootViewController: albumVC)
                navi.modalPresentationStyle = .fullScreen
                avplayer?.pause()
                self.isComeInToAlbum = true
                self.present(navi, animated: true, completion: nil)
            }else{
                if self.footages.count > 0 {
                    
                    let albumVC = NvAlbumViewController.init()
                    albumSelectService.categoryTemplate = Int(self.templateInfo?.category_Id ?? "1") ?? 1
                    albumVC.delegate = self
                    albumSelectService.templateClips = clipInfos
                    albumSelectService.templateSupportRations = templateInfo?.getSupportedAspectRatios() ?? []
                    albumSelectService.templateDefaultRation = templateInfo?.getAspectRatioStr(for: self.templateRatio) ?? ""
                    albumSelectService.templateGrouped = hasGrouped
                    albumVC.selectStrategy = albumSelectService
                    albumVC.alwaysShowCustomBottom = true
                    albumVC.hiddenSelectAll = true
                    albumVC.mutableSelect = true
                    let navi = UINavigationController.init(rootViewController: albumVC)
                    navi.modalPresentationStyle = .fullScreen
                    avplayer?.pause()
                    self.isComeInToAlbum = true
                    self.present(navi, animated: true, completion: nil)
                }else {
                    /// 没有可替换的素材，直接进入编辑页面
                    /// With no alternate material, go straight to the edit page
                    if let context = NvsStreamingContext.sharedInstance() {
                        if let cTimeline = context.createTimeline(packageId, templateFootages: nil) {
                            guard cTimeline.duration > 0 else {
                                NvToast.showToastAction(message: "timeline create failed." as NSString)
                                return
                            }
                            let vc = NvTemplateEditViewController.init(withTemplate: self.templateId, pid: self.packageId, cTimeline: cTimeline)
                            vc.templateInfo = self.templateInfo
                            vc.categoryTemplate = Int(self.templateInfo?.category_Id ?? "1") ?? 1
                            vc.isPackagingTemplate = self.isPackagingTemplate
                            self.navigationController?.pushViewController(vc, animated: false)
                        }
                    }
                }
            }
            
        }else if installState == NvsAssetPackageManagerError_WorkingInProgress {
            NvToast.showToastAction(message: NvLocalProvider.String(key: "Material installing", comment: "素材安装中") as NSString)
            return
        }else {
            NvToast.showToastAction(message: NvLocalProvider.String(key: "Material installation failed", comment: "素材安装失败") as NSString)
            return
        }
    }
    
    /// Handle the event of cutting the same item
    ///
    /// - Remark: 选择相册回调
    ///
    /// - Parameters:
    ///   - controller: album VC
    ///   - templates: selected resources
    ///
    func nvAlbumViewController(controller : NvAlbumViewController, selectTemplates templates: Array<NvAlbumTemplateItem>, supportedRatio: Int) {
        if templates.count == 0 {
            self.dismiss(animated: false, completion: { })
            self.avplayer?.play()
            return
        }
        
        if supportedRatio != 0 {
            self.templateRatio = Int32(supportedRatio)
            if let assetPackageManager = NvsStreamingContext.sharedInstance()?.assetPackageManager {
                assetPackageManager.changeTemplateAspectRatio(packageId, aspectRatio: self.templateRatio)
                templateInfo?.defaultAspectRatio = assetPackageManager.getTemplateCurrentAspectRatio(packageId)
            }
        }
        
        if templateInfo?.category_Id == "1" {
            ///标准模板
            ///Standard template
            ///处理倒放
            ///Processing inversion
            if FileManager.default.fileExists(atPath: TEMPLATE_Reverse_URL) {
                try? FileManager.default.createDirectory(atPath: TEMPLATE_Reverse_URL, withIntermediateDirectories: true, attributes: nil)
            }
            let convertAssets = templates.filter { (item) -> Bool in
                if item.isImage { return false }
                if item.needReverse {
                    /// 视频倒放
                    /// Video play backwards
                    let subArray = item.asset!.localIdentifier.split(separator: "/")
                    let fileName = subArray.joined(separator: "")
                    let filePath = TEMPLATE_Reverse_URL + "/upend_" + fileName + ".mp4"
                    if FileManager.default.fileExists(atPath: filePath) {
                        item.isReversed = true
                        item.reversePath = filePath
                    }else {
                        item.isReversed = false
                    }
                    return !item.isReversed
                }else {
                    return false
                }
            }
            if convertAssets.count > 0 {
                NvConvertorAlert.nv_fadeIn(for: convertAssets, size: CGSize.init(width: 160, height: 160), completeHandle: { (isSuccess) in
                    if isSuccess {
                        self.nv_createTemplateTimeline(templates: templates, controller: controller)
                    }else {
                        NvToast.showToastAction(message: NvLocalProvider.String(key: "Upend error", comment: "倒放失败") as NSString)
                        self.dismiss(animated: false, completion: { })
                        self.avplayer?.play()
                        return
                    }
                })
            }else {
                self.nv_createTemplateTimeline(templates: templates, controller: controller)
            }
        }else if(templateInfo?.category_Id == "2"){
            ///自适时长模板
            ///Self-timed long template
            self.nv_createApplyTemplateTimeline(templates: templates, templateRecommendedRatio: supportedRatio)
        }else{
            ///AE模板
            ///AE template
            ///处理倒放
            ///Processing inversion
            if FileManager.default.fileExists(atPath: TEMPLATE_Reverse_URL) {
                try? FileManager.default.createDirectory(atPath: TEMPLATE_Reverse_URL, withIntermediateDirectories: true, attributes: nil)
            }
            let convertAssets = templates.filter { (item) -> Bool in
                if item.isImage { return false }
                if item.needReverse {
                    /// 视频倒放
                    /// Video play backwards
                    let subArray = item.asset!.localIdentifier.split(separator: "/")
                    let fileName = subArray.joined(separator: "")
                    let filePath = TEMPLATE_Reverse_URL + "/upend_" + fileName + ".mp4"
                    if FileManager.default.fileExists(atPath: filePath) {
                        item.isReversed = true
                        item.reversePath = filePath
                    }else {
                        item.isReversed = false
                    }
                    return !item.isReversed
                }else {
                    return false
                }
            }
            if convertAssets.count > 0 {
                NvConvertorAlert.nv_fadeIn(for: convertAssets, size: CGSize.init(width: 160, height: 160), completeHandle: { (isSuccess) in
                    if isSuccess {
                        self.nv_createAETemplateTimeline(templates: templates)
                    }else {
                        NvToast.showToastAction(message: NvLocalProvider.String(key: "Upend error", comment: "倒放失败") as NSString)
                        self.dismiss(animated: false, completion: { })
                        self.avplayer?.play()
                        return
                    }
                })
            }else {
                self.nv_createAETemplateTimeline(templates: templates)
            }
        }
    }
    private func nv_createTemplateTimeline(templates: [NvAlbumTemplateItem], controller : NvAlbumViewController) {
        if let context = NvsStreamingContext.sharedInstance() {
            var tempFootages: [NvsTemplateFootageInfo] = []
            for index in 0..<self.footages.count {
                let footage = footages[index]
                if let source = templates.first(where: { $0.trackIndex == footage.clipInfo.trackIndex && $0.clipIndex == footage.clipInfo.clipIndex && $0.footageId == footage.id }) {
                    let info = NvsTemplateFootageInfo.init()
                    info.footageId = footage.id
                    if footage.clipInfo.needReverse && !source.isImage {
                        info.reverseFilePath = source.reversePath
                        info.filePath = ""
                    }else {
                        info.filePath = source.asset?.localIdentifier
                        info.reverseFilePath = ""
                    }
                    tempFootages.append(info)
                }
            }
            if let cTimeline = context.createTimeline(packageId, templateFootages: tempFootages) {
                /// 如果出现编组，clip选择不同的素材，需要替换路径
                /// If marshalling appears, clip selects a different material and needs to replace the path
                templates.forEach { (item) in
                    if item.isGrouped {
                        if let videoTrack = cTimeline.getVideoTrack(by: UInt32(item.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(item.clipIndex)) {
                            var filePath = ""
                            if item.needReverse && !item.isImage {
                                filePath = item.reversePath
                            }else {
                                filePath = item.asset?.localIdentifier ?? ""
                            }
                            videoClip.changeFilePath(filePath)
                        }
                    }
                }
                let vc = NvTemplateEditViewController.init(withTemplate: self.templateId, pid: self.packageId, cTimeline: cTimeline)
                var assets: [NvAlbumTemplateItem] = []
                templates.forEach { assets.append( $0.copy() as! NvAlbumTemplateItem) }
                vc.replaceAssets = assets
                vc.templateInfo = self.templateInfo
                vc.isPackagingTemplate = self.isPackagingTemplate
                self.navigationController?.pushViewController(vc, animated: true)
                self.dismiss(animated: true, completion: nil)
            }else {
                /// 创建timeline失败
                /// Failed to create timeline
                self.dismiss(animated: false, completion: { })
                self.avplayer?.play()
                return
            }
        }
    }
    
    private func nv_createApplyTemplateTimeline(templates: [NvAlbumTemplateItem], templateRecommendedRatio: Int) {
        if let context = NvsStreamingContext.sharedInstance() {
            let size = NvUtils.calculateTimelineSize(aspectRatio: templateRecommendedRatio)
            print("=============\(size)=====\(templateRecommendedRatio)")
            var videoRes: NvsVideoResolution = NvsVideoResolution.init(imageWidth: UInt32(size.width), imageHeight: UInt32(size.height), imagePAR: NvsRational.init(num: 1, den: 1), bitDepth: NvsVideoResolutionBitDepth_8Bit)
            var videoFps: NvsRational = NvsRational.init(num: 25, den: 1)
            var audioEditRes: NvsAudioResolution = NvsAudioResolution.init()
            audioEditRes.sampleRate = 48000;
            audioEditRes.channelCount = 2;
            audioEditRes.sampleFormat = NvsAudSmpFmt_S16
            if let cTimeline = context.createTimeline(&videoRes, videoFps: &videoFps, audioEditRes: &audioEditRes, flags: 0){
                cTimeline.appendVideoTrack()
                cTimeline.appendAudioTrack()
                let videoTrack = cTimeline.getVideoTrack(by: 0)
                
                for item in templates {
                    let clip = videoTrack?.appendClip(item.asset?.localIdentifier)
                    clip?.setVolumeGain(0, rightVolumeGain: 0)
                    item.clipIndex = Int32(clip!.index)
                    item.trackIndex = 0
                }
                
                let successful = cTimeline.applyThemeTemplate(packageId)
                
                /*
                 自适应模版里会有片头和片尾，应用模版之后，原先记录的片段clipIndex会发生改变，这里需要根据片段index重新更新一下数据里的clipIndex
                 
                 There will be the beginning and end of the title in the adaptive template. After applying the template, the clipIndex of the original recorded segment will be changed. Here, the clipIndex in the data needs to be updated according to the segment index
                 */
                var clip = videoTrack!.getClipWith(0)
                var tempItem = templates.first
                var clipTitle:Bool = false
                var clipTrailer:Bool = false
                
                if tempItem!.asset!.localIdentifier != clip!.filePath {
                    clipTitle = true
                }
                
                clip = videoTrack!.getClipWith(videoTrack!.clipCount-1)
                tempItem = templates.last
                if tempItem!.asset!.localIdentifier != clip!.filePath {
                    clipTrailer = true
                }
                
                var index:Int = 0
                
                for i in 0..<videoTrack!.clipCount {
                    if clipTitle && i == 0 {
                        
                    }else if clipTrailer && i == (videoTrack!.clipCount - 1) {
                        
                    }else{
                        let clip = videoTrack!.getClipWith(i)
                        let item = templates[index]
                        item.clipIndex = Int32(clip!.index)
                        index += 1
                    }
                }
                
                if successful {
                    print("=============应用成功")
                    self.dismiss(animated: false, completion: {
                        let vc = NvTemplateEditViewController.init(withTemplate: self.templateId, pid: self.packageId, cTimeline: cTimeline)
                        var assets: [NvAlbumTemplateItem] = []
                        templates.forEach { assets.append( $0.copy() as! NvAlbumTemplateItem) }
                        vc.replaceAssets = assets
                        vc.categoryTemplate = Int(self.templateInfo?.category_Id ?? "1") ?? 1
                        vc.templateInfo = self.templateInfo
                        vc.isPackagingTemplate = self.isPackagingTemplate
                        self.navigationController?.pushViewController(vc, animated: false)
                    })
                }else{
                    NvToast.showToastAction(message: NvLocalProvider.String(key: "Application failed", comment: "应用失败") as NSString)
                    self.dismiss(animated: false, completion: { })
                    self.avplayer?.play()
                }
            }else{
                self.dismiss(animated: false, completion: { })
                self.avplayer?.play()
                return
            }
        }
    }
    
    private func nv_createAETemplateTimeline(templates: [NvAlbumTemplateItem]) {
        if let context = NvsStreamingContext.sharedInstance() {
            var tempFootages: [NvsTemplateFootageInfo] = []
            var timelineClipInfos: [NvTemplateTimelineClipInfo] = []
            for index in 0..<self.footages.count {
                let footage = footages[index]
                if let source = templates.first(where: { $0.trackIndex == footage.clipInfo.trackIndex && $0.clipIndex == footage.clipInfo.clipIndex && $0.footageId == footage.id }) {
                    let info = NvsTemplateFootageInfo.init()
                    info.footageId = footage.id
                    if footage.clipInfo.needReverse && !source.isImage {
                        info.reverseFilePath = source.reversePath
                        info.filePath = ""
                    }else {
                        info.filePath = source.asset?.localIdentifier
                        info.reverseFilePath = ""
                    }
                    tempFootages.append(info)
                }
            }
            
            if let cTimeline = context.createTimeline(packageId, templateFootages: tempFootages) {
                /// 如果出现编组，clip选择不同的素材，需要替换路径
                /// If marshalling appears, clip selects a different material and needs to replace the path
                templates.forEach { (item) in
                    if item.isGrouped {
                        if let videoTrack = cTimeline.getVideoTrack(by: UInt32(item.trackIndex)), let videoClip = videoTrack.getClipWith(UInt32(item.clipIndex)) {
                            var filePath = ""
                            if item.needReverse && !item.isImage {
                                filePath = item.reversePath
                            }else {
                                filePath = item.asset?.localIdentifier ?? ""
                            }
                            videoClip.changeFilePath(filePath)
                        }
                    }
                }
                
                self.dismiss(animated: false, completion: {
                    let vc = NvTemplateEditViewController.init(withTemplate: self.templateId, pid: self.packageId, cTimeline: cTimeline)
                    var assets: [NvAlbumTemplateItem] = []
                    templates.forEach { assets.append( $0.copy() as! NvAlbumTemplateItem) }
                    vc.replaceAssets = assets
                    vc.categoryTemplate = Int(self.templateInfo?.category_Id ?? "1") ?? 1
                    vc.templateInfo = self.templateInfo
                    vc.isPackagingTemplate = self.isPackagingTemplate
                    self.navigationController?.pushViewController(vc, animated: false)
                })
            }else {
                /// 创建timeline失败
                /// Failed to create timeline
                self.dismiss(animated: false, completion: { })
                self.avplayer?.play()
                return
            }
        }
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

extension NvTemplatePreviewViewController: NvsAssetPackageManagerDelegate {
    
    /// Register template, get template information
    ///
    /// - Remark: 注册模版，获取模版信息
    ///
    private func installTemplate() {
        if let context = NvsStreamingContext.sharedInstance() {
            context.assetPackageManager.delegate = self
        
            let originVersion = context.assetPackageManager.getAssetPackageVersion(templateId, type: NvsAssetPackageType_Template)
            let targetVersion = context.assetPackageManager.getAssetPackageVersion(fromAssetPackageFilePath: templatePath)
            
            if targetVersion > originVersion {
                context.assetPackageManager.uninstallAssetPackage(templateId, type: NvsAssetPackageType_Template)
            }
            
            let pid = NSMutableString.init()
            installState = context.assetPackageManager.installAssetPackage(templatePath, license: templateLicPath, type: NvsAssetPackageType_Template, sync: false, assetPackageId: pid)
            if installState == NvsAssetPackageManagerError_NoError || installState == NvsAssetPackageManagerError_AlreadyInstalled {
                packageId = pid as String
                if let assetPackageManager = NvsStreamingContext.sharedInstance()?.assetPackageManager {
                    assetPackageManager.changeTemplateAspectRatio(packageId, aspectRatio: self.templateInfo!.defaultAspectRatio)
                    templateInfo?.supportedAspectRatio = assetPackageManager.getAssetPackageSupportedAspectRatio(packageId, type: NvsAssetPackageType_Template)
                    templateInfo?.defaultAspectRatio = assetPackageManager.getTemplateCurrentAspectRatio(packageId)
                }
                /// 获取模版信息
                /// Obtain template information
                if let context = NvsStreamingContext.sharedInstance(),let templateFootages = context.assetPackageManager.getTemplateFootages(packageId) {
                    self.footages.removeAll()
                    /// 编组id
                    /// Marshalling id
                    var groupId: Int = 0
                    getTemplateFootageFromArray(templateFootages, groupId: &groupId)
                    self.templateInfo!.canReplaceShotsNumber = self.footages.count
                    /// 获取模板时长
                    /// Template acquisition duration
                    if let url = nv_convertURL(urlPath: self.templateInfo!.previewVideoUrl) {
                        let urlAsset = AVURLAsset.init(url: url)
                        let duration = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
                        self.templateInfo?.duration = Int64(duration * 1000)
                    }
                    self.infoView.configData(info: self.templateInfo!)
                }
            }
        }
    }
    
    
    /// Asynchronous registration template callback
    ///
    /// - Remark: 异步注册模版回调
    ///
    /// - Parameters:
    ///   - assetPackageId: PackageId
    ///   - assetPackageFilePath: Resource path
    ///   - assetPackageType: Package type
    ///   - error: Return error
    ///
    func didFinishAssetPackageInstallation(_ assetPackageId: String!, filePath assetPackageFilePath: String!, type assetPackageType: NvsAssetPackageType, error: NvsAssetPackageManagerError) {
        installState = error
        packageId = assetPackageId
        if error == NvsAssetPackageManagerError_NoError || error == NvsAssetPackageManagerError_AlreadyInstalled {
            if let assetPackageManager = NvsStreamingContext.sharedInstance()?.assetPackageManager {
                assetPackageManager.changeTemplateAspectRatio(packageId, aspectRatio: self.templateInfo!.defaultAspectRatio)
                templateInfo?.supportedAspectRatio = assetPackageManager.getAssetPackageSupportedAspectRatio(packageId, type: NvsAssetPackageType_Template)
                templateInfo?.defaultAspectRatio = assetPackageManager.getTemplateCurrentAspectRatio(packageId)
            }
            /// 获取模版信息
            /// Obtain template information
            if let context = NvsStreamingContext.sharedInstance(),let templateFootages = context.assetPackageManager.getTemplateFootages(packageId) {
                self.footages.removeAll()
                /// 编组id
                /// Marshalling id
                var groupId: Int = 0
                getTemplateFootageFromArray(templateFootages, groupId: &groupId)
                self.templateInfo!.canReplaceShotsNumber = self.footages.count
                self.infoView.configData(info: self.templateInfo!)
            }
        }
    }
    
    func getTemplateFootageFromArray(_ templateFootages: [NvsTemplateFootageDesc], groupId: inout Int) {
        for index in 0..<templateFootages.count {
            let footage = templateFootages[index]
            if footage.type == NvsTemplateFootageTypeAudio || footage.canReplace == false || footage.footageId == "footageEmpty" {
                continue
            }
            if footage.timelineClipFootages.count > 0 {
                getTemplateFootageFromArray(footage.timelineClipFootages, groupId:&groupId)
            }else {
                var isGrouped: Bool = false
                if footage.correspondingClipInfos.count > 1 {
                    isGrouped = true
                }
                for clipInfo in footage.correspondingClipInfos {
                    self.footages.append((footage.footageId, footage.type.rawValue, isGrouped, groupId, clipInfo))
                }
                if isGrouped { groupId += 1 }
            }
        }
    }
}

extension NvTemplatePreviewViewController: NvPlayerDelegate {
    func player(player: NvPlayer?, currentTimeValue value: Double) { }
    func playerEOF(player: NvPlayer?) {
        player?.seek(time: 0.0)
        player?.play()
    }
    
}

extension NvTemplatePreviewViewController: NvTemplateAlbumSelectServiceDelegate {
    func nvTemplateAlbumSelectService(service: NvTemplateAlbumSelectService, toast: NSString) {
        NvToast.showToastAction(message: toast)
    }
    
    func nvTemplateAlbumSelectService(service: NvTemplateAlbumSelectService, controller: NvAlbumViewController, selectTemplates templates: Array<NvAlbumTemplateItem>, supportedRatio: Int) {
        nvAlbumViewController(controller: controller, selectTemplates: templates, supportedRatio: supportedRatio)
    }
}

extension NvTemplatePreviewViewController {
    
    /// Gets whether the template is cached
    ///
    /// - Remark: 获取模版是否缓存
    ///
    private func nv_preparePlayer() {
        networkmanager = AFNetworkReachabilityManager.shared()
        networkmanager.startMonitoring()
        networkmanager.setReachabilityStatusChange { (state) in
            if state == .notReachable || state == .unknown {
                if self.isDownloaded == false {
                    NvToast.showToastAction(message: NvLocalProvider.String(key: "Please check your network", comment: "请检查网络环境") as NSString)
                    return
                }
                guard let info = self.templateInfo else { return }
                /// 缓存已下载
                /// Cache downloaded
                let version: String = info.version == 0 ? "" : ".\(info.version)"
                if let videoUrl = nv_convertURL(urlPath: TEMPLATE_URL + "/\(info.id)" + "/\(info.id)\(version).mp4") {
                    if self.avplayer != nil {
                        self.avplayer?.urlPath = videoUrl
                    }else {
                        self.avplayer = NvPlayer.init(urlPath: videoUrl)
                        let session = AVAudioSession.sharedInstance()
                        if #available(iOS 10.0, *) {
                            do {
                                try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [.defaultToSpeaker, .allowBluetooth,.allowBluetoothA2DP])
                            } catch let err{
                                print("设置类型失败:\(err.localizedDescription)")
                            }
                            
                        } else {
                            do {
                                try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
                            } catch let err{
                                print("设置类型失败:\(err.localizedDescription)")
                            }
                        }
                        
                    }
                }
                self.templatePath = TEMPLATE_URL + "/\(info.id)" + "/\(info.id)\(version).template"
                self.isDownloaded = true
                self.nv_playTemplate()
            }else {
                guard let info = self.templateInfo else { return }
                if self.fetchVideoDownloadState(url: info.previewVideoUrl, videoID: info.id) {
                    
                    if let videoUrl = nv_convertURL(urlPath: "\(TEMPLATE_URL)/\(info.id)/" + URL(string: info.previewVideoUrl)!.lastPathComponent) {
                        
                        if self.avplayer != nil {
                            self.avplayer?.urlPath = videoUrl
                        }else {
                            self.avplayer = NvPlayer.init(urlPath: videoUrl)
                        }
                    }
                }else{
                    if (info.previewVideoUrl.length == 0 && info.coverUrl.length > 0) {
                        if self.avplayer != nil {
                            self.avplayer?.urlPath = URL(string: info.coverUrl)
                        }else {
                            self.avplayer = NvPlayer.init(urlPath: URL(string: info.coverUrl)!)
                        }
                        self.coverImageView.nv_image(urlString: info.coverUrl)
                        self.coverImageView.isHidden = false
                    } else {
                        if let videoUrl = nv_convertURL(urlPath: info.previewVideoUrl) {
                            if self.avplayer != nil {
                                self.avplayer?.urlPath = videoUrl
                            }else {
                                self.avplayer = NvPlayer.init(urlPath: videoUrl)
                            }
                            /// 开始下载
                            /// Start downloading
                            DispatchQueue.global().async(execute: {
                                self.downloadVideoPre(url: info.previewVideoUrl, videoID: info.id, version: info.version)
                            })
                        }
                    }
                }
                /// 缓存已下载
                /// Cache downloaded
                if self.fetchTemplateDownloadState(rid: info.id, packageUrlStr: info.packageUrl) {
                    
                    self.isDownloaded = true
                }else {
                    /// 开始下载
                    /// Start downloading
                    DispatchQueue.global().async(execute: {
                        self.downloadZip(url: info.zipUrl,templateID: info.id)
                    })
                }
                self.nv_playTemplate()
            }
        }
    }
    
    private func nv_playTemplate() {
        guard avplayer != nil else { return }
        avplayer!.delegate = self
        player.setPlayer(player: avplayer!)
        avplayer!.play()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            weakSelf?.avplayer!.pause()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            if !self.isComeInToAlbum{
                weakSelf?.avplayer!.play()
            }
        }
    }
    
    
    /// Gets whether the template is cached
    ///
    /// - Remark: 获取模版是否缓存
    ///
    /// - Parameters:
    ///   - rid: PackageID
    ///   - packageUrlStr:packagePath
    /// - Returns: Cache or not
    private func fetchTemplateDownloadState(rid: String?, packageUrlStr: String) -> Bool {
        
        guard let templateID = rid, templateID.count > 0 else { return false }
        var templateFilePath = ""
        if packageUrlStr.count > 0,
            packageUrlStr.contains(templateID),
           let packageURL = URL(string: packageUrlStr) {
            
            templateFilePath = "\(TEMPLATE_URL)/\(self.templateId)/\(packageURL.lastPathComponent)"
        }else{
            
            let version = self.templateInfo?.version ?? 0
            templateFilePath = "\(TEMPLATE_URL)/\(templateID)/\(templateID)" + (version > 0 ? ".\(version)" : "") + ".template"
        }
        let licenseFilePath = "\(TEMPLATE_URL)/\(templateID)/\(templateID).lic"
        let fm = FileManager.default
        if fm.fileExists(atPath: templateFilePath) && fm.fileExists(atPath: licenseFilePath) {
            self.templatePath = templateFilePath
            self.templateLicPath = licenseFilePath
            return true
        } else {
            return false
        }
    }
    
    /// Gets whether the video is cached
    ///
    /// - Remark: 获取视频是否缓存
    ///
    /// - Parameters:
    ///   - rid: PackageID
    ///   - version: version
    /// - Returns: Cache or not
    private func fetchVideoDownloadState(url: String?,videoID:String) -> Bool {
        guard let videoUrl = url, videoUrl.count > 0 else { return false }
        let cachePath = "\(TEMPLATE_URL)/\(videoID)/" + URL(string: videoUrl)!.lastPathComponent
        let fm = FileManager.default
        if fm.fileExists(atPath: cachePath) {
            return true
        } else {
            return false
        }
    }
    
    /// Download zip to sandbox
    ///
    /// - Remark: 下载zip包并解压到沙盒
    ///
    /// - Parameters:
    ///   - url: Download url
    ///   - templateID:templateID
    ///   - templateVersion: version
    private func downloadZip(url: String,templateID:String) {
        /// 下载模版到沙盒中
        /// Download the template to the sandbox
        let templateDirPath = "\(TEMPLATE_URL)/\(templateID)"
        
        NvTemplateHttpRequest.sharedInstance.downloadTemplateZip(urlString: url, templateDirPath: templateDirPath) { progress in
            
        } success: { templateFilePath, licenseFilePath in
            
            self.templatePath = templateFilePath
            self.templateLicPath = licenseFilePath
            self.isDownloaded = true
            
        } failure: { Error in
            
        }
    }

    
    
    /// Download Preview video to sandbox
    ///
    /// - Remark: 下载预览视频到沙盒
    ///
    /// - Parameters:
    ///   - url: Download url
    ///   - uuid:PackageID
    ///   - version: version
    ///
    private func downloadVideoPre(url: String, videoID:String, version: Int) {
        ///开始下载
        ///Start downloading
        let temp: String = version == 0 ? "" : ".\(version)"
        let ori = TEMPLATE_URL + "/\(videoID)" + "/\(videoID)\(temp).mp4"
        let dest = TEMPLATE_URL + "/\(videoID)/" + URL.init(string: url)!.lastPathComponent
        NvTemplateHttpRequest.sharedInstance.downloadTemplate(urlString: url, destinationUrl: dest, originalUrl: ori, progressBlock: { (_) in
            
        }, success: { (destinationurl) in

        }, failure: { (_) in })
    }
    
    private func nv_setupUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(comeToPreview), name: NSNotification.Name(rawValue: "ComeToPreview"), object: nil)
        /// 模版信息
        /// Template information
        view.insertSubview(player, at: 0)
        coverImageView.isHidden = true
        view.addSubview(coverImageView)
        view.addSubview(infoView)
        view.addSubview(enterButton)
        let startY: CGFloat = NV_STATUSBARHEIGHT + NV_NAV_BAR_HEIGHT
        player.frame = CGRect.init(x: -1, y: 0, width: SCREENWIDTH + 1, height: SCREENHEIGHT - startY)
        coverImageView.frame = CGRect.init(x: -1, y: 0, width: SCREENWIDTH + 1, height: SCREENHEIGHT - startY)
        infoView.frame = CGRect.init(x: 16 * SCREENSCALE, y: SCREENHEIGHT - SafeAreaBottomHeight - 196 * SCREENSCALE - startY, width: SCREENWIDTH - 32 * SCREENSCALE, height: 120 * SCREENSCALE)
        enterButton.frame = CGRect.init(x: SCREENWIDTH - 97 * SCREENSCALE, y: infoView.frame.maxY - 32 * SCREENSCALE, width: 64 * SCREENSCALE, height: 64 * SCREENSCALE)
        enterButton.backgroundColor = UIColor.init(hex: "#FF365E")
        enterButton.setTitle(NvLocalProvider.String(key: "To use", comment: "去使用"), for: .normal)
        enterButton.titleLabel?.numberOfLines = 2;
        enterButton.titleLabel?.textAlignment = .center;
        enterButton.setTitleColor(UIColor.white, for: .normal)
        enterButton.titleLabel?.font = NvUtils.fontWithSize(size: 14 * SCREENSCALE)
        enterButton.layer.cornerRadius = 32 * SCREENSCALE
        enterButton.layer.masksToBounds = true
        enterButton.addTarget(self, action: #selector(didTouchEditEvent), for: .touchUpInside)
        
        
    }
    
    @objc func comeToPreview(){
//        avplayer?.play()
    }
}

