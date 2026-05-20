//
//  NvConvertorProvider.swift
//  MYVideo
//
//  Created by chengww on 2021/1/20.
//  Copyright © 2021 MEISHE. All rights reserved.
//

import UIKit
import Photos
import NvStreamingSdkCore

protocol NvConvertorProviderDelegate: class {
    func start()
    func cancel()
}
extension NvConvertorProvider {
    public enum State: Int {
        case success = 0
        case cancel  = 1
        case error   = 2
    }
}
class NvConvertorProvider: NSObject {
    var convertorProcess: ((_ progress: Float) -> Void)?
    var convertorCallback: ((_ state: NvConvertorProvider.State) -> Void)?
    init(for dataSource: [NvAlbumTemplateItem]) {
        super.init()
        self.fileConvertor = NvsMediaFileConvertor.init()
        self.fileConvertor?.delegate = self
        self.source = dataSource
        self.currentItem = self.source.first
    }
    private var source: [NvAlbumTemplateItem] = []
    private var fileConvertor: NvsMediaFileConvertor?
    private var taskId: Int64?
    private var tempPath: String?
    private var currentItem: NvAlbumTemplateItem?
}

extension NvConvertorProvider: NvConvertorProviderDelegate {
    func start() {
        guard let item = self.currentItem, let asset = item.asset else { return }
        let subArray = asset.localIdentifier.split(separator: "/")
        let fileName = subArray.joined(separator: "")
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (resultAsset, mix, info) in
            if let retAsset = resultAsset, let convertor = self.fileConvertor {
                if retAsset.isKind(of: AVURLAsset.self) {
                    DispatchQueue.main.async(execute: {
                        let avAsset = retAsset as! AVURLAsset
                        let filePath = avAsset.url.path
                        let outFilePath = TEMPLATE_Reverse_URL + "/upend_" + fileName + ".mp4"
                        let duration: Int64  = Int64(CMTimeGetSeconds(retAsset.duration) * 1000000)
                        self.taskId = convertor.convertMeidaFile(filePath, outputFile: outFilePath, isReverseConvert: true, fromPosition: 0, toPosition: duration, options: NSMutableDictionary.init())
                    })
                }else if retAsset.isKind(of: AVComposition.self){
                    let avcomposition = retAsset as! AVComposition
                    self.nv_convertAvcompositionToAvasset(avComp: avcomposition) { (avasset, path, isSuccess) in
                        if isSuccess {
                            let filePath = avasset!.url.path
                            let outFilePath = TEMPLATE_Reverse_URL + "/upend_" + fileName + ".mp4"
                            let duration: Int64  = Int64(CMTimeGetSeconds(retAsset.duration) * 1000000)
                            self.tempPath = path
                            self.taskId = convertor.convertMeidaFile(filePath, outputFile: outFilePath, isReverseConvert: true, fromPosition: 0, toPosition: duration, options: NSMutableDictionary.init())
                        }else {
                            try? FileManager.default.removeItem(atPath: path)
                        }
                    }
                }
            }
        })
    }
    func cancel() {
        if let task = self.taskId {
            self.fileConvertor?.cancelTask(task)
        }
    }
    
    func nv_convertAvcompositionToAvasset(avComp: AVComposition, completion:@escaping (_ avasset: AVURLAsset?,_ path: String, _ isSuccess: Bool) -> Void){
        let exporter = AVAssetExportSession(asset: avComp, presetName: AVAssetExportPresetHighestQuality)
        let randNum:Int = Int(arc4random())
        let exportPath = NSTemporaryDirectory().appendingFormat("\(randNum)"+"video.mp4")
        let exportUrl: URL = URL.init(fileURLWithPath: exportPath)
        exporter?.outputURL = exportUrl
        exporter?.outputFileType = .mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.exportAsynchronously(completionHandler: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if exporter?.status == .completed {
                    if let url = exporter?.outputURL {
                        let asset:AVURLAsset = AVURLAsset.init(url: url)
                        completion(asset, exportPath, true)
                    }else {
                        completion(nil, exportPath, true)
                    }
                }else if exporter?.status == .failed{
                    completion(nil, exportPath, true)
                }
            })
        })
    }
}

extension NvConvertorProvider: NvsMediaFileConvertorDelegate {
    func didConvertorProgress(_ taskId: Int64, progress: Float) {
        DispatchQueue.main.async(execute: {
            if self.convertorProcess != nil {
                self.convertorProcess!(progress)
            }
        })
    }
    
    func didConvertorFinish(_ taskId: Int64, sourceFile src: String!, outputFile dst: String!, errorCode error: NvsMediaConvertorErrorType) {
        if self.tempPath != nil {
            try? FileManager.default.removeItem(atPath: self.tempPath!)
            self.tempPath = nil
        }
        if error == keNvsMediaConvertorErrorType_NoError {
            let lastItem = self.source.last
            self.currentItem?.reversePath = dst
            if lastItem?.trackIndex == self.currentItem?.trackIndex && lastItem?.clipIndex == self.currentItem?.clipIndex {
                /// 全部转码完成
                /// All transcoding is complete
                self.fileConvertor?.delegate = nil
                self.fileConvertor = nil
                self.currentItem = nil
                DispatchQueue.main.async(execute: {
                    if self.convertorCallback != nil {
                        self.convertorCallback!(.success)
                    }
                })
            }else {
                if let index = self.source.firstIndex(where: { $0.trackIndex == self.currentItem?.trackIndex && $0.clipIndex == self.currentItem?.clipIndex }) {
                    self.currentItem = self.source[index + 1]
                    self.start()
                }
            }
        }else if error == keNvsMediaConvertorErrorType_Cancled {
            self.fileConvertor?.delegate = nil
            self.fileConvertor = nil
            self.currentItem = nil
            try? FileManager.default.removeItem(atPath: dst)
            DispatchQueue.main.async(execute: {
                if self.convertorCallback != nil {
                    self.convertorCallback!(.cancel)
                }
            })
        }else {
            self.fileConvertor?.delegate = nil
            self.fileConvertor = nil
            self.currentItem = nil
            try? FileManager.default.removeItem(atPath: dst)
            DispatchQueue.main.async(execute: {
                if self.convertorCallback != nil {
                    self.convertorCallback!(.error)
                }
            })
        }
    }
    
    func didAudioMuteRage(_ taskId: Int64, muteStart start: Int64, muteEnd end: Int64) {}
}

