//
//  String+Arbitrary.swift
//  NvMeicam
//
//  Created by chengww on 2022/1/12.
//

import UIKit
import CommonCrypto

protocol Arbitrary {
    static func arbitrary() -> Self
}

extension Character: Arbitrary {
    static func arbitrary() -> Character {
        return Character(UnicodeScalar(Int.random(from: 65, to: 90))!)
    }
}

extension Int {
    static func random(from: Int, to: Int) -> Int {
        return from + (Int(arc4random()) % (to - from))
    }
}

extension String: Arbitrary {
    public var length: Int {
        get { self.count }
    }
    public var md5:String{
        get{
            let str = self.cString(using: String.Encoding.utf8)
            let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
            let digestLen = Int(CC_MD5_DIGEST_LENGTH)
            let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
            CC_MD5(str!, strLen, result)
            let hash = NSMutableString()
            for i in 0 ..< digestLen {
                hash.appendFormat("%02x", result[i])
            }
            result.deallocate()
            return String(format: hash as String)
        }
    }
    public static func arbitrary() -> String {
        let randomLength = 5
        let randomCharacters = tabulate(times: randomLength) { _ in
            Character.arbitrary()
        }
        return String(format: "%.f", Date().timeIntervalSince1970 * 1000) + String(randomCharacters)
    }
    
    public static func tabulate<A>(times: Int, transform: (Int) -> A) -> [A] {
        return (0..<times).map(transform)
    }
    
    
    /// 沙盒内相对路径
    /// Relative path in the sandbox
    /// - Returns: 沙盒内相对路径
    public func relativePath() -> String? {
        if hasPrefix(NSHomeDirectory()) {
            let nsString = self as NSString
            let str = nsString.substring(from: NSHomeDirectory().length+1) //+1: /
            return str
        }
        return nil
    }
    
    
    /// 沙盒内绝对路径，使用时注意 文件位置
    /// Absolute path in sandbox, pay attention to file location when using
    /// - Returns: 沙盒内绝对路径
    public func absolutePath() -> String {
        return NSHomeDirectory() + "/" + self
    }
    public func bundleRelativePath() -> String? {
        let nsString = self as NSString
        let mainBundlePath = Bundle.main.bundlePath
        if nsString.contains(mainBundlePath) {
            let r = nsString.range(of: mainBundlePath)
            return nsString.substring(from: r.location + r.length) as String
        }
        return nil
    }
    
    public func bundleAbsolutePath() -> String? {
        return Bundle.main.bundlePath + self
    }

    public func nv_stringSize(font: UIFont) -> CGSize {
        let resultSize = self.boundingRect(with: CGSize.init(width: 100, height: 30), options: (NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)), attributes: [NSAttributedString.Key.font : font], context: nil).size
        return resultSize
    }
    public func nv_substring(form index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subStr = self[startIndex..<self.endIndex]
            return String.init(subStr)
        }
        return String.init()
    }
    public func nv_substring(to index: Int) -> String {
        if self.count > index {
            let endIndex = self.index(self.startIndex, offsetBy: index)
            let subStr = self[self.startIndex..<endIndex]
            return String.init(subStr)
        }
        return self
    }
    public func toInt() -> Int {
        return Int(Double(self) ?? 0)
    }
    public func toInt32() -> Int32 {
        return Int32(Double(self) ?? 0)
    }
    public func toInt64() -> Int64 {
        return Int64(Double(self) ?? 0)
    }
    public func toCGFloat() -> CGFloat {
        var value: CGFloat = 0
        if let dValue = Double(self) {
            value = CGFloat(dValue)
        }
        return value
    }
    public func toFloat() -> Float {
        var value: Float = 0
        if let dValue = Double(self) {
            value = Float(dValue)
        }
        return value
    }
    public func toDouble() -> Double {
        var value: Double = 0
        if let dValue = Double(self) {
            value = dValue
        }
        return value
    }
}
