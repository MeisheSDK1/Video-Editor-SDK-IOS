//
//  NvLocalProvider.swift
//  NvTemplateModule
//
//  Created by chengww on 2021/2/1.
//

import UIKit

class NvLocalProvider: NSObject {
    class func String(key: String, comment: String) -> String {
        let languageBundle = Bundle(for: NvTemplatePageViewController.self)
        return NvLocalStringFromTableInBundle(key: key, tableName: "NvTemplate", bundle: languageBundle, comment: comment)
    }
}

func NvLocalStringFromTableInBundle(key: String, tableName: String?,bundle: Bundle,comment: String?) -> String {
    var s = ""
    if let curr_lang = Locale.preferredLanguages.first{
        
        if  curr_lang.contains("en") ||
                curr_lang.contains("zh") ||
                curr_lang.contains("es") ||
                curr_lang.contains("ar") ||
                curr_lang.contains("de") ||
                curr_lang.contains("el") ||
                curr_lang.contains("fi") ||
                curr_lang.contains("fr") ||
                curr_lang.contains("hi") ||
                curr_lang.contains("id") ||
                curr_lang.contains("it") ||
                curr_lang.contains("ja") ||
                curr_lang.contains("ko") ||
                curr_lang.contains("nl") ||
                curr_lang.contains("pl") ||
                curr_lang.contains("pt") ||
                curr_lang.contains("ru") ||
                curr_lang.contains("tr") ||
                curr_lang.contains("he") ||
                curr_lang.contains("sv") {
            
            let locale = Locale(identifier: curr_lang)
            // 使用该Locale对象获取两字母的语言代码
            if let languageCode = locale.languageCode {
                
                var localeBundle: Bundle
                if languageCode.contains("zh") {
                    
                    localeBundle = Bundle.init(path: "\(bundle.bundlePath)\("/zh-Hans.lproj")") ?? Bundle.main
                }else{
                    
                    localeBundle = Bundle.init(path: "\(bundle.bundlePath)\("/")\(languageCode)\(".lproj")") ?? Bundle.main
                }
                s = NSLocalizedString(key, tableName: tableName, bundle: localeBundle, value: "", comment: comment ?? "")
                return s
            }
        }
    }
    let path = bundle.path(forResource: "en", ofType: "lproj")
    let languageBundle = Bundle(path: path!)
    s = languageBundle?.localizedString(forKey: key, value: "", table: nil) ?? key
    return s
}

