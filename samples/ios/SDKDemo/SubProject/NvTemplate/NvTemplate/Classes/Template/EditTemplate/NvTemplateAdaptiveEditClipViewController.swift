//
//  NvTemplateAdaptiveEditClipViewController.swift
//  MYVideo
//
//  Created by meicam on 2020/11/6.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore

protocol NvTemplateAdaptiveEditClipViewControllerDelegate: class {
    func templateTailorDidEnded(trimIn: Int64, trimOut: Int64, isChnaged: Bool)
}

protocol NvCoverAdaptiveViewDelegate: class {
    func tailorLeftDidEnded(offset: CGFloat, isChnaged: Bool)
    func tailorRifhtDidEnded(offset: CGFloat, isChnaged: Bool)
}

class NvCoverAdaptiveView: UIView {
    let leftView = UIView()
    let rightView = UIView()
    var leftMin : CGFloat = 0
    var rightMax : CGFloat = 0
    var widthMin : CGFloat = 0
    var oriFrame : CGRect = CGRect.zero
    weak var delegate: NvCoverAdaptiveViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        leftView.frame = CGRect(x: 0, y: 0, width: 10, height: frame.height)
        leftView.backgroundColor = UIColor.white
        leftView.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(handleLeftPan(recognizer:))))
        addSubview(leftView)
        
        rightView.frame = CGRect(x: frame.width - 10, y: 0, width: 10, height: frame.height)
        rightView.backgroundColor = UIColor.white
        rightView.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(handleRightPan(recognizer:))))
        addSubview(rightView)
        
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 1
        self.layer.masksToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleLeftPan(recognizer:UIPanGestureRecognizer) -> Void{
        switch recognizer.state {
        case .began:
            oriFrame = self.frame
            break
        case .changed:
            var translation = recognizer.translation(in: self)
            var offset = translation.x+oriFrame.origin.x
            var currentWidth = oriFrame.width-translation.x
            if offset <= self.leftMin  {
                offset = self.leftMin
                currentWidth = oriFrame.width+oriFrame.origin.x-offset
                print("超出")
            }else if (currentWidth <= self.widthMin){
                currentWidth = self.widthMin
                offset = oriFrame.width - currentWidth+oriFrame.origin.x
                print("宽度太小了")
            }
            self.frame = CGRect.init(x: offset, y: self.frame.origin.y, width: currentWidth, height: self.frame.height)
            self.rightView.center.x = currentWidth-self.rightView.frame.size.width/2.0
            delegate?.tailorLeftDidEnded(offset: offset - self.leftMin, isChnaged: true)
            break
        case .ended:
            delegate?.tailorLeftDidEnded(offset: self.frame.origin.x - self.leftMin, isChnaged: false)
            break
        default:
            break
        }
    }
    
    @objc func handleRightPan(recognizer : UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            oriFrame = self.frame
            break
        case .changed:
            var translation = recognizer.translation(in: self)
            var currentWidth = oriFrame.width+translation.x
            var offset = currentWidth+oriFrame.origin.x

            if offset >= self.rightMax {
                currentWidth = self.rightMax - oriFrame.origin.x
                print("超出")
            }else if (currentWidth <= self.widthMin){
                currentWidth = self.widthMin
                print("宽度太小了")
            }
            self.frame = CGRect.init(x: oriFrame.origin.x, y: self.frame.origin.y, width: currentWidth, height: self.frame.height)
            self.rightView.center.x = currentWidth-self.rightView.frame.size.width/2.0
            delegate?.tailorRifhtDidEnded(offset: offset-self.leftMin, isChnaged: true)
            break
        case .ended:
            delegate?.tailorRifhtDidEnded(offset: self.frame.size.width-self.leftMin, isChnaged: false)
            break
        default:
            break
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.leftView.frame.contains(point) {
            return leftView
        }
        if self.rightView.frame.contains(point) {
            return rightView
        }
        if self.bounds.contains(point) {
            return nil
        } else {
            return super.hitTest(point, with: event)
        }
    }
}

class NvTemplateAdaptiveEditClipViewController: UIViewController {
    
    weak var delegate: NvTemplateAdaptiveEditClipViewControllerDelegate?
    
    init(for assetId: String, trimIn: Int64, trimOut: Int64, resolution: NvsVideoResolution, offset: Int64) {
        super.init(nibName: nil, bundle: nil)
        self.sourceId = assetId
        self.clipTrimIn = trimIn
        self.clipTrimOut = trimOut
        self.editRes = resolution
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
    public var isChange: Bool = false
    public var scaleForSeek: Float = 0.0
    private var pointsPerMicrosecond: CGFloat = 0
    
    private var coverView: NvCoverAdaptiveView!
    private let line = UIView()
    private let timeLabel = UILabel.init()
    private let timeClipLabel = UILabel.init()
    private let playButton = UIButton.init()
    private var sureButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
        /// 初始化UI
        /// Initialize the UI
        self.nv_setupUI()
        /// 初始化SDK
        /// Initialize SDK
        self.nv_configSdk()
    }
}

extension NvTemplateAdaptiveEditClipViewController {
    
    @objc func tapLiveWindow() {
        if !self.playButton.isHidden {
            return
        }
        self.playButton.isHidden = false
        streamingContext.stop()
    }
    @objc func playClick(sender: UIButton) {
        sender.isHidden = true
        streamingContext.playbackTimeline(timeline, startTime: streamingContext.getTimelineCurrentPosition(timeline), endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        
    }
    
    @objc func backClick() {
        navigationController?.popViewController(animated: true)
    }
    @objc func sureClick() {
        delegate?.templateTailorDidEnded(trimIn: self.clipTrimIn, trimOut: self.clipTrimOut, isChnaged: true)
        navigationController?.popViewController(animated: true)
    }
    
    func seek(pos: Int64) {
        var flags = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue)
        if (self.isChange) {
            flags = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_AllowFastScrubbing.rawValue)
            self.scaleForSeek = Float(CGFloat(timeline.duration)/1000000.0/self.sequenceView.contentSize.width/UIScreen.main.scale)
            streamingContext.setTimeline(timeline, scaleForSeek: Double(self.scaleForSeek))
        }
        
        streamingContext.seekTimeline(timeline, timestamp:pos, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags:flags)
    }
}

extension NvTemplateAdaptiveEditClipViewController: NvsStreamingContextDelegate, UIScrollViewDelegate {
    func didPlaybackTimelinePosition(_ timeline: NvsTimeline!, position: Int64) {
        let offectX = CGFloat(position)*sequenceView.pointsPerMicrosecond
        timeLabel.text = NvUtils.timeToString((position), afterPoint: 1) + "s"
        sequenceView.setContentOffset(CGPoint.init(x: offectX, y: 0), animated: false)
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
            self.streamingContext.playbackTimeline(timeline, startTime: self.clipTrimIn, endTime: self.clipTrimOut, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        sureButton.isEnabled = false
        self.streamingContext.stop()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.isChange = true
        if self.streamingContext.getStreamingEngineState() != NvsStreamingEngineState_Playback {
            self.seek(pos: Int64( scrollView.contentOffset.x/sequenceView.pointsPerMicrosecond))
            timeLabel.text = NvUtils.timeToString((Int64( scrollView.contentOffset.x/sequenceView.pointsPerMicrosecond)), afterPoint: 1) + "s"
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isChange = false
        let stop:Bool = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if stop {
            sureButton.isEnabled = true
            self.streamingContext.playbackTimeline(timeline, startTime: streamingContext.getTimelineCurrentPosition(timeline), endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isChange = false
        let stop:Bool = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if stop {
            sureButton.isEnabled = true
            self.streamingContext.playbackTimeline(timeline, startTime: streamingContext.getTimelineCurrentPosition(timeline), endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
}

extension NvTemplateAdaptiveEditClipViewController: NvCoverAdaptiveViewDelegate {
    func tailorLeftDidEnded(offset: CGFloat, isChnaged: Bool) {
        if isChnaged {
            self.isChange = true
            self.seek(pos: Int64(offset/sequenceView.pointsPerMicrosecond))
            self.clipTrimIn = streamingContext.getTimelineCurrentPosition(timeline)
            timeClipLabel.text = NvLocalProvider.String(key: "Clip Duration", comment: "片段时长")+"："+NvUtils.timeToString((clipTrimOut-clipTrimIn), afterPoint: 1) + "s"
            timeClipLabel.sizeToFit()
            timeClipLabel.center = CGPoint(x: SCREENWIDTH / 2, y: sureButton.center.y)
        }else{
            self.isChange = false
            self.seek(pos: Int64(offset/sequenceView.pointsPerMicrosecond))
            self.streamingContext.playbackTimeline(timeline, startTime: self.clipTrimIn, endTime: self.clipTrimOut, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
    
    func tailorRifhtDidEnded(offset: CGFloat, isChnaged: Bool) {
        if isChnaged {
            self.isChange = true
            self.seek(pos: Int64(offset/sequenceView.pointsPerMicrosecond))
            self.clipTrimOut = streamingContext.getTimelineCurrentPosition(timeline)
            if self.clipTrimOut-clipTrimIn < 2*100000{
                self.clipTrimOut = clipTrimIn+2*100000
            }
            timeClipLabel.text = NvLocalProvider.String(key: "Clip Duration", comment: "片段时长")+"："+NvUtils.timeToString((clipTrimOut-clipTrimIn), afterPoint: 1) + "s"
            timeClipLabel.sizeToFit()
            timeClipLabel.center = CGPoint(x: SCREENWIDTH / 2, y: sureButton.center.y)
        }else{
            self.isChange = false
            self.seek(pos: Int64(offset/sequenceView.pointsPerMicrosecond))
            self.streamingContext.playbackTimeline(timeline, startTime:self.clipTrimIn, endTime: self.clipTrimOut, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        }
    }
}

extension NvTemplateAdaptiveEditClipViewController {
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
        streamingContext.seekTimeline(cTimeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue))
        
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
                let pos = CGFloat(self.clipTrimIn)*sequenceView.pointsPerMicrosecond
                sequenceView.contentOffset = CGPoint.init(x: pos, y: 0)
            }
        }
        coverView.leftMin = sequenceView.startPadding;
        coverView.rightMax = sequenceView.startPadding+CGFloat(self.timeline.duration)*pointsPerMicrosecond
        coverView.widthMin = CGFloat(NV_TIME_BASE)*pointsPerMicrosecond
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
        pointsPerMicrosecond = 30.0/CGFloat(NV_TIME_BASE)
        
        sequenceView.thumbnailImageFillMode = NvsThumbnailFillModeAspectCrop
        sequenceView.thumbnailAspectRatio = 0.5
        sequenceView.pointsPerMicrosecond = Double(pointsPerMicrosecond)
        sequenceView.startPadding = SCREENWIDTH/2.0
        sequenceView.endPadding = sequenceView.startPadding
        sequenceView.bounces = false
        sequenceView.delegate = self
        
        let coverViewWidth = Double(clipTrimOut - clipTrimIn)*sequenceView.pointsPerMicrosecond
        let coverViewX = Double(self.clipTrimIn)*sequenceView.pointsPerMicrosecond+sequenceView.startPadding
        coverView = NvCoverAdaptiveView.init(frame: CGRect.init(x: coverViewX, y: 0, width: coverViewWidth, height: 59 * SCREENSCALE))
        coverView.delegate = self
        sequenceView.addSubview(coverView)
        
        timeLabel.frame = CGRect(x: 10, y: sequenceView.frame.maxY + 11 * SCREENSCALE, width: SCREENWIDTH - 20, height: 19 * SCREENSCALE)
        timeLabel.center = CGPoint(x: SCREENWIDTH / 2, y: timeLabel.center.y)
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont(name: "PingFang SC", size: 15)
        timeLabel.textColor = .white
        timeLabel.text = NvUtils.timeToString((clipTrimIn), afterPoint: 1) + "s"
        
        playButton.setImage(NvUtils.imageWithName( "template_edit_play"), for: .normal)
        playButton.setImage(NvUtils.imageWithName( "template_edit_play"), for: .highlighted)
        playButton.addTarget(self, action: #selector(playClick(sender:)), for: .touchUpInside)
        playButton.isHidden = false
        
        sureButton = UIButton(frame: CGRect(x: SCREENWIDTH - 61 * SCREENSCALE, y: sequenceView.frame.maxY + 50 * SCREENSCALE, width: 50 * SCREENSCALE, height: 23 * SCREENSCALE))
        sureButton.layer.cornerRadius = 23 * SCREENSCALE * 0.5
        sureButton.layer.masksToBounds = true
        sureButton.setBackgroundColor(UIColor(hex: "#FF365E")!, forState: .normal)
        sureButton.setTitle("确认", for: .normal)
        sureButton.addTarget(self, action: #selector(sureClick), for: .touchUpInside)
        sureButton.titleLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        
        let backButton = UIButton(frame: CGRect(x: 19 * SCREENSCALE, y: sureButton.frame.minY, width: 40, height: 23 * SCREENSCALE))
        backButton.contentHorizontalAlignment = .left
        backButton.setImage(NvUtils.imageWithName( "template_edit_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        
        timeClipLabel.frame = CGRect(x: 10, y: sequenceView.frame.maxY + 11 * SCREENSCALE, width: SCREENWIDTH - 20, height: 19 * SCREENSCALE)
        timeClipLabel.textAlignment = .center
        timeClipLabel.font = UIFont(name: "PingFang SC", size: 15)
        timeClipLabel.textColor = .white
        timeClipLabel.text = NvLocalProvider.String(key: "Clip Duration", comment: "片段时长")+"："+NvUtils.timeToString((clipTrimOut-clipTrimIn), afterPoint: 1) + "s"
        timeClipLabel.sizeToFit()
        timeClipLabel.center = CGPoint(x: SCREENWIDTH / 2, y: sureButton.center.y)
        
        view.addSubview(backButton)
        view.addSubview(sureButton)
        view.addSubview(timeClipLabel)
        
        line.frame = CGRect(x:SCREENWIDTH/2.0 - 1 , y: sequenceView.frame.minY-5, width: 2, height: 59 * SCREENSCALE + 10)
        line.backgroundColor = .white
        line.layer.cornerRadius = 1
        line.layer.masksToBounds = true
        view.addSubview(line)
    }
}
