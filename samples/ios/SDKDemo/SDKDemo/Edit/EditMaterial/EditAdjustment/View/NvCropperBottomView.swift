//
//  NvCropperBottomView.swift
//  MYVideo
//
//  Created by 刘东旭 on 2020/3/18.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import SnapKit
///屏幕高度
///Screen height
let Cropper_SCREENWIDTH = UIScreen.main.bounds.width
///屏幕宽度
///Screen width
let Cropper_SCREENHEIGHT = UIScreen.main.bounds.height
let Cropper_SCREENSCALE = UIScreen.main.bounds.size.width / 375.0



let Cropper_NV_STATUSBARHEIGHT = UIApplication.shared.statusBarFrame.size.height
let Cropper_SafeAreaBottomHeight:CGFloat = Cropper_NV_STATUSBARHEIGHT>20 ? 34 : 0

let Cropper_NV_TIME_BASE:Int64 = 1000000

protocol NvCropperBottomViewDelegate: AnyObject {
    func cropperBottomView(cropperBottomView: NvCropperBottomView, playButtonClicked: UIButton)
    func cropperBottomView(cropperBottomView: NvCropperBottomView, valueChanged: Float)
}

class NvCropperBottomView: UIView {
    weak var delegate: NvCropperBottomViewDelegate?
    let playButton = UIButton()
    let leftLabel = UILabel()
    let slider = NvSlider()
    let rightLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        playButton.addTarget(self, action: #selector(playButtonClick), for: .touchUpInside)
        addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.width.equalTo(21*Cropper_SCREENSCALE)
        }
        leftLabel.text = "00:00"
        leftLabel.textAlignment = .center
        leftLabel.textColor = UIColor(white: 1, alpha: 0.8)
        leftLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right).offset(8*Cropper_SCREENSCALE)
            make.centerY.equalTo(self)
            make.height.equalTo(21*Cropper_SCREENSCALE)
        }
        rightLabel.text = "00:00"
        rightLabel.textAlignment = .center
        rightLabel.textColor = UIColor(white: 1, alpha: 0.8)
        rightLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-8*Cropper_SCREENSCALE)
            make.centerY.equalTo(self)
            make.height.equalTo(21*Cropper_SCREENSCALE)
        }
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.maximumTrackTintColor = UIColor(white: 1, alpha: 0.8)
        slider.minimumTrackTintColor = UIColor(white: 1, alpha: 0.8)
        slider.setThumbImage(UIImage(named: "NvSliderHandle"), for: .normal)
        slider.setThumbImage(UIImage(named: "NvSliderHandle"), for: .highlighted)
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.left.equalTo(leftLabel.snp.right).offset(7*Cropper_SCREENSCALE)
            make.right.equalTo(rightLabel.snp.left).offset(-7*Cropper_SCREENSCALE)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func playButtonClick() {
        delegate?.cropperBottomView(cropperBottomView: self, playButtonClicked: playButton)
    }

    @objc func valueChanged() {
        delegate?.cropperBottomView(cropperBottomView: self, valueChanged: slider.value)
    }
    
}
