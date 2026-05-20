//
//  NvTemplateEditClipViewController.swift
//  MYVideo
//
//  Created by meicam on 2020/11/6.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore

protocol NvTemplateEditClipViewControllerDelegate: class {
    func templateTailorDidEnded(offset: Int64, isChnaged: Bool)
}

class NvCoverView: UIView {
    let line = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        line.frame = CGRect(x: -1, y: -5, width: 2, height: frame.height + 10)
        line.backgroundColor = .white
        line.layer.cornerRadius = 1
        line.layer.masksToBounds = true
        addSubview(line)
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 1
        self.layer.masksToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValue(value: CGFloat) {
        let x = frame.width * value
        line.center = CGPoint(x: x, y: line.center.y)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let lineRect = line.frame.insetBy(dx: -15, dy: 0)
        if lineRect.contains(point) {
            return line
        }
        if self.bounds.contains(point) {
            return nil
        } else {
            return super.hitTest(point, with: event)
        }
    }
}

class NvTemplateEditClipViewController: UIViewController {
    
    weak var delegate: NvTemplateEditClipViewControllerDelegate?
    
    init(for assetId: String, trimIn: Int64, trimOut: Int64, resolution: NvsVideoResolution, offset: Int64) {
        super.init(nibName: nil, bundle: nil)
        self.sourceId = assetId
        self.clipTrimIn = trimIn
        self.clipTrimOut = trimOut
        self.editRes = resolution
        self.currentOffset = offset
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private var sourceId: String = ""
    private var clipTrimIn: Int64 = 0
    private var clipTrimOut: Int64 = 0
    private var orgDuration: Int64 = 0
    private var videoClip: NvsVideoClip!
    private var editRes: NvsVideoResolution!
    private var originAspectRatio: CGFloat = -1.0
    
    private let liveWindow: NvsLiveWindow = NvsLiveWindow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    private var timeline: NvsTimeline!
    private let streamingContext: NvsStreamingContext = NvsStreamingContext.sharedInstance()!
    private let sequenceView = NvsMultiThumbnailSequenceView()!
    public var scaleForSeek: Float = 0.0
    private var pointsPerMicrosecond: CGFloat = 0
    
    private var coverView: NvCoverView!
    private let timeLabel = UILabel.init()
    private let playButton = UIButton.init()
    private var currentOffset: Int64 = 0
    private var sureButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarButtonItem = UIBarButtonItem.init(customView: UIView())
        if #available(iOS 26.0, *) {
            leftBarButtonItem.hidesSharedBackground = true
        }
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
  
        /// 初始化UI
        /// Initialize the UI
        self.nv_setupUI()
        /// 初始化SDK
        /// Initialize SDK
        self.nv_configSdk()
    }
}

extension NvTemplateEditClipViewController {
    
    @objc func tapLiveWindow() {
        if !self.playButton.isHidden {
            return
        }
        self.playButton.isHidden = false
        streamingContext.stop()
    }
    @objc func playClick(sender: UIButton) {
        sender.isHidden = true
        streamingContext.playbackTimeline(timeline, startTime: streamingContext.getTimelineCurrentPosition(timeline), endTime: self.currentOffset + clipTrimOut - clipTrimIn, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        
    }
    
    @objc func backClick() {
        delegate?.templateTailorDidEnded(offset: self.currentOffset, isChnaged: false)
        navigationController?.popViewController(animated: true)
    }
    @objc func sureClick() {
        delegate?.templateTailorDidEnded(offset: self.currentOffset, isChnaged: true)
        navigationController?.popViewController(animated: true)
    }
}

extension NvTemplateEditClipViewController: NvsStreamingContextDelegate, UIScrollViewDelegate {
    func didPlaybackTimelinePosition(_ timeline: NvsTimeline!, position: Int64) {
        /// 指示线位置
        /// Indicator position
        let value = CGFloat(position - self.currentOffset) / CGFloat(clipTrimOut - clipTrimIn)
        coverView.setValue(value: value)
    }
    
    func didStreamingEngineStateChanged(_ state: NvsStreamingEngineState) {
        if state == NvsStreamingEngineState_Playback {
            self.playButton.isHidden = true
        } else {
            self.playButton.isHidden = false
        }
    }
    
    func didPlaybackEOF(_ timeline: NvsTimeline!) {
        DispatchQueue.main.async {
            self.streamingContext.playbackTimeline(timeline, startTime: self.currentOffset, endTime: self.currentOffset + self.clipTrimOut - self.clipTrimIn, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
            
            self.coverView.setValue(value: 0)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        sureButton.isEnabled = false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.width == 0 {
            return
        }
        self.coverView.setValue(value: 0)
        let pos = (scrollView.contentOffset.x + 70) * CGFloat(self.orgDuration) / scrollView.contentSize.width
        self.currentOffset = Int64(pos)
        var flags = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_AllowFastScrubbing.rawValue)
        self.scaleForSeek = Float(CGFloat(timeline.duration)/1000000.0/self.sequenceView.contentSize.width/UIScreen.main.scale)
        streamingContext.setTimeline(timeline, scaleForSeek: Double(self.scaleForSeek))
        streamingContext.seekTimeline(timeline, timestamp: self.currentOffset, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: flags)
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let stop:Bool = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if stop {
            sureButton.isEnabled = true
            self.streamingContext.playbackTimeline(timeline, startTime: self.currentOffset, endTime: self.currentOffset + self.clipTrimOut - self.clipTrimIn, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let stop:Bool = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if stop {
            sureButton.isEnabled = true
            self.streamingContext.playbackTimeline(timeline, startTime: self.currentOffset, endTime: self.currentOffset + self.clipTrimOut - self.clipTrimIn, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
}


extension NvTemplateEditClipViewController {
    private func nv_getContentWidth() -> CGFloat {
        return CGFloat(self.orgDuration) * pointsPerMicrosecond + 140
    }
    private func nv_configSdk() {
        if originAspectRatio == -1 {
            /// 获取文件失败
            /// File acquisition failure
            return
        }
        /// 创建timeline
        /// Create timeline
        var videoRes: NvsVideoResolution = self.editRes
        var videoFps: NvsRational = NvsRational.init(num: 25, den: 1)
        var audioEditRes: NvsAudioResolution = NvsAudioResolution.init()
        audioEditRes.sampleRate = 48000;
        audioEditRes.channelCount = 2;
        audioEditRes.sampleFormat = NvsAudSmpFmt_S16
        let cTimeline = streamingContext.createTimeline(&videoRes, videoFps: &videoFps, audioEditRes: &audioEditRes, flags: 0)
        cTimeline?.appendVideoTrack()
        timeline = cTimeline
        
        /// 添加资源
        /// Add resources
        guard let videoTrack = cTimeline?.getVideoTrack(by: 0) else { return }
        videoTrack.removeAllClips()
        videoClip = videoTrack.appendClip(self.sourceId, trimIn: 0, trimOut: self.orgDuration)
        
        let bottomH = 190 * SCREENSCALE + SafeAreaBottomHeight
        let naviH = NV_NAV_BAR_HEIGHT + NV_STATUSBARHEIGHT
        let maxH = SCREENWIDTH * CGFloat(timeline.videoRes.imageHeight) / CGFloat(timeline.videoRes.imageWidth)
        if maxH < SCREENHEIGHT - naviH - bottomH {
            liveWindow.frame = CGRect.init(x: 0, y: (SCREENHEIGHT - naviH - bottomH - maxH) * 0.5, width: SCREENWIDTH, height: maxH)
        }else {
            let maxW = (SCREENHEIGHT - naviH - bottomH) * CGFloat(timeline.videoRes.imageWidth) / CGFloat(timeline.videoRes.imageHeight)
            liveWindow.frame = CGRect.init(x: (SCREENWIDTH - maxW) * 0.5, y: 0, width: maxW, height: (SCREENHEIGHT - naviH - bottomH))
        }
        self.playButton.frame = CGRect.init(x: (liveWindow.frame.size.width - 54 * SCREENSCALE) * 0.5, y: (liveWindow.frame.size.height - 54 * SCREENSCALE) * 0.5, width: 54 * SCREENSCALE, height: 54 * SCREENSCALE)
        /// 连接lineWindow
        /// Connection lineWindow
        streamingContext.delegate = self
        streamingContext.connect(cTimeline, with: liveWindow)
        streamingContext.seekTimeline(cTimeline, timestamp: self.currentOffset, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        
        let desc = NvsThumbnailSequenceDesc()
        desc.mediaFilePath = self.sourceId
        desc.trimIn = 0
        desc.trimOut = self.orgDuration
        desc.inPoint = 0
        desc.outPoint = self.orgDuration
        sequenceView.descArray = [desc]
        
        if let avfileInfo = self.streamingContext.getAVFileInfo(self.sourceId) {
            if avfileInfo.avFileType == NvsAVFileType_Image {
                
            }else{
                /// 设置偏移量
                /// Set offset
                let pos = CGFloat(self.currentOffset) * nv_getContentWidth() / CGFloat(self.orgDuration) - 70
                sequenceView.contentOffset = CGPoint.init(x: pos, y: 0)
            }
        }
        
    }
    
    private func getVideoResolution() -> NvsVideoResolutionBitDepth {
        var bitDepth = NvsVideoResolutionBitDepth_8Bit
        let number :NSNumber? = UserDefaults.standard.object(forKey: "NvResolutionConfiguration") as? NSNumber
        if (number?.intValue == 1) {
            bitDepth = NvsVideoResolutionBitDepth_8Bit
        }else if (number?.intValue == 2){
            bitDepth = NvsVideoResolutionBitDepth_16Bit_Float
        }else if(number?.intValue == 3){
            bitDepth = NvsVideoResolutionBitDepth_Auto
        }
        
        return bitDepth
    }
    
    private func nv_setupUI() {
        view.addSubview(liveWindow)
        liveWindow.addSubview(self.playButton)
        view.addSubview(sequenceView)
        view.addSubview(timeLabel)
        /// 添加手势
        /// Add gesture
        liveWindow.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapLiveWindow)))
        if let avfileInfo = self.streamingContext.getAVFileInfo(self.sourceId) {
            self.orgDuration = avfileInfo.duration == 0 ? (clipTrimOut - clipTrimIn) : avfileInfo.duration
            let size = avfileInfo.getVideoStreamDimension(0)
            if avfileInfo.getVideoStreamRotation(0) == NvsVideoRotation_90 || avfileInfo.getVideoStreamRotation(0) == NvsVideoRotation_270 {
                originAspectRatio = CGFloat(size.height) / CGFloat(size.width)
            } else {
                originAspectRatio = CGFloat(size.width) / CGFloat(size.height)
            }
        }else {
            return
        }
        let naviH = NV_NAV_BAR_HEIGHT + NV_STATUSBARHEIGHT
        sequenceView.frame = CGRect.init(x: 0, y: SCREENHEIGHT - naviH - 174 * SCREENSCALE - SafeAreaBottomHeight, width: SCREENWIDTH, height: 59 * SCREENSCALE)
        pointsPerMicrosecond = (SCREENWIDTH - 140)/(CGFloat(clipTrimOut - clipTrimIn)/CGFloat(NV_TIME_BASE))/CGFloat(NV_TIME_BASE)
        sequenceView.thumbnailImageFillMode = NvsThumbnailFillModeAspectCrop
        sequenceView.thumbnailAspectRatio = 0.5
        sequenceView.pointsPerMicrosecond = Double(pointsPerMicrosecond)
        sequenceView.startPadding = 70
        sequenceView.endPadding = sequenceView.startPadding
        sequenceView.bounces = false
        sequenceView.delegate = self
        coverView = NvCoverView.init(frame: CGRect.init(x: 70, y: sequenceView.frame.minY, width: SCREENWIDTH - 140, height: 59 * SCREENSCALE))
        view.addSubview(coverView)
        
        timeLabel.frame = CGRect(x: 10, y: sequenceView.frame.maxY + 11 * SCREENSCALE, width: SCREENWIDTH - 20, height: 19 * SCREENSCALE)
        timeLabel.center = CGPoint(x: SCREENWIDTH / 2, y: timeLabel.center.y)
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont(name: "PingFang SC", size: 15)
        timeLabel.textColor = .white
        timeLabel.text = NvUtils.timeToString((clipTrimOut - clipTrimIn), afterPoint: 1) + "s"
        
        playButton.setImage(NvUtils.imageWithName( "template_edit_play"), for: .normal)
        playButton.setImage(NvUtils.imageWithName( "template_edit_play"), for: .highlighted)
        playButton.addTarget(self, action: #selector(playClick(sender:)), for: .touchUpInside)
        playButton.isHidden = false
        
        sureButton = UIButton(frame: CGRect(x: SCREENWIDTH - 61 * SCREENSCALE, y: sequenceView.frame.maxY + 50 * SCREENSCALE, width: 50 * SCREENSCALE, height: 23 * SCREENSCALE))
        sureButton.layer.cornerRadius = 23 * SCREENSCALE * 0.5
        sureButton.layer.masksToBounds = true
        sureButton.setBackgroundColor(UIColor(hex: "#FF365E")!, forState: .normal)
        sureButton.setTitle(NvLocalProvider.String(key: "Confirm", comment: "确认"), for: .normal)
        sureButton.addTarget(self, action: #selector(sureClick), for: .touchUpInside)
        sureButton.titleLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        
        let backButton = UIButton(frame: CGRect(x: 19 * SCREENSCALE, y: sureButton.frame.minY, width: 40, height: 23 * SCREENSCALE))
        backButton.contentHorizontalAlignment = .left
        backButton.setImage(NvUtils.imageWithName( "template_edit_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        
        view.addSubview(backButton)
        view.addSubview(sureButton)
    }
}
