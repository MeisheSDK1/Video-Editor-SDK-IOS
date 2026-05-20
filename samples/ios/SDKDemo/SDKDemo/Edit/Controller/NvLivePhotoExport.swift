//
//  NvLivePhotoExport.swift
//  SDKDemo
//
//  Created by Mac-Mini on 2025/5/9.
//  Copyright © 2025 meishe. All rights reserved.
//

import UIKit
import CoreMedia
import Photos

@objcMembers
public class NvLivePhotoExport: NSObject {
    class public func exportLivePhoto(videoPath: String, image: UIImage, timeRange: CMTimeRange, completion: @escaping (Bool, Error?) -> Void) {
        let assetIdentifier = UUID().uuidString
        let exportDir = NSHomeDirectory() + "/Documents/ExportLivePhoto"
        let imagePath = exportDir + "/IMG.heic"
        let movVideoPath = exportDir + "/IMG.MOV"
        let _ = try? FileManager.default.createDirectory(atPath: exportDir, withIntermediateDirectories: true, attributes: nil)
        do {
            try FileManager.default.removeItem(atPath: imagePath)
            try FileManager.default.removeItem(atPath: movVideoPath)
        } catch {
            print("Error removing files: \(error)")
        }
        let imageUrl = URL(fileURLWithPath: imagePath)
        let outputFileURL = URL(fileURLWithPath: movVideoPath)
        if LivePhotoStillImageTimeWriter.writeJPEGImage(with: image, assetIdentifier: assetIdentifier, to: imageUrl) {
            LivePhotoStillImageTimeWriter.export(inputURL: URL(fileURLWithPath: videoPath), outputURL: outputFileURL, contentIdentifier: assetIdentifier, stillImageTimeRange: timeRange) { result in
                switch result {
                case .success(let url):
                    PHPhotoLibrary.shared().performChanges({
                        let creationRequest=PHAssetCreationRequest.forAsset()
                        let options = PHAssetResourceCreationOptions()
                        creationRequest.addResource(with: .photo, fileURL: imageUrl, options: options)
                        creationRequest.addResource(with: .pairedVideo, fileURL: url, options: options)
                    }) { suc, error in
                        if suc {
                            print("Live photo export success")
                            completion(true, nil)
                        } else {
                            print("Live photo export failed: \(String(describing: error))")
                            completion(false, error)
                        }
                    }
                case .failure(let error):
                    print("Error exporting live photo: \(error)")
                    completion(false, error)
                }
            }
        }
        
        
    }
}
