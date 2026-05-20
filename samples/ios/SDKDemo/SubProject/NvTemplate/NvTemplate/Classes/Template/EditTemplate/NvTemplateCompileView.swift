//
//  NvTemplateCompileView.swift
//  MYVideo
//
//  Created by chengww on 2020/11/6.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import NvStreamingSdkCore
import NvSDKCommon

protocol NvTemplateCompileViewDelegate : class {
    func templateCompileViewRemoved()
}

class NvTemplateCompileView: UIView {
    var auxiliaryContext:NvsStreamingContext?
    weak var delegate:NvTemplateCompileViewDelegate?
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        if auxiliaryContext != nil {
            auxiliaryContext = nil
        }
    }
    init() {
        super.init(frame:CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT))
        backgroundColor = UIColor.init(hex: "#000000", alpha: 0.5)
        nv_setupSheetView()
    }
    
    class func compileTimeline(cTimeline: NvsTimeline, tid: String, delegate: NvTemplateCompileViewDelegate, defaultAspectRatio:UInt32){
        ///MARK: ym --  打包事件统计
        ///MARK: ym -- Package event statistics
        let view = NvTemplateCompileView.init()
        view.templateId = tid
        view.timeline = cTimeline
        view.delegate = delegate
        view.defaultAspectRatio = defaultAspectRatio
        view.nv_fadeIn()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var templateId: String = ""
    private var isWillResignActive: Bool = false
    private var preset: Int32 = 720
    private var videoSize: CGSize = CGSize.init(width: 0, height: 0)
    private var timeline: NvsTimeline!
    private var outputFilePath: String = ""
    private var defaultAspectRatio: UInt32 = 1
    
    private let compileOptionContainerView = UIView.init()
    private let compileBackButton = UIButton.init(type: .custom)
    private let compileTitleLabel = UILabel.init()
    private var compilePresetView: NvTemplateCompileOptionView!
    private let compileFileLabel = UILabel.init()
    private let compileButton = UIButton.init(type: .custom)
    
    
    private lazy var compileCoverImageView: UIImageView = {
        let view = UIImageView.init()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFit
        return view
    }()
    private lazy var compileProgressView: NvTemplateCircleProgressView = {
        let view = NvTemplateCircleProgressView.init(frame: CGRect(x: 0, y: 0, width: 91 * SCREENSCALE, height: 91 * SCREENSCALE))
        view.updateProgress(value: 0)
        return view
    }()
    private lazy var compileProgressLabel: UILabel = {
        let view = UILabel.init()
        view.font = NvUtils.fontWithSize(size: 12.0 * SCREENSCALE)
        view.textColor = UIColor.white
        view.textAlignment = .center
        return view
    }()
    private lazy var compileInfoLabel: UILabel = {
        let view = UILabel.init()
        view.font = NvUtils.fontWithSize(size: 11 * SCREENSCALE)
        view.textColor = UIColor(white: 1, alpha: 0.8)
        view.textAlignment = .center
        return view
    }()
    private lazy var compileCancelButton: UIButton = {
        let view = UIButton.init()
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        view.setTitle(NvLocalProvider.String(key: "Cancel", comment: "取消"), for: .normal)
        view.titleLabel?.font = NvUtils.fontWithSize(size: 14.0 * SCREENSCALE)
        return view
    }()
    private lazy var compileFinishButton: UIButton = {
        let view = UIButton.init()
        view.backgroundColor = UIColor.init(hex: "#FC2B55")
        view.setTitle(NvLocalProvider.String(key: "Compile Success", comment: "完成"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = NvUtils.fontWithSize(size: 11.0 * SCREENSCALE)
        return view
    }()
    private lazy var compileCloseButton: UIButton = {
        let view = UIButton.init()
        view.setImage(NvUtils.imageWithName( "settings_close"), for: .normal)
        view.setImage(NvUtils.imageWithName( "settings_close"), for: .highlighted)
        return view
    }()
}

///MARK: - 事件处理
///MARK: - Event handling
extension NvTemplateCompileView: NvTemplateCompileOptionViewDelegate {
    func templateCompileOptionView(_ optionView: NvTemplateCompileOptionView, didSelectedAt optionValue: String) {
        let endIndex = optionValue.index(optionValue.startIndex, offsetBy: optionValue.count - 1)
        var strValue = String.init(optionValue[optionValue.startIndex..<endIndex])
        strValue = strValue != "4" ? strValue : "2160"
        preset = Int32.init(strValue) ?? 720
        nv_convertToVideoSize(preset: CGFloat(Float(preset)))
        let str = nv_compileFile(fps: timeline.videoFps.num, preset: preset, duration: Float(timeline.duration) / Float(NV_TIME_BASE))
        compileFileLabel.text = NvLocalProvider.String(key: "File size is approximately", comment: "文件大小约为") + str
    }
    /// 分辨率选择，点击返回
    /// Select the resolution and click back
    @objc func nv_didTapCompileBackEvent() {
        auxiliaryContext?.stop()
        delegate?.templateCompileViewRemoved()
        self.removeFromSuperview()
    }
    /// 分辨率选择，点击导出
    /// Select the resolution and click Export
    @objc func nv_didTapCompileEvent() {
        self.compileOptionContainerView.isHidden = true
        self.backgroundColor = UIColor.init(hex: "#000000", alpha: 1)
        self.nv_setupCompileView()
        self.compileProgressView.updateProgress(value: 0)
        self.compileProgressLabel.text = String(format: "%.f%", compileProgressView.percent * 100)
        self.nv_startCompile()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appliationWillBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /// 导出页面点击取消和关闭按钮
    /// Export page click Cancel and close button
    @objc func nv_didTapCompileCancelEvent(){
        auxiliaryContext?.stop()
        compileCloseButton.removeFromSuperview()
        compileCoverImageView.subviews.forEach { $0.removeFromSuperview() }
        compileCoverImageView.removeFromSuperview()
        compileInfoLabel.removeFromSuperview()
        compileCancelButton.removeFromSuperview()
        compileFinishButton.removeFromSuperview()
        compileOptionContainerView.isHidden = false
        backgroundColor = UIColor.init(hex: "#000000", alpha: 0.5)
    }
    /// 导出页面完成
    /// Export page complete
    @objc func nv_didTapCompileFinishEvent(){
        auxiliaryContext?.stop()
        delegate?.templateCompileViewRemoved()
        self.removeFromSuperview()
    }
        
    @objc func applicationWillResignActive(){
        self.isWillResignActive = true
        auxiliaryContext?.stop()
    }
    @objc func appliationWillBecomeActive() {
        if !self.compileProgressView.isHidden && self.compileProgressView.percent > 0 {
            self.compileProgressView.updateProgress(value: 0)
            self.isWillResignActive = false
            NvToast.showToastAction(message: NvLocalProvider.String(key: "Compile failed", comment: "导出失败") as NSString)
        }
    }
    private func nv_fadeIn() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        self.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    /*
     sdk的PackageAspectRatio，资源包支持的比例
     PackageAspectRatio of the sdk: Ratio of resource package support
     */
    private func nv_convertToVideoSize(preset: CGFloat) {
        let size = timeline.videoRes
        let ratio = NvsAssetPackageAspectRatio.init(rawValue: self.defaultAspectRatio)
        switch ratio {
            case NvsAssetPackageAspectRatio_16v9:
                videoSize.width = preset / 9.0 * 16.0
                videoSize.height = preset
            case NvsAssetPackageAspectRatio_1v1:
                videoSize.width = preset
                videoSize.height = preset
            case NvsAssetPackageAspectRatio_9v16:
                videoSize.width = preset
                videoSize.height = preset / 9.0 * 16.0
            case NvsAssetPackageAspectRatio_4v3:
                videoSize.width = preset / 3.0 * 4.0
                videoSize.height = preset
            case NvsAssetPackageAspectRatio_3v4:
                videoSize.width = preset
                videoSize.height = preset / 3.0 * 4.0
            case NvsAssetPackageAspectRatio_18v9:
                videoSize.width = preset / 9.0 * 18.0
                videoSize.height = preset
            case NvsAssetPackageAspectRatio_9v18:
                videoSize.width = preset
                videoSize.height = preset / 9.0 * 18.0
            default:
                if size.imageWidth > size.imageHeight {
                    videoSize.width = 1280
                    videoSize.height = 720
                }else {
                    videoSize.width = 720
                    videoSize.height = 1280
                }
            }
    }
    
    private func nv_compileFile(fps: Int32, preset: Int32, duration: Float) -> String {
        /// 6Mbps/
        let value = Float(fps * preset * 6) * duration / Float(720 * 25 * 8)
        if value > 1024 {
            return String(format: "%.01f G", value/1024.0)
        }
        return String(format: "%.01f M", value)
    }
}

//MARK: - NvsStreamingContextDelegate
extension NvTemplateCompileView: NvsStreamingContextDelegate {
    
    private func nv_startCompile(){
        auxiliaryContext = NvsStreamingContext.sharedInstance()
        if auxiliaryContext != nil {
            auxiliaryContext?.delegate = self
            let compileConfigurations: NSMutableDictionary = NSMutableDictionary.init()
            compileConfigurations[NVS_COMPILE_OPTIMIZE_FOR_NETWORK_USE] = NSNumber(true)
            var videoFps = NvsRational.init(num: timeline.videoFps.num, den: 1)
            compileConfigurations[NVS_COMPILE_VIDEO_FPS] = Data.init(bytes: &videoFps, count: MemoryLayout<NvsRational>.size)
            
            outputFilePath = self.projectPath() + String(format: "%.f", Date().timeIntervalSince1970) + ".mp4"
            auxiliaryContext?.setCustomCompileVideoHeight(UInt32(videoSize.height))
            auxiliaryContext?.compileConfigurations = compileConfigurations
            auxiliaryContext?.compileTimeline(timeline, startTime: 0, endTime: timeline.duration, outputFilePath: outputFilePath, videoResolutionGrade: NvsCompileVideoResolutionGradeCustom, videoBitrateGrade: NvsCompileBitrateGradeHigh, flags: Int32(NvsStreamingEngineCompileFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize.rawValue))
        }else{
            compileInfoLabel.text = NvLocalProvider.String(key: "Compile failed", comment: "导出失败")
            compileProgressView.isHidden = true
            compileProgressLabel.isHidden = true
            compileFinishButton.isHidden = true
            compileCancelButton.isHidden = false
        }
    }
    func didCompileProgress(_ timeline: NvsTimeline!, progress: Int32) {
        let value = CGFloat(progress) / 100
        compileProgressView.updateProgress(value: value)
        compileProgressLabel.text = String(format: "%.f%%", compileProgressView.percent * 100)
    }
    
    func didCompileCompleted(_ timeline: NvsTimeline!, isCanceled: Bool) {
        if !self.isWillResignActive {
            if isCanceled {
                compileInfoLabel.text = NvLocalProvider.String(key: "Compile failed", comment: "导出失败")
                compileProgressView.isHidden = true
                compileProgressLabel.isHidden = true
                compileFinishButton.isHidden = true
                compileCancelButton.isHidden = false
            }else {
                UISaveVideoAtPathToSavedPhotosAlbum(outputFilePath, self, #selector(video(videoPath:error:contextInfo:)), nil)
            }
        }
    }
    func didCompileFailed(_ timeline: NvsTimeline!) {
        if !self.isWillResignActive {
            compileInfoLabel.text = NvLocalProvider.String(key: "Compile failed", comment: "导出失败")
            compileProgressView.isHidden = true
            compileProgressLabel.isHidden = true
            compileFinishButton.isHidden = true
            compileCancelButton.isHidden = false
        }
    }
    
    @objc func video(videoPath : String, error: Error?, contextInfo: Any) {
        if error == nil {
            ///保存成功
            ///Save successfully
            compileInfoLabel.text = NvLocalProvider.String(key: "Saved to album", comment: "已保存到相册")
            try? FileManager.default.removeItem(atPath: videoPath)
            compileProgressView.isHidden = true
            compileProgressLabel.isHidden = true
            compileFinishButton.isHidden = false
            compileCancelButton.isHidden = true
        }
    }
    private func projectPath() -> String {
        let projectPath = NSHomeDirectory() + "/Documents/" + "Project"
        if FileManager.default.fileExists(atPath: projectPath) == false {
            do {
                try FileManager.default.createDirectory(atPath: projectPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
            }
        }
        return projectPath + "/"
    }
}

extension NvTemplateCompileView {
    private func nv_setupSheetView() {
        compileOptionContainerView.frame = CGRect.init(x: 0, y: SCREENHEIGHT - 294 * SCREENSCALE - SafeAreaBottomHeight, width: SCREENWIDTH, height: 294 * SCREENSCALE + SafeAreaBottomHeight)
        compileOptionContainerView.backgroundColor = UIColor.init(hex: "#101010")
        addSubview(compileOptionContainerView)
        compileBackButton.frame = CGRect.init(x: 0, y: 0, width: 49 * SCREENSCALE, height: 40 * SCREENSCALE)
        compileBackButton.setImage(NvUtils.imageWithName( "template_edit_back"), for: .normal)
        compileBackButton.setImage(NvUtils.imageWithName( "template_edit_back"), for: .highlighted)
        compileBackButton.addTarget(self, action: #selector(nv_didTapCompileBackEvent), for: .touchUpInside)
        compileOptionContainerView.addSubview(compileBackButton)
        compileTitleLabel.frame = CGRect.init(x: (compileOptionContainerView.frame.size.width - 100 * SCREENSCALE) * 0.5, y: 0, width: 100 * SCREENSCALE, height: 40 * SCREENSCALE)
        compileTitleLabel.text = NvLocalProvider.String(key: "Select Resolution", comment: "选择分辨率")
        compileTitleLabel.textColor = .white
        compileTitleLabel.textAlignment = .center
        compileTitleLabel.font = NvUtils.fontWithSize(size: 13 * SCREENSCALE)
        compileOptionContainerView.addSubview(compileTitleLabel)
        compilePresetView = NvTemplateCompileOptionView.init(frame: CGRect.init(x: 45 * SCREENSCALE, y: 65 * SCREENSCALE, width: compileOptionContainerView.frame.size.width - 90 * SCREENSCALE, height: 86 * SCREENSCALE))
        compilePresetView.delegate = self
        compileOptionContainerView.addSubview(compilePresetView)
        compileButton.frame = CGRect.init(x: 56 * SCREENSCALE, y: compileOptionContainerView.frame.size.height - SafeAreaBottomHeight - 82 * SCREENSCALE , width: compileOptionContainerView.frame.size.width - 112 * SCREENSCALE, height: 37 * SCREENSCALE)
        compileButton.backgroundColor = UIColor.init(hex: "#FC2B55")
        compileButton.setTitle(NvLocalProvider.String(key: "Confirm Compile", comment: "确认导出"), for: .normal)
        compileButton.setTitleColor(.white, for: .normal)
        compileButton.titleLabel?.font = NvUtils.fontWithSize(size: 11 * SCREENSCALE)
        compileOptionContainerView.addSubview(compileButton)
        compileButton.addTarget(self, action: #selector(nv_didTapCompileEvent), for: .touchUpInside)
        compileFileLabel.frame = CGRect.init(x: 20, y: compileButton.frame.minY - 47 * SCREENSCALE, width: compileOptionContainerView.frame.size.width - 40, height: 47 * SCREENSCALE)
        compileFileLabel.textColor = UIColor.init(hex: "#9F9F9F")
        compileFileLabel.font = NvUtils.fontWithSize(size: 11 * SCREENSCALE)
        compileFileLabel.textAlignment = .center
        compileOptionContainerView.addSubview(compileFileLabel)
    }
    private func nv_setupCompileView() {
        compileCloseButton.frame = CGRect.init(x: 10 * SCREENSCALE, y: NV_STATUSBARHEIGHT + 50 * SCREENSCALE, width: 39 * SCREENSCALE, height: 24 * SCREENSCALE)
        compileCloseButton.addTarget(self, action: #selector(nv_didTapCompileCancelEvent), for: .touchUpInside)
        addSubview(compileCloseButton)
        compileCoverImageView.frame = CGRect.init(x: 85 * SCREENSCALE, y: NV_STATUSBARHEIGHT + 100 * SCREENSCALE, width: SCREENWIDTH - 170 * SCREENSCALE, height: 365 * SCREENSCALE)
        compileCoverImageView.image = NvsStreamingContext.sharedInstance()?.grabImage(from: timeline, timestamp: NV_TIME_BASE, proxyScale: nil) /// 封面
        addSubview(compileCoverImageView)
        let coverSize = compileCoverImageView.frame.size
        compileProgressView.frame = CGRect.init(x: (coverSize.width - 91 * SCREENSCALE) * 0.5, y: (coverSize.height - 91 * SCREENSCALE) * 0.5, width: 91 * SCREENSCALE, height: 91 * SCREENSCALE)
        compileCoverImageView.insertSubview(compileProgressView, at: 0)
        compileProgressLabel.frame = compileProgressView.frame
        compileCoverImageView.addSubview(compileProgressLabel)
    
        compileInfoLabel.frame = CGRect.init(x: 5, y: compileCoverImageView.frame.maxY + 50 * SCREENSCALE, width: SCREENWIDTH - 10, height: 19 * SCREENSCALE)
        addSubview(compileInfoLabel)
        compileCancelButton.frame = CGRect.init(x: (SCREENWIDTH - 68 * SCREENSCALE) * 0.5, y: compileCoverImageView.frame.maxY + 144 * SCREENSCALE, width: 68 * SCREENSCALE, height: 32 * SCREENSCALE)
        compileCancelButton.addTarget(self, action: #selector(nv_didTapCompileCancelEvent), for: .touchUpInside)
        addSubview(compileCancelButton)
        compileFinishButton.frame = CGRect.init(x: 56 * SCREENSCALE, y: SCREENHEIGHT - SafeAreaBottomHeight - 82 * SCREENSCALE, width: SCREENWIDTH - 112 * SCREENSCALE, height: 37 * SCREENSCALE)
        compileFinishButton.isHidden = true
        compileFinishButton.addTarget(self, action: #selector(nv_didTapCompileFinishEvent), for: .touchUpInside)
        addSubview(compileFinishButton)
        compileInfoLabel.text = NvLocalProvider.String(key: "Please do not lock the screen or switch to other apps", comment: "请不要锁屏或切换到其他的应用程序")
        compileProgressView.isHidden = false
        compileProgressLabel.isHidden = false
        compileFinishButton.isHidden = true
        compileCancelButton.isHidden = false
    }
}

//MARK: - NvTemplateCompileOptionView
protocol NvTemplateCompileOptionViewDelegate: class {
    func templateCompileOptionView(_ compileOptionView: NvTemplateCompileOptionView, didSelectedAt optionValue: String)
}
class NvTemplateCompileOptionView: UIView {
    weak var delegate: NvTemplateCompileOptionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        nv_setupUI()
        nv_configData()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var dataSource: [String] = [String]()
    private var currentIndex: Int = 0
    private var titleLabel: UILabel!
    private var detailLabel: UILabel!
    private var sliderView: NvTemplateCompileOptionSliderView!
}

extension NvTemplateCompileOptionView: NvTemplateCompileOptionSliderViewDelegate {
    func templateSliderView(didChanged index: Int) {
        delegate?.templateCompileOptionView(self, didSelectedAt: dataSource[index])
    }
    
    private func nv_configData() {
        dataSource = ["480P","720P","1080P"]
        currentIndex = 1
        titleLabel.text = "分辨率"
        detailLabel.text = "分辨率越高，视频越清晰"
        let pointInterval = (bounds.size.width - 21 * SCREENSCALE - CGFloat(dataSource.count) * 7 * SCREENSCALE)  / CGFloat(dataSource.count - 1)
        sliderView.dataSource = (dataSource, currentIndex, pointInterval)
    }
    
    private func nv_setupUI() {
        titleLabel = UILabel.init(frame: CGRect.init(x: 10.5 * SCREENSCALE, y: 0, width: 50 * SCREENSCALE, height: 18 * SCREENSCALE))
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.font = NvUtils.fontWithSize(size: 13 * SCREENSCALE)
        addSubview(titleLabel)
        detailLabel = UILabel.init(frame: CGRect.init(x: 80 * SCREENSCALE, y: 0, width: bounds.size.width - 80 * SCREENSCALE - 10.5 * SCREENSCALE, height: 18 * SCREENSCALE))
        detailLabel.textAlignment = .right
        detailLabel.textColor = UIColor.init(hex: "#A4A4A4", alpha: 1)
        detailLabel.font = NvUtils.fontWithSize(size: 9 * SCREENSCALE)
        addSubview(detailLabel)
        sliderView = NvTemplateCompileOptionSliderView.init(frame: CGRect.init(x: 0, y: detailLabel.frame.maxY + 2 * SCREENSCALE, width: bounds.size.width, height: 68 * SCREENSCALE))
        sliderView.backgroundColor = .clear
        sliderView.delegate = self
        addSubview(sliderView)
    }
}

//MARK: - NvCompileOptionSliderView
protocol NvTemplateCompileOptionSliderViewDelegate: class {
    func templateSliderView(didChanged index: Int)
}
class NvTemplateCompileOptionSliderView: UIView {
    weak var delegate: NvTemplateCompileOptionSliderViewDelegate?
    var dataSource: (data: [String], index: Int, interval: CGFloat)? {
        didSet {
            if let source = dataSource {
                points.removeAll()
                source.data.forEach { points.append($0) }
                index = source.index
                pointInterval = source.interval
                lineW = CGFloat(points.count - 1) * (pointInterval + pointSize.width)
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        startX = (frame.size.width - lineW) * 0.5
        startY = (frame.size.height - 1.5 * SCREENSCALE) * 0.5 - 10 * SCREENSCALE
        addSubview(imageView)
        imageView.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(panGesture:))))
        setRecommand(for: index)
    }

    private var points: [String] = []
    private var index: Int!
    private var pointInterval: CGFloat = 0
    private var startX: CGFloat = 0
    private var startY: CGFloat = 0
    private var lineW: CGFloat = 0
    private var radius: CGFloat = 3.5 * SCREENSCALE
    private let pointSize: CGSize = CGSize.init(width: 7 * SCREENSCALE, height: 7 * SCREENSCALE)
    private lazy var imageView: UIImageView = {
        let view = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 45 * SCREENSCALE, height: 45 * SCREENSCALE))
        view.image = NvUtils.imageWithName( "speed_slder")
        view.contentMode = .center
        view.isUserInteractionEnabled = true
        return view
    }()
}

extension NvTemplateCompileOptionSliderView {
    @objc
    private func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .changed:
            let locationPoint:CGPoint = panGesture.location(in: imageView)
            let locationViewPoint:CGPoint = panGesture.location(in: self)
            
            if (imageView.center.x <= startX && locationPoint.x < imageView.frame.width * 0.2) ||
                (imageView.center.x >= (startX + CGFloat(points.count) * pointInterval) && locationPoint.x > imageView.frame.width * 0.8) {
                    return
            }
            var center = imageView.center
            center.x = locationViewPoint.x
            if center.x < startX {
                center.x = startX
            }else if center.x > (frame.width - startX) {
                center.x = frame.width - startX
            }
            
            for i in 0...points.count {
                let adsorptionX = startX + (pointInterval + pointSize.width) * CGFloat(i)
                if adsorptionX <= center.x && center.x - adsorptionX < pointInterval{
                    if center.x - adsorptionX < pointInterval * 0.5 {
                        center.x = adsorptionX
                        index = i
                    }else {
                        center.x = startX + (pointInterval + pointSize.width) * CGFloat(i+1)
                        index = i+1
                    }
                    break
                }
            }
            imageView.center = center
            panGesture.setTranslation(CGPoint.zero, in: self)
            break
        case .ended:
            delegate?.templateSliderView(didChanged: index)
            break
        default:
            break
        }
    }
    
    private func setRecommand(for value:Int) {
        imageView.center = CGPoint.init(x: startX + (pointInterval + pointSize.width) * CGFloat(value), y: startY)
        delegate?.templateSliderView(didChanged: value)
    }
    override func draw(_ rect: CGRect) {
        UIColor.init(hex: "#363636")!.set()
        let centerPath = UIBezierPath.init()
        centerPath.lineWidth = 1.5 * SCREENSCALE
        centerPath.setLineDash([4.0, 2.0], count: 2, phase: 0)
        centerPath.move(to: CGPoint.init(x: startX + pointSize.width * 0.5, y: startY))
        centerPath.addLine(to: CGPoint.init(x: frame.width - startX, y: startY))
        centerPath.stroke()
        let context = UIGraphicsGetCurrentContext()
        for i in 0..<points.count {
            let roundPath = UIBezierPath.init(arcCenter: CGPoint.init(x: startX + (pointInterval + pointSize.width) * CGFloat(i), y: startY), radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: true)
            UIColor.init(hex: "#363636")!.setFill()
            roundPath.fill()
            drawText(text: points[i], context: context, centerX: startX + (pointInterval + pointSize.width) * CGFloat(i), centerY: startY + 15 * SCREENSCALE)
            if index == i {
                drawText(text: "(推荐)", context: context, centerX: startX + (pointInterval + pointSize.width) * CGFloat(i), centerY: startY + 33 * SCREENSCALE)
            }
        }
    }
    
    private func drawText(text:String, context:CGContext?,centerX: CGFloat,centerY: CGFloat) {
        if let cgContext = context {
            let size: CGSize = textSize(context: text)
            let textWidth:CGFloat = CGFloat(text.count) * size.width
            let textRect = CGRect(x: centerX - textWidth * 0.5, y: centerY - size.height * 0.5, width:textWidth, height: size.height)
            let textStyle = NSMutableParagraphStyle()
            textStyle.alignment = .center
            let textFontAttributes = [
                NSAttributedString.Key.font: NvUtils.fontWithSize(size: 10 * SCREENSCALE),
                NSAttributedString.Key.foregroundColor: UIColor.init(white: 1, alpha: 0.8),
                NSAttributedString.Key.paragraphStyle: textStyle,
                ]
            cgContext.saveGState()
            cgContext.clip(to: textRect)
            text.draw(in: textRect, withAttributes: textFontAttributes)
            cgContext.restoreGState()
        }
    }
    private func textSize(context: String) -> CGSize {
        return (context as NSString).boundingRect(with: CGSize.init(width: frame.size.width, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: NvUtils.fontWithSize(size: 10*SCREENSCALE)], context: nil).size
    }
}

//MARK: - NvCircleProgressView
class NvTemplateCircleProgressView: UIView {
    lazy var colorImage: UIImageView = {
        let imageView = UIImageView(image: NvUtils.imageWithName( "progress_bg"))
        imageView.frame = self.bounds
        return imageView
    }()
    var percent :CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateProgress(value:CGFloat){
        var cValue = value
        if cValue < 0 {
            cValue = 0
        }else if cValue > 1 {
            cValue = 1
        }
        percent = cValue
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        colorImage.draw(self.bounds)
        let path = UIBezierPath.init(arcCenter:CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5), radius: self.bounds.size.width * 0.5 - 5, startAngle: CGFloat.pi * -0.5, endAngle: CGFloat.pi * 2 * self.percent + CGFloat.pi * -0.5, clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 6.0
        self.layer.mask = shapeLayer
    }
}

