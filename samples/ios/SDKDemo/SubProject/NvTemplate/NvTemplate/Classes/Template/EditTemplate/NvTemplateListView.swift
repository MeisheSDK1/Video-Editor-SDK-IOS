//
//  NvTemplateListView.swift
//  MYVideo
//
//  Created by meicam on 2020/11/5.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit
import Photos
enum NvTemplateEditType: Int {
    case video = 0
    case text  = 1
}

protocol NvTemplateListViewDelegate: class {
    func templateListView(_ listView: NvTemplateListView, didChangeEditType type: NvTemplateEditType)
    func templateListView(_ listView: NvTemplateListView, didSelectAtIndex index: Int, templateEdit type: NvTemplateEditType)
    func templateListView(_ listView: NvTemplateListView, willEditTemplateAtIndex index: Int, templateEdit type: NvTemplateEditType)
}

class NvTemplateListView: UIView {
    weak var delegate: NvTemplateListViewDelegate?
    init(frame: CGRect, clips: [NvTemplateEditItem], captions: [NvTemplateEditItem]) {
        super.init(frame: frame)
        clips.forEach { self.templateClips.append($0) }
        captions.forEach { self.templateCaptions.append($0) }
        nv_layoutSubviews()
        /// 默认选中视频编辑
        /// Video editing is selected by default
        self.videoEditBtn.isSelected = true
        videoEditView.nv_reloadData()
    }
    
    func reloadVideoTemplate(for asset: PHAsset?, image: UIImage?, atIndex index: Int) {
        let item = self.templateClips[index]
        if let targetAsset = asset {
            item.asset = targetAsset
        }
        if let coverImage = image {
            item.coverImage = coverImage
            item.asset = nil
        }
        videoEditView.nv_reloadData()
    }
    
    func resetTemplateState(for type: NvTemplateEditType) {
        if type == .video {
            self.templateClips.forEach { $0.isSelected = false }
            self.videoEditView.nv_reloadData()
        }else {
            self.templateCaptions.forEach { $0.isSelected = false }
            self.textEditView.nv_reloadData()
        }
    }
    
    public var templateClips: [NvTemplateEditItem] = []
    private var templateCaptions: [NvTemplateEditItem] = []
    /// 编辑类型
    /// Edit type
    private var editType: NvTemplateEditType = .video
    
    private lazy var videoEditBtn: NvEditButton = {
        let btn = NvEditButton.init()
        btn.setTitle(NvLocalProvider.String(key: "VideoEdit", comment: "视频编辑"), for: .normal)
        btn.titleLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setImage(NvUtils.imageWithName( "template_video_edit_normal"), for: .normal)
        btn.setTitleColor(UIColor.init(hex: "#FF365E"), for: .selected)
        btn.setImage(NvUtils.imageWithName( "template_video_edit_selected"), for: .selected)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0)
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    private lazy var textEditBtn: NvEditButton = {
        let btn = NvEditButton.init()
        btn.setTitle(NvLocalProvider.String(key: "TextEdit", comment: "文本编辑"), for: .normal)
        btn.titleLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setImage(NvUtils.imageWithName( "template_text_edit_normal"), for: .normal)
        btn.setTitleColor(UIColor.init(hex: "#FF365E"), for: .selected)
        btn.setImage(NvUtils.imageWithName( "template_text_edit_selected"), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 7)
        btn.contentHorizontalAlignment = .right
        return btn
    }()
    private lazy var videoEditView: NvListView = {
        let view = NvListView.init(frame: CGRect.init(x: 9 * SCREENSCALE, y: 66 * SCREENSCALE, width: frame.size.width - 9 * SCREENSCALE, height: 77 * SCREENSCALE), type: .video)
        view.backgroundColor = UIColor.init(hex: "#000000", alpha: 0.95)
        return view
    }()
    private lazy var textEditView: NvListView = {
        let view = NvListView.init(frame: CGRect.init(x: 9 * SCREENSCALE + frame.size.width, y: 66 * SCREENSCALE, width: frame.size.width - 9 * SCREENSCALE, height: 77 * SCREENSCALE), type: .text)
        view.backgroundColor = UIColor.init(hex: "#000000", alpha: 0.95)
        return view
    }()
    private lazy var lineView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: "#363636")
        return view
    }()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NvTemplateListView: NvListViewDelegate {
    func listView(listView: NvListView, didSelectedAtIndex index: Int) {
        delegate?.templateListView(self, didSelectAtIndex: index, templateEdit: editType)
    }
    
    func listView(listView: NvListView, willStartEditAtIndex index: Int) {
        if editType == .video {
            if index < templateClips.count && templateClips[index].isCanReplace {
                delegate?.templateListView(self, willEditTemplateAtIndex: index, templateEdit: editType)
            }
        }else if editType == .text {
            if index < templateCaptions.count && templateCaptions[index].isCanReplace {
                delegate?.templateListView(self, willEditTemplateAtIndex: index, templateEdit: editType)
            }
        }
    }
    @objc
    private func changeToVideoEditEvent(sender: UIButton) {

        self.videoEditView.frame = CGRect.init(x: 9 * SCREENSCALE, y: 66 * SCREENSCALE, width: frame.size.width - 9 * SCREENSCALE, height: 77 * SCREENSCALE)
        self.textEditView.frame = CGRect.init(x: 9 * SCREENSCALE + frame.size.width, y: 66 * SCREENSCALE, width: frame.size.width - 9 * SCREENSCALE, height: 77 * SCREENSCALE)
        if !sender.isSelected {
            /// 刷新
            /// refresh
            videoEditView.nv_reloadData()
        }
        sender.isSelected = true
        self.textEditBtn.isSelected = false
        self.editType = sender.isSelected ? .video : .text
        self.delegate?.templateListView(self, didChangeEditType: self.editType)
    }
    @objc
    private func changeToTextEditEvent(sender: UIButton) {
        self.videoEditView.frame = CGRect.init(x: -frame.size.width + 9 * SCREENSCALE, y: 66 * SCREENSCALE, width: frame.size.width - 9 * SCREENSCALE, height: 77 * SCREENSCALE)
        self.textEditView.frame = CGRect.init(x: 9 * SCREENSCALE, y: 66 * SCREENSCALE, width: frame.size.width - 9 * SCREENSCALE, height: 77 * SCREENSCALE)
        if !sender.isSelected {
            /// 刷新
            /// refresh
            textEditView.nv_reloadData()
        }
        sender.isSelected = true
        self.videoEditBtn.isSelected = false
        self.editType = sender.isSelected ? .text : .video
        self.delegate?.templateListView(self, didChangeEditType: self.editType)
    }
}

extension NvTemplateListView {
    private func nv_layoutSubviews() {
        self.addSubview(lineView)
        self.lineView.frame = CGRect.init(x: 0, y: 48 * SCREENSCALE, width: SCREENWIDTH, height: 0.5)
        if templateCaptions.count > 0 {
            self.addSubview(videoEditBtn)
            self.addSubview(textEditBtn)
            self.addSubview(videoEditView)
            self.addSubview(textEditView)
            videoEditBtn.frame = CGRect.init(x: 79 * SCREENSCALE, y: 15 * SCREENSCALE, width: 75 * SCREENSCALE, height: 18 * SCREENSCALE)
            textEditBtn.frame = CGRect.init(x: frame.size.width - 154 * SCREENSCALE, y: 15 * SCREENSCALE, width: 75 * SCREENSCALE, height: 18 * SCREENSCALE)
            videoEditBtn.addTarget(self, action: #selector(changeToVideoEditEvent(sender:)), for: .touchUpInside)
            textEditBtn.addTarget(self, action: #selector(changeToTextEditEvent(sender:)), for: .touchUpInside)
            videoEditView.videoSource = templateClips
            textEditView.captionSource = templateCaptions
            videoEditView.delegate = self
            textEditView.delegate = self
            
        }else {
            self.addSubview(videoEditBtn)
            self.addSubview(videoEditView)
            videoEditBtn.frame = CGRect.init(x: (frame.size.width - 75 * SCREENSCALE) * 0.5, y: 15 * SCREENSCALE, width: 75 * SCREENSCALE, height: 18 * SCREENSCALE)
            videoEditBtn.contentHorizontalAlignment = .center
            videoEditBtn.addTarget(self, action: #selector(changeToVideoEditEvent(sender:)), for: .touchUpInside)
            videoEditView.videoSource = templateClips
            videoEditView.delegate = self
        }
    }
}

//MARK: - NvListView
protocol NvListViewDelegate: class {
    func listView(listView: NvListView, didSelectedAtIndex index: Int)
    func listView(listView: NvListView, willStartEditAtIndex index: Int)
}
class NvListView: UIView {
    var videoSource = [NvTemplateEditItem]() {
        didSet {
            let maxWidth = (54 + 16) * CGFloat(videoSource.count) * SCREENSCALE + 2
            if frame.size.width >= maxWidth {
                collectionView.frame = CGRect.init(x: (frame.size.width - maxWidth) * 0.5, y: 0, width: maxWidth, height: frame.height)
            }
        }
    }
    var captionSource = [NvTemplateEditItem]() {
        didSet {
            let maxWidth = (54 + 16) * CGFloat(captionSource.count) * SCREENSCALE + 2
            if frame.size.width > maxWidth {
                collectionView.frame = CGRect.init(x: (frame.size.width - maxWidth) * 0.5, y: 0, width: maxWidth, height: frame.height)
            }
        }
    }
    
    weak var delegate: NvListViewDelegate?
    init(frame: CGRect, type: NvTemplateEditType) {
        super.init(frame: frame)
        editType = type
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize.init(width: 54 * SCREENSCALE, height: 77 * SCREENSCALE)
        layout.minimumLineSpacing = 16 * SCREENSCALE
        layout.minimumInteritemSpacing = 16 * SCREENSCALE
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        addSubview(collectionView)
        collectionView.register(NvTemplateClipEditCell.classForCoder(), forCellWithReuseIdentifier: "NvTemplateClipEditCell_Identifier_\(editType.rawValue)")
    }
    func nv_reloadData() {
        collectionView.reloadData()
    }
    private var collectionView: UICollectionView!
    private var editType: NvTemplateEditType = .video
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NvListView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if editType == .video {
            return videoSource.count
        }else {
            return captionSource.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NvTemplateClipEditCell_Identifier_\(editType.rawValue)", for: indexPath) as! NvTemplateClipEditCell
        if editType == .video {
            cell.renderCell(for: videoSource[indexPath.item], atIndex: indexPath)
        }else {
            cell.renderCell(for: captionSource[indexPath.item], atIndex: indexPath)
        }
        cell.templateEditEvent = {
            self.delegate?.listView(listView: self, willStartEditAtIndex: $0.item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editType == .video {
            videoSource.forEach { $0.isSelected = false }
            let item = videoSource[indexPath.item]
            item.isSelected = true
            collectionView.reloadData()
            delegate?.listView(listView: self, didSelectedAtIndex: indexPath.item)
        }else {
            captionSource.forEach { $0.isSelected = false }
            let item = captionSource[indexPath.item]
            item.isSelected = true
            collectionView.reloadData()
            delegate?.listView(listView: self, didSelectedAtIndex: indexPath.item)
        }
    }
}


class NvTemplateClipEditCell: UICollectionViewCell {
    public var templateEditEvent: ((_ indexPath: IndexPath) -> Void)?
    private var indexPath: IndexPath!
    private var imageView: UIImageView!
    private var timeLabel: UILabel!
    private var indexLabel: UILabel!
    private var editButton: NvAligmentButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nv_setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func renderCell(for item: NvTemplateEditItem, atIndex index: IndexPath) {
        indexPath = index
        if let asset = item.asset {
            PHImageManager.default().requestImage(for: asset, targetSize:frame.size, contentMode: .aspectFill, options: nil) { (result, info) in
                self.imageView.image = result
            }
        }else {
            self.imageView.image = item.coverImage
        }
        self.indexLabel.text = "\(item.index + 1)"
        if item.isCaption == true || item.isCompoundCaption == true {
            self.timeLabel.text = item.captionContent
        }else{
            self.timeLabel.text = NvUtils.timeToString(item.duration, afterPoint: 1) + "s"
        }
        self.editButton.backgroundColor = UIColor.init(hex: "#FF365E")
        if item.isCanReplace {
            self.editButton.isHidden = !item.isSelected
            self.editButton.setImage(NvUtils.imageWithName( "template_edit"), for: .normal)
            self.editButton.setImage(NvUtils.imageWithName( "template_edit"), for: .highlighted)
            self.editButton.setTitle(NvLocalProvider.String(key: "Click Edit", comment: "点击编辑"), for: .normal)
            self.editButton.nv_resetLayout(for: .top, space: 3 * SCREENSCALE)
            self.editButton.isEnabled = true
        }else {
            if !item.isSelected {
                self.editButton.backgroundColor = UIColor.init(hex: "#646464")
            }
            self.editButton.setImage(NvUtils.imageWithName( "template_unreplace"), for: .normal)
            self.editButton.setImage(NvUtils.imageWithName( "template_unreplace"), for: .highlighted)
            self.editButton.setTitle("  ", for: .normal)
            self.editButton.isEnabled = false
            self.editButton.isHidden = false
            self.editButton.nv_resetLayout(for: .top, space: 0)
        }
    }
}

extension NvTemplateClipEditCell {
    @objc
    private func nv_didClickEdit() {
        if self.templateEditEvent != nil {
            self.templateEditEvent!(self.indexPath)
        }
    }
    private func nv_setupSubviews() {
        let wh = self.contentView.bounds.size.width
        self.imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: wh, height: wh))
        self.imageView.backgroundColor = UIColor(hex: "#2E2E2E")
        self.imageView.isUserInteractionEnabled = true
        self.imageView.contentMode = .scaleAspectFill
        self.contentView.insertSubview(self.imageView, at: 0)
        self.imageView.layer.cornerRadius = 2 * SCREENSCALE
        self.imageView.layer.masksToBounds = true
        
        self.timeLabel = UILabel.init(frame: self.imageView.bounds)
        self.timeLabel.numberOfLines = 2
        self.timeLabel.font = NvUtils.fontWithSize(size: 11 * SCREENSCALE)
        self.timeLabel.textAlignment = .center
        self.timeLabel.textColor = UIColor.init(hex: "#FFFFFF")
        self.timeLabel.backgroundColor = UIColor.clear
        self.imageView.addSubview(self.timeLabel)
        
        self.indexLabel = UILabel.init(frame: CGRect.init(x: 0, y: self.imageView.frame.maxY, width: wh, height: frame.size.height - imageView.frame.maxY))
        self.indexLabel.font = NvUtils.fontWithSize(size: 9 * SCREENSCALE)
        self.indexLabel.textAlignment = .center
        self.indexLabel.textColor = UIColor.init(hex: "#363636")
        self.indexLabel.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.indexLabel)
        
        self.editButton = NvAligmentButton.init(frame: self.imageView.bounds, style: .top, space: 3 * SCREENSCALE)
        self.editButton.backgroundColor = UIColor.init(hex: "#FF365E")
        self.editButton.showsTouchWhenHighlighted = false
        self.editButton.titleLabel?.font = NvUtils.fontWithSize(size: 8 * SCREENSCALE)
        self.editButton.isHidden = true
        self.editButton.layer.cornerRadius = 2 * SCREENSCALE
        self.editButton.layer.masksToBounds = true
        self.contentView.addSubview(self.editButton)
        self.editButton.addTarget(self, action: #selector(nv_didClickEdit), for: .touchUpInside)
    }
}

class NvEditButton: UIButton {
    override var isHighlighted: Bool {
        set {}
        get {
            return false
        }
    }
}
