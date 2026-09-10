//
//  NvShortVideoEditView.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/8/31.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvShortVideoEditView.h"
#import "NvsTimelineEditor.h"
#import "NVHeader.h"
#import "UIView+Dimension.h"
#import "NvTimelineDataModel.h"
#import "NvVideoFxItem.h"
#import "NvFxCollectionViewCell.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvFilterFxCollectionViewCell.h"
#import "NvFilterFxModel.h"

@interface NvShortVideoEditView ()<UICollectionViewDataSource, UICollectionViewDelegate, NvTimelineEditorDelegate, NvEffectWrapperDelegate>
///长按时是否已经下载完成
///asset finished or not when long press downloading
@property (nonatomic, assign) BOOL touchDownloadFinishStatus;

@end

@implementation NvShortVideoEditView {
    UIButton *_cancelBtn;           //取消按钮 cancel button
    UIButton *_saveBtn;             //保存按钮 save button
    
    UIButton *_playBtn;
    UIView *_videoFxPanelView;      //特效设置面板 fx setting view
    UIButton *_timeVideoFxBtn;      //时间线特效按钮 timeline fx button
    UIButton *_videoFxBtn;          //滤镜特效按钮 fx button
    
    UICollectionView *_timeVideoFxCollectionView;   //时间线特效列表 timeline fx collectionView
    UICollectionView *_videoFxCollectionView;       //滤镜特效列表 fx collectionView

    UIView *_timeVideoFxView;       //时间线特效视图 timeline fx view
    UIView *_videoFxView;           //滤镜特效视图 fx view
    
    UIView *_liveWindowContainer;   //视频播放窗口容器 player container
    UIView *_playView;              //视频播放窗口蒙版视图 player view
    NvsLiveWindow *_liveWindow;     //视频播放窗口 livewindow
    
    NvTimelineFxType _timelineFxType; //时间线特效类型 timeline fx type
    
    NSMutableArray *_timeVideoFxDataSource;
    unsigned int _currentTimeVideoFxIndex;
    unsigned int _currentVideoFxIndex;
    NvsTimelineEditor *_videoFxTimelineEditor;
    NSMutableArray *_videoFxDataArray;
    NSMutableArray *_needRecovervVideoFxDataArray;
    BOOL _isAddingEffect;
    BOOL _isFirstCreate;
    NSString *_recoverBuildFxName;
    BOOL _hasModified;
    BOOL _canStart;
    
    NSMutableArray *backArray;
    NSMutableArray *backOperateArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.isAddFilterFx = YES;
    [self initLiveWindow];
    [self initEffectPanel];
    
    [self setupTimelineFxData];
    return self;
}

- (void)initCancelBtn {
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 30 * SCREENSCALE, 60 * SCREENSCALE, 30 * SCREENSCALE)];
    [_cancelBtn setTitle:NvLocalString(@"Cancel", @"取消") forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = FONT16;
    [_cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_cancelBtn];
}

- (void)cancelBtnClicked {
    if ([self.delegate respondsToSelector:@selector(cancelBtnClicked)]) {
        [self.delegate cancelBtnClicked];
    }
}

- (void)initSaveBtn {
    _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 60*SCREENSCALE, 30 * SCREENSCALE, 60*SCREENSCALE, 30*SCREENSCALE)];
    [_saveBtn setTitle:NvLocalString(@"Save", @"保存") forState:UIControlStateNormal];
    _saveBtn.titleLabel.font = FONT16;
    [_saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_saveBtn];
}

- (void)saveBtnClicked {
    if ([self.delegate respondsToSelector:@selector(saveBtnClicked)]) {
        [self.delegate saveBtnClicked];
    }
}

- (void)initLiveWindow {
    _liveWindowContainer = [[UIView alloc] initWithFrame:CGRectMake(82*SCREENSCALE,
                                                                    0,
                                                                    211*SCREENSCALE,
                                                                    SCREENWIDTH)];
    _liveWindowContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:_liveWindowContainer];
    
    _liveWindow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, _liveWindowContainer.frame.size.width, _liveWindowContainer.frame.size.height)];
    [_liveWindowContainer addSubview:_liveWindow];
    
    UITapGestureRecognizer *tapLiveWindow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveWindowTapped)];
    [_liveWindow addGestureRecognizer:tapLiveWindow];
    
    _playImageView = UIImageView.new;
    _playImageView.userInteractionEnabled = YES;
    _playImageView.image = NvImageNamed(@"play - FontAwesome Copy");
    [_liveWindowContainer addSubview:_playImageView];
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self->_liveWindowContainer);
    }];
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageTapped)];
    [_playImageView addGestureRecognizer:tapImage];
}

- (void)tapImageTapped {
    if ([self.delegate respondsToSelector:@selector(imageViewTappedPlay)]) {
        [self.delegate imageViewTappedPlay];
    }
}

- (void)liveWindowTapped {
    if ([self.delegate respondsToSelector:@selector(liveWindowTappedStop)]) {
        [self.delegate liveWindowTappedStop];
    }
}

- (void)initEffectPanel {
    _videoFxPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - (49*SCREENSCALE+214*SCREENSCALE + INDICATOR), self.width, (49*SCREENSCALE+214*SCREENSCALE + INDICATOR))];
    _videoFxPanelView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    [self addSubview:_videoFxPanelView];

    [self initVideoFxBtn];
    [self initTimelineFxBtn];
}

- (void)initTimelineFxBtn {
    int buttonHeight = 49 * SCREENSCALE;
    _timeVideoFxBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2, _videoFxPanelView.height - buttonHeight - INDICATOR, SCREENWIDTH / 2, buttonHeight)];
    [_timeVideoFxBtn setTitle:NvLocalString(@"Time Fx", @"时间特效") forState:UIControlStateNormal];
    [_timeVideoFxBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _timeVideoFxBtn.titleLabel.font = [NvUtils fontWithSize:14];;
    _timeVideoFxBtn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    _timeVideoFxBtn.titleLabel.alpha = 0.8;
    [_videoFxPanelView addSubview:_timeVideoFxBtn];
    [_timeVideoFxBtn addTarget:self action:@selector(timeVideoFxBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(_videoFxBtn.right,_videoFxBtn.top+13*SCREENSCALE,1,_videoFxBtn.height-26*SCREENSCALE);
    view.backgroundColor = [UIColor whiteColor];
    view.alpha = 0.15;
    [_videoFxPanelView addSubview:view];
    
    [self initTimelineFxView];
}

- (void)initVideoFxBtn {
    int buttonHeight = 49 * SCREENSCALE;
    _videoFxBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _videoFxPanelView.height - buttonHeight - INDICATOR, SCREENWIDTH / 2, buttonHeight)];
    [_videoFxBtn setTitle:NvLocalString(@"Filter Fx", @"滤镜特效") forState:UIControlStateNormal];
    [_videoFxBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    _videoFxBtn.titleLabel.font = [NvUtils fontWithSize:14];
    _videoFxBtn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    [_videoFxPanelView addSubview:_videoFxBtn];
    [_videoFxBtn addTarget:self action:@selector(videoFxBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _videoFxBtn.top - 1 , SCREENWIDTH, 1)];
    line.backgroundColor = [UIColor whiteColor];
    line.alpha = 0.15;
    [_videoFxPanelView addSubview:line];
    [self initVideoFxView];
}

- (void)timeVideoFxBtnClicked {
    _videoFxView.hidden = YES;
    _timeVideoFxView.hidden = NO;
    
    [_videoFxBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _videoFxBtn.titleLabel.alpha = 0.8;
    
    [_timeVideoFxBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    _timeVideoFxBtn.titleLabel.alpha = 1;
    if ([self.delegate respondsToSelector:@selector(timeFxClick)]) {
        [self.delegate timeFxClick];
    }
}

- (void)videoFxBtnClicked {
    _videoFxView.hidden = NO;
    _timeVideoFxView.hidden = YES;

    [_videoFxBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    _videoFxBtn.titleLabel.alpha = 1;
    [_timeVideoFxBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _timeVideoFxBtn.titleLabel.alpha = 0.8;
    if ([self.delegate respondsToSelector:@selector(videoFxClick)]) {
        [self.delegate videoFxClick];
    }
}

- (void)revertBtnClicked {
    if ([self.delegate respondsToSelector:@selector(revertClick)]) {
        [self.delegate revertClick];
    }
}

- (void)initTimelineFxView {
    int viewHeight = 160 * SCREENSCALE;
    _timeVideoFxView = [[UIView alloc] initWithFrame:CGRectMake(0, _timeVideoFxBtn.top - viewHeight - 6*SCREENSCALE, SCREENWIDTH, viewHeight)];
    [_videoFxPanelView addSubview:_timeVideoFxView];
    _timeVideoFxView.hidden = YES;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49*SCREENSCALE, 70*SCREENSCALE);
    layout.minimumLineSpacing = (SCREENWIDTH - 13*2*SCREENSCALE - 4*49*SCREENSCALE)/3.0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 13*SCREENSCALE, 0, 13*SCREENSCALE);
    _timeVideoFxCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _timeVideoFxView.height - 70*SCREENSCALE, SCREENWIDTH, 70*SCREENSCALE) collectionViewLayout:layout];
    _timeVideoFxCollectionView.delegate = self;
    _timeVideoFxCollectionView.dataSource = self;
    _timeVideoFxCollectionView.backgroundColor = [UIColor clearColor];
    _timeVideoFxCollectionView.showsHorizontalScrollIndicator = NO;
    [_timeVideoFxView addSubview:_timeVideoFxCollectionView];
    [_timeVideoFxCollectionView registerClass:[NvFxCollectionViewCell class] forCellWithReuseIdentifier:@"NvFxCollectionViewCellTime"];
    
    UILabel *timelineFxLabel = [[UILabel alloc] initWithFrame:CGRectMake(13 * SCREENSCALE, _timeVideoFxCollectionView.top -15*SCREENSCALE - 20*SCREENSCALE, 300, 20 * SCREENSCALE)];
    timelineFxLabel.text = NvLocalString(@"selectTimeFx", @"点击选择时间特效");
    timelineFxLabel.textColor = [UIColor whiteColor];
    timelineFxLabel.alpha = 0.6;
    timelineFxLabel.font = [NvUtils boldFontWithSize:12];
    [_timeVideoFxView addSubview:timelineFxLabel];
    
    int timelineEditorHeight = 25 * SCREENSCALE;
    _timelineEditor = [[NvTimelineEditor alloc] initWithFrame:CGRectMake(13*SCREENSCALE, timelineFxLabel.top - 15*SCREENSCALE - timelineEditorHeight, _timeVideoFxView.width - 26*SCREENSCALE, timelineEditorHeight)];
    _timelineEditor.delegate = self;
    _timelineEditor.caneditTimeSpan = true;
    _timelineEditor.canOverlapTimeSpan = true;
    [_timeVideoFxView addSubview:_timelineEditor];
    
    self.repeatView = [[UIImageView alloc] initWithFrame:CGRectMake(_timelineEditor.width/2-15*SCREENSCALE, -2*SCREENSCALE, 22*SCREENSCALE, 29*SCREENSCALE)];
    self.repeatView.userInteractionEnabled = YES;
    self.repeatView.backgroundColor = [UIColor clearColor];
    self.repeatView.hidden = YES;
    [_timelineEditor addSubview:self.repeatView];
    [self.repeatView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(repeatPan:)]];
    
    
}

- (void)initVideoFxView {
    int viewHeight = 160 * SCREENSCALE;
    _videoFxView = [[UIView alloc] initWithFrame:CGRectMake(0, _videoFxBtn.top - viewHeight -6*SCREENSCALE, SCREENWIDTH, viewHeight)];
    [_videoFxPanelView addSubview:_videoFxView];
    
    UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc] init];
    layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout1.itemSize = CGSizeMake(49*SCREENSCALE, 75*SCREENSCALE);
    layout1.minimumLineSpacing = 30*SCREENSCALE;
    layout1.minimumInteritemSpacing = 0;
    layout1.sectionInset = UIEdgeInsetsMake(0, 13*SCREENSCALE, 0, 13*SCREENSCALE);
    _videoFxCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _videoFxView.height - 75*SCREENSCALE, SCREENWIDTH, 75 * SCREENSCALE) collectionViewLayout:layout1];
    _videoFxCollectionView.delegate = self;
    _videoFxCollectionView.dataSource = self;
    _videoFxCollectionView.backgroundColor = [UIColor clearColor];
    _videoFxCollectionView.showsHorizontalScrollIndicator = NO;
    [_videoFxView addSubview:_videoFxCollectionView];
    [_videoFxCollectionView registerClass:[NvFilterFxCollectionViewCell class] forCellWithReuseIdentifier:@"NvFilterFxCollectionViewCell"];
    
    UILongPressGestureRecognizer *longPress =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 0.1;
    longPress.allowableMovement = 1;
    [_videoFxCollectionView addGestureRecognizer:longPress];
    
    UILabel *videoFxLabel = [[UILabel alloc] initWithFrame:CGRectMake(13 * SCREENSCALE, _videoFxCollectionView.top -15*SCREENSCALE - 20*SCREENSCALE, 300, 20 * SCREENSCALE)];
    videoFxLabel.text = NvLocalString(@"selectPoint", @"选择位置后，按住使用效果");
    videoFxLabel.textColor = [UIColor whiteColor];
    videoFxLabel.alpha = 0.6;
    videoFxLabel.font = [NvUtils boldFontWithSize:12];
    [_videoFxView addSubview:videoFxLabel];
    
    int timelineEditorHeight = 25 * SCREENSCALE;
    _effectWrapper = [[NvEffectWrapper alloc] initWithFrame:CGRectMake(13*SCREENSCALE, videoFxLabel.top - 15*SCREENSCALE - timelineEditorHeight, _videoFxView.width - 26*SCREENSCALE, timelineEditorHeight)];
    _effectWrapper.delegate = self;
    _effectWrapper.sliderView.value = (_timelineFxType == NV_TIMELINE_FX_TYPE_REVERSE ? 1 : 0);
    [_videoFxView addSubview:_effectWrapper];
    
    _revertBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH -53 * SCREENSCALE, videoFxLabel.top, 40 * SCREENSCALE, 18 * SCREENSCALE)];
    _revertBtn.centerY = videoFxLabel.centerY;
    [_revertBtn setImage:NvImageNamed(@"revertBackgroud") forState:UIControlStateNormal];
    [_videoFxView addSubview:_revertBtn];
    _revertBtn.layer.cornerRadius = _revertBtn.height/2;
    _revertBtn.layer.masksToBounds = YES;
    [_revertBtn addTarget:self action:@selector(revertBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
   
}

#pragma mark
- (void)repeatPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:_timelineEditor];
    float value = point.x/_timelineEditor.width;
    pan.view.centerX = point.x;
    UIGestureRecognizerState status = pan.state;
    if ([self.delegate respondsToSelector:@selector(repeatPointValue:forStatus:)]) {
        [self.delegate repeatPointValue:value forStatus:status];
    }
}

#pragma mark 滤镜特效长按
///Filter effects long press
- (void)longPressAction:(UILongPressGestureRecognizer *)recognizer {
    if (!self.isAddFilterFx) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _canStart = [self.delegate canStart];
        if (!_canStart) {
            return;
        }
        CGPoint point = [recognizer locationInView:_videoFxCollectionView];
        NSIndexPath *indexPath = [_videoFxCollectionView indexPathForItemAtPoint:point];
        if (indexPath != nil) {
            NvFilterFxModel *item = _videoFxDataSource[indexPath.row];
            if (item.state == Finish) {
                self.touchDownloadFinishStatus = NO;
                [_videoFxCollectionView reloadData];
                if ([self.delegate respondsToSelector:@selector(startFilter:)]) {
                    [self.delegate startFilter:item.packageId];
                }
                
                _effectWrapper.colorBarView.timelineStartPosition = _effectWrapper.sliderView.value * _effectWrapper.colorBarView.timelineDuration;
                float posX = _effectWrapper.sliderView.value * (SCREENWIDTH - 26*SCREENSCALE);
                NSString *color = [NvSDKUtils getColorWithIndex:indexPath.row];
                [_effectWrapper.colorBarView addBar:posX width:0 color:color fxUuid:item.packageId];
            } else {
                ///下载
                ///download
                self.touchDownloadFinishStatus = YES;
                if ([self.delegate respondsToSelector:@selector(downloadAsset:)]) {
                    NvFilterFxModel *item = _videoFxDataSource[indexPath.row];
                    [self.delegate downloadAsset:item];
                }
            }
        } else {
            self.touchDownloadFinishStatus = YES;
        }

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (!_canStart) {
            return;
        }
        if (!self.touchDownloadFinishStatus) {
            if ([self.delegate respondsToSelector:@selector(stopFilter)]) {
                [self.delegate stopFilter];
            }
        }
    }
}

- (void)setupTimelineEditor:(NSMutableArray *)descArray duration:(int64_t)duration {
    [_timelineEditor setPointsPerMicrosecond:(double)SCREENWIDTH / duration];
    [_timelineEditor initTimelineEditor:descArray
                       timelineDuration:duration];
}

- (void)timelineEditor:(id)timelineEditor dragTimeAxis:(int64_t)timestamp {
    if ([self.delegate respondsToSelector:@selector(timelineEditor:dragTimeAxis:)]) {
        [self.delegate timelineEditor:timelineEditor dragTimeAxis:timestamp];
    }
}

- (void)timelineEditorDragTimeAxisEnded{
    if ([self.delegate respondsToSelector:@selector(timelineEditorDragTimeAxisEnded)]) {
        [self.delegate timelineEditorDragTimeAxisEnded];
    }
}

- (void)setupEffectWrapper:(NSMutableArray *)descArray duration:(int64_t)duration {
    _effectWrapper.sequenceView.descArray = descArray;
    _effectWrapper.sequenceView.pointsPerMicrosecond = _effectWrapper.frame.size.width/duration;//SCREENWIDTH/duration;
    _effectWrapper.colorBarView.timelineDuration = duration;
    _effectWrapper.delegate = self;
}

- (void)updateColorBarView:(NSMutableArray *)filterModelArray {
    [_effectWrapper.colorBarView clearCurrentArray];
    
    for (id videoFx in filterModelArray) {
        [_effectWrapper.colorBarView addToCurrentArray:[(NvTimeFilterInfoModel *)videoFx name]
                                               inPoint:[(NvTimeFilterInfoModel *)videoFx inPoint]
                                              outPoint:[(NvTimeFilterInfoModel *)videoFx outPoint]];
    }
    
    [_effectWrapper.colorBarView updateSubviewsByCurrentArray:_timelineFxType == NV_TIMELINE_FX_TYPE_REVERSE withColor:nil];
}

- (NvsLiveWindow *)getLiveWindow {
    return _liveWindow;
}

- (void)finishConvert {
    for (NvVideoFxItem *item in _timeVideoFxDataSource) {
        item.isAnimation = NO;
    }
    
    [_timeVideoFxCollectionView reloadData];
}

- (void)selectIndex:(int)index {
    for (int i = 0; i < _timeVideoFxDataSource.count; i++) {
        NvVideoFxItem *item = _timeVideoFxDataSource[i];
        if (index == i) {
            item.selected = YES;
            _currentTimeVideoFxIndex = index;
        } else {
            item.selected = NO;
        }
    }
}

- (void)updateProgress:(float)progress uuid:(NSString *)uuid {
    [self.videoFxDataSource enumerateObjectsUsingBlock:^(NvFilterFxModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:uuid]) {
            obj.state = Downloading;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexpath = [NSIndexPath indexPathForItem:idx inSection:0];
                NvFilterFxCollectionViewCell *cell = (NvFilterFxCollectionViewCell *)[self->_videoFxCollectionView cellForItemAtIndexPath:indexpath];
                [cell renderCellWithModel:obj];
                cell.downloadButton.status = NvDownloading;
                cell.downloadButton.progress = progress;
            });
        }
    }];
}

- (void)downloadFailduuid:(NSString *)uuid {
    [self.videoFxDataSource enumerateObjectsUsingBlock:^(NvFilterFxModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:uuid]) {
            obj.state = DownloadError;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexpath = [NSIndexPath indexPathForItem:idx inSection:0];
                NvFilterFxCollectionViewCell *cell = (NvFilterFxCollectionViewCell *)[self->_videoFxCollectionView cellForItemAtIndexPath:indexpath];
                [cell renderCellWithModel:obj];
                cell.downloadButton.status = NvNoDownload;
                cell.downloadButton.progress = 0;
            });
        }
    }];
}

# pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _videoFxCollectionView) {
        return _videoFxDataSource.count;
    } else {
        return _timeVideoFxDataSource.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _videoFxCollectionView) {
        NvFilterFxCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvFilterFxCollectionViewCell" forIndexPath:indexPath];
        cell.indexPath = indexPath;
        NvFilterFxModel *model = _videoFxDataSource[indexPath.row];
        [cell renderCellWithModel:model];
        return cell;
    } else {
        NvFxCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvFxCollectionViewCellTime" forIndexPath:indexPath];
        [cell renderCellWithItem:_timeVideoFxDataSource[indexPath.row]];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView == _timeVideoFxCollectionView) {
        for (NvVideoFxItem *item in _timeVideoFxDataSource) {
            item.isAnimation = NO;
        }
        NvVideoFxItem *item = _timeVideoFxDataSource[_currentTimeVideoFxIndex];
        item.selected = NO;
        _currentTimeVideoFxIndex = (unsigned int)indexPath.row;
        item = _timeVideoFxDataSource[indexPath.row];
        item.selected = YES;
        if (indexPath.item == 1 || indexPath.item == 2) {
            if ([self.delegate currentConvertStatus]) {
                 item.isAnimation = NO;
            } else {
                 item.isAnimation = YES;
            }
        }
        [_timeVideoFxCollectionView reloadData];
        if ([self.delegate respondsToSelector:@selector(timeFxClick:)]) {
            [self.delegate timeFxClick:indexPath];
        }
    } else {
        if (!self.isAddFilterFx) {
            return;
        }
        NvFilterFxModel *item = _videoFxDataSource[indexPath.row];
        if (item.state != Finish) {
            if ([self.delegate respondsToSelector:@selector(downloadAsset:)]) {
                NvFilterFxModel *item = _videoFxDataSource[indexPath.row];
                item.state = Downloading;
                NvFilterFxCollectionViewCell *cell = (NvFilterFxCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell renderCellWithModel:item];
                cell.downloadButton.status = NvDownloading;
                [self.delegate downloadAsset:item];
            }
        }
    }
}
#pragma mark - NvEffectWrapperDelegate
- (void)sliderValueChanged:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:slider];
    }
}

- (void)sliderValueEnd:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(sliderValueEnd:)]) {
        [self.delegate sliderValueEnd:slider];
    }
}

- (void)setVideoFxDataSource:(NSMutableArray<NvFilterFxModel *> *)videoFxDataSource {
    _videoFxDataSource = videoFxDataSource;
    [_videoFxCollectionView reloadData];
}

- (void)setupTimelineFxData {
    if (!_timeVideoFxDataSource)
        _timeVideoFxDataSource = NSMutableArray.new;
    NSArray *timeVideoFxArray = [NSArray arrayWithObjects:NvLocalString(@"None", nil), NvLocalString(@"Revert", @"倒放"), NvLocalString(@"Repeat", @"重复"), NvLocalString(@"Slowmotion", @"慢动作"), nil];
    NSArray *timelineVideoFxIconArray = [NSArray arrayWithObjects:@"NvsNone", @"shortVideoPlayRevert", @"shortVideoRepeatIcon", @"shortVideoSlowMotion", nil];
    for (int i = 0; i < timeVideoFxArray.count; i++) {
        NvVideoFxItem *item = [NvVideoFxItem new];
        item.builtinName = nil;
        item.package = nil;
        item.cover = timelineVideoFxIconArray[i];
        item.displayName = timeVideoFxArray[i];
        item.isAnimation = NO;
        if (i == _currentTimeVideoFxIndex)
            item.selected = YES;
        else
            item.selected = NO;
        [_timeVideoFxDataSource addObject:item];
    }
    
    [_timeVideoFxCollectionView reloadData];
    [_timeVideoFxCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:_currentTimeVideoFxIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}
@end
