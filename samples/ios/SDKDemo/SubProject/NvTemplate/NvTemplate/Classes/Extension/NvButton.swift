//
//  NvButton.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit

extension UIButton {
    class func nv_button(title:String,textColor:UIColor?,fontSize:CGFloat,image:UIImage?) -> UIButton {
        let button:UIButton = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.setImage(image, for: .normal)
        button.titleLabel?.font = NvUtils.fontWithSize(size: fontSize)
        return button;
    }
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
       setBackgroundImage(imageWithColor(color), for: forState)
   }
    private func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    func nv_BtnClickHandler(clickHandler:(()->Void)?){
        let key : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "NvButtonBlockKey".hashValue)
        objc_setAssociatedObject(self, key, clickHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(itemClick(_:)), for:.touchUpInside)
    }
    
    @objc private func itemClick(_ button : UIButton){
        let key : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "NvButtonBlockKey".hashValue)
        objc_getAssociatedObject(self, key)
        if let nvBlock = objc_getAssociatedObject(self, key) as? (()->Void){
            nvBlock()
        }
    }
}
