//
//  NvColor.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit

extension UIColor{
    
    ///根据字符串创建Color
    ///Create a Color from the string
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
