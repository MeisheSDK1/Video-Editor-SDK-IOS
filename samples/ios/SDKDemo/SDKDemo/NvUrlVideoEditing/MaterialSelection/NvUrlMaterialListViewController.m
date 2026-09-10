//
//  NvUrlMaterialListViewController.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/3.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvUrlMaterialListViewController.h"
#import "NvWaterFallLayout.h"
#import "NvUrlVideoMaterialCVCell.h"
#import "NvUrlMusicMaterialCVCell.h"
#import "MJRefresh.h"
#import <NvSDKCommon/NvHttpRequest.h>
#import <NSObject+YYModel.h>
#import "NvAudioPlayerView.h"
#import "NvAudioPlayer.h"
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvUrlMaterialListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, NvWaterFallLayoutDataSoure, NvAudioPlayerViewDelegate, NvAudioPlayerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NvAudioPlayerView *audioPlayerView;
@property (nonatomic, strong) NvAudioPlayer *audioPlayer;
@property (nonatomic, strong) NvEditSelectMusicItem *musicItem;

@property (nonatomic, strong) UIButton *selectBtn;

@end

@implementation NvUrlMaterialListViewController

-(void)dealloc {
    if (self.isMusicEdit) {
        [self.audioPlayerView removeObserver:self forKeyPath:@"hidden"];
        [self.audioPlayer pause];
        self.audioPlayer = nil;
    }
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#181818"];
    [self addSubViews];
    [self refreshHeaderAndFooter];
    [self.collectionView.mj_header beginRefreshing];
    [self addMusicView];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.isMusicEdit) {
        [self selectMusicEdit:nil];
        for (NvListMediaInfoModel *info in self.dataArray) {
            info.isPlay = false;
            info.isSelected = false;
        }
    }
}

- (void)addSubViews{
    if (!self.isMusicEdit) {
        self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selectBtn.titleLabel.font = [NvUtils regularFontWithSize:13];
        self.selectBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15* SCREENSCALE, 0, 0);
        [self.selectBtn setTitle:NvLocalString(@"urlEditing_home_select", nil) forState:UIControlStateNormal];
        [self.selectBtn setTitle:NvLocalString(@"urlEditing_home_selectCancel", nil) forState:UIControlStateSelected];
        [self.selectBtn setImage:NvImageNamed(@"NvUrlEdit_selectBtn") forState:UIControlStateNormal];
        [self.selectBtn setImage:UIImage.new forState:UIControlStateSelected];
        [self.selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.selectBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#63ABFF"] forState:UIControlStateSelected];
        [self.selectBtn addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.selectBtn];
        [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.right.equalTo(self.view).offset(-6 * SCREENSCALE);
            make.width.offset(100 * SCREENSCALE);
            make.height.offset(25 * SCREENSCALE);
        }];
    }
    
    [self.view addSubview:self.collectionView];
    if (self.selectBtn) {
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.selectBtn.mas_bottom).offset(5 * SCREENSCALE);
            make.left.right.bottom.equalTo(self.view);
        }];
    } else {
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.bottom.equalTo(self.view);
        }];
    }
    
    [self.collectionView registerClass:[NvUrlVideoMaterialCVCell class] forCellWithReuseIdentifier:NSStringFromClass([NvUrlVideoMaterialCVCell class])];
    [self.collectionView registerClass:[NvUrlMusicMaterialCVCell class] forCellWithReuseIdentifier:NSStringFromClass([NvUrlMusicMaterialCVCell class])];
    
    if (!self.isMusicEdit) {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, INDICATOR+50*SCREENSCALE, 0);
    }
}

- (void)addMusicView{
    if (self.isMusicEdit) {
        [self.view addSubview:self.audioPlayerView];
        self.audioPlayerView.delegate = self;
        
        self.audioPlayerView.hidden = YES;
        self.audioPlayer = [[NvAudioPlayer alloc] init];
        self.audioPlayer.delegate = self;
        [self.audioPlayerView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"hidden"]) {
        BOOL hidden = [change[NSKeyValueChangeNewKey] boolValue];
        if (hidden) {
            [self.audioPlayer pause];
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            [self.audioPlayer play];
            [self.audioPlayerView renderViewWithItem:self.musicItem];
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 130 * SCREENSCALE + INDICATOR, 0);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)refreshHeaderAndFooter {
    self.dataArray = [NSMutableArray array];
    self.selectDataArray = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadData:NO];
    }];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    footer.arrowView.image = nil;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData:YES];
    }];
    
    self.collectionView.mj_footer = footer;
    self.collectionView.mj_header = header;
}

- (void)loadData:(BOOL)refresh {
    __weak typeof(self)weakSelf = self;
    if (refresh) {
        self.page = 1;
    } else {
        self.page++;
    }
    [NvHttpRequest RequestListMediaInfoListWithType:self.isMusicEdit?2:1 page:self.page pageSize:20 completionBlock:^(id respondData) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.collectionView.mj_footer.isRefreshing) {
                [weakSelf.collectionView.mj_footer endRefreshing];
            }
            if (weakSelf.collectionView.mj_header.isRefreshing) {
                [weakSelf.collectionView.mj_header endRefreshing];
            }
            
            NSDictionary *dict = (NSDictionary *)respondData;
            NSNumber *code = dict[@"code"];
            if (code.intValue == 1) {
                NSDictionary *dataDic = dict[@"data"];
                NSArray *list = [NSArray yy_modelArrayWithClass:NvListMediaInfoModel.class json:dataDic[@"elements"]];
                if (list.count > 0) {
                    if (refresh) {
                        
                        if (weakSelf.selectBtn.isSelected) {
                            [weakSelf.dataArray removeAllObjects];
                            [weakSelf.dataArray addObjectsFromArray:list];
                            for (NvListMediaInfoModel *model in weakSelf.dataArray) {
                                model.selectedModel = true;
                            }
                            NSMutableArray *tmpSelectArr = [NSMutableArray array];
                            if (weakSelf.selectDataArray.count > 0) {
                                for (NvListMediaInfoModel *item in weakSelf.selectDataArray) {
                                    for (NvListMediaInfoModel *model in weakSelf.dataArray) {
                                        if ([model.url isEqualToString:item.url]) {
                                            model.isSelected = true;
                                            [tmpSelectArr addObject:model];
                                            break;
                                        }
                                    }
                                }
                            }
                            [weakSelf.selectDataArray removeAllObjects];
                            [weakSelf.selectDataArray addObjectsFromArray:tmpSelectArr];
                        } else {
                            [weakSelf.dataArray removeAllObjects];
                            [weakSelf.selectDataArray removeAllObjects];
                            [weakSelf.dataArray addObjectsFromArray:list];
                        }
                        
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(changeSelectData)]) {
                            [weakSelf.delegate changeSelectData];
                        }
                    } else {
                        [weakSelf.dataArray addObjectsFromArray:list];
                    }
                    [weakSelf.collectionView reloadData];
                } else {
                    if (!refresh && weakSelf.page > 0) {
                        weakSelf.page --;
                    }
                }
            } else {
                
            }
        });
    } failureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!refresh && weakSelf.page > 0) {
                weakSelf.page --;
            }
            if (weakSelf.collectionView.mj_footer.isRefreshing) {
                [weakSelf.collectionView.mj_footer endRefreshing];
            }
            if (weakSelf.collectionView.mj_header.isRefreshing) {
                [weakSelf.collectionView.mj_header endRefreshing];
            }
        });
    }];
}

- (void)selectBtnClick{
    for (NvListMediaInfoModel *model in self.dataArray) {
        model.selectedModel = !model.selectedModel;
    }
    
    [self.collectionView reloadData];
    
    self.selectBtn.selected = !self.selectBtn.selected;
    if (self.selectBtn.selected) {
        self.selectBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.selectBtn.titleLabel sizeToFit];
        CGFloat tempWidth = self.selectBtn.titleLabel.frame.size.width;
        [self.selectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(tempWidth);
        }];
    } else {
        self.selectBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15* SCREENSCALE, 0, 0);
        [self.selectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(100 * SCREENSCALE);
        }];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isMusicEdit) {
        NvUrlMusicMaterialCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NvUrlMusicMaterialCVCell class]) forIndexPath:indexPath];
        [cell renderCellWithItem:self.dataArray[indexPath.row]];
        return cell;
    } else {
        NvUrlVideoMaterialCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NvUrlVideoMaterialCVCell class]) forIndexPath:indexPath];
        [cell renderCellWithItem:self.dataArray[indexPath.row]];
        return cell;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isMusicEdit) {
        NvListMediaInfoModel *model = self.dataArray[indexPath.item];
        [self selectEditState:model];
    } else if (self.selectBtn.selected) {
        NvListMediaInfoModel *model = self.dataArray[indexPath.item];
        if (model.isSelected) {
            [self.selectDataArray removeObject:model];
            model.isSelected = false;
        } else {
            [self.selectDataArray addObject:model];
            model.isSelected = true;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeSelectData)]) {
            [self.delegate changeSelectData];
        }
        [collectionView reloadData];
    }
}

- (void)selectEditState:(NvListMediaInfoModel *)item {
    if (item.isSelected) {
        item.isSelected = false;
        item.isPlay = false;
        item = nil;
    }else {
        for (NvListMediaInfoModel *info in self.dataArray) {
            info.isSelected = false;
            info.isPlay = false;
        }
        item.isSelected = true;
        item.isPlay = true;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeSelectData)]) {
        [self.delegate changeSelectData];
    }
    
    if (self.isMusicEdit) {
        [self selectMusicEdit:item];
    }
}

- (void)selectMusicEdit:(NvListMediaInfoModel *)info{
    if (info) {
        [NvToast showLoading];
        self.musicItem = [[NvEditSelectMusicItem alloc] init];
        self.musicItem.musicPath = info.url;
        self.musicItem.musicName = info.displayName;
        self.musicItem.duration = info.duration;
        self.musicItem.isPlay = true;
        self.musicItem.coverUrl = info.coverUrl;
        
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [NvToast dismiss];
            [weakSelf.audioPlayer setUrlString:weakSelf.musicItem.musicPath];
            [weakSelf.audioPlayerView setLeftValue:0 rightValue:100];
            
            weakSelf.audioPlayerView.hidden = NO;
            weakSelf.trimIn = 0;
            weakSelf.trimOut = self.audioPlayer.duration;
        });
    } else {
        self.musicItem = nil;
        self.audioPlayerView.hidden = YES;
    }
}

- (void)removeSelect {
    [self.selectDataArray removeAllObjects];
    [self selectMusicEdit:nil];
}

#pragma mark - NvAudioPlayerDelegate
///当前播放的位置
///The current playing position
- (void)nvAudioPlayer:(NvAudioPlayer *)player currentTime:(double)currentTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audioPlayerView.currentValue = currentTime;
        if (currentTime>self.trimOut) {
            [self.audioPlayer seekToTime:self.trimIn];
        }
    });
}
///播放到末尾
///Play to the end
- (void)nvAudioPlayerPlayEOF:(NvAudioPlayer *)player {
    [self.audioPlayer seekToTime:self.trimIn];
    [self.audioPlayer play];
}

#pragma mark - NvAudioPlayerViewDelegate
///裁剪时拖动左滑块
///Drag the left slider while cropping
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView leftValueChanged:(float)value {
    [self.audioPlayer seekToTime:value];
    if (self.trimOut == 0) {
        self.trimOut = self.musicItem.duration;
    }
    self.trimIn = value;
    [self.audioPlayer play];
}
///裁剪时拖动右滑块
///Drag the right slider while cropping
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView rightValueChanged:(float)value {
    self.trimOut = value;
    NSLog(@"%f",value);
}

- (void)audioPlayerViewPlayClick:(NvAudioPlayerView *)audioPlayerView withPlay:(BOOL)state{
    if (state) {
        [self.audioPlayer play];
    } else {
        [self.audioPlayer pause];
    }
}

- (void)audioPlayerViewImport{
    [self.selectDataArray removeAllObjects];
    self.audioPlayerView.hidden = YES;
    NvListMediaInfoModel *info = [[NvListMediaInfoModel alloc] init];
    info.url = self.musicItem.musicPath;
    [self.selectDataArray addObject:info];
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicImport)]) {
        [self.delegate musicImport];
    }
}

#pragma mark - JYWaterFallLayoutDataSoure

- (CGFloat)waterFallLayout:(NvWaterFallLayout *)waterFallLayout heightForItemAtIndex:(NSUInteger)index width:(CGFloat)width {
    if (self.isMusicEdit) {
        return 80 * SCREENSCALE;
    }
    NvListMediaInfoModel *model = self.dataArray[index];
    return width*model.height/model.width;
}

- (CGFloat)rowMarginOfWaterFallLayout:(NvWaterFallLayout *)waterFallLayout{
    return self.isMusicEdit?0:10 * SCREENSCALE;
}

- (CGFloat)columnMarginOfWaterFallLayout:(NvWaterFallLayout *)waterFallLayout{
    return 10 * SCREENSCALE;
}

- (UIEdgeInsets)edgeInsetsOfWaterFallLayout:(NvWaterFallLayout *)waterFallLayout{
    if (self.isMusicEdit) {
        return UIEdgeInsetsMake(0, 0 , 0, 0);
    }
    return UIEdgeInsetsMake(0, 10 * SCREENSCALE, 0, 10 * SCREENSCALE);
}

- (NSUInteger)columnCountOfWaterFallLayout:(NvWaterFallLayout *)waterFallLayout {
    return self.isMusicEdit?1:2;
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear{
    
}

#pragma mark - lazy

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        NvWaterFallLayout *layout = [[NvWaterFallLayout alloc] init];
        layout.dataSource = self;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.clearColor;
    }
    return _collectionView;
}

-(NvAudioPlayerView *)audioPlayerView {
    if (!_audioPlayerView) {
        _audioPlayerView = [[NvAudioPlayerView alloc] initUrlViewWithFrame:CGRectMake(0, self.view.frame.size.height - (200 * SCREENSCALE + INDICATOR), self.view.frame.size.width, 200 * SCREENSCALE + INDICATOR)];
        _audioPlayerView.backgroundColor = UIColor.blackColor;
    }
    return _audioPlayerView;
}


@end
