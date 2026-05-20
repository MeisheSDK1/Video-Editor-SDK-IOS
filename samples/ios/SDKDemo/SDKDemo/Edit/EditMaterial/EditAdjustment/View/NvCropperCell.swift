//
//  NvCropperCell.swift
//  MYVideo
//
//  Created by 刘东旭 on 2020/3/18.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit

class NvCropperCell: UICollectionViewCell {
    var titleLabel = UILabel()
    var imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(white: 1, alpha: 0.8)
        titleLabel.font = NvUtils.fontWithSize(size: 10)
        contentView.addSubview(titleLabel)
//        titleLabel.frame = CGRect(x: 0, y: frame.height-15*Cropper_SCREENSCALE, width: frame.width, height: 15*Cropper_SCREENSCALE)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(15*Cropper_SCREENSCALE)
        }
        contentView.addSubview(imageView)
//        imageView.frame = self.bounds
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(titleLabel.snp.top).offset(-1.5)
        }
        imageView.contentMode = .bottom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func renderCellWithItem(model: NvCropperRatio,seleted:Bool) {
        titleLabel.text = model.aspectRatio
        imageView.image = NvUtils.imageWithName(model.imageName)
        imageView.highlightedImage = NvUtils.imageWithName(model.seletedImageName)
        setSeleted(seleted:seleted)
    }
    
    func setSeleted(seleted:Bool){
        imageView.isHighlighted = seleted
        titleLabel.textColor = seleted ? .red : UIColor(white: 1, alpha: 0.8)
    }

}
