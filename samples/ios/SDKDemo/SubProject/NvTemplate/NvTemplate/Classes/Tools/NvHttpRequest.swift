//
//  NvTemplateHttpRequest.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit
import Foundation
import AFNetworking
import SSZipArchive

class NvTemplateHttpRequest: NSObject {
    
    var currentDownloadTask: URLSessionDownloadTask?
    let manager = AFHTTPSessionManager()
    static let sharedInstance: NvTemplateHttpRequest = {
        let instance = NvTemplateHttpRequest()
        // setup code
        return instance
    }()
    
    func syncBodyRequestPost(urlString: String, header: [String: String] , param: Dictionary<String, String>) -> ( data: Dictionary<String, Any>?, error:Error?){
        
        var responseData: Dictionary<String, Any>? = nil
        var responseError:Error? = nil
        let semaphore = DispatchSemaphore(value: 0)
        var jsonData:Data? = nil
        do {
            jsonData = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        } catch {
        }
        if jsonData == nil {
            return (nil,nil)
        }
        let bodyJsonData = jsonData!
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.httpMethod = "POST"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        urlRequest.httpBody = bodyJsonData
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        for (key, value) in header {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            responseError = error
            if error == nil {
                if data != nil {
                    if let dic = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) {
                        responseData = (dic as! Dictionary<String, Any>)
                    } else {
                        responseData = Dictionary<String, Any>()
                    }
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
        return (data: responseData, error:responseError)
    }
    
    func syncPost(urlString: String, header: [String: String]? = nil, param: Dictionary<String, String>) -> ( data: Dictionary<String, Any>?, error:Error?){
        
        var responseData: Dictionary<String, Any>? = nil
        var responseError:Error? = nil
        let semaphore = DispatchSemaphore(value: 0)
        
        let sessionManager = AFURLSessionManager.init(sessionConfiguration: URLSessionConfiguration.default)
        let serializer = AFJSONRequestSerializer.init()
        do {
            let request = try serializer.request(withMethod: "POST", urlString: urlString, parameters: param)
            request.timeoutInterval = 15.0
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            if let requestHeader = header {
                for (key, value) in requestHeader {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            let task = sessionManager.dataTask(with: request as URLRequest, uploadProgress: nil, downloadProgress: nil) { (response, objc, error) in
                if error == nil {
                    responseData = objc as? Dictionary<String, Any>
                }else {
                    responseError = error
                }
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        } catch let error {
            responseError = error
        }
        return (data: responseData, error: responseError)
    }
    
    func get(urlString: String, header: [String: String] , param: Dictionary<String, String>, success: @escaping (_ data: Dictionary<String, Any>, Any?)-> Void, failure: @escaping (Error)-> Void)  {
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.timeoutInterval = 15.0
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        for (key, value) in header {
            manager.requestSerializer.setValue(value, forHTTPHeaderField: key)
        }
        manager.requestSerializer.cachePolicy = .reloadIgnoringLocalCacheData
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = ["application/json", "text/plain", "text/javascript", "text/json", "text/html"]
        let task = manager.get(urlString, parameters: param, headers: nil, progress: nil) { (dataTask, response) in
            if (dataTask.response as! HTTPURLResponse).statusCode == 200 {
                if let dic = try? JSONSerialization.jsonObject(with: response as! Data, options: .fragmentsAllowed) {
                    success(dic as! Dictionary<String, Any>,dataTask)
                } else {
                    success(Dictionary<String, Any>(),dataTask)
                }
            } else {
                failure(dataTask.error!)
            }
            dataTask.cancel()
        } failure: { (dataTask, error) in
            print(error.localizedDescription)
            failure(error)
        }
        task?.resume()
    }

    func get(urlString: String, param: Dictionary<String, Any>, success: @escaping (_ data: Dictionary<String, Any>, Any?)-> Void, failure: @escaping (Error)-> Void) {
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.timeoutInterval = 15.0
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.cachePolicy = .reloadIgnoringLocalCacheData
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = ["application/json", "text/plain", "text/javascript", "text/json", "text/html"]
        let task = manager.get(urlString, parameters: param, headers: nil, progress: nil) { (dataTask, response) in
            if (dataTask.response as! HTTPURLResponse).statusCode == 200 {
                if let dic = try? JSONSerialization.jsonObject(with: response as! Data, options: .fragmentsAllowed) {
                    success(dic as! Dictionary<String, Any>,dataTask)
                } else {
                    success(Dictionary<String, Any>(),dataTask)
                }
            } else {
                failure(dataTask.error!)
            }
            dataTask.cancel()
        } failure: { (dataTask, error) in
            print(error.localizedDescription)
            failure(error)
        }
        task?.resume()
    }
    func post(urlString: String, header: [String: String]? = nil, param: Dictionary<String, String>, success: @escaping (_ data: Dictionary<String, Any>, Any?)-> Void, failure: @escaping (Error)-> Void) {
        let sessionManager = AFURLSessionManager.init(sessionConfiguration: URLSessionConfiguration.default)
        let serializer = AFJSONRequestSerializer.init()
        do {
            let request = try serializer.request(withMethod: "POST", urlString: urlString, parameters: param)
            request.timeoutInterval = 15.0
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            if let requestHeader = header {
                for (key, value) in requestHeader {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            let task = sessionManager.dataTask(with: request as URLRequest, uploadProgress: nil, downloadProgress: nil) { (response, objc, error) in
                if error == nil {
                    success(objc as? Dictionary<String, Any> ?? Dictionary<String, Any>(), nil )
                }else {
                    failure(error!)
                }
            }
            task.resume()
        } catch let error {
            failure(error)
        }
    }
    
    func download(urlString: String,destinationUrl: String, progressBlock: @escaping (_ progress: CGFloat)->Void , success: @escaping (_ urlString: String)-> Void, failure: @escaping (Error)-> Void) {
        let request = URLRequest(url: URL(string: urlString)!)
//        weak var weakSelf = self
        self.currentDownloadTask = manager.downloadTask(with: request, progress: { (pro) in
            progressBlock(CGFloat(pro.completedUnitCount)/CGFloat(pro.totalUnitCount))
        }, destination: { (url, urlResponse) -> URL in
            let fm = FileManager.default
            if fm.fileExists(atPath: destinationUrl) {
                try? fm.removeItem(atPath: destinationUrl)
            }
            
            let fileDir = URL(fileURLWithPath: destinationUrl).deletingLastPathComponent().path
            if !fm.fileExists(atPath: fileDir) {
                try? fm.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
            }
            return URL(fileURLWithPath: destinationUrl)
        }) { (urlResponse, url, error) in
            self.currentDownloadTask?.cancel()
            if let e = error {
                failure(e)
            } else {
                success(destinationUrl)
            }
        }
        self.currentDownloadTask?.resume()
    }
    
    
    func downloadTemplate(urlString: String,destinationUrl: String, originalUrl: String, progressBlock: @escaping (_ progress: CGFloat)->Void , success: @escaping (_ urlString: String)-> Void, failure: @escaping (Error)-> Void) {
        let request = URLRequest(url: URL(string: urlString)!)
        //        weak var weakSelf = self
        manager.downloadTask(with: request, progress: { (pro) in
            progressBlock(CGFloat(pro.completedUnitCount)/CGFloat(pro.totalUnitCount))
        }, destination: { (url, urlResponse) -> URL in
            
            let filePath:String = destinationUrl
            let fileDir = URL(fileURLWithPath: filePath).deletingLastPathComponent().path
            let fm = FileManager.default
            if fm.fileExists(atPath: originalUrl) {
                try? fm.removeItem(atPath: originalUrl)
            }
            
            if !fm.fileExists(atPath: fileDir) {
                try? fm.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
            }
            return URL(fileURLWithPath: filePath)
        }) { (urlResponse, url, error) in
            if let e = error {
                failure(e)
            } else {
                success(destinationUrl)
            }
        }.resume()
    }
    
    ///下载模版zip文件
    func downloadTemplateZip(urlString: String, templateDirPath: String, progressBlock: @escaping (_ progress: CGFloat) -> Void, success: @escaping (_ templateFilePath: String, _ licenseFilePath: String) -> Void, failure: @escaping (Error) -> Void) {
        
        guard let downloadURL = URL(string: urlString) else {
            failure(NSError(domain: "DownloadError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid download URL"]))
            return
        }
        let request = URLRequest(url: downloadURL)
        let tempZipPath = NSTemporaryDirectory() + downloadURL.lastPathComponent
        manager.downloadTask(with: request, progress: { progress in
            
            progressBlock(CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount))
        }, destination: { _, _ -> URL in
            
            return URL(fileURLWithPath: tempZipPath)
        }) { _, filePath, error in
            
            if let e = error {
                
                failure(e)
            } else {
                
                let zipPath = filePath?.path ?? ""
                let tempUnzipPath = NSTemporaryDirectory() + UUID().uuidString
                if SSZipArchive.unzipFile(atPath: zipPath, toDestination: tempUnzipPath) {
                    do {
                        let fm = FileManager.default
                        let files = try fm.contentsOfDirectory(atPath: tempUnzipPath)
                        var templateFilePath: String?
                        var licenseFilePath: String?
                        for file in files {
                            
                            if file.hasSuffix(".template") || file.hasSuffix(".lic") {
                                
                                let srcPath = tempUnzipPath + "/" + file
                                let dstPath = templateDirPath + "/" + file
                                let baseFileName = file.components(separatedBy: ".").first ?? ""
                                let extensionName = file.components(separatedBy: ".").last ?? ""
                                //判断文件夹是否存在
                                if fm.fileExists(atPath: templateDirPath) {
                                    
                                    let existingFiles = try fm.contentsOfDirectory(atPath: templateDirPath)
                                    //删除存在的同名文件
                                    for existingFile in existingFiles where existingFile.contains(baseFileName) {
                                        
                                        let existingExtensionName = existingFile.components(separatedBy: ".").last ?? ""
                                        if existingExtensionName == extensionName {
                                            let existingFilePath = templateDirPath + "/" + existingFile
                                            try fm.removeItem(atPath: existingFilePath)
                                        }
                                    }
                                }else{
                                    
                                    do {
                                        try fm.createDirectory(atPath: templateDirPath, withIntermediateDirectories: true, attributes: nil)
                                    } catch {
                                        print("创建目录失败: \(error)")
                                        return
                                    }
                                }
                                try fm.moveItem(atPath: srcPath, toPath: dstPath)
                                if file.hasSuffix(".template") {
                                    templateFilePath = dstPath
                                } else if file.hasSuffix(".lic") {
                                    licenseFilePath = dstPath
                                }
                            }
                        }
                        try fm.removeItem(atPath: zipPath)  //删除zip压缩文件
                        try fm.removeItem(atPath: tempUnzipPath)  // 删除解压文件
                        if let templatePath = templateFilePath, let licensePath = licenseFilePath {
                            success(templatePath, licensePath)
                        } else {
                            failure(NSError(domain: "FileError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Required files not found"]))
                        }
                    } catch {
                        failure(error)
                    }
                } else {
                    failure(NSError(domain: "UnzipError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to unzip file"]))
                }
            }
        }.resume()
    }
}
