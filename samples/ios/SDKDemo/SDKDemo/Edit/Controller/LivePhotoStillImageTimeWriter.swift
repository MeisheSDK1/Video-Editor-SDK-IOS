//
//  LivePhotoStillImageTimeWriter.swift
//  MYVideo
//
//  Created by meishe on 2025/4/15.
//

import AVFoundation
import UIKit
import MobileCoreServices

public class LivePhotoStillImageTimeWriter {
    private var reader: AVAssetReader?
    private var writer: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var videoOutput: AVAssetReaderTrackOutput?
    private var audioInput: AVAssetWriterInput?
    private var audioOutput: AVAssetReaderTrackOutput?
    private var metadataInputAdaptor: AVAssetWriterInputMetadataAdaptor?
    private var metadataInput: AVAssetWriterInput?

    private var writingQueue = DispatchQueue(label: "livephoto.writer")
    
    class func writeJPEGImage(with image: UIImage, assetIdentifier: String, to url: URL) -> Bool {
        guard let cgImage = image.cgImage else { return false }

        // 改成 JPEG 类型
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeJPEG, 1, nil) else { return false }

        // 嵌入 MakerApple.assetIdentifier
        let metadata: [String: Any] = [
            kCGImagePropertyMakerAppleDictionary as String: [
                "17": assetIdentifier
            ]
        ]

        CGImageDestinationAddImage(destination, cgImage, metadata as CFDictionary)
        return CGImageDestinationFinalize(destination)
    }

    static func export(
        inputURL: URL,
        outputURL: URL,
        contentIdentifier: String,
        stillImageTimeRange: CMTimeRange,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let instance = LivePhotoStillImageTimeWriter()

        // 持有 instance，直到任务完成
        instance.performExport(
            inputURL: inputURL,
            outputURL: outputURL,
            contentIdentifier: contentIdentifier,
            stillImageTimeRange: stillImageTimeRange
        ) { result in
            // 这里引用 instance，使它在任务完成前不会释放
            _ = instance  // 强引用保持到这里
            completion(result)
        }
    }

    private func performExport(
        inputURL: URL,
        outputURL: URL,
        contentIdentifier: String,
        stillImageTimeRange: CMTimeRange,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let asset = AVAsset(url: inputURL)

        do {
            reader = try AVAssetReader(asset: asset)
            writer = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
        } catch {
            completion(.failure(error))
            return
        }

        guard let reader = reader, let writer = writer else {
            completion(.failure(NSError(domain: "LivePhoto", code: -1, userInfo: [NSLocalizedDescriptionKey: "初始化失败"])))
            return
        }

        // 视频轨处理
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
            if let videoOutput = videoOutput, reader.canAdd(videoOutput) {
                reader.add(videoOutput)
            }

            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
            videoInput?.expectsMediaDataInRealTime = false
            if let videoInput = videoInput, writer.canAdd(videoInput) {
                writer.add(videoInput)
            }
        }

        // 音频轨处理（可选）
        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if let audioOutput = audioOutput, reader.canAdd(audioOutput) {
                reader.add(audioOutput)
            }

            audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
            audioInput?.expectsMediaDataInRealTime = false
            if let audioInput = audioInput, writer.canAdd(audioInput) {
                writer.add(audioInput)
            }
        }
        // 写入 global metadata: content.identifier
        let contentID = AVMutableMetadataItem()
        contentID.key = "com.apple.quicktime.content.identifier" as NSString
        contentID.keySpace = .quickTimeMetadata
        contentID.value = contentIdentifier as NSString
        writer.metadata = [contentID]
        
        // 添加 still-image-time metadata
        let key = "com.apple.quicktime.still-image-time"
        let keySpace = "mdta"
        let spec: NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString: "\(keySpace)/\(key)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString: "com.apple.metadata.datatype.int8"
        ]
        var desc: CMFormatDescription?
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(
            allocator: kCFAllocatorDefault,
            metadataType: kCMMetadataFormatType_Boxed,
            metadataSpecifications: [spec] as CFArray,
            formatDescriptionOut: &desc
        )

        metadataInput = AVAssetWriterInput(mediaType: .metadata, outputSettings: nil, sourceFormatHint: desc)
        if let metadataInput = metadataInput {
            metadataInputAdaptor = AVAssetWriterInputMetadataAdaptor(assetWriterInput: metadataInput)
            if writer.canAdd(metadataInput) {
                writer.add(metadataInput)
            }
        }

        guard let metadataAdaptor = metadataInputAdaptor else {
            completion(.failure(NSError(domain: "LivePhoto", code: -2, userInfo: [NSLocalizedDescriptionKey: "Metadata adaptor 创建失败"])))
            return
        }

        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: .zero)

        // 并发执行写入流程
        let group = DispatchGroup()

        // 视频写入
        if let videoInput = videoInput, let videoOutput = videoOutput {
            group.enter()
            videoInput.requestMediaDataWhenReady(on: writingQueue) {
                while videoInput.isReadyForMoreMediaData {
                    if let buffer = videoOutput.copyNextSampleBuffer() {
                        videoInput.append(buffer)
                    } else {
                        videoInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            }
        }

        // 音频写入
        if let audioInput = audioInput, let audioOutput = audioOutput {
            group.enter()
            audioInput.requestMediaDataWhenReady(on: writingQueue) {
                while audioInput.isReadyForMoreMediaData {
                    if let buffer = audioOutput.copyNextSampleBuffer() {
                        audioInput.append(buffer)
                    } else {
                        audioInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            }
        }

        // Metadata 写入
        group.enter()
        let item = AVMutableMetadataItem()
        item.identifier = AVMetadataIdentifier(rawValue: "\(keySpace)/\(key)")
        item.dataType = "com.apple.metadata.datatype.int8"
        item.value = NSNumber(value: 0)

        let timeRange = stillImageTimeRange
        let groupToWrite = AVTimedMetadataGroup(items: [item], timeRange: timeRange)
        metadataAdaptor.append(groupToWrite)
        metadataInput?.markAsFinished()
        group.leave()

        group.notify(queue: writingQueue) {
            writer.finishWriting {
                if writer.status == .completed {
                    completion(.success(outputURL))
                } else {
                    completion(.failure(writer.error ?? NSError(domain: "LivePhoto", code: -3, userInfo: nil)))
                }
            }
        }
    }
}
