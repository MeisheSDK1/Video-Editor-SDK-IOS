//
//  NvUtils.swift
//  DouVideoDemo
//
//  Created by 董凌晓 on 2019/12/2.
//  Copyright © 2019 美摄. All rights reserved.
//

import UIKit
import AudioToolbox
import Photos
import NvStreamingSdkCore
func editAspectRatioModeToAssetAspectRatio(editAspectRatioMode:NvVideoEditAspectRatioMode,originAspectRatio:CGFloat) -> AspectRatio {
    switch editAspectRatioMode {
    case .NvVideoEditAspectRatioMode_Free:
        let originAspectRatioString = String(format: "%.1f", originAspectRatio)
        if originAspectRatioString == String(format: "%.1f", CGFloat(9)/16) {
            return AspectRatio.AspectRatio_9v16
        }else if originAspectRatioString == String(format: "%.1f", CGFloat(3)/4) {
            return AspectRatio.AspectRatio_3v4
        }else if originAspectRatioString == "1.0" {
            return AspectRatio.AspectRatio_1v1
        }else if originAspectRatioString == String(format: "%.1f", CGFloat(4)/3) {
            return AspectRatio.AspectRatio_4v3
        }else if originAspectRatioString == String(format: "%.1f", CGFloat(16)/9) {
            return AspectRatio.AspectRatio_16v9
        }else{
            return AspectRatio.AspectRatio_Origin
        }
    case .NvVideoEditAspectRatioMode_9v16:
        return AspectRatio.AspectRatio_9v16
    case .NvVideoEditAspectRatioMode_3v4:
        return AspectRatio.AspectRatio_3v4
    case .NvVideoEditAspectRatioMode_1v1:
        return AspectRatio.AspectRatio_1v1
    case .NvVideoEditAspectRatioMode_4v3:
        return AspectRatio.AspectRatio_4v3
    case .NvVideoEditAspectRatioMode_16v9:
        return AspectRatio.AspectRatio_16v9
    case .NvVideoEditAspectRatioMode_9v18:
        return AspectRatio.AspectRatio_9v18
    case .NvVideoEditAspectRatioMode_9v21:
        return AspectRatio.AspectRatio_9v21
    case .NvVideoEditAspectRatioMode_18v9:
        return AspectRatio.AspectRatio_18v9
    case .NvVideoEditAspectRatioMode_21v9:
        return AspectRatio.AspectRatio_21v9
    }
}

extension NvSwiftUtils {
    public enum FileType {
        case video
        case audio
        case image
        case text
        case unknown
    }
}

class NvSwiftUtils: NSObject {
    
    class func createTimeline(editMode : NvVideoEditAspectRatioMode,originAspectRatio:CGFloat,context:NvsStreamingContext) ->(NvsTimeline) {
        
        var videoEditRes : NvsVideoResolution = NvsVideoResolution ()
        let videoSize:NvsSize = calculateTimelineSize(editMode: editMode,originAspectRatio:originAspectRatio)
        videoEditRes.imageWidth = UInt32(videoSize.width)
        videoEditRes.imageHeight = UInt32(videoSize.height)
        videoEditRes.imagePAR = NvsRational.init(num: 1, den: 1)
        var videoFps : NvsRational = NvsRational.init(num: 25, den: 1)
        var audioEditRes : NvsAudioResolution = NvsAudioResolution()
        audioEditRes.sampleRate = 48000;
        audioEditRes.channelCount = 2;
        audioEditRes.sampleFormat = NvsAudSmpFmt_S16
        let timeline = context.createTimeline(&videoEditRes, videoFps: &videoFps, audioEditRes: &audioEditRes)
        return timeline!
    }
    class func playback(timeine: NvsTimeline, startTime: Int64, endTime: Int64) {
        if let streamingContext = NvsStreamingContext.sharedInstance() {
//            streamingContext.clearCached Resources(false)
            streamingContext.playbackTimeline(timeine, startTime: startTime, endTime: endTime, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize,preload: true,flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyHostVideoFrame.rawValue|64))
        }
    }
    @discardableResult
    class func seek(timeine: NvsTimeline, positon: Int64) -> Bool {
        if let streamingContext = NvsStreamingContext.sharedInstance() {
            let flags = streamingContext.seekTimeline(timeine, timestamp: positon, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue|64))
            return flags
        }
        return false
    }
    
    class func checkVideoAssetIs4K(asset: PHAsset) -> (is4K: Bool, duration: Int64) {
        if asset.mediaType == .video {
            if let avfileInfo = NvsStreamingContext.sharedInstance()?.getAVFileInfo(asset.localIdentifier) {
                let size = avfileInfo.getVideoStreamDimension(0)
                let duration = avfileInfo.duration
                let flags = size.height >= size.width ? (size.width == 2160) : (size.height == 2160)
                return (flags, duration)
            }else {
                return (false, -1)
            }
        }else {
            return (false, -1)
        }
    }
    
    class func calculateTimelineSize(editMode:NvVideoEditAspectRatioMode,originAspectRatio:CGFloat) -> NvsSize {
        var size:NvsSize = NvsSize()
        let compileRes:Int32 = UserDefaults.standard.bool(forKey: "CompileResolution") == true ? 720 : 1080
        //如果根据第一素材创建的话，这块需要改
        if (editMode == .NvVideoEditAspectRatioMode_Free) {
            if originAspectRatio > 1 {
                var w = Int32(CGFloat(compileRes)*originAspectRatio)
                var h = Int32(compileRes)
                w = (w + 3) & ~3
                h = (h + 1) & ~1
                size.width = Int32(w)
                size.height = Int32(h)
            }else{
                var w = Int32(compileRes)
                var h = Int32(CGFloat(compileRes)/originAspectRatio)
                w = (w + 3) & ~3
                h = (h + 1) & ~1
                size.width = Int32(w)
                size.height = Int32(h)
            }
        } else if (editMode == .NvVideoEditAspectRatioMode_16v9) {
            size.height = compileRes;
            size.width = compileRes * 16 / 9
        } else if (editMode == .NvVideoEditAspectRatioMode_1v1) {
            size.height = compileRes;
            size.width = compileRes;
        } else if (editMode == .NvVideoEditAspectRatioMode_9v16) {
            size.width = compileRes;
            size.height = compileRes * 16 / 9
        } else if (editMode == .NvVideoEditAspectRatioMode_3v4) {
            size.width = compileRes;
            size.height = compileRes * 4 / 3
        } else if (editMode == .NvVideoEditAspectRatioMode_4v3) {
            size.width = compileRes * 4 / 3
            size.height = compileRes
        } else {
            size.width = 1280
            size.height = 720
        }
        return size
    }
    
    /// 计算接近比例
    /// - Parameter aspectRatio: 素材宽高比
    /// - Returns: timeline宽高比例模式
    class func findNearbyAspectRatio(aspectRatio: CGFloat) -> NvVideoEditAspectRatioMode {
        let array = [9.0/16.0,3.0/4.0,1,4.0/3.0,16.0/9.0]
        let diff = array.map { (ratio) -> Double in
            return fabs(ratio - Double(aspectRatio))
        }
        let min = diff.min()
        var i = 0
        for (index,value) in diff.enumerated() {
            if value == min {
                i = index
                break
            }
        }
        var editAspectRatioMode: NvVideoEditAspectRatioMode = .NvVideoEditAspectRatioMode_9v16
        switch i {
        case 0:
            editAspectRatioMode = .NvVideoEditAspectRatioMode_9v16
            break
        case 1:
            editAspectRatioMode = .NvVideoEditAspectRatioMode_3v4
            break
        case 2:
            editAspectRatioMode = .NvVideoEditAspectRatioMode_1v1
            break
        case 3:
            editAspectRatioMode = .NvVideoEditAspectRatioMode_4v3
            break
        case 4:
            editAspectRatioMode = .NvVideoEditAspectRatioMode_16v9
            break
        default:
            editAspectRatioMode = .NvVideoEditAspectRatioMode_9v16
            break
        }
        return editAspectRatioMode
    }
    class func getAspectRatioRawValue(for ratio: String) -> Int32 {
        switch ratio {
        case "16:9","16v9":
            return 1
        case "9:16","9v16":
            return 4
        case "1:1","1v1":
            return 2
        case "4:3","4v3":
            return 8
        case "3:4","3v4":
            return 16
        case "18:9","18v9":
            return 32
        case "9:18","9v18":
            return 64
        case "21:9","21v9":
            return 512
        case "9:21","9v21":
            return 1024
        default:
            return 1
        }
    }
    class func isBuiltinFilter(_ filterName : String?) -> Bool {
        if filterName == nil {
//            log.info("滤镜名字为空")
        }
        let context = NvsStreamingContext.sharedInstance()
        var array : Array<String> = context?.getAllBuiltinVideoFxNames() as! Array<String>
        array.append("Video Echo")
        array.append("Cartoon")
        for str : String in array {
            if filterName == nil {
                continue
            }
            if str == filterName {
                return true
            }
        }
        return false
    }
    
    class func uuidString() ->NSString {
        let uuid : CFUUID = CFUUIDCreate(kCFAllocatorDefault)
        let uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid)
        let uuidStr = NSString(string: uuidString!)
        return uuidStr        
    }
    
    class func timeToString(_ time: Int64, afterPoint: Int) -> String {
        let format = String.init(format: "%%.%df", afterPoint)
        return String.init(format: format, CGFloat(time) / CGFloat(Cropper_NV_TIME_BASE))
    }
    class func numberToString(_ num: Int, den: Int, afterPoint: Int) -> String {
        let format = String.init(format: "%%.%df", afterPoint)
        return String.init(format: format, CGFloat(num) / CGFloat(den))
    }
    
    class func convertTimecode(time: Int64) -> String {
        let sec = Int(time/Cropper_NV_TIME_BASE)
        let minutes = sec/60
        let hour = minutes/60
        if hour == 0 {
            return String(format: "%02.0f:%02.0f", round(Float(minutes).truncatingRemainder(dividingBy: 60)),round(Float(sec).truncatingRemainder(dividingBy: 60)))
        }else{
            return String(format: "%02.0f:%02.0f:%02.0f", Float(hour).truncatingRemainder(dividingBy: 60),Float(minutes).truncatingRemainder(dividingBy: 60),Float(sec).truncatingRemainder(dividingBy: 60))
        }
    }
    
    class func nv_fileType(ext: String) -> NvSwiftUtils.FileType {
        guard ext.count > 0 else { return .unknown }
        let videoExts: [String] = ["mp4","mov","flv","3gp","avi","wmv","mpg","m2v","ogg","ogv","webm","rmvb","rm"]
        let audioExts: [String] = ["m4a","mp3","aac","wav","wma","flac","oga"]
        let imageExts: [String] = ["jpg","jpe","jpeg","png","tif","tiff","tga","bmp","webp","wbmp","heif","heic","dng"]
        let textExts: [String] = ["json","text"]
        let suff = ext.lowercased()
        if videoExts.contains(suff) { return .video }
        if imageExts.contains(suff) { return .image }
        if audioExts.contains(suff) { return .audio }
        if textExts.contains(suff) { return .text }
        return .unknown
    }
    
    class func fetchFileMediaType(filePath: String) -> NvSwiftUtils.FileType {
        do {
            let url = URL.init(fileURLWithPath: filePath)
            let request = URLRequest.init(url: url)
            var response: URLResponse?
            try NSURLConnection.sendSynchronousRequest(request, returning: &response)
            if let mimiType = response?.mimeType {
                if mimiType.contains("text/") {
                    return .text
                }else if mimiType.contains("audio/") {
                    return .audio
                }else if mimiType.contains("video/") {
                    return .video
                }else if mimiType.contains("image/") {
                    return .image
                }else {
                    return .unknown
                }
            }else {
                return .unknown
            }
        } catch {
            return .unknown
        }
    }
    
    class func compileResolutionSetting() ->(Int) {
        let setting = UserDefaults.standard.object(forKey: "compileResolutionSetting") as? NSNumber
        if setting != nil {
            return setting!.intValue
        }
        return 720
    }
    
    class func dateConvertString(interval:TimeInterval, dateFormat:String) -> String {
        let date:Date = Date(timeIntervalSince1970: interval)
        let formatter = DateFormatter()
//        let timeZone = TimeZone.init(identifier: "UTC")
//        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let dateString = formatter.string(from: date)
        return dateString//dateString.components(separatedBy: " ").first!
    }
    
    class func compileBitrateSetting() ->(Int64) {
        let setting = UserDefaults.standard.object(forKey: "NvCompileBitrate") as? NSNumber
        if setting != nil {
            return setting!.int64Value
        }
        return 0
    }
    
    class func currentDateAndTime() ->(String) {
        let date = Date.init()
        let zone = NSTimeZone.system
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "YYYYMMddHHmmssSSS"
        dateFormatter.timeZone = zone
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    class func imageWithName(_ name :String) -> UIImage {
        if name.isEmpty {
            return UIImage()
        }
        let image = UIImage(named: name, in: Bundle(for: self.classForCoder()), compatibleWith: nil) ?? nil
        if image == nil {
            return UIImage()
        } else {
            return image ?? UIImage()
        }
    }
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage? {
        guard size.width != 0 && size.height != 0 else { return nil }
        let rect: CGRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    class func fontWithSize(name: String, size: CGFloat) -> UIFont {
//        var font = UIFont(name: name, size: size)
//        if (font == nil) {
//            font = UIFont.systemFont(ofSize: size)
//        }
        return UIFont.systemFont(ofSize: size)
    }
    
    class func fontWithSize(size: CGFloat) -> UIFont {
//        var font = UIFont(name: "PingFangSC-Regular", size: size)
//        if (font == nil) {
//            font = UIFont.systemFont(ofSize: size)
//        }
        return UIFont.systemFont(ofSize: size)
    }
    
    class func getColorWithIndex(_ index : Int) -> NSString {
        let array = captionColors()
        if index < array.count {
            return array[index]
        }
        let idx = Int(array.count % index)
        return array[idx-1]
    }
    
    class func getAllFilePath(_ dirPath: String) -> [String]? {
        var filePaths = [String]()
        
        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: dirPath)
            
            for fileName in array {
                var isDir: ObjCBool = true
                
                let fullPath = "\(dirPath)/\(fileName)"
                
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    if !isDir.boolValue {
                        filePaths.append(fullPath)
                    }
                }
            }
            
        } catch let error as NSError {
            
        }
        
        return filePaths;
    }
    
    class func captionColors() -> Array<NSString> {
        return ["#ffffffff", "#ff000000", "#ffd0021b",
        "#ff4169e1", "#ff05d109", "#ff02c9ff",
        "#ff9013fe", "#ff8b6508", "#ffff0080",
        "#ff02f78e", "#ff00ffff", "#ffffd709",
        "#ff4876ff", "#ff19ff2f", "#ffda70d6",
        "#ffff6347", "#ff5b45ae", "#ff8b1c62",
        "#ff8b7500", "#ff228b22", "#ffc0ff3e",
        "#ff00Bfff", "#ffababab", "#ff6495ed",
        "#ff0000E3", "#ffe066ff", "#fff08080"]
    }
    
    class func impactFeedback(){
        if #available(iOS 10.0, *) {
            let feedBack:UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedBack.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    class func nv_getTemplateFootagesColors() -> [UIColor] {
        let colorHexs: [String] = ["#FF0000","#FC2B55","#FC2BCC","#FC632B","#FCA42B","#ECFC2B","#0C811E","#2BFC83","#2BC4FC","#2BFCE4","#2B7BFC","#532BFC","#B42BFC"]
        var colors: [UIColor] = []
        for hex in colorHexs {
            if let color = UIColor.init(hex: hex) {
                colors.append(color)
            }
        }
        return colors
    }
}

//public typealias TitleClickHandler = (PageTitleView, Int) -> ()
typealias ColorRGB = (red: CGFloat, green: CGFloat, blue: CGFloat)

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    

    
    convenience init?(hex: String, alpha: CGFloat = 1.0) {

        guard hex.count >= 6 else {
            return nil
        }
        
        var hexString = hex.uppercased()
        
        if (hexString.hasPrefix("##") || hexString.hasPrefix("0x")) {

            hexString = (hexString as NSString).substring(from: 2)
        }
        
        if (hexString.hasPrefix("#")) {

            hexString = (hexString as NSString).substring(from: 1)
        }
        
        
        var range = NSRange(location: 0, length: 2)
        let rStr = (hexString as NSString).substring(with: range)
        range.location = 2
        let gStr = (hexString as NSString).substring(with: range)
        range.location = 4
        let bStr = (hexString as NSString).substring(with: range)
        

        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        Scanner(string: rStr).scanHexInt32(&r)
        Scanner(string: gStr).scanHexInt32(&g)
        Scanner(string: bStr).scanHexInt32(&b)
        
        self.init(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b), alpha: alpha)
    }
    
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (red * 255, green * 255, blue * 255)
    }
}


extension NvSwiftUtils {
    class func stringToCurvePoints(curveStr: String?) -> [[CGFloat]] {
        var points: [[CGFloat]] = []
        if let str = curveStr {
            points = parseCurveString(for: str)
        }
        return points
    }
    class func curvePointsToString(_ points:[[CGFloat]]) -> String {
        var str: String = ""
        for index in 0..<points.count {
            let item = points[index]
            if item.count == 2 {
                str += "("+CGFloatToString(item[0], afterPoint: 10)+","+CGFloatToString(item[1], afterPoint: 10)+")"
            }
        }
        return str
    }
    
    private class func parseCurveString(for str: String) -> [[CGFloat]] {
        let curStr = str.replacingOccurrences(of: "(", with: "", options: .literal, range: nil)
        let strArray = curStr.split(separator: ")")
        var points = [[CGFloat]]()
        for index in 0..<strArray.count where index%3 == 0  {
            let xyStrs = strArray[index].split(separator: ",")
            if xyStrs.count == 2 {
                points.append([StringToCGFloat(String(xyStrs[0])), StringToCGFloat(String(xyStrs[1]))])
            }
        }
        return points
    }
    class func StringToCGFloat(_ str: String) -> CGFloat {
        return CGFloat(Double(str) ?? 0.0)
    }
    class func CGFloatToString(_ number: CGFloat, afterPoint: Int) -> String {
        let format = String.init(format: "%%.%df", afterPoint)
        return String.init(format: format, number)
    }
}

extension UIColor{
    
    //根据字符串创建Color
    public class func nv_color(hexRGBA rgba : NSString) -> UIColor {
        let hexStr = rgba.substring(from: 1)
        var hexInt : UInt64 = 0
        let scanner = Scanner(string: hexStr)
        if scanner.scanHexInt64(&hexInt) {
            let divisor : CGFloat = 255.0
            let red = CGFloat((hexInt & 0xFF000000) >> 24) / divisor
            let green   = CGFloat((hexInt & 0x00FF0000) >> 16) / divisor
            let blue    = CGFloat((hexInt & 0x0000FF00) >>  8) / divisor
            let alpha   = CGFloat( hexInt & 0x000000FF       ) / divisor
            return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        return UIColor.red
    }
    
   public class func nv_color(hexARGB argb : NSString) -> UIColor {
        let hexStr = argb.substring(from: 1)
        var hexInt : UInt64 = 0
        let scanner = Scanner(string: hexStr)
        if scanner.scanHexInt64(&hexInt) {
            let divisor : CGFloat = 255.0
            let alpha = CGFloat((hexInt & 0xFF000000) >> 24) / divisor
            let red   = CGFloat((hexInt & 0x00FF0000) >> 16) / divisor
            let green  = CGFloat((hexInt & 0x0000FF00) >>  8) / divisor
            let blue  = CGFloat( hexInt & 0x000000FF       ) / divisor
            return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        return UIColor.red
    }
}


extension UILabel{
    class func nv_label(text: String?, fontSize: Float, textColor: UIColor?) -> UILabel {
        let label = UILabel()
        label.textColor = textColor
        label.textAlignment = .center
        label.text = text
        var font: UIFont?
//        if UIFont(name: "PingFangSC-Semibold", size: CGFloat(fontSize)) == nil {
//            font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
//        } else {
//            font = UIFont(name: "PingFangSC-Semibold", size: CGFloat(fontSize))
//        }
        font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        label.font = font
        return label
    }
}

extension UIButton{
    class func nv_button(title:String,textColor:UIColor?,fontSize:CGFloat,image:UIImage?) -> UIButton {
        let button:UIButton = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.setImage(image, for: .normal)
        button.titleLabel?.font = NvSwiftUtils.fontWithSize(size: fontSize)
        return button;
    }
}
//MARK: - String
extension String {
    /**
     * @brief 截取子字符串 index...endIndex
     * @param string 源字符串
     * @param index 开始截取的位置
     */
    static func nvs_substring(string: String, form index: Int) -> String {
        if string.count > index {
            let startIndex = string.index(string.startIndex, offsetBy: index)
            let subStr = string[startIndex..<string.endIndex]
            return String.init(subStr)
        }
        return String.init()
    }
    
    /**
     * @brief 截取子字符串 startIndex...index
     * @param string 源字符串
     * @param index 结束截取的位置
     */
    static func nvs_substring(string: String, to index: Int) -> String {
        if string.count > index {
            let endIndex = string.index(string.startIndex, offsetBy: index)
            let subStr = string[string.startIndex..<endIndex]
            return String.init(subStr)
        }
        return string
    }

    /**
     * @brief 截取子字符串
     * @param string 源字符串
     * @param ranges 截取的位置和长度
     */
    static func nvs_substring(string: String, range ranges: NSRange) -> String {
        if ranges.location >= 0 && string.count >= (ranges.location + ranges.length) {
            let startIndex = string.index(string.startIndex, offsetBy: ranges.location)
            let endIndex = string.index(string.startIndex, offsetBy: ranges.location + ranges.length)
            let subStr = string[startIndex..<endIndex]
            return String.init(subStr)
        }
        return String.init()
    }
}


