//
//  NvTemplateModule.swift
//  NvTemplate
//
//  Created by rongwf on 2021/7/9.
//

import Foundation
public class NvTemplateModule: NvModule {
    
    public override func moduleCover() -> UIImage {
        let bundle = Bundle(for: NvTemplateModule.self)
        let image = UIImage(named: "Template", in: bundle, compatibleWith: nil) ?? nil
        if image == nil {
            return UIImage()
        } else {
            return image!
        }
    }
    
    public override func localString(_ translation_key: String, comment: String) -> String {
        let languageBundle = Bundle(for: NvTemplateModule.self)
        let text = languageBundle.localizedString(forKey: translation_key, value: "", table: "NvTemplate")
        return text ?? ""
    }

    public override func moduleTitle() -> String {
        return self.localString("Template", comment: "剪同款")
    }
    
    public override class func moduleIndex() -> Int32 {
        return 3;
    }
    
    public override func start(_ param: [AnyHashable : Any]) {
        let vc = NvTemplatePageViewController()
        self.navigationController.pushViewController(vc, animated: true)
    }
}
