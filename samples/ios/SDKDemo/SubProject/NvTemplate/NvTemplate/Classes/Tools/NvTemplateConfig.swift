//
//  NvTemplateConfig.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit


let SCREENHEIGHT = UIScreen.main.bounds.height
let SCREENWIDTH = UIScreen.main.bounds.width
let SCREENSCALE = UIScreen.main.bounds.size.width / 375.0
let NV_TIME_BASE:Int64 = 1000000

let NV_STATUSBARHEIGHT = UIApplication.shared.statusBarFrame.size.height
let NV_NAV_BAR_HEIGHT:CGFloat = 44
var SafeAreaBottomHeight:CGFloat = NV_STATUSBARHEIGHT>20 ? 34 : 0

let NvDocumentsDir = NSHomeDirectory()+"/Documents"
let TEMPLATE_URL = NvDocumentsDir + "/Templates"
let TEMPLATE_Reverse_URL = NvDocumentsDir + "/ReverseTemplates"
let TEMPLATE_Compile_URL = NvDocumentsDir + "/CompileTemplates"
let TEMPLATE_CompileZip_URL = NvDocumentsDir + "/CompileTemplateZip"

let TrackBgColor = UIColor(red: 0.063, green: 0.063, blue: 0.063, alpha: 1.00)

enum AspectRatio : Int {
    case AspectRatio_Origin = 0
    case AspectRatio_16v9 = 1
    case AspectRatio_1v1 = 2
    case AspectRatio_9v16 = 4
    case AspectRatio_4v3 = 8
    case AspectRatio_3v4 = 16
    case AspectRatio_18v9 = 32
    case AspectRatio_9v18 = 64
    case AspectRatio_21v9 = 512
    case AspectRatio_9v21 = 1024
    case AspectRatio_All = 127
}

@objc enum NvVideoEditAspectRatioMode : Int {
    case originalOrFree = 0
    case NvEditMode9v16
    case NvEditMode3v4
    case NvEditMode1v1
    case NvEditMode4v3
    case NvEditMode16v9
    case NvEditMode18v9
    case NvEditMode9v18
    case NvEditMode21v9
    case NvEditMode9v21
    
    func toString() -> String {
        switch self {
        case .NvEditMode3v4:
            return "3v4"
        case .NvEditMode4v3:
            return "4v3"
        case .NvEditMode1v1:
            return "1v1"
        case .NvEditMode9v16:
            return "9v16"
        case .NvEditMode16v9:
            return "16v9"
        case .NvEditMode18v9:
            return "18v9"
        case .NvEditMode9v18:
            return "9v18"
        case .NvEditMode21v9:
            return "21v9"
        case .NvEditMode9v21:
            return "9v21"
        default:
            return ""
        }
    }
    
    func toIndex() -> Int32 {
        switch self {
        case .NvEditMode3v4:
            return 16
        case .NvEditMode4v3:
            return 8
        case .NvEditMode9v16:
            return 4
        case .NvEditMode1v1:
            return 2
        case .NvEditMode16v9:
            return 1
        case .NvEditMode18v9:
            return 32
        case .NvEditMode9v18:
            return 64
        case .NvEditMode21v9:
            return 512
        case .NvEditMode9v21:
            return 1024
        default:
            return 0
        }
    }
}
