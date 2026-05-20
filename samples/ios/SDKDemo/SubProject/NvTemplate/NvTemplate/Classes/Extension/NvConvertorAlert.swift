//
//  NvConvertorAlert.swift
//  MYVideo
//
//  Created by chengww on 2021/1/20.
//  Copyright © 2021 MEISHE. All rights reserved.
//

import UIKit
import Photos

struct NvConvertorAlert {
    public static func nv_fadeIn(for dataSource: [NvAlbumTemplateItem], size: CGSize, completeHandle: @escaping (_ isSuccess: Bool) -> Void) {
        let aView = NvConvertorAlertView.init(frame: UIScreen.main.bounds, dataSource: dataSource)
        aView.itemSize = size
        aView.handle = completeHandle
        aView.nv_showAlert()
        aView.nv_layoutSubviews()
        aView.nv_startReverse()
    }
}

class NvConvertorAlertView: UIView {
    fileprivate var handle: ((Bool) -> Void)?
    fileprivate var itemSize: CGSize = .zero
    init(frame: CGRect, dataSource: [NvAlbumTemplateItem]) {
        super.init(frame: frame)
        self.provider = NvConvertorProvider.init(for: dataSource)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 视频转换工具 倒放转码
    /// Video conversion tool inverted transcoding
    private var source: [NvAlbumTemplateItem] = []
    private var provider: NvConvertorProvider!
    
    private lazy var containerView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(r: 32, g: 32, b: 41)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.text = "正在倒放"
        label.textColor = UIColor.white
        label.font = NvUtils.fontWithSize(size: 10)
        label.textAlignment = .center
        return label
    }()
    private lazy var progressView: NvProgressView = {
        var option = NvProgressView.Options.init()
        option.progressColor = UIColor.init(r: 252.0, g: 43.0, b: 85.0)
        option.progressTrackColor = UIColor.init(r: 54.0, g: 54.0, b: 54.0)
        option.backgroundColor = UIColor.init(r: 32, g: 32, b: 41)
        option.progressWidth = 5 * SCREENSCALE
        let view = NvProgressView.init(for: option)
        return view
    }()
    private lazy var cancelButton: UIButton = {
        let btn = UIButton.init()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.init(r: 58, g: 60, b: 73)
        btn.titleLabel?.font = NvUtils.fontWithSize(size: 10)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        return btn
    }()
}

extension NvConvertorAlertView{
    @objc func nv_didTapCancelReverse() {
        self.provider.cancel()
    }
    public func nv_startReverse() {
        self.provider.start()
        self.provider.convertorProcess = {
            self.progressView.percent = CGFloat($0)
        }
        self.provider.convertorCallback = { (state) in
            if state == .success {
                self.nv_dismiss(flags: true)
            }else {
                self.nv_dismiss(flags: false)
            }
        }
    }
    
    public func nv_showAlert() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        self.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    public func nv_dismiss(flags: Bool) {
        if handle != nil {
            handle!(flags)
        }
        self.subviews.forEach { $0.removeFromSuperview() }
        self.removeFromSuperview()
    }
    
    public func nv_layoutSubviews() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(progressView)
        containerView.addSubview(cancelButton)
        containerView.frame = CGRect.init(x: (self.frame.size.width - itemSize.width) * 0.5, y: (self.frame.size.height - itemSize.height) * 0.5, width: itemSize.width, height: itemSize.height)
        titleLabel.frame = CGRect.init(x: 10, y: 10, width: itemSize.width - 20, height: 30)
        progressView.frame = CGRect.init(x: (containerView.frame.size.width - 60) * 0.5, y: 50, width: 60, height: 60)
        cancelButton.frame = CGRect.init(x: (containerView.frame.width - 80) * 0.5, y: progressView.frame.maxY + 15, width: 80, height: 25)
        cancelButton.addTarget(self, action: #selector(nv_didTapCancelReverse), for: .touchUpInside)
    }
}
