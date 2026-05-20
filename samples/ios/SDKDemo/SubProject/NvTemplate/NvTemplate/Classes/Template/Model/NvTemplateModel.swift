//
//  NvTemplateModel.swift
//  MYVideo
//
//  Created by chengww on 2020/11/3.
//  Copyright © 2020 MEISHE. All rights reserved.
//
import Photos
import UIKit


enum NvDownloadStatus: Int, Decodable {
    case noDownload  = 0
    case finish      = 1
    case error       = 2
    case update      = 3
    case downloading = 4
    case unSupport   = 5
    case unknown     = 6
}

class NvAssetModel: Decodable {
    var type: Int = 0
    var category: Int = 0
    var typeInfo: NvAssetTypeInfo = NvAssetTypeInfo.init()
    var categoryInfo: NvAssetCategoryInfo = NvAssetCategoryInfo.init()
    var kindInfo: NvAssetKindInfo = NvAssetKindInfo.init()
    var id: String = ""
    var version: Int = 0
    var minAppVersion: String = ""
    var displayName: String = ""
    var displayNamezhCN: String = ""
    var customDisplayName: String = ""
    var description: String = ""
    var descriptionZhCn: String = ""
    var coverUrl: String = ""
    var previewVideoUrl: String = ""
    var packageRelativePath: String = ""
    var packageUrl: String = ""
    var infoUrl: String = ""
    var sizeLevel: Int64 = 0
    var packageSize: Int64 = 0
    var ratioFlag: Int32 = 0
    var supportedAspectRatio: Int = 0
    var defaultAspectRatio: Int = 0
    var templateTotalDuration: Int64 = 0
    var duration: Int64 = 0
    var shotsNumber: Int = 0
    var canReplaceShotsNumber: Int = 0
    var costQuota: Int32 = 0
    var rate: Int32 = 0
    var userInfo: NvTemplateUserInfo = NvTemplateUserInfo.init()
    var queryInteractiveResultDto: NvTemplateInteractive = NvTemplateInteractive.init()
    var zipUrl: String = ""
    /// 带账户标记是否显示已购
    /// Whether to show purchased with account mark
    var authed: Bool = false
    ///标记图片的高度
    ///Mark the height of the picture
    var itemHeight: CGFloat = 0
    /// 标记是否是生成的模版
    /// Mark whether the template is generated
    var isCompiled: Bool = false
    var downloadStatus: NvDownloadStatus = .unknown
    enum CodingKeys: String, CodingKey {
        case type
        case kindInfo
        case zipUrl
        case costQuota
        case kind
        case infoUrl
        case supportedAspectRatio
        case packageSize
        case displayNamezhCN
        case description
        case descriptionZhCn
        case packageUrl
        case coverUrl
        case previewVideoUrl
        case minAppVersion
        case queryInteractiveResultDto
        case category
        case duration
        case displayName
        case typeInfo
        case ratioFlag
        case id
        case defaultAspectRatio
        case sizeLevel
        case categoryInfo
        case version
        case shotsNumber
    }
    required init() {}
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(Int.self, forKey: .type) ?? 0
        category = try container.decodeIfPresent(Int.self, forKey: .category) ?? 0
        typeInfo = try container.decodeIfPresent(NvAssetTypeInfo.self, forKey: .typeInfo) ?? NvAssetTypeInfo()
        categoryInfo = try container.decodeIfPresent(NvAssetCategoryInfo.self, forKey: .categoryInfo) ?? NvAssetCategoryInfo()
        kindInfo = try container.decodeIfPresent(NvAssetKindInfo.self, forKey: .kindInfo) ?? NvAssetKindInfo()
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 0
        minAppVersion = try container.decodeIfPresent(String.self, forKey: .minAppVersion) ?? ""
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        displayNamezhCN = try container.decodeIfPresent(String.self, forKey: .displayNamezhCN) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        descriptionZhCn = try container.decodeIfPresent(String.self, forKey: .descriptionZhCn) ?? ""
        coverUrl = try container.decodeIfPresent(String.self, forKey: .coverUrl) ?? ""
        previewVideoUrl = try container.decodeIfPresent(String.self, forKey: .previewVideoUrl) ?? ""
        packageUrl = try container.decodeIfPresent(String.self, forKey: .packageUrl) ?? ""
        infoUrl = try container.decodeIfPresent(String.self, forKey: .infoUrl) ?? ""
        sizeLevel = try container.decodeIfPresent(Int64.self, forKey: .sizeLevel) ?? 0
        packageSize = try container.decodeIfPresent(Int64.self, forKey: .packageSize) ?? 0
        ratioFlag = try container.decodeIfPresent(Int32.self, forKey: .ratioFlag) ?? 0
        supportedAspectRatio = try container.decodeIfPresent(Int.self, forKey: .supportedAspectRatio) ?? 0
        defaultAspectRatio = try container.decodeIfPresent(Int.self, forKey: .defaultAspectRatio) ?? 0
        duration = try container.decodeIfPresent(Int64.self, forKey: .duration) ?? 0
        shotsNumber = try container.decodeIfPresent(Int.self, forKey: .shotsNumber) ?? 0
        costQuota = try container.decodeIfPresent(Int32.self, forKey: .costQuota) ?? 0
        queryInteractiveResultDto = try container.decodeIfPresent(NvTemplateInteractive.self, forKey: .queryInteractiveResultDto) ?? NvTemplateInteractive()
        zipUrl = try container.decodeIfPresent(String.self, forKey: .zipUrl) ?? ""
    }
}

class NvAssetTypeInfo: Decodable{
    var id: Int = 0
    var displayState: Int = 0
    var displayName: String = ""
    var displayNameZhCn: String = ""
    enum CodingKeys: String, CodingKey {
        case id
        case displayState
        case displayName
        case displayNameZhCn
    }
    required init() {  }
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        displayState = try container.decodeIfPresent(Int.self, forKey: .displayState) ?? 0
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        displayNameZhCn = try container.decodeIfPresent(String.self, forKey: .displayNameZhCn) ?? ""
    }
}

class NvAssetCategoryInfo: Decodable{
    var id: Int = 0
    var type: Int = 0
    var displayName: String = ""
    var displayNameZhCn: String = ""
    required init() {  }
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case displayName
        case displayNameZhCn
    }
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        type = try container.decodeIfPresent(Int.self, forKey: .type) ?? 0
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        displayNameZhCn = try container.decodeIfPresent(String.self, forKey: .displayNameZhCn) ?? ""
    }
}

class NvAssetKindInfo: Decodable{
    var id: Int = 0
    var materialType: Int = 0
    var category: Int = 0
    var displayName: String = ""
    var displayNameZhCn: String = ""
    required init() {  }
    enum CodingKeys: String, CodingKey {
        case id
        case materialType
        case category
        case displayName
        case displayNameZhCn
    }
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        materialType = try container.decodeIfPresent(Int.self, forKey: .materialType) ?? 0
        category = try container.decodeIfPresent(Int.self, forKey: .category) ?? 0
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        displayNameZhCn = try container.decodeIfPresent(String.self, forKey: .displayNameZhCn) ?? ""
    }
}
class NvTemplateUserInfo {
    var nickname: String = ""
    var iconUrl: String = ""
    required init() { }
    enum CodingKeys: String, CodingKey {
        case nickname
        case iconUrl
    }
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname) ?? ""
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl) ?? ""
    }
}

class NvTemplateInteractive: Decodable {
    var materialId: String = ""
    var useNum: Int = 0
    var likeNum: Int = 0
    required init() { }
    enum CodingKeys: String, CodingKey {
        case materialId
        case useNum
        case likeNum
    }
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        materialId = try container.decodeIfPresent(String.self, forKey: .materialId) ?? ""
        useNum = try container.decodeIfPresent(Int.self, forKey: .useNum) ?? 0
        likeNum = try container.decodeIfPresent(Int.self, forKey: .likeNum) ?? 0
    }
}

extension NvAssetModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = NvAssetModel()
        copyObj.type = type
        copyObj.category = type
        copyObj.typeInfo = typeInfo.copy() as! NvAssetTypeInfo
        copyObj.categoryInfo = categoryInfo.copy() as! NvAssetCategoryInfo
        copyObj.kindInfo = kindInfo.copy() as! NvAssetKindInfo
        copyObj.id = id
        copyObj.version = version
        copyObj.minAppVersion = minAppVersion
        copyObj.displayName = displayName
        copyObj.displayNamezhCN = displayNamezhCN
        copyObj.customDisplayName = customDisplayName
        copyObj.description = description
        copyObj.descriptionZhCn = descriptionZhCn
        copyObj.coverUrl = coverUrl
        copyObj.previewVideoUrl = previewVideoUrl
        copyObj.packageUrl = packageUrl
        copyObj.infoUrl = infoUrl
        copyObj.sizeLevel = sizeLevel
        copyObj.packageSize = packageSize
        copyObj.ratioFlag = ratioFlag
        copyObj.supportedAspectRatio = supportedAspectRatio
        copyObj.defaultAspectRatio = defaultAspectRatio
        copyObj.duration = duration
        copyObj.shotsNumber = shotsNumber
        copyObj.canReplaceShotsNumber = canReplaceShotsNumber
        copyObj.costQuota = costQuota
        copyObj.rate = rate
        copyObj.userInfo = userInfo.copy() as! NvTemplateUserInfo
        copyObj.queryInteractiveResultDto = queryInteractiveResultDto.copy() as! NvTemplateInteractive
        copyObj.authed = authed
        copyObj.packageRelativePath = packageRelativePath
        copyObj.templateTotalDuration = templateTotalDuration
        copyObj.itemHeight = itemHeight
        copyObj.isCompiled = isCompiled
        copyObj.downloadStatus = downloadStatus
        return copyObj
    }
}

extension NvAssetTypeInfo: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = NvAssetTypeInfo()
        copyObj.id              = id
        copyObj.displayState    = displayState
        copyObj.displayName     = displayName
        copyObj.displayNameZhCn = displayNameZhCn
        return copyObj
    }
}
extension NvAssetCategoryInfo: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = NvAssetCategoryInfo()
        copyObj.id = id
        copyObj.type  = type
        copyObj.displayName = displayName
        copyObj.displayNameZhCn  = displayNameZhCn
        return copyObj
    }
}
extension NvAssetKindInfo: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = NvAssetKindInfo()
        copyObj.id              = id
        copyObj.materialType    = materialType
        copyObj.category        = category
        copyObj.displayName     = displayName
        copyObj.displayNameZhCn = displayNameZhCn
        return copyObj
    }
}
extension NvTemplateInteractive: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = NvTemplateInteractive()
        copyObj.materialId  = materialId
        copyObj.useNum      = useNum
        copyObj.likeNum     = likeNum
        return copyObj
    }
}

extension NvTemplateUserInfo: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = NvTemplateUserInfo()
        copyObj.nickname = nickname
        copyObj.iconUrl  = iconUrl
        return copyObj
    }
}



///// 模版列表的数据类型
///// The data type of the template list
//class NvTemplateData: Decodable {
//    var enMsg: String = ""
//    var msg: String = ""
//    var code: Int = -1
//    var data: NvTemplateModel = NvTemplateModel.init()
//    required init() { }
//}
//class NvTemplateModel: Decodable {
//    var total: Int = 0
//    var elements: [NvTemplateInfo] = []
//    required init() { }
//}
public class NvTemplateInfo: Decodable {
    /// 剪同款模版ID
    /// Cut the template ID of the same style
    var id: String = ""
    /// 模版的版本号
    /// The version number of the template
    var version: Int = 0
    /// 模版名称
    /// Template name
    var displayName: String = ""
    /// 模版名称中文
    /// Template name in Chinese
    var displayNameZhCn: String = ""
    /// 模版描述
    /// Template description
    var description: String = ""
    /// 中文模版描述
    /// Chinese template description
    var descriptionZhCn: String = ""
    /// 模版封面URL
    /// Template cover URL
    var coverUrl: String = ""
    /// 模板的分类
    /// Classification of templates
    var category_Id: String = ""
    /// 模版预览视频URL
    /// Template preview video URL
    var previewVideoUrl: String = ""
    /// 模版包URL
    /// Template package URL
    var packageUrl: String = ""
    var packageLic: String = ""
    /// 模版info.json URL
    /// Template info.json URL
    var infoUrl: String = ""
    var packageInfo: String = ""
    /// 支持的画幅比例
    /// Supported picture scale
    var supportedAspectRatio: Int32 = 0
    /// 当前画幅比例
    /// Current frame ratio
    var defaultAspectRatio: Int32 = 0
    /// 原始当前画幅比例
    /// Original current frame scale
    var originalDefaultAspectRatio: Int32 = 0
    /// 时长
    /// duration
    var duration: Int64 = 0
    var shotsNumber: Int = 0
    var canReplaceShotsNumber: Int = 0
    /// 使用次数
    /// Times of use
    var useNum: Int = 0
    /// 点赞次数
    /// Number of likes
    var likeNum: Int = 0
    /// 创建者信息
    ///Creator information
    var producer: NvTemplateProducer = NvTemplateProducer.init()
    ///标记图片的高度
    ///Mark the height of the picture
    var itemHeight: CGFloat = 0
    /// 带账户标记是否显示已购
    /// Whether to show purchased with account mark
    var isStored: Bool = false
    /// 标记是否是生成的模版
    /// Mark whether the template is generated
    var isCompiled: Bool = false
    var zipUrl: String = ""
    required public init() { }
    
    class NvTemplateProducer: Decodable {
        /// 昵称
        /// nickname
        var nickname: String = ""
        /// 头像
        /// Head picture
        var iconUrl: String = ""
        required init() { }
    }
}

class NvTemplateCategoryModel: Decodable {
    var category: Int = 0
    var displayName: String = ""
    required init() { }
}
class NvTemplateCategories: Decodable {
    var categories: [NvTemplateCategoryModel] = []
    required init() { }
}

class NvTemplateEditItem: NSObject {
    var asset: PHAsset?
    var coverImage: UIImage = UIImage.init()
    var duration: Int64 = 0
    var index: Int = 0
    var isSelected: Bool = false
    var isCanReplace: Bool = false
    var isCaption: Bool = false
    var isCompoundCaption: Bool = false
    var isClipCaption: Bool = false
    var isTrackCaption: Bool  = false
    var compoundCaptionIndex: Int = 0
    var captionContent: String = ""
    var trackIndex: UInt32 = 0
    var clipIndex: UInt32 = 0
    var clipInPoint: Int64 = 0
    var clipType: UInt32 = 0
    var footageId: String = ""
    /// 是否是自适应模板的片段
    /// Whether it is a fragment of an adaptive template
    var isAdaptationDuration: Bool = false
    
    ///ae模板嵌套的seek位置
    ///ae template nested seek position
    var bestDuration: Int64 = 0
    var bestSeekTime: Int64 = 0
    var timelineNestInfos: [NvTemplateTimelineClipInfo] = []
    var isGrouped: Bool = false
    var groupId: Int = -1
    
    public func copyItem() -> NvTemplateEditItem {
        var item: NvTemplateEditItem = NvTemplateEditItem.init()
        item.asset = self.asset
        item.coverImage = self.coverImage
        item.duration = self.duration
        item.index = self.index
        item.isSelected = self.isSelected
        item.isCanReplace = self.isCanReplace
        item.isCaption = self.isCaption
        item.isCompoundCaption = self.isCompoundCaption
        item.isClipCaption = self.isClipCaption
        item.isTrackCaption = self.isTrackCaption
        item.compoundCaptionIndex = self.compoundCaptionIndex
        item.captionContent = self.captionContent
        item.trackIndex = self.trackIndex
        item.clipIndex = self.clipIndex
        item.clipInPoint = self.clipInPoint
        item.clipType = self.clipType
        item.footageId = self.footageId
        item.isAdaptationDuration = self.isAdaptationDuration
        item.bestDuration = self.bestDuration
        item.bestSeekTime = self.bestSeekTime
        item.timelineNestInfos = self.timelineNestInfos
        item.isGrouped = self.isGrouped
        item.groupId = self.groupId
        return item
    }
    
    required override init() { }
}

extension NvTemplateInfo {
    func getSupportedAspectRatios() -> [String] {
        var strs: [String] = []
        let ratios: [Int32] = [1, 2, 4, 8, 16, 32, 64, 512, 1024]
        for ratio in ratios {
            if ratio & supportedAspectRatio != 0 {
                let ratioStr = getAspectRatioStr(for: ratio)
                strs.append(ratioStr)
            }
        }
        return strs
    }
    func getAspectRatio() -> CGFloat {
        switch self.defaultAspectRatio {
        case 1:
            return CGFloat(16)/CGFloat(9)
        case 2:
            return CGFloat(1)
        case 4:
            return CGFloat(9)/CGFloat(16)
        case 8:
            return CGFloat(4)/CGFloat(3)
        case 16:
            return CGFloat(3)/CGFloat(4)
        case 32:
            return CGFloat(18)/CGFloat(9)
        case 64:
            return CGFloat(9)/CGFloat(18)
        case 512:
            return CGFloat(21)/CGFloat(9)
        case 1024:
            return CGFloat(9)/CGFloat(21)
        default:
            return CGFloat(9)/CGFloat(16)
        }
    }
    public func getAspectRatioStr(for rawValue: Int32) -> String {
        var str = "9:16"
        switch rawValue {
        case 1:
            str = "16:9"
            break
        case 2:
            str = "1:1"
            break
        case 4:
            str = "9:16"
            break
        case 8:
            str = "4:3"
            break
        case 16:
            str = "3:4"
            break
        case 32:
            str = "18:9"
            break
        case 64:
            str = "9:18"
            break
        case 512:
            str = "21:9"
            break
        case 1024:
            str = "9:21"
            break
        default:
            break
        }
        return str
    }
}

///MARK: - 解析模板的信息
///Parses the template information
public final class NvTemplateGroupInfo {
    public var groupId: Int = -1
    public var info: [String: Int] = [:]
    public var footages: [String] = []
}

public final class NvTemplateTimelineClipInfo {
    public var trackIndex: Int32 = 0
    public var clipIndex: Int32 = 0
    public var inPoint: Int64 = 0
    public var isEmptyDesc: Bool = true
    public init(trackIndex: Int32, clipIndex: Int32, inPoint: Int64, isEmptyDesc: Bool) {
        self.trackIndex = trackIndex
        self.clipIndex = clipIndex
        self.inPoint = inPoint
        self.isEmptyDesc = isEmptyDesc
    }
    
    public func copyItem() -> NvTemplateTimelineClipInfo {
        return NvTemplateTimelineClipInfo.init(trackIndex: trackIndex, clipIndex: clipIndex, inPoint: inPoint, isEmptyDesc: isEmptyDesc)
    }
}
