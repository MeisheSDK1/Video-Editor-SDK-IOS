//
//  NvTemplateViewController.swift
//  MYVideo
//
//  Created by chengww on 2020/11/3.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import MJRefresh
import NvStreamingSdkCore
import NvSDKCommon
import SnapKit

protocol NvTemplateViewControllerDelegate: class {
    func templateView(_ templateInfo: NvTemplateInfo, didSelectItemAt index: Int)
}

class NvTemplateViewController: UIViewController {
    weak var delegate: NvTemplateViewControllerDelegate?
    init(with category: String) {
        super.init(nibName: nil, bundle: nil)
        self.category_Id = category
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        /// 设置UI
        /// Set the UI
        nv_setupUI()
        if category_Id == "1000" {
            /// 我的，自己生成的模版
            /// My, uh, self-generated template
            /// 配置刷新
            /// Configuration refresh
            nv_loadLocalData()
            NotificationCenter.default.addObserver(self, selector: #selector(nv_loadLocalData), name: NSNotification.Name.init("refreshLocalTemplateEvent"), object: nil)
        }else if category_Id == "9898" {
            /// 测试模板
            /// Test template
            nv_loadLocalTestData()
            NotificationCenter.default.addObserver(self, selector: #selector(nv_loadLocalTestData), name: NSNotification.Name.init("refreshLocalTemplateEvent"), object: nil)
        }else {
            /// 配置刷新
            /// Configuration refresh
            self.contentView.mj_header = refreshHeader
            self.contentView.mj_footer = refreshFooter
            self.contentView.mj_header?.isAutomaticallyChangeAlpha = true
            self.refreshHeader.setRefreshingTarget(self, refreshingAction: #selector(nv_loadNewData))
            self.refreshFooter.setRefreshingTarget(self, refreshingAction: #selector(nv_loadMoreData))
            /// 开始下拉刷新
            /// Start the drop-down refresh
            self.contentView.mj_header?.beginRefreshing()
            self.contentView.mj_footer?.endRefreshing()
            NotificationCenter.default.addObserver(self, selector: #selector(nv_loadNewData), name: NSNotification.Name.init("refreshTemplateEvent"), object: nil)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var category_Id: String = ""
    public var keyword: String = ""
    public var isLoad: Bool = false
    private var contentView: UICollectionView!
    private let refreshHeader: MJRefreshNormalHeader = MJRefreshNormalHeader.init()
    private let refreshFooter: MJRefreshAutoNormalFooter = MJRefreshAutoNormalFooter.init()
    private var dataSource: [NvTemplateInfo] = []
    private var currentPage: Int = 1
    private lazy var stateView: NvTemplateNoDataView = {
        let view = NvTemplateNoDataView.init(frame: self.view.bounds)
        return view
    }()
    
    /// 模版文件夹根目录
    /// Template folder root
    var extTemplate = ""
    /// 标准模版文件夹根目录
    /// Standard template folder root
    var ext_Template = ""
    /// 自适应时长模版文件夹根目录
    /// Adaptive duration template folder root
    var ext_FreeTemplate = ""
    /// AE转换模版文件夹根目录
    /// AE conversion template folder root
    var ext_AETemplate = ""
    var currentTemplateModel = NvTemplateInfo()
    var currentTemplateModelIndex:Int = -1
    var loaded = false
}

extension NvTemplateViewController {
    
    public func isLoadedLocalMaterial() -> Bool {
        extTemplate = NSHomeDirectory() + "/Documents/extTemplates"
        ext_Template = extTemplate+"/Template"
        ext_FreeTemplate = extTemplate+"/TemplateFree"
        ext_AETemplate = extTemplate+"/TemplateAE"
        
        if !FileManager.default.fileExists(atPath: extTemplate) {
            try? FileManager.default.createDirectory(atPath: extTemplate, withIntermediateDirectories: true, attributes: nil)
        }
        if !FileManager.default.fileExists(atPath: ext_Template) {
            try? FileManager.default.createDirectory(atPath: ext_Template, withIntermediateDirectories: true, attributes: nil)
        }
        if !FileManager.default.fileExists(atPath: ext_FreeTemplate) {
            try? FileManager.default.createDirectory(atPath: ext_FreeTemplate, withIntermediateDirectories: true, attributes: nil)
        }
        if !FileManager.default.fileExists(atPath: ext_AETemplate) {
            try? FileManager.default.createDirectory(atPath: ext_AETemplate, withIntermediateDirectories: true, attributes: nil)
        }
        
        do {
            let tempArray:Array = [ext_Template,ext_FreeTemplate,ext_AETemplate]
            for itemString in tempArray {
                let templatePaths = try FileManager.default.contentsOfDirectory(atPath: itemString)
                if templatePaths.count > 0 {
                    loaded = true
                }
            }
        } catch {
            
        }
        
        return loaded
    }
    
    @objc
    private func nv_loadLocalTestData() {
        self.dataSource.removeAll()
        self.currentTemplateModel = NvTemplateInfo()
        self.currentTemplateModelIndex = -1
        if self.isLoadedLocalMaterial() {
            do {
                let tempArray:Array = [ext_Template,ext_FreeTemplate,ext_AETemplate]
                for itemString in tempArray {
                    let templatePaths = try FileManager.default.contentsOfDirectory(atPath: itemString)
                    for path in templatePaths {
                        if path.hasSuffix("template") {
                            let templatePath = itemString + "/\(path)"
                            let item = NvTemplateInfo.init()
                            if let PathId = NvsStreamingContext.sharedInstance()?.assetPackageManager.getAssetPackageId(fromAssetPackageFilePath: templatePath) {
                                item.description = PathId
                                item.id = PathId
                                
                                if let supportedAspectRatio = NvsStreamingContext.sharedInstance()?.assetPackageManager.getAssetPackageSupportedAspectRatio(PathId, type: NvsAssetPackageType_Template) {
                                    item.supportedAspectRatio = supportedAspectRatio
                                }
                                if let defaultAspectRatio = NvsStreamingContext.sharedInstance()?.assetPackageManager.getTemplateCurrentAspectRatio(PathId) {
                                    item.defaultAspectRatio = defaultAspectRatio
                                    if self.currentTemplateModel.originalDefaultAspectRatio != defaultAspectRatio && self.currentTemplateModel.originalDefaultAspectRatio != 0 {
                                        item.defaultAspectRatio = self.currentTemplateModel.originalDefaultAspectRatio
                                    }
                                }
                            }
                            
                            item.version = 1
                            item.coverUrl = ""
                            item.previewVideoUrl = ""
                            item.packageLic = ""
                            item.packageUrl = templatePath
                            item.displayName = "测试模版"
                            item.duration = 0
                            item.producer.nickname = NvLocalStringFromTableInBundle(key: "Created by Meishe", tableName: "NvTemplate", bundle: Bundle(for: self.classForCoder), comment: "Meishe原创")
                            item.producer.iconUrl = "template_header"
                            if itemString == ext_Template{
                                item.category_Id = "1";
                            }else if itemString == ext_FreeTemplate {
                                item.category_Id = "2";
                            }else{
                                item.category_Id = "3";
                            }
                            item.isCompiled = true
                            dataSource.append(item)
                        }else{
                            let templatePath = itemString + "/\(path)/"
                            if let filePaths = FileManager.default.subpaths(atPath: templatePath), filePaths.count > 0 {
                                let item = NvTemplateInfo.init()
                                item.id = path
                                item.version = 1
                                filePaths.forEach { (fileName) in
                                    guard let fileSuff = fileName.split(separator: ".").map(String.init).last else { return }
                                    let fileType = NvUtils.nv_fileType(ext: fileSuff)
                                    if fileType == .image {
                                        item.coverUrl = templatePath + fileName
                                    }else if fileType == .video {
                                        item.previewVideoUrl = templatePath + fileName
                                    }else {
                                        if fileName.hasSuffix("template") {
                                            item.packageUrl = templatePath + fileName
                                        }else if fileName.hasSuffix("lic") {
                                            item.packageLic = templatePath + fileName
                                        }
                                    }
                                }
                                item.displayName = "测试模版"
                                item.description = path
                                item.supportedAspectRatio = 0
                                item.defaultAspectRatio = 0
                                item.duration = 0
                                item.producer.nickname = NvLocalStringFromTableInBundle(key: "Created by Meishe", tableName: "NvTemplate", bundle: Bundle(for: self.classForCoder), comment: "Meishe原创")
                                item.producer.iconUrl = "template_header"
                                if itemString == ext_Template{
                                    item.category_Id = "1";
                                }else if itemString == ext_FreeTemplate {
                                    item.category_Id = "2";
                                }else{
                                    item.category_Id = "3";
                                }
                                item.isCompiled = true
                                dataSource.append(item)
                            }
                        }
                    }
                }
                
                self.contentView.reloadData()
                
            } catch  {
                self.contentView.reloadData()
                return
            }
        }
    }
    
    @objc
    private func nv_loadLocalData() {
        self.dataSource.removeAll()
        let infoPath = TEMPLATE_Compile_URL + "/info.json"
        if !FileManager.default.fileExists(atPath: infoPath) {
            self.nv_reloadData()
            return
        }
        guard let jsonText = try? String.init(contentsOf: URL.init(fileURLWithPath: infoPath)) else {
            self.nv_reloadData()
            return
        }
        let templateList = NvHandyJSON.jsonArrayToModel(jsonString: jsonText, modelType: NvTemplateCompileInfoModel.self)
        templateList.forEach { (compileModel) in
            let templatePath = TEMPLATE_Compile_URL + "/\(compileModel.uuid)/"
            let item = NvTemplateInfo.init()
            item.id = compileModel.uuid
            item.version = compileModel.version
            item.coverUrl = templatePath + compileModel.uuid + ".png"
            item.previewVideoUrl = templatePath + compileModel.uuid + ".mp4"
            item.packageUrl = templatePath + compileModel.uuid + ".template"
            item.displayName = compileModel.name
            item.displayNameZhCn = compileModel.name
            item.description = compileModel.description
            item.descriptionZhCn = compileModel.description
            item.supportedAspectRatio = compileModel.getSupportedAspectRatio()
            item.defaultAspectRatio = NvUtils.getAspectRatioRawValue(for: compileModel.defaultAspectRatio)
            item.duration = compileModel.duration / 1000
            item.producer.nickname = "美映创作者"
            item.producer.iconUrl = "template_header"
            item.isCompiled = true
            dataSource.append(item)
        }
        
        self.nv_reloadData()
        
    }
    @objc
    public func nv_loadNewData() {
        /// 下拉加载
        /// Pull down loading
        self.contentView.mj_footer?.resetNoMoreData()
        self.isLoad = true
        let lang = NvHttpRequest.getCurrentLang()
        var params: [String: Any] = ["type":"19",
                                     "category":self.category_Id,
                                     "keyword":self.keyword,
                                     "pageNum":"\(currentPage)",
                                     "pageSize":"20",
                                     "sdkVersion": NvUtils.getSdkVersion(),
                                     "needInteractive": true,
                                     "isAbove4k":"0"]
        
        if (NvHttpRequest.getTestMaterial()){
            let testNumMaterial:NSNumber = UserDefaults.standard.object(forKey: "NvTestNumMaterial") as! NSNumber
            if (testNumMaterial != nil && testNumMaterial.boolValue){
                params = ["type":"19",
                          "category":self.category_Id,
                          "keyword":self.keyword,
                          "pageNum":"\(currentPage)",
                          "pageSize":"20",
                          "sdkVersion": NvUtils.getSdkVersion(),
                          "needInteractive": true,
                          "isAbove4k":"0",
                          "isTestMaterial":"0"]
            }
        }
        params["lang"] = lang
        NvTemplateHttpRequest.sharedInstance.get(urlString: NV_ASSET_REQUEST_URL, param: params, success: { (response, _) in
            var result = Array<NvAssetModel>()
            if let ret = response["data"] as? [String: Any] {
                let array = ret["elements"] as? Array<[String: Any]>
                array?.forEach { (dic) in
                    if let templateData = NvHandyJSON.mapToModel(map: dic, modelType: NvAssetModel.self) {
                        result.append(templateData)
                    }
                }
                self.contentView.mj_header?.endRefreshing()
                self.currentPage = 1
                /// 更新数据
                /// Update data
                self.dataSource.removeAll()
                result.forEach { self.dataSource.append(self.convert(from: $0)) }
                if result.count < 20 {
                    self.contentView.mj_footer?.isHidden = true
                }else {
                    self.contentView.mj_footer?.isHidden = false
                }
                /// 刷新数据
                /// Update data
                self.nv_reloadData()
            }else {
                self.contentView.mj_header?.endRefreshing()
            }
            
        }, failure: { (_) in
            self.contentView.mj_header?.endRefreshing()
        })
    }
    
    private func convert(from asset: NvAssetModel) -> NvTemplateInfo {
        let item = NvTemplateInfo.init()
        item.category_Id = self.category_Id
        item.id = asset.id
        item.version = asset.version
        item.coverUrl = asset.coverUrl
        item.previewVideoUrl = asset.previewVideoUrl
        item.packageUrl = asset.packageUrl
        item.displayName = NvUtils.isZh() ? asset.displayNamezhCN : asset.displayName
        item.description = NvUtils.isZh() ? asset.descriptionZhCn : asset.description
        item.supportedAspectRatio = Int32(asset.supportedAspectRatio)
        item.defaultAspectRatio = Int32(asset.defaultAspectRatio)
        item.duration = asset.duration
        item.isStored = false
        item.producer.nickname = asset.userInfo.nickname
        item.producer.iconUrl = asset.userInfo.iconUrl
        item.useNum = asset.queryInteractiveResultDto.useNum
        item.likeNum = asset.queryInteractiveResultDto.likeNum
        item.isCompiled = false
        item.zipUrl = asset.zipUrl
        return item
    }
    
    @objc
    private func nv_loadMoreData() {
        /// 上拉加载
        /// Pull-up loading
        let lang = NvHttpRequest.getCurrentLang()
        self.currentPage += 1
        
        var params: [String: Any] = ["type":"19",
                                     "category":self.category_Id,
                                     "keyword":self.keyword,
                                     "pageNum":"\(currentPage)",
                                     "pageSize":"20",
                                     "sdkVersion": NvUtils.getSdkVersion(),
                                     "needInteractive": true,
                                     "isAbove4k":"0"]
        if (NvHttpRequest.getTestMaterial()){
            let testNumMaterial:NSNumber = UserDefaults.standard.object(forKey: "NvTestNumMaterial") as! NSNumber
            if (testNumMaterial != nil && testNumMaterial.boolValue){
            params = ["type":"19",
                      "category":self.category_Id,
                      "keyword":self.keyword,
                      "pageNum":"\(currentPage)",
                      "pageSize":"20",
                      "sdkVersion": NvUtils.getSdkVersion(),
                      "needInteractive": true,
                      "isAbove4k":"0",
                      "isTestMaterial":"0"]
            }
        }
        params["lang"] = lang
        NvTemplateHttpRequest.sharedInstance.get(urlString: NV_ASSET_REQUEST_URL, param: params, success: { (response, _) in
            var result = Array<NvAssetModel>()
            if let ret = response["data"] as? [String: Any] {
                let array = ret["elements"] as? Array<[String: Any]>
                array?.forEach { (dic) in
                    if let templateData = NvHandyJSON.mapToModel(map: dic, modelType: NvAssetModel.self) {
                        self.contentView.mj_header?.endRefreshing()
                        result.append(templateData)
                    }
                }
                result.forEach { self.dataSource.append(self.convert(from: $0)) }
                if result.count < 20 {
                    self.contentView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.contentView.mj_footer?.endRefreshing()
                }
                /// 刷新数据
                /// Refresh data
                self.nv_reloadData()
            }else {
                self.currentPage -= 1
                self.contentView.mj_footer?.endRefreshing()
            }
            
        }, failure: { (_) in
            self.currentPage -= 1
            self.contentView.mj_footer?.endRefreshing()
        })
    }
    
    private func nv_reloadData() {
        self.contentView.reloadData()
        if self.dataSource.count > 0 {
            self.stateView.removeFromSuperview()
        }else {
            self.view.addSubview(self.stateView)
        }
    }
}

extension NvTemplateViewController: UICollectionViewDelegate, UICollectionViewDataSource, NvCollectionViewLayoutDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NvTemplateViewCell_Identifier", for: indexPath) as! NvTemplateViewCell
        cell.renderCellWithItem(model: dataSource[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if self.loaded {
            if self.currentTemplateModelIndex == -1 {
                self.currentTemplateModel = dataSource[indexPath.item]
                self.currentTemplateModelIndex = indexPath.item
                self.installTemplate()
            }else{
                if self.currentTemplateModel.id.count > 0 {
                    if let status = NvsStreamingContext.sharedInstance()?.assetPackageManager.getAssetPackageStatus(self.currentTemplateModel.id, type: NvsAssetPackageType_Template) {
                        if status == NvsAssetPackageStatus_Installing || status == NvsAssetPackageStatus_Upgrading {
                            NvToast.showToastAction(message: "素材安装中")
                        }else{
                            self.currentTemplateModel = dataSource[indexPath.item]
                            self.currentTemplateModelIndex = indexPath.item
                            self.installTemplate()
                        }
                    }
                }
            }
        }else{
            delegate?.templateView(dataSource[indexPath.item], didSelectItemAt: indexPath.item)
        }
    }
    func waterFlowLayout(layout: NvCollectionViewLayout, indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        let item = dataSource[indexPath.item]
        item.itemHeight = itemWidth / item.getAspectRatio()
        return item.itemHeight + 84 * SCREENSCALE
    }
}

extension NvTemplateViewController: NvsAssetPackageManagerDelegate {
    
    /// Register template, get template information
    ///
    /// - Remark: 注册模版，获取模版信息
    ///
    private func installTemplate() {
        if let context = NvsStreamingContext.sharedInstance() {
            context.assetPackageManager.delegate = self
            
            context.assetPackageManager.uninstallAssetPackage(self.currentTemplateModel.id, type: NvsAssetPackageType_Template)
            
            let pid = NSMutableString.init()
            let installState = context.assetPackageManager.installAssetPackage(self.currentTemplateModel.packageUrl, license: self.currentTemplateModel.packageLic, type: NvsAssetPackageType_Template, sync: false, assetPackageId: pid)
            if installState == NvsAssetPackageManagerError_NoError || installState == NvsAssetPackageManagerError_AlreadyInstalled {
                if let assetPackageManager = NvsStreamingContext.sharedInstance()?.assetPackageManager {
                    self.currentTemplateModel.supportedAspectRatio = assetPackageManager.getAssetPackageSupportedAspectRatio(self.currentTemplateModel.id, type: NvsAssetPackageType_Template)
                    self.currentTemplateModel.defaultAspectRatio = assetPackageManager.getTemplateCurrentAspectRatio(self.currentTemplateModel.id)
                    if self.currentTemplateModel.originalDefaultAspectRatio != self.currentTemplateModel.defaultAspectRatio && self.currentTemplateModel.originalDefaultAspectRatio != 0 {
                        self.currentTemplateModel.defaultAspectRatio = self.currentTemplateModel.originalDefaultAspectRatio
                    }
                    self.contentView.reloadData()
                    delegate?.templateView(dataSource[self.currentTemplateModelIndex], didSelectItemAt: self.currentTemplateModelIndex)
                }
            }
        }
    }
    
    
    /// Asynchronous registration template callback
    ///
    /// - Remark: 异步注册模版回调
    ///
    /// - Parameters:
    ///   - assetPackageId: PackageId
    ///   - assetPackageFilePath: Resource path
    ///   - assetPackageType: Package type
    ///   - error: Return error
    ///
    func didFinishAssetPackageInstallation(_ assetPackageId: String!, filePath assetPackageFilePath: String!, type assetPackageType: NvsAssetPackageType, error: NvsAssetPackageManagerError) {
        if error == NvsAssetPackageManagerError_NoError || error == NvsAssetPackageManagerError_AlreadyInstalled {
            if let assetPackageManager = NvsStreamingContext.sharedInstance()?.assetPackageManager {
                self.currentTemplateModel.supportedAspectRatio = assetPackageManager.getAssetPackageSupportedAspectRatio(self.currentTemplateModel.id, type: NvsAssetPackageType_Template)
                self.currentTemplateModel.defaultAspectRatio = assetPackageManager.getTemplateCurrentAspectRatio(self.currentTemplateModel.id)
                if self.currentTemplateModel.originalDefaultAspectRatio == 0 {
                    self.currentTemplateModel.originalDefaultAspectRatio = self.currentTemplateModel.defaultAspectRatio
                }
                
                DispatchQueue.main.async { [self] in
                    self.contentView.reloadData()
                    delegate?.templateView(dataSource[self.currentTemplateModelIndex], didSelectItemAt: self.currentTemplateModelIndex)
                }
            }
        }
    }
    
}

extension NvTemplateViewController {
    private func nv_setupUI() {
        let layout = NvCollectionViewLayout.init()
        layout.delegate = self
        layout.columnCount = 2
        layout.columnMargin = 9 * SCREENSCALE
        contentView = UICollectionView.init(frame: CGRect.init(x: 13 * SCREENSCALE, y: 0, width: SCREENWIDTH - 26 * SCREENSCALE, height: self.view.frame.size.height), collectionViewLayout: layout)
    
        contentView.backgroundColor = UIColor.black
        contentView.bounces = true
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.delegate = self
        contentView.dataSource = self
        self.view.addSubview(contentView)
        contentView.register(NvTemplateViewCell.classForCoder(), forCellWithReuseIdentifier: "NvTemplateViewCell_Identifier")
        contentView.contentInset = UIEdgeInsets.init(top: 10 * SCREENSCALE, left: 0, bottom: 0, right: 0)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    private func nv_getDefaultTemplateInfo() -> NvTemplateInfo {
        let item = NvTemplateInfo.init()
        return item
    }
}


class NvTemplateViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.black
        self.nv_layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func renderCellWithItem(model: NvTemplateInfo) {
        if model.coverUrl.count > 0{
            self.coverImageView.backgroundColor = UIColor.clear
            self.coverImageView.nv_image(urlString: model.coverUrl)
        }else{
            self.coverImageView.backgroundColor = UIColor.red
        }
        
        coverImageView.snp.updateConstraints { (make) in
            make.height.equalTo(model.itemHeight)
        }
        if model.useNum > 10000 {
            let numStr = NvUtils.numberToString(model.useNum, den: 10000, afterPoint: 1)
            self.templateApplayLabel.text = NvLocalProvider.String(key: "Usage amount", comment: "使用量")+" "+"\(numStr) W"
        }else {
            self.templateApplayLabel.text = NvLocalProvider.String(key: "Usage amount", comment: "使用量")+" "+"\(model.useNum)"
        }
        
        self.templateApplayLabel.isHidden = false
        let itemW = textWidth(for: self.templateApplayLabel.text ?? "") + 13 * SCREENSCALE
        templateApplayLabel.snp.updateConstraints { (make) in
            make.width.equalTo(itemW)
        }
        
        self.templateLabel.text = model.displayName
        self.templateDescLabel.text = model.description
        
        self.headerView.nv_image(urlString: model.producer.iconUrl.count > 0 ? model.producer.iconUrl : "template_header")
        self.userLabel.text = model.producer.nickname.count > 0 ? model.producer.nickname : NvLocalStringFromTableInBundle(key: "Created by Meishe", tableName: "NvTemplate", bundle: Bundle(for: self.classForCoder), comment: "Meishe原创")
    }
    
    private lazy var coverImageView: UIImageView = {
        let view = UIImageView.init()
        view.contentMode = .scaleAspectFill
        return view
    }()
    private lazy var templateApplayLabel: UILabel = {
        let view = UILabel.init()
        view.textAlignment = .center
        view.textColor = .white
        view.font = NvUtils.fontWithSize(size: 9 * SCREENSCALE)
        view.backgroundColor = UIColor.black
        return view
    }()
    private lazy var templateLabel: UILabel = {
        let view = UILabel.init()
        view.textAlignment = .left
        view.textColor = .white
        view.font = NvUtils.fontWithSize(size: 12 * SCREENSCALE)
        return view
    }()
    private lazy var templateDescLabel: UILabel = {
        let view = UILabel.init()
        view.textAlignment = .left
        view.textColor = UIColor.init(hex: "#FFFFFF", alpha: 0.8)
        view.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        return view
    }()
    private lazy var headerView: UIImageView = {
        let view = UIImageView.init()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private lazy var userLabel: UILabel = {
        let view = UILabel.init()
        view.textAlignment = .left
        view.textColor = UIColor.init(hex: "#FFFFFF", alpha: 0.8)
        view.font = NvUtils.fontWithSize(size: 9 * SCREENSCALE)
        return view
    }()
}

extension NvTemplateViewCell {
    private func nv_layoutSubviews() {
        self.contentView.addSubview(coverImageView)
        coverImageView.addSubview(templateApplayLabel)
        self.contentView.addSubview(templateLabel)
        self.contentView.addSubview(templateDescLabel)
        self.contentView.addSubview(headerView)
        self.contentView.addSubview(userLabel)
        coverImageView.layer.cornerRadius = 5 * SCREENSCALE
        coverImageView.layer.masksToBounds = true
        templateApplayLabel.layer.cornerRadius = 13 * SCREENSCALE * 0.5
        templateApplayLabel.layer.masksToBounds = true
        
        let itemSize = self.frame.size
        coverImageView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self.contentView)
            make.height.equalTo(0)
        }
        templateApplayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(7 * SCREENSCALE)
            make.bottom.equalTo(self.coverImageView.snp.bottom).offset(-7 * SCREENSCALE)
            make.height.equalTo(13 * SCREENSCALE)
            make.width.equalTo(0)
        }
        templateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(7 * SCREENSCALE)
            make.height.equalTo(17 * SCREENSCALE)
            make.width.equalTo(itemSize.width)
        }
        templateDescLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(self.templateLabel.snp.bottom).offset(5 * SCREENSCALE)
            make.width.equalTo(itemSize.width)
            make.height.equalTo(14 * SCREENSCALE)
        }
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.height.equalTo(18 * SCREENSCALE)
            make.top.equalTo(templateDescLabel.snp.bottom).offset(5 * SCREENSCALE)
        }
        userLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerView.snp.right).offset(5 * SCREENSCALE)
            make.centerY.equalTo(headerView.snp.centerY)
            make.width.equalTo(itemSize.width - 25 * SCREENSCALE)
            make.height.equalTo(13 * SCREENSCALE)
        }
    }
    
    private func textWidth(for string: String) -> CGFloat {
        let text = string as NSString
        let rect = text.boundingRect(with: CGSize.init(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: NvUtils.fontWithSize(size: 9 * SCREENSCALE)], context: nil)
        return rect.size.width
    }
}
