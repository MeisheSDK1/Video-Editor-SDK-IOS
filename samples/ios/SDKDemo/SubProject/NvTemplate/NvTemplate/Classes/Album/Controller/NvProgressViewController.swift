//
//  NvProgressViewController.swift
//  swiftAlbum
//
//  Created by MS on 2019/12/17.
//  Copyright © 2019 MS. All rights reserved.
//

import UIKit

class NvProgressViewController: UIViewController {
    ///显示数据label
    ///Display data label
    private lazy var numLabel : UILabel = {
        let numLabel = UILabel(frame: CGRect(x: 0, y: self.circleView.frame.minY-15, width: SCREENWIDTH, height: 30*SCREENSCALE))
        numLabel.backgroundColor = .clear
        numLabel.textColor = UIColor(white: 1, alpha: 0.8)
        numLabel.center.x = self.view.center.x
        numLabel.font = NvUtils.fontWithSize(size: 15.0)
        numLabel.textAlignment = .center
        self.view.addSubview(numLabel)
        return numLabel
    }()
    
    private var _titleStr : String?
    private var circleView : NvCircleView = NvCircleView()
    private var cancelBtn : UIButton = UIButton(type: .custom)
    typealias CancelHandlerBlock = () ->Void
    private var cancelBlock : CancelHandlerBlock?
    
    public var progress : CGFloat = 0.0 {
        willSet{
            circleView.progress = newValue
        }
    }
    
    public var titleStr : String? {
        get{
            return _titleStr
        }
        set{
            _titleStr = newValue
            numLabel.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        circleView.frame = CGRect(x: 220, y: 100, width: 60, height: 60)
        view.addSubview(circleView)
        circleView.center = view.center
        cancelBtn.frame = CGRect(x: circleView.center.x-20, y: circleView.frame.maxY+15, width: 40, height: 40)
        cancelBtn.isHidden = false
        cancelBtn.setImage(NvUtils.imageWithName("NvCancelCompile"), for: .normal)
        view.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
    }
    

    public func setCancelBlock(_ block: @escaping () -> Void) {
        cancelBlock = block
    }
    
    @objc private func cancelBtnClicked() {
        if cancelBlock != nil {
            cancelBlock!()
        }
    }

}
