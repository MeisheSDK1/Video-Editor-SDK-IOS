//
//  NvAspectRatioView.swift
//  MYVideo
//
//  Created by chengww on 2020/12/31.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit

extension NvAspectRatioView {
    public enum SupportedRatio: Int {
        case k16v9  = 1
        case k1v1   = 2
        case k9v16  = 4
        case k4v3   = 8
        case k3v4   = 16
        case k18v9  = 32
        case k9v18  = 64
        case k21v9  = 512
        case k9v21  = 1024
    }
}

class NvAspectRatioView: UIView {
    public static func nv_fadeIn(supportedRatios: [String], defaultRatio: String, completeHandle: @escaping (_ style: Int) -> Void) {
        let view = NvAspectRatioView.init()
        supportedRatios.forEach { view.titles.append($0) }
        view.defaultTitle = defaultRatio
        /// 布局控件
        /// Layout control
        view.nv_layoutSubviews()
        /// 添加回调
        /// Add callback
        view.handle = completeHandle
        view.nv_showAspectView()
    }
    private init() {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var titles: [String] = []
    private var defaultTitle: String = ""
    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var closeButton: UIButton!
    private var rationBtns: [UIButton] = []
    private var handle: ((Int) -> Void)?
}

extension NvAspectRatioView {
    @objc private func nv_didTapRatio(sender: UIButton) {
        rationBtns.forEach { $0.isSelected = false }
        if let btn = rationBtns.first(where: { $0.tag == sender.tag }) {
            btn.isSelected = true
            self.nv_dismiss()
        }
    }
    
    private func nv_showAspectView() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        self.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    @objc private func nv_dismiss() {
        if handle != nil {
            if let btn = rationBtns.first(where: { $0.isSelected == true }) {
                let type = btn.tag
                handle!(type)
            }
        }
        self.subviews.forEach { $0.removeFromSuperview() }
        self.rationBtns.removeAll()
        self.removeFromSuperview()
    }
    
    private func nv_layoutSubviews() {
        let rows = ceilf(Float(self.titles.count) / 2.0)
        let height = CGFloat(45.0 + 8.0 + 30.0 * rows) * SCREENSCALE
        containerView = UIView.init(frame: CGRect.init(x: (frame.size.width - 268 * SCREENSCALE) * 0.5, y: (frame.size.height - height) * 0.5, width: 268 * SCREENSCALE, height: height))
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 5 * SCREENSCALE
        containerView.layer.masksToBounds = true
        self.addSubview(containerView)
        titleLabel = UILabel.init(frame: CGRect.init(x: 50 * SCREENSCALE, y: 0, width: containerView.frame.size.width - 100 * SCREENSCALE, height: 34 * SCREENSCALE))
        titleLabel.font = NvUtils.fontWithSize(size: 14 * SCREENSCALE)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.text = NvLocalProvider.String(key: "Select Aspect Ratio", comment: "选择制作比例")
        containerView.addSubview(titleLabel)
        closeButton = UIButton.init(frame: CGRect.init(x: containerView.frame.size.width - 37 * SCREENSCALE, y: 0, width: 37 * SCREENSCALE, height: 33 * SCREENSCALE))
        closeButton.setImage(NvUtils.imageWithName( "template_ration_close"), for: .normal)
        closeButton.setImage(NvUtils.imageWithName( "template_ration_close"), for: .highlighted)
        closeButton.addTarget(self, action: #selector(nv_dismiss), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        let count: Int = self.titles.count
        for index in 1...count {
            let col: Int = index % 2
            let row: Float = ceilf(Float(index) / 2.0)
            let startY: CGFloat = 45.0 * SCREENSCALE + CGFloat(row - 1) * 30 * SCREENSCALE
            let startX: CGFloat = col == 0 ? 138.0 * SCREENSCALE : 20.0 * SCREENSCALE
            let title = self.titles[index - 1]
            let btn = nv_createButton(for: title)
            btn.frame = CGRect.init(x: startX, y: startY, width: 109 * SCREENSCALE, height: 24 * SCREENSCALE)
            if title == defaultTitle {
                let defaultTiltle = NvLocalProvider.String(key: "Default", comment: "默认")
                btn.setTitle(title+"("+defaultTiltle+")", for: .normal)
                btn.isSelected = true
            }
            btn.tag = Int(NvUtils.getAspectRatioRawValue(for: title))
            btn.addTarget(self, action: #selector(nv_didTapRatio(sender:)), for: .touchUpInside)
            rationBtns.append(btn)
            containerView.addSubview(btn)
        }
    }
    
    private func nv_createButton(for title: String) -> UIButton {
        let btn = UIButton.init()
        btn.setBackgroundColor(UIColor.init(r: 239.0, g: 239.0, b: 239.0), forState: .normal)
        btn.setBackgroundColor(UIColor.init(r: 239.0, g: 239.0, b: 239.0), forState: .highlighted)
        btn.setBackgroundColor(UIColor.init(r: 252.0, g: 43.0, b: 85.0), forState: .selected)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.init(hex: "#1C1C1C"), for: .normal)
        btn.titleLabel?.font = NvUtils.fontWithSize(size: 12 * SCREENSCALE)
        btn.layer.cornerRadius = 2 * SCREENSCALE
        btn.layer.masksToBounds = true
        return btn
    }
}
