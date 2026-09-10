//
//  NvTemplateCompileInfoModel.swift
//  MYVideo
//
//  Created by chengww on 2020/12/31.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit

class NvTemplateCompileInfoModel: Decodable {
    var cover: String = ""
    var minSdkVersion: String = ""
    var name: String = ""
    var supportedAspectRatio: String = ""
    var defaultAspectRatio: String = ""
    var translation: [NvTemplateCompileTransitionModel] = []
    var uuid: String = ""
    var version: Int = 0
    var innerAssetTotalCount: Int = 0
    var footageCount: Int = 0
    var duration: Int64 = 0
    var creator: String = ""
    var description: String = ""
    
    enum CodingKeys: String, CodingKey {
        case cover
        case minSdkVersion
        case name
        case supportedAspectRatio
        case defaultAspectRatio
        case translation
        case uuid
        case version
        case innerAssetTotalCount
        case footageCount
        case duration
        case creator
        case description
    }
    required init() {  }
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cover = try container.decodeIfPresent(String.self, forKey: .cover) ?? ""
        minSdkVersion = try container.decodeIfPresent(String.self, forKey: .minSdkVersion) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        supportedAspectRatio = try container.decodeIfPresent(String.self, forKey: .supportedAspectRatio) ?? ""
        defaultAspectRatio = try container.decodeIfPresent(String.self, forKey: .defaultAspectRatio) ?? ""
        translation = try container.decodeIfPresent(Array.self, forKey: .translation) ?? Array<NvTemplateCompileTransitionModel>()
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid) ?? ""
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 0
        innerAssetTotalCount = try container.decodeIfPresent(Int.self, forKey: .innerAssetTotalCount) ?? 0
        footageCount = try container.decodeIfPresent(Int.self, forKey: .footageCount) ?? 0
        duration = try container.decodeIfPresent(Int64.self, forKey: .duration) ?? 0
        creator = try container.decodeIfPresent(String.self, forKey: .creator) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    }
    
    
    func getSupportedAspectRatio() -> Int32 {
        var ratio: Int32 = 0
        let ratios: [String] = supportedAspectRatio.split(separator: "|").map(String.init)
        for str in ratios {
            let number = NvUtils.getAspectRatioRawValue(for: str)
            ratio += number
        }
        return ratio
    }
    
}

class NvTemplateCompileTransitionModel: Decodable {
    var originalText: String = ""
    var targetLanguage: String = ""
    var targetText: String = ""
    enum CodingKeys: String, CodingKey {
        case originalText
        case targetLanguage
        case targetText
    }
    required init() {  }
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        originalText = try container.decodeIfPresent(String.self, forKey: .originalText) ?? ""
        targetLanguage = try container.decodeIfPresent(String.self, forKey: .targetLanguage) ?? ""
        targetText = try container.decodeIfPresent(String.self, forKey: .targetText) ?? ""
    }
}
