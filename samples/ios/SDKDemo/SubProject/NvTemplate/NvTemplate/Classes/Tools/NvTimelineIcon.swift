//
//  NvTimelineIcon.swift
//  NvMeicam
//
//  Created by chengww on 2022/6/16.
//

import UIKit
import NvStreamingSdkCore

public class NvTimelineIcon: NSObject, NvsImageGrabberDelegate {
    
    /// Synchronous grab image at the position of timeline
    /// - Remark: 以同步的方式获取timeline上某一帧图片
    /// - Parameters:
    ///   - context: the object of NvsStreamingContext
    ///   - timeline: the object of timeline
    ///   - timestamp: the position of timeline
    ///   - needScale: need scale the grab image
    ///   - completeHandle: callback the response grab image
    public static func syncGrab(_ context: NvsStreamingContext, timeline: NvsTimeline, timestamp: Int64,needScale: Bool = true, completeHandle: @escaping (_ image: UIImage?) -> Void) {
        var rational:NvsRational = NvsRational(num: 1, den: 1)
        rational.num = 375
        rational.den = Int32(timeline.videoRes.imageWidth)
        ///优先异步加载
        ///Priority asynchronous loading
        var newImage: UIImage? = nil
        if needScale {
            newImage = context.grabImage(from: timeline, timestamp: timestamp, proxyScale: &rational, flags: Int32(NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue))
        }else{
            newImage = context.grabImage(from: timeline, timestamp: timestamp, proxyScale: nil, flags: Int32(NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue))
        }
        newImage = NvTimelineIcon.drawImage(newImage)
        completeHandle(newImage)
    }
    
    /// Asynchronous grab image at the position of timeline
    /// - Remark: 从timeline异步获取图片
    /// - Parameters:
    ///   - context: the object of NvsStreamingContext
    ///   - timeline: the object of timeline
    ///   - timestamp: the position of timeline
    ///   - needScale: need scale the grab image
    ///   - completeHandle: callback the response grab image
    @discardableResult
    public static func asyncGrab(_ context: NvsStreamingContext, timeline: NvsTimeline, timestamp: Int64,needScale: Bool = true, completeHandle: @escaping (_ image: UIImage?) -> Void) -> Bool {
        provider = NvTimelineIcon.init()
        context.imageGrabberDelegate = provider
        var rational:NvsRational = NvsRational(num: 1, den: 1)
        rational.num = 375
        rational.den = Int32(timeline.videoRes.imageWidth)
        ///优先异步加载
        ///Priority asynchronous loading
        var ret = false
        
        provider?.callback = { thumb in
            DispatchQueue.main.async {
                defer {
                    provider = nil
                }
                completeHandle(thumb)
            }
        }
        
        if needScale {
            ret = context.grabImage(fromTimelineAsync: timeline, timestamp: timestamp, proxyScale: &rational, flags: Int32(NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue))
        }else{
            ret = context.grabImage(fromTimelineAsync: timeline, timestamp: timestamp, proxyScale: nil, flags: Int32(NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue))
        }
        context.stop()
        
        if ret {

        }else {
            context.imageGrabberDelegate = nil
            provider = nil
        }
        return ret
    }
    
    /// Asynchronous grab image at the position of videoClip
    /// - Remark: 从videoClip异步获取图片
    /// - Parameters:
    ///   - streamingContext: the object of NvsStreamingContext
    ///   - imageWidth: the width of timeline
    ///   - imageHeight: the height of timeline
    ///   - filePath: the path of videoClip
    ///   - timestamp: the position of videoClip[inPoint, outPoint]
    ///   - completeHandle: callback the response grab image
    public static func asyncGrabVideoClipFrame(_ streamingContext: NvsStreamingContext, imageWidth: UInt32, imageHeight: UInt32, filePath: String, timestamp: Int64, completeHandle: @escaping (_ image: UIImage?) -> Void) {
        var auxiliaryContext = streamingContext.createAuxiliaryStreamingContext(Int32(NvsStreamingContextFlag_Support4KEdit.rawValue))
        guard let context = auxiliaryContext, !filePath.isEmpty else {
            auxiliaryContext = nil
            completeHandle(nil)
            return
        }
        
        var videoRes: NvsVideoResolution = configVideoRes(streamingContext, filePath: filePath, width: imageWidth, height: imageHeight)
        var videoFps: NvsRational = NvsRational.init(num: 30, den: 1)
        var audioRes: NvsAudioResolution = NvsAudioResolution.init(sampleRate: 48000, sampleFormat: NvsAudSmpFmt_S16, channelCount: 2)
        guard let timeline = context.createTimeline(&videoRes, videoFps: &videoFps, audioEditRes: &audioRes) else {
            streamingContext.destoryAuxiliaryStreamingContext(context)
            auxiliaryContext = nil
            completeHandle(nil)
            return
        }
        if let videoTrack = timeline.appendVideoTrack(), let videoClip = videoTrack.appendClip(filePath), timeline.duration >= timestamp {
            asyncGrab(context, timeline: timeline, timestamp: timestamp, needScale: false, completeHandle: {
                context.remove(timeline)
                context.clearCachedResources(false)
                streamingContext.destoryAuxiliaryStreamingContext(context)
                auxiliaryContext = nil
                completeHandle($0)
            })
        }else {
            context.remove(timeline)
            context.clearCachedResources(false)
            streamingContext.destoryAuxiliaryStreamingContext(context)
            auxiliaryContext = nil
            completeHandle(nil)
        }
    }
    
    public func onImageGrabbedArrived( _ image: UIImage?,timestamp: Int64) {
        var newImage = NvTimelineIcon.drawImage(image)
        if self.callback != nil {
            self.callback!(newImage)
        }
    }
    
    private static func drawImage(_ image: UIImage?) -> UIImage? {
        var newImage: UIImage? = image
        if let tempImage = image {
            ///重新绘制，添加黑色背景
            ///Redraw and add a black background
            let size = tempImage.size
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
            UIColor.black.setFill()
            UIRectFill(rect)
            tempImage.draw(in: rect)
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return newImage
    }
    
    private static func configVideoRes(_ context: NvsStreamingContext, filePath: String, width: UInt32, height: UInt32) -> NvsVideoResolution {
        var videoRes = NvsVideoResolution.init()
        videoRes.imagePAR = NvsRational.init(num: 1, den: 1)
        videoRes.imageWidth = width
        videoRes.imageHeight = height
        if let fileInfo = context.getAVFileInfo(filePath) {
            let size = fileInfo.getVideoStreamDimension(0)
            var fSize = CGSize(width: CGFloat(size.width), height: CGFloat(size.height))
            let pixelAspect = fileInfo.getVideoStreamPixelAspectRatio(0)
            if (pixelAspect.num != pixelAspect.den){
                let scaleX = CGFloat(pixelAspect.num)/CGFloat(pixelAspect.den)
                fSize.width *= scaleX
            }
            let rotation = fileInfo.getVideoStreamRotation(0)
            if rotation == NvsVideoRotation_90 || rotation == NvsVideoRotation_270 {
                videoRes.imageWidth = UInt32(fSize.height)
                videoRes.imageHeight = UInt32(fSize.width)
            } else {
                videoRes.imageWidth = UInt32(fSize.width)
                videoRes.imageHeight = UInt32(fSize.height)
            }
            videoRes.imageWidth = (videoRes.imageWidth + 3) & ~3
            videoRes.imageHeight = (videoRes.imageHeight + 1) & ~1
            return videoRes
        }
        return videoRes
    }
    
    private var callback: ((_ thumb: UIImage?) -> Void)?
    static var provider: NvTimelineIcon?
    private override init() {
        super.init()
    }
}

