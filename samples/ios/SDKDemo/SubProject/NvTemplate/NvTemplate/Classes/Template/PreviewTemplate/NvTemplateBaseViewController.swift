//
//  NvTemplateBaseViewController.swift
//  NvTemplateModule
//
//  Created by chengww on 2021/2/1.
//

import UIKit

public class NvTemplateBaseViewController: UIViewController {
    /// 侧滑返回开关
    /// Sideslip return switch
    var enableSwipeBack: Bool = false
    
    /// 入口是否是从包装模板进入
    /// Whether the entry is from the packaging template
    var isPackagingTemplate: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        if self.navigationController?.viewControllers.count ?? 1 > 1 {
            let leftBarButtonItem = UIBarButtonItem.init(customView: leftItem)
            if #available(iOS 26.0, *) {
                leftBarButtonItem.hidesSharedBackground = true
            }
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
            leftItem.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        }
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    open func popEvent() {
        self.navigationController?.popViewController(animated: true)
    }
    
    public lazy var leftItem: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(NvUtils.imageWithName( "template_edit_back"), for: .normal)
        btn.setImage(NvUtils.imageWithName( "template_edit_back"), for: .highlighted)
        btn.contentHorizontalAlignment = .left
        btn.frame.size = CGSize.init(width: 40, height: 40)
        btn.adjustsImageWhenHighlighted = false
        return btn
    }()
}

extension NvTemplateBaseViewController: UIGestureRecognizerDelegate {
    @objc
    private func backAction() {
        popEvent()
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.enableSwipeBack
    }
}
