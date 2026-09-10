//
//  NvToast
//  MYVideo
//
//  NvToast
//
//  Created by 美摄 on 2020/3/10.
//  Copyright © 2020 MeiShe. All rights reserved.
//

import UIKit

let main_width = UIScreen.main.bounds.size.width
let main_height = UIScreen.main.bounds.size.height

class NvToast: NSObject {
    ///默认显示消息-->center
    ///The default display message --&gt; center
    class func showToastAction(message : NSString) {
        self.showToast(message: message, aLocationStr: "center", aShowTime: 1.5)
    }
 
    ///显示消息
    ///Display message
    class func showToast(message : NSString?, aLocationStr : NSString?, aShowTime : TimeInterval) {
        if Thread.current.isMainThread {
            toastLabel = self.currentToastLabel()
            toastLabel?.removeFromSuperview()
            let window = UIApplication.shared.keyWindow
            window?.addSubview(toastLabel!)
            var width = self.stringText(aText: message, aFont: 16, isHeightFixed: true, fixedValue: 40)
            var height : CGFloat = 0
            if width > (main_width - 20) {
                width = main_width - 20
                height = self.stringText(aText: message, aFont: 16, isHeightFixed: false, fixedValue: width)
            }else{
                height = 40
            }
            var labFrame = CGRect.zero
            if aLocationStr != nil, aLocationStr == "top" {
                labFrame = CGRect.init(x: (main_width-width)/2, y: main_height*0.15, width: width, height: height)
            }else if aLocationStr != nil, aLocationStr == "bottom" {
                labFrame = CGRect.init(x: (main_width-width)/2, y: main_height*0.85, width: width, height: height)
            }else{
                //default-->center
                labFrame = CGRect.init(x: (main_width-width)/2, y: main_height*0.5, width: width, height: height)
            }
            toastLabel?.frame = labFrame
            toastLabel?.text = message as String?
            toastLabel?.alpha = 1
            UIView.animate(withDuration: aShowTime, animations: {
                toastLabel?.alpha = 0;
            })
        }else{
            DispatchQueue.main.async {
                self.showToast(message: message, aLocationStr: aLocationStr, aShowTime: aShowTime)
            }
            return
        }
    }
}

//MARK: init UI
extension NvToast {
    
    static var toastView : UIView?
    class func currentToastView() -> UIView {
        objc_sync_enter(self)
        if toastView == nil {
            toastView = UIView.init()
            toastView?.frame = CGRect(x: 0, y: 0, width: main_width, height: main_height)
            toastView?.alpha = 0
            
            let centerView = UIView()
            centerView.frame = CGRect.init(x: (main_width-70)/2, y: (main_height-70)/2, width: 70, height: 70)
            centerView.backgroundColor = UIColor.darkGray
            centerView.layer.masksToBounds = true
            centerView.layer.cornerRadius = 5.0
            toastView?.addSubview(centerView)
            
            let indicatorView = UIActivityIndicatorView.init(style: .whiteLarge)
            indicatorView.tag = 10
            indicatorView.hidesWhenStopped = true
            indicatorView.color = UIColor.white
            indicatorView.center = centerView.center
            toastView?.addSubview(indicatorView)
        }
        objc_sync_exit(self)
        return toastView!
    }
    
    static var toastLabel : UILabel?
    class func currentToastLabel() -> UILabel {
        objc_sync_enter(self)
        if toastLabel == nil {
            toastLabel = UILabel.init()
            toastLabel?.backgroundColor = UIColor.darkGray
            toastLabel?.font = NvUtils.fontWithSize(size: 16.0)
            toastLabel?.textColor = UIColor(white: 1, alpha: 0.8)
            toastLabel?.numberOfLines = 0;
            toastLabel?.textAlignment = .center
            toastLabel?.lineBreakMode = .byCharWrapping
            toastLabel?.layer.masksToBounds = true
            toastLabel?.layer.cornerRadius = 5.0
            toastLabel?.alpha = 0;
        }
        objc_sync_exit(self)
        return toastLabel!
    }
    
    static var toastViewLabel : UIView?
    class func currentToastViewLabel() -> UIView {
        objc_sync_enter(self)
        if toastViewLabel == nil {
            toastViewLabel = UIView.init()
            toastViewLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            toastViewLabel?.layer.masksToBounds = true
            toastViewLabel?.layer.cornerRadius = 5.0
            toastViewLabel?.alpha = 0
            
            let indicatorView = UIActivityIndicatorView.init(style: .whiteLarge)
            indicatorView.tag = 10
            indicatorView.hidesWhenStopped = true
            indicatorView.color = UIColor.white
            toastViewLabel?.addSubview(indicatorView)
            
            let aLabel = UILabel.init()
            aLabel.tag = 11
            aLabel.backgroundColor = UIColor.clear
            aLabel.font = NvUtils.fontWithSize(size: 16.0)
            aLabel.textColor = UIColor(white: 1, alpha: 0.8)
            aLabel.textAlignment = .center
            aLabel.lineBreakMode = .byCharWrapping
            aLabel.layer.masksToBounds = true
            aLabel.layer.cornerRadius = 5.0
            aLabel.numberOfLines = 0;
            toastViewLabel?.addSubview(aLabel)
        }
        objc_sync_exit(self)
        return toastViewLabel!
    }
}

//MARK: config
extension NvToast {
    
    ///根据字符串长度获取对应的宽度或者高度
    ///Gets the width or height of the string based on its length
    class func stringText(aText : NSString?, aFont : CGFloat, isHeightFixed : Bool, fixedValue : CGFloat) -> CGFloat {
        var size = CGSize.zero
        if isHeightFixed == true {
            size = CGSize.init(width: CGFloat(MAXFLOAT), height: fixedValue)
        }else{
            size = CGSize.init(width: fixedValue, height: CGFloat(MAXFLOAT))
        }
        ///返回计算出的size
        ///Returns the calculated size
        let resultSize = aText?.boundingRect(with: size, options: (NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)), attributes: [NSAttributedString.Key.font : NvUtils.fontWithSize(size: aFont)], context: nil).size
        if isHeightFixed == true {
            ///增加左右20间隔
            ///Add about 20 intervals
            return resultSize!.width + 20
        } else {
            ///增加上下20间隔
            ///Add 20 intervals up and down
            return resultSize!.height + 20
        }
    }
}


