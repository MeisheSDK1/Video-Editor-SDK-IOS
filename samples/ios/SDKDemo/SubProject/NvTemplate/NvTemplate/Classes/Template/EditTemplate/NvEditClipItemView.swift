//
//  NvEditClipItemView.swift
//  MYVideo
//
//  Created by ms on 2020/11/9.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
enum NvTemplateEditClip : Int {
    case Replace = 0
    case Tailor
    case Volumn
}

protocol NvEditClipItemViewDelegate : NSObjectProtocol{
    func selectedEditItem(item:NvTemplateEditClip)
}

class NvEditClipItemView: UIView {
    weak var delegate: NvEditClipItemViewDelegate?
    private var itemView: UIView!
    
    public var replaceBtn: NvAligmentButton!
    public var tailorBtn: NvAligmentButton!
    public var volumnBtn: NvAligmentButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(bViewClicked))
        self.addGestureRecognizer(tap)
        itemView = UIView.init(frame: CGRect.init(x: 0, y: SCREENHEIGHT - NV_NAV_BAR_HEIGHT - NV_STATUSBARHEIGHT - SafeAreaBottomHeight - 120, width: 110*SCREENSCALE, height: 50 * SCREENSCALE))
        itemView.center.x = self.center.x
        itemView.backgroundColor = .white
        itemView.layer.cornerRadius = 4
        itemView.layer.masksToBounds = true
        itemView.layer.shadowColor = UIColor.init(hex: "#000000")?.cgColor
        itemView.layer.shadowOffset=CGSize(width:0, height:1)
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
        
        self.addSubview(itemView)
        
        replaceBtn = NvAligmentButton.init(frame: CGRect.init(x: 5*SCREENSCALE, y: 0, width: 50 * SCREENSCALE, height: 50 * SCREENSCALE), style: .top, space: 5 * SCREENSCALE)
        replaceBtn.tag = 0;
        replaceBtn.setTitle(NvLocalProvider.String(key: "Replace", comment: "替换"), for: .normal)
        replaceBtn.setTitleColor(UIColor.init(hex: "#101010"), for: .normal)
        replaceBtn.setTitleColor(UIColor.init(hex: "#101010"), for: .selected)
        replaceBtn.setImage(NvUtils.imageWithName( "template_replace"), for: .normal)
        replaceBtn.setImage(NvUtils.imageWithName( "template_replace"), for: .highlighted)
        replaceBtn.titleLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        replaceBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        itemView.addSubview(replaceBtn)
        
        tailorBtn = NvAligmentButton.init(frame: CGRect.init(x: replaceBtn.frame.maxX , y: 0, width: 50 * SCREENSCALE, height: 50 * SCREENSCALE), style: .top, space: 5 * SCREENSCALE)
        tailorBtn.setTitle(NvLocalProvider.String(key: "Cropp", comment: "裁剪"), for: .normal)
        tailorBtn.tag = 1;
        tailorBtn.setTitleColor(UIColor.init(hex: "#101010"), for: .normal)
        tailorBtn.setTitleColor(UIColor.init(hex: "#101010"), for: .selected)
        tailorBtn.setImage(NvUtils.imageWithName( "template_tailor"), for: .normal)
        tailorBtn.setImage(NvUtils.imageWithName( "template_tailor"), for: .highlighted)
        tailorBtn.titleLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        tailorBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        itemView.addSubview(tailorBtn)

        volumnBtn = NvAligmentButton.init(frame: CGRect.init(x:tailorBtn.frame.maxX, y: 0, width: 50 * SCREENSCALE, height: 50 * SCREENSCALE), style: .top, space: 5 * SCREENSCALE)
        volumnBtn.tag = 2;
        volumnBtn.setTitle(NvLocalProvider.String(key: "Volume", comment: "音量"), for: .normal)
        volumnBtn.setTitleColor(UIColor.init(hex: "#101010"), for: .normal)
        volumnBtn.setTitleColor(UIColor.init(hex: "#101010"), for: .selected)
        volumnBtn.setImage(NvUtils.imageWithName( "cut_the_same_volumn"), for: .normal)
        volumnBtn.setImage(NvUtils.imageWithName( "cut_the_same_volumn"), for: .highlighted)
        volumnBtn.titleLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        volumnBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
    }
    
    @objc func bViewClicked(tap:UITapGestureRecognizer){
        let point:CGPoint = tap.location(in: itemView)
        if point.x < 0 || point.y > itemView.frame.size.width || point.y < 0 || point.y > itemView.frame.size.height  {
            dismiss()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func btnClick(sender: UIButton) {
        delegate?.selectedEditItem(item: NvTemplateEditClip.init(rawValue: sender.tag)!)
    }
    func show()  {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func dismiss()  {
        self.removeFromSuperview()
    }
}
