//
//  NvAlbumTemplateView.swift
//  MYVideo
//
//  Created by chengww on 2020/11/4.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import Photos

protocol NvAlbumTemplateViewDelegate: class {
    func templateView(_ templateView: NvAlbumTemplateView, didReceive nextEvent: Bool)
    func templateView(_ templateView: NvAlbumTemplateView, didDeleteTemplate index: Int)
}

class NvAlbumTemplateView: UIView {
    weak var delegate: NvAlbumTemplateViewDelegate?
    var dataSource: [NvAlbumTemplateItem] = [] {
        didSet {
            if self.categoryTemplate == 2 {
                self.titleLabel.text = NvLocalStringFromTableInBundle(key: "album.pleaseSelect", tableName: "NvAlbum", bundle: Bundle(for: NvAlbumTemplateView.self), comment: "album.pleaseSelect")
            }else{
                if isGrouped {
                    self.indicatorView.isHidden = false
                    self.titleLabel.text = NvLocalStringFromTableInBundle(key: "album.suggestionClip", tableName: "NvAlbum", bundle: Bundle(for: NvAlbumTemplateView.self), comment: "album.suggestionClip")
                }else {
                    self.indicatorView.isHidden = true
                    self.titleLabel.text =  NvLocalStringFromTableInBundle(key: "album.selectClip", tableName: "NvAlbum", bundle: Bundle(for: NvAlbumTemplateView.self), comment: "album.selectClip")+" \(dataSource.count) "+NvLocalStringFromTableInBundle(key: "album.clip", tableName: "NvAlbum", bundle: Bundle(for: NvAlbumTemplateView.self), comment: "album.clip")
                    self.titleLabel.frame = CGRect.init(x: 17 * SCREENSCALE, y: 14 * SCREENSCALE, width: frame.size.width - 99 * SCREENSCALE, height: 14 * SCREENSCALE)
                }
            }
            
            nv_reloadData()
        }
    }
    init(frame: CGRect, hasGrouped: Bool) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "#000000", alpha: 0.95)
        self.isGrouped = hasGrouped
        nv_layoutSubviews()
    }
    
    public func nv_reloadData() {
        /// 重置选中状态
        /// Reset selected state
        dataSource.forEach { $0.isSelected = false }
        if let index = dataSource.firstIndex(where: { $0.asset == nil }){
            /// 还没有全部导入素材
            /// Not all the materials have been imported yet
            nextButton.setTitleColor(UIColor.init(hex: "#A4A4A4"), for: .normal)
            nextButton.backgroundColor = UIColor.init(hex: "#4B4B4B")
            nextButton.isEnabled = false
            dataSource[index].isSelected = true
            collectionView.reloadData()
            if index > 2 {
                collectionView.scrollToItem(at: IndexPath.init(item: index - 2, section: 0), at: .left, animated: true)
            }
        }else {
            nextButton.setTitleColor(UIColor.init(hex: "#FFFFFF"), for: .normal)
            nextButton.backgroundColor = UIColor.init(hex: "#FF365E")
            nextButton.isEnabled = true
            collectionView.reloadData()
            if dataSource.count > 0 {
                collectionView.scrollToItem(at: IndexPath.init(item: dataSource.count > 0 ? dataSource.count - 1 : 0, section: 0), at: .left, animated: true)
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var isGrouped: Bool = false
    /// 这里和网络请求的分类一致，1=标准模版，2=自适应时长模版，3=AE转换模版
    /// This is consistent with the classification of network requests, 1= standard template, 2= adaptive duration template, 3=AE conversion template
    public var categoryTemplate : Int = 1
    private var collectionView: UICollectionView!
    private var indicatorView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: "#FC2B55")
        view.layer.cornerRadius = 1.5 * SCREENSCALE
        view.layer.masksToBounds = true
        return view
    }()
    private var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .left
        label.textColor = .white
        label.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        return label
    }()
    private var nextButton: UIButton = {
        let btn = UIButton.init()
        btn.setTitle(NvLocalProvider.String(key: "Next", comment: "下一步"), for: .normal)
        btn.setTitleColor(UIColor.init(hex: "#A4A4A4"), for: .normal)
        btn.backgroundColor = UIColor.init(hex: "#4B4B4B")
        btn.titleLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        return btn
    }()
}
extension NvAlbumTemplateView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NvAlbumTemplateViewCell_Identifier", for: indexPath) as! NvAlbumTemplateViewCell
        cell.renderCell(for: dataSource[indexPath.item], atIndex: indexPath)
        cell.deleteTemplateHandle = { (index) in
            self.delegate?.templateView(self, didDeleteTemplate: index.item)
        }
        return cell
    }
}

extension NvAlbumTemplateView {
    @objc
    private func nv_didTapNextAction() {
        delegate?.templateView(self, didReceive: true)
    }
    private func nv_layoutSubviews() {
        self.addSubview(self.indicatorView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.nextButton)
        self.indicatorView.frame = CGRect.init(x: 20 * SCREENSCALE, y: 14 * SCREENSCALE + (14 - 3) * 0.5 * SCREENSCALE, width: 3 * SCREENSCALE, height: 3 * SCREENSCALE)
        self.titleLabel.frame = CGRect.init(x: 27 * SCREENSCALE, y: 14 * SCREENSCALE, width: frame.size.width - 99 * SCREENSCALE, height: 14 * SCREENSCALE)
        self.nextButton.frame = CGRect.init(x: frame.size.width - 60 * SCREENSCALE, y: 10 * SCREENSCALE, width: 50 * SCREENSCALE, height: 23 * SCREENSCALE)
        self.nextButton.layer.cornerRadius = 23 * SCREENSCALE * 0.5
        self.nextButton.layer.masksToBounds = true
        self.nextButton.addTarget(self, action: #selector(nv_didTapNextAction), for: .touchUpInside)
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize.init(width: 62 * SCREENSCALE, height: 85 * SCREENSCALE)
        layout.minimumLineSpacing = 8 * SCREENSCALE
        layout.minimumInteritemSpacing = 8 * SCREENSCALE
        collectionView = UICollectionView.init(frame: CGRect.init(x: 17 * SCREENSCALE, y: 39 * SCREENSCALE, width: SCREENWIDTH - 20 * SCREENSCALE, height: 85 * SCREENSCALE), collectionViewLayout: layout)
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        self.addSubview(collectionView)
        collectionView.register(NvAlbumTemplateViewCell.classForCoder(), forCellWithReuseIdentifier: "NvAlbumTemplateViewCell_Identifier")
    }
}


class NvAlbumTemplateViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .black
        nv_layoutItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var deleteTemplateHandle: ((_ index: IndexPath) -> Void)?
    private var indexPath: IndexPath?
    
    private lazy var coverImageView: UIImageView = {
        let view = UIImageView.init()
        view.contentMode = .scaleAspectFill
        return view
    }()
    private lazy var indexButton: NvIndexButton = {
        let btn = NvIndexButton.init()
        btn.setTitleColor(UIColor.init(hex: "#363636"), for: .normal)
        btn.setTitle("", for: .normal)
        btn.titleLabel?.font = NvUtils.fontWithSize(size: 9 * SCREENSCALE)
        return btn
    }()
    private lazy var durationLabel: UILabel = {
        let view = UILabel.init()
        view.textColor = UIColor.init(hex: "#101010")
        view.textAlignment = .center
        view.font = NvUtils.fontWithSize(size: 11 * SCREENSCALE)
        return view
    }()
    private lazy var deleteButton: UIButton = {
        let view = UIButton.init()
        view.setImage(NvUtils.imageWithName( "template_delete"), for: .normal)
        view.setImage(NvUtils.imageWithName( "template_delete"), for: .highlighted)
        return view
    }()
}

extension NvAlbumTemplateViewCell {
    public func renderCell(for item: NvAlbumTemplateItem, atIndex index: IndexPath) {
        indexPath = index
        self.indexButton.setTitle("\(item.index + 1)", for: .normal)
        if item.isGrouped {
            let colors = NvUtils.nv_getTemplateFootagesColors()
            let colorIndex: Int = item.groupId % colors.count
            if let image = NvUtils.imageWithColor(colors[colorIndex], size: CGSize.init(width: 3 * SCREENSCALE, height: 3 * SCREENSCALE)) {
                self.indexButton.setImage(image, for: .normal)
            }
        }else {
            self.indexButton.setImage(nil, for: .normal)
        }
        self.durationLabel.text = NvUtils.timeToString(item.duration, afterPoint: 1) + "s"
        if let asset = item.asset {
            let itemWH = frame.size.width - 8 * SCREENSCALE
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: itemWH, height: itemWH), contentMode: .aspectFill, options: nil) { (result, info) in
                self.coverImageView.image = result
                self.durationLabel.textColor = UIColor.white
                self.deleteButton.isHidden = false
            }
        }else {
            self.durationLabel.textColor = UIColor.init(hex: "#101010")
            self.coverImageView.image = nil
            self.deleteButton.isHidden = true
        }
        /// 设置边框
        /// Set border
        durationLabel.layer.borderWidth = item.isSelected ? SCREENSCALE : 0
    }
    @objc
    private func didTouchDeleteTemplate() {
        if let index = indexPath, self.deleteTemplateHandle != nil {
            self.deleteTemplateHandle!(index)
        }
    }
    private func nv_layoutItem() {
        contentView.insertSubview(coverImageView, at: 0)
        coverImageView.addSubview(durationLabel)
        contentView.addSubview(indexButton)
        contentView.addSubview(deleteButton)
        coverImageView.frame = CGRect.init(x: 0, y: 8 * SCREENSCALE, width: frame.size.width - 8 * SCREENSCALE, height: frame.size.width - 8 * SCREENSCALE)
        durationLabel.frame = coverImageView.bounds
        indexButton.frame = CGRect.init(x: 0, y: coverImageView.frame.maxY, width: frame.size.width - 8 * SCREENSCALE, height: frame.size.height - coverImageView.frame.maxY)
        deleteButton.frame = CGRect.init(x: frame.size.width - 16 * SCREENSCALE, y: 0, width: 16 * SCREENSCALE, height: 16 * SCREENSCALE)
        deleteButton.addTarget(self, action: #selector(didTouchDeleteTemplate), for: .touchUpInside)
        coverImageView.backgroundColor = UIColor.white
        coverImageView.layer.cornerRadius = 2 * SCREENSCALE
        coverImageView.layer.masksToBounds = true
        durationLabel.layer.borderWidth = SCREENSCALE
        durationLabel.layer.borderColor = UIColor.init(hex: "#FF365E")?.cgColor
        durationLabel.layer.cornerRadius = 2 * SCREENSCALE
    }
    
}

extension NvAlbumTemplateViewCell {
    class NvIndexButton: UIButton {
        override func layoutSubviews() {
            super.layoutSubviews()
            if let iconView = self.imageView {
                var rect = iconView.frame
                rect.size = CGSize.init(width: 3 * SCREENSCALE, height: 3 * SCREENSCALE)
                iconView.frame = rect
                iconView.layer.cornerRadius = 1.5 * SCREENSCALE
                iconView.layer.masksToBounds = true
                self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 5)
            }
        }
    }
}
