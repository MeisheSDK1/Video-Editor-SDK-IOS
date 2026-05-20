//
//  NvTemplatePageViewController.swift
//  MYVideo
//
//  Created by chengww on 2020/11/3.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit

public class NvTemplatePageViewController: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.navigationController?.navigationBar.isTranslucent = false
        let leftBarButtonItem = UIBarButtonItem.init(customView: leftItem)
        if #available(iOS 26.0, *) {
            leftBarButtonItem.hidesSharedBackground = true
        }
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        leftItem.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        self.searchBar = UISearchBar.init(frame: CGRect.init(x: 60*SCREENSCALE, y: 0, width: SCREENWIDTH - 70*SCREENSCALE, height: 50*SCREENSCALE))
        if #available(iOS 26.0, *) {

        } else {
            self.searchBar.backgroundColor = .black
            self.searchBar.barTintColor = UIColor.red;
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.searchBar)
        

        if #available(iOS 13.0, *) {
            
            self.searchBar.searchTextField.font = UIFont(name: "PingFang SC", size: 13)
        } else {
            
            if let searchTextField = self.searchBar.value(forKey: "searchField") as? UITextField {
                searchTextField.font = UIFont(name: "PingFang SC", size: 13)
            }
        }
        self.searchBar.placeholder = NvLocalProvider.String(key: "Enter the keyword search template", comment: "输入关键词搜索模版")
        self.searchBar.delegate = self
        
        for var childView in self.searchBar.subviews {
            for var childView1 in childView.subviews {
                if #available(iOS 13.0, *) {
                    for var childView2 in childView1.subviews {
                        if childView2.isKind(of: UITextField.self) {
                            let textField:UITextField = childView2 as! UITextField;
                            textField.backgroundColor = UIColor.nv_color(hexARGB: "#FF333333")
                            textField.textColor = UIColor.white;
                            textField.layer.masksToBounds = true;
                            textField.layer.cornerRadius = 17.5*SCREENSCALE;
//                            textField.leftView?.frame = CGRect(x: 10, y: 0, width: 10, height: 10)
                        }
                    }
                } else {
                    if childView1.isKind(of: UITextField.self) {
                        let textField:UITextField = childView1 as! UITextField;
                        textField.backgroundColor = UIColor.nv_color(hexARGB: "#FF333333")
                        textField.textColor = UIColor.white;
                        textField.layer.masksToBounds = true;
                        textField.layer.cornerRadius = 17.5*SCREENSCALE;
                    }
                }
            }
        }
        self.searchBar.setImage(NvUtils.imageWithName( "template_search"), for: UISearchBar.Icon.search, state: UIControl.State.normal)
        self.searchBar.searchTextPositionAdjustment = UIOffset.init(horizontal: 10, vertical: 0)
        self.searchBar.setPositionAdjustment(UIOffset.init(horizontal: 10, vertical: 0), for: UISearchBar.Icon.search)
        
        requestCategoryData()
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var titleView: PageTitleView!
    var contentView: PageContentView!
    var searchBar: UISearchBar!
    var titles = [String]()
    var childs: [UIViewController] = []
    /// 入口是否是从包装模板进入
    /// Whether the entry is from the packaging template
    @objc public var isPackagingTemplate: Bool = false
    
    public lazy var leftItem: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(NvUtils.imageWithName( "template_edit_back"), for: .normal)
        btn.setImage(NvUtils.imageWithName( "template_edit_back"), for: .highlighted)
        btn.contentHorizontalAlignment = .left
        btn.frame.size = CGSize.init(width: 40, height: 40)
        btn.adjustsImageWhenHighlighted = false
        return btn
    }()
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    func nv_configData() {
        self.nv_setupPageView()
        self.titleView.titles = titles
        self.contentView.childViewControllers = self.childs
    }
    func requestCategoryData() {
        self.titles.append(NvLocalProvider.String(key: "Standard formwork", comment: "标准模板"))
        self.titles.append(NvLocalProvider.String(key: "Adaptation duration", comment: "自适时长"))
        self.titles.append(NvLocalProvider.String(key: "AE conversion template", comment: "AE转换模板"))

        let vc = NvTemplateViewController.init(with: "1")
        vc.delegate = self
        self.childs.append(vc)

        let vc1 = NvTemplateViewController.init(with: "2")
        vc1.delegate = self
        self.childs.append(vc1)

        let vc2 = NvTemplateViewController.init(with: "3")
        vc2.delegate = self
        self.childs.append(vc2)

        let testVC = NvTemplateViewController.init(with: "9898")
        if testVC.isLoadedLocalMaterial() {
            self.titles.append(NvLocalProvider.String(key: "测试模板", comment: "测试模板"))
            testVC.delegate = self
            self.childs.append(testVC)
        }
        
        self.nv_configData()
    }
}

extension NvTemplatePageViewController: PageTitleViewDelegate, PageContentViewDelegate, NvTemplateViewControllerDelegate {
    
    func templateView(_ templateInfo: NvTemplateInfo, didSelectItemAt index: Int) {
        let vc = NvTemplatePreviewViewController.init(for: templateInfo.id, compiled: templateInfo.isCompiled)
        vc.templateRatio = templateInfo.defaultAspectRatio
        vc.localTemplateInfo = templateInfo
        vc.isPackagingTemplate = self.isPackagingTemplate
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func titleView(_ titleView: PageTitleView, didSelectAt index: Int) {
        let indexPath = IndexPath.init(item: index, section: 0)
        contentView.collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    
    public func contentView(_ contentView: PageContentView, didEndScrollAt index: Int) {
        titleView.selectedTitle(at: index)
    }
    public func contentView(_ contentView: PageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        
    }
}

extension NvTemplatePageViewController {
    private func nv_setupPageView() {
        let startY: CGFloat = 0
        let style = PageStyle.init()
        style.isTitleViewScrollEnabled = true
        style.titleViewHeight = 34 * SCREENSCALE
        style.titleColor = UIColor.white.withAlphaComponent(0.8)
        style.titleSelectedColor = UIColor.white.withAlphaComponent(1.0)
        style.titleFont = NvUtils.fontWithSize(name: "PingFangSC-Regular", size: 12 * SCREENSCALE)
        style.titleSelectedFont = NvUtils.fontWithSize(name: "PingFangSC-Semibold", size: 12 * SCREENSCALE)
        style.titleMargin = 34 * SCREENSCALE
        style.isShowBottomLine = true
        style.bottomLineColor = UIColor.init(hex: "#FF365E") ?? .clear
        style.bottomLineHeight = 2 * SCREENSCALE
        style.bottomLineWidth = 34 * SCREENSCALE
        style.bottomLineRadius = 1 * SCREENSCALE
        style.titleViewBackgroundColor = UIColor.black
        style.contentViewBackgroundColor = UIColor.black
        let titleHeight = self.titles.count == 1 ? 0 : style.titleViewHeight * SCREENSCALE
        titleView = PageTitleView.init(frame: CGRect.init(x: 0, y: startY, width: SCREENWIDTH, height: titleHeight), style: style, titles: [], currentIndex: 0)
        contentView = PageContentView.init(frame: CGRect.init(x: 0, y: titleView.frame.maxY, width: SCREENWIDTH, height: SCREENHEIGHT - NV_STATUSBARHEIGHT - NV_NAV_BAR_HEIGHT - titleView.frame.maxY), style: style, childViewControllers: [], currentIndex: 0)
        self.view.addSubview(titleView)
        self.view.addSubview(contentView)
        titleView.delegate = self
        contentView.delegate = self
        titleView.backgroundColor = .black
        contentView.backgroundColor = .black
        titleView.clickHandler = { (_, index) in
            let indexPath = IndexPath.init(item: index, section: 0)
            self.contentView.collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }
}

extension NvTemplatePageViewController :UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text!.length > 0){
            for index in 0..<self.childs.count {
                var vc:NvTemplateViewController = self.childs[index] as! NvTemplateViewController
                vc.keyword = searchBar.text!
                if vc.isLoad {
                    vc.nv_loadNewData()
                }
            }
        }else{
            NvToast.showToastAction(message: NvLocalProvider.String(key: "Please enter the search content", comment: "请输入搜索内容") as NSString)
        }
        
        searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        for index in 0..<self.childs.count {
            var vc:NvTemplateViewController = self.childs[index] as! NvTemplateViewController
            vc.keyword = searchBar.text!
            if vc.isLoad {
                vc.nv_loadNewData()
            }
        }
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
}

