//
//  ViewController.swift
//  NvTemplate
//
//  Created by chuyang009@163.com on 05/27/2021.
//  Copyright (c) 2021 chuyang009@163.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func click(_ sender: UIButton) {
        self.navigationController?.pushViewController(NvTemplateTestViewController(), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UINavigationBar {
    func setNavigationBarBg(alpha:CGFloat) {
        for view in self.subviews {
            view.alpha = 0
        }
    }
}
