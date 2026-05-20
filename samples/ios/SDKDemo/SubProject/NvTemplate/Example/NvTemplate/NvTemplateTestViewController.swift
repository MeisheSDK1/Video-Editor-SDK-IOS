//
//  NvTemplateTestViewController.swift
//  NvTemplate_Example
//
//  Created by chengww on 2022/1/28.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class NvTemplateTestViewController: NvTemplatePageViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setNavigationBarBg(alpha: 0)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.clear]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func nv_configData() {
        super.nv_configData()
        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        let itemSize = UIScreen.main.bounds.size
        titleView.frame = CGRect.init(x: 0, y: statusBarH + 44.0, width: itemSize.width, height: 34 * SCREENSCALE)
        contentView.frame = CGRect.init(x: 0, y: titleView.frame.maxY, width: itemSize.width, height: itemSize.height - 34 * SCREENSCALE)
    }

    override func requestCategoryData() {
        let lang = (Locale.preferredLanguages.first?.contains("zh") ?? true) ? "zh_CN" : "en"
        let params: [String: String] = ["type":"19","lang":lang]
        NvHttpRequest.sharedInstance.get(urlString: "https://vsapi.meishesdk.com/api/my/template/listCategories", param: params, success: { (response, _) in
            if let code = response["code"] as? Int, code == 1 {
                if let dict = response["data"] as? [String : Any] {
                    let items = NvHandyJSON.mapToModel(map: dict, modelType: NvTemplateCategories.self)
                    
                    /// 临时添加
                    let testItem = NvTemplateCategoryModel.init()
                    testItem.displayName = "测试"
                    testItem.category = 9898
                    items?.categories.append(testItem)
                    
                    items?.categories.forEach({
                        self.titles.append($0.displayName)
                        let vc = NvTemplateViewController.init(with: "\($0.category)")
                        vc.delegate = self
                        self.childs.append(vc)
                    })
                    self.nv_configData()
                }
            }
        }, failure: { (_) in })
    }
}
