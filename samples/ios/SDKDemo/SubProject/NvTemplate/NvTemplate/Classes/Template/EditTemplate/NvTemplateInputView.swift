//
//  NvTemplateInputView.swift
//  MYVideo
//
//  Created by ms on 2020/11/9.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit

protocol NvTemplateInputViewDelegate : NSObjectProtocol{
    func editTextview(word:String)
}

class NvTemplateInputView: UIView {
    weak var delegate: NvTemplateInputViewDelegate?
    let textView = UITextView()
    /// 统一返回
    /// Uniform return
    var backButton = UIButton()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1)
        textView.backgroundColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
        textView.textColor = UIColor(white: 1, alpha: 0.8)
        textView.font = NvUtils.fontWithSize(size: 14)
        textView.layer.cornerRadius = 2.5 * SCREENSCALE
        textView.layer.masksToBounds = true
        textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(inputTextChanged), name: UITextView.textDidChangeNotification, object: textView)
        addSubview(textView)
        textView.delegate = self
        
        backButton.setTitle(NvLocalProvider.String(key: "Complete", comment: "完成"), for: .normal)
        backButton.titleLabel?.font = NvUtils.fontWithSize(size: 13)
        backButton.titleLabel?.numberOfLines = 2
        backButton.titleLabel?.textColor = .white
        backButton.backgroundColor = UIColor.init(hex: "#FF365E")
        backButton.layer.cornerRadius = 3
        backButton.layer.masksToBounds = true
        addSubview(backButton)
        
        ///键盘通知
        ///Keyboard notification
        ///监听键盘出现
        ///Monitor keyboard appears
        weak var weakSelf = self
        var frame:CGRect = self.frame
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { (notification) in
            let info = notification.userInfo
            ///键盘动画时间
            ///Keyboard animation time
            let duration = (info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
            ///键盘坐标尺寸
            ///Keyboard coordinate dimension
            let keyBoderRect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            ///获取键盘被遮盖部分的高度
            ///Gets the height of the covered part of the keyboard
            ///获取键盘高度
            ///Get keyboard height
            let keyBoderHeight = keyBoderRect.size.height
            frame.origin.y =  SCREENHEIGHT - keyBoderHeight - 60 - NV_STATUSBARHEIGHT - NV_NAV_BAR_HEIGHT
            UIView.animate(withDuration: duration, animations: {
                weakSelf?.frame = frame
            }, completion: nil)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { (notification) in
        
        let info = notification.userInfo
            ///键盘动画时间
            //////Keyboard animation time
        let duration = (info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
            frame.origin.y = SCREENHEIGHT
            UIView.animate(withDuration: duration, animations: {
                weakSelf?.frame = frame
                
            }) { (completion) in
                weakSelf?.removeFromSuperview()
            }
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = CGRect(x: 10*SCREENSCALE, y: 10*SCREENSCALE, width: frame.width - 90*SCREENSCALE, height: 35*SCREENSCALE)
        backButton.frame = CGRect(x: frame.width - 70*SCREENSCALE, y: 15*SCREENSCALE, width: 60*SCREENSCALE, height: 35*SCREENSCALE)
        backButton.center.y = textView.center.y
        backButton.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
    }
    
    @objc func inputTextChanged() {
        contentSizeToFit(textView: textView)
        delegate?.editTextview(word: textView.text)
    }
    
    func inputEndEditing(text: String) {
        
    }
    
    @objc
    private func btnClick(sender: UIButton) {
        textView.resignFirstResponder()
    }
    
    private func contentSizeToFit(textView: UITextView) {
        if textView.text.count > 0 {
            let contentSize = textView.contentSize
            let offsetY = (textView.frame.size.height - contentSize.height) * 0.5
            textView.contentInset = UIEdgeInsets.init(top: offsetY, left: 0, bottom: 0, right: 0)
        }
    }
}

extension NvTemplateInputView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        inputEndEditing(text: textView.text)
    }
}
