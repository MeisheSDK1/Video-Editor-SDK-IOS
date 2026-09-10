//
//  NvUtils.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit
import AudioToolbox
import NvStreamingSdkCore

func editAspectRatioModeToAssetAspectRatio(editAspectRatioMode:NvVideoEditAspectRatioMode,originAspectRatio:CGFloat) -> AspectRatio {
    switch editAspectRatioMode {
    case .originalOrFree:
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
    case .NvEditMode9v16:
        return AspectRatio.AspectRatio_9v16
    case .NvEditMode3v4:
        return AspectRatio.AspectRatio_3v4
    case .NvEditMode1v1:
        return AspectRatio.AspectRatio_1v1
    case .NvEditMode4v3:
        return AspectRatio.AspectRatio_4v3
    case .NvEditMode16v9:
        return AspectRatio.AspectRatio_16v9
    case .NvEditMode18v9:
        return AspectRatio.AspectRatio_18v9
    case .NvEditMode9v18:
        return AspectRatio.AspectRatio_9v18
    case .NvEditMode21v9:
        return AspectRatio.AspectRatio_21v9
    case .NvEditMode9v21:
        return AspectRatio.AspectRatio_9v21
    }
}

extension NvUtils {
    public enum FileType {
        case video
        case audio
        case image
        case text
        case unknown
    }
}

class NvUtils: NSObject {
    /// 计算接近比例
    /// Computed approach ratio
    /// - Parameter aspectRatio: 素材宽高比
    /// Material aspect ratio
    /// - Returns: timeline宽高比例模式
    /// timeline Width-to-scale mode
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
        var editAspectRatioMode: NvVideoEditAspectRatioMode = .NvEditMode9v16
        switch i {
        case 0:
            editAspectRatioMode = .NvEditMode9v16
            break
        case 1:
            editAspectRatioMode = .NvEditMode3v4
            break
        case 2:
            editAspectRatioMode = .NvEditMode1v1
            break
        case 3:
            editAspectRatioMode = .NvEditMode4v3
            break
        case 4:
            editAspectRatioMode = .NvEditMode16v9
            break
        default:
            editAspectRatioMode = .NvEditMode9v16
            break
        }
        return editAspectRatioMode
    }
    
    class func calculateTimelineSize(aspectRatio: Int) -> CGSize {
        let editMode = self.getEditAspectRatioMode(for: aspectRatio)
        var size = CGSize.init(width: 0, height: 0)
        let compileRes:CGFloat = 1080.0
        if (editMode == .NvEditMode16v9) {
            size.height = CGFloat(compileRes);
            size.width = CGFloat(compileRes * 16 / 9);
        } else if (editMode == .NvEditMode1v1) {
            size.height = CGFloat(compileRes);
            size.width = CGFloat(compileRes);
        } else if (editMode == .NvEditMode9v16) {
            size.width = CGFloat(compileRes);
            size.height = CGFloat(compileRes * 16 / 9);
        } else if (editMode == .NvEditMode3v4) {
            size.width = CGFloat(compileRes);
            size.height = CGFloat(compileRes * 4 / 3);
        } else if (editMode == .NvEditMode4v3) {
            size.width = CGFloat(compileRes * 4 / 3);
            size.height = CGFloat(compileRes);
        }else if (editMode == .NvEditMode21v9){
            size.height = compileRes;
            size.width = compileRes * 21.0 / 9.0
        }else if (editMode == .NvEditMode9v21) {
            size.width = compileRes
            size.height = compileRes * 21 / 9
        } else if (editMode == .NvEditMode18v9) {
            size.height = compileRes;
            size.width = compileRes * 18 / 9;
        } else if (editMode == .NvEditMode9v18) {
            size.width = compileRes;
            size.height = compileRes * 18 / 9;
        }else{
            size.width = 720;
            size.height = 1280;
        }
        
        return size
    }
    /*
    + (NvsSize)calculateTimelineSize:(NvEditMode)editMode {
        int compileRes = 1080;
        NvsSize size;
        if (editMode == NvEditMode16v9) {
            size.height = compileRes;
            size.width = compileRes * 16 / 9;
        } else if (editMode == NvEditMode1v1) {
            size.height = compileRes;
            size.width = compileRes;
        } else if (editMode == NvEditMode9v16) {
            size.width = compileRes;
            size.height = compileRes * 16 / 9;
        } else if (editMode == NvEditMode3v4) {
            size.width = compileRes;
            size.height = compileRes * 4 / 3;
        } else if (editMode == NvEditMode4v3) {
            size.width = compileRes * 4 / 3;
            size.height = compileRes;
        } else if (editMode == NvEditMode21v9){
            size.height = compileRes;
            size.width = compileRes * 21 / 9;
            if ([NvUtils isUnSupport4KEdit] && size.width > UnSupport4kLength) {
                size.width = UnSupport4kLength;
                int h = UnSupport4kLength * 9 / 21;
                size.height = (h + 1) & ~1;
            }
        } else if (editMode == NvEditMode9v21) {
            size.width = compileRes;
            size.height = compileRes * 21 / 9;
            if ([NvUtils isUnSupport4KEdit] && size.height > UnSupport4kLength) {
                size.height = UnSupport4kLength;
                int w = UnSupport4kLength * 9 / 21;
                size.width =  (w + 3) & ~3;
            }
        } else if (editMode == NvEditMode18v9) {
            size.height = compileRes;
            size.width = compileRes * 18 / 9;
            if ([NvUtils isUnSupport4KEdit] && size.width > UnSupport4kLength) {
                size.width = UnSupport4kLength;
                int h = UnSupport4kLength * 9 / 18;
                size.height = (h + 1) & ~1;
            }
        } else if (editMode == NvEditMode9v18) {
            size.width = compileRes;
            size.height = compileRes * 18 / 9;
            if ([NvUtils isUnSupport4KEdit] && size.height > UnSupport4kLength) {
                size.height = UnSupport4kLength;
                int w = UnSupport4kLength * 9 / 18;
                size.width =  (w + 3) & ~3;
            }
        }else if (editMode == NvEditMode7v6) {
            size.height = compileRes;
            size.width = compileRes * 7 / 6;
        } else if (editMode == NvEditMode6v7) {
            size.width = compileRes;
            size.height = compileRes * 7 / 6;
        }else {
            size.width = 1280;
            size.height = 720;
        }
        return size;
    }
*/
    
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
    
    class func getEditAspectRatioMode(for ratio: Int) -> NvVideoEditAspectRatioMode {
        var editAspectRatioMode: NvVideoEditAspectRatioMode = .NvEditMode9v16
        switch ratio {
        case 0:
            editAspectRatioMode = .NvEditMode16v9
            break
        case 1:
            editAspectRatioMode = .NvEditMode16v9
            break
        case 4:
            editAspectRatioMode = .NvEditMode9v16
            break
        case 2:
            editAspectRatioMode = .NvEditMode1v1
            break
        case 8:
            editAspectRatioMode = .NvEditMode4v3
            break
        case 16:
            editAspectRatioMode = .NvEditMode3v4
            break
        case 32:
            editAspectRatioMode = .NvEditMode18v9
            break
        case 64:
            editAspectRatioMode = .NvEditMode9v18
            break
        case 512:
            editAspectRatioMode = .NvEditMode21v9
            break
        case 1024:
            editAspectRatioMode = .NvEditMode9v21
            break
        default:
            editAspectRatioMode = .NvEditMode16v9
            break
        }
        return editAspectRatioMode
    }
    
    class func isZh() -> Bool {
        if let curr_lang = Locale.preferredLanguages.first {
            return curr_lang.contains("zh")
        }
        return true
    }
    class func isBuiltinFilter(_ filterName : String?) -> Bool {
        if filterName == nil {
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
        return String.init(format: format, CGFloat(time) / CGFloat(NV_TIME_BASE))
    }
    class func numberToString(_ num: Int, den: Int, afterPoint: Int) -> String {
        let format = String.init(format: "%%.%df", afterPoint)
        return String.init(format: format, CGFloat(num) / CGFloat(den))
    }
    
    class func convertTimecode(time: Int64) -> String {
        let sec = Int(time/NV_TIME_BASE)
        let minutes = sec/60
        let hour = minutes/60
        if hour == 0 {
            return String(format: "%02.0f:%02.0f", round(Float(minutes).truncatingRemainder(dividingBy: 60)),round(Float(sec).truncatingRemainder(dividingBy: 60)))
        }else{
            return String(format: "%02.0f:%02.0f:%02.0f", Float(hour).truncatingRemainder(dividingBy: 60),Float(minutes).truncatingRemainder(dividingBy: 60),Float(sec).truncatingRemainder(dividingBy: 60))
        }
    }
    
    class func getSdkVersion() -> String {
        var majorVersion: Int32 = 0
        var minorVersion: Int32 = 0
        var revisionNumber: Int32 = 0
        NvsStreamingContext.getSdkVersion(&majorVersion, minorVersion: &minorVersion, revisionNumber: &revisionNumber)
        return "\(majorVersion).\(minorVersion).\(revisionNumber)"
    }
    
    class func nv_fileType(ext: String) -> NvUtils.FileType {
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
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let dateString = formatter.string(from: date)
        return dateString
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
        return UIFont.systemFont(ofSize: size)
    }
    
    class func fontWithSize(size: CGFloat) -> UIFont {
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
            
        } catch  {  }
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

extension NvUtils {
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








