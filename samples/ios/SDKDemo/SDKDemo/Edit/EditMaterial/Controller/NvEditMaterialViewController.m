//
//  NvEditMaterialViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditMaterialViewController.h"
#import "NvEditMaterialCollectionViewCell.h"
#import "NvEditMaterialLayout.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvEditBottomCollectionViewCell.h"
#import "NvEditTailoringViewController.h"
#import "NvAlbumViewController.h"
#import <NvSDKCommon/NvBaseNavigationController.h>
#import "NvTimelineUtils.h"
#import "NvTimelineImageUtils.h"
#import "NvEditPictureViewController.h"

#import "NvEditColorCorrectViewController.h"
#import "NvEditVolumeViewController.h"
#import "NvEditNoiseSuppressionViewController.h"
#import "NvEditSpeedViewController.h"
#import "NvEditAdjustmentViewController.h"
#import "NvEditClipCaptionViewController.h"
#import "NvEditClipStickerViewController.h"
#import "NvUrlVideoMaterialVC.h"

@interface NvEditMaterialViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, NvEditMaterialLayoutDelegate, NvUrlVideoMaterialVCDelegate>

@property (nonatomic, strong) NvsStreamingContext *context;
@property (nonatomic, strong) NvsVideoTrack *track;

@property (nonatomic, strong) UICollectionView *collection;
///滑动视图数组
///Sliding view array
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UICollectionView *bottomView;
///视频编辑对应的功能数组
///Function array corresponding to video editing
@property (nonatomic, strong) NSArray *dataArray1;
///图片编辑对应的功能数组
///Image edit corresponding function array
@property (nonatomic, strong) NSArray *dataArray2;
///当前需要展示的数组
///The array that currently needs to be displayed
@property (nonatomic, strong) NSArray *currentArray;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic, assign) NSInteger currentInt;
///添加asset时dataSource的下标位置
///The subscript position of the dataSource when adding the asset
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NvTimelineData *timelineData;

@property (nonatomic, strong) NvsTimeline *currentTimeline;
///长按标识
///Long press sign
@property (nonatomic, assign) BOOL longState;

@property (nonatomic, assign) BOOL addMaterial;

@property (nonatomic, strong) UIView *line;

@end

@implementation NvEditMaterialViewController

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.title = NvLocalString(@"Edit", @"编辑");
    self.context = [NvSDKUtils getSDKContext];
    self.dataArray1 = @[@{NvLocalString(@"Crop", @"裁剪"):@"NvTrim"},
                        @{NvLocalString(@"Split", @"分割"):@"NvSplit"},
                        @{NvLocalString(@"Color correction", @"校色"):@"NvColorCorrect"},
                        @{NvLocalString(@"Adjustment", @"调整"):@"NvFlip"},
                        @{NvLocalString(@"Filter", @"滤镜"):@"NvFilterIcon"},
                        @{NvLocalString(@"Sticker", @"贴纸"):@"edit_clip_sticker"},
                        @{NvLocalString(@"Caption", @"字幕"):@"edit_clip_caption"},
                        @{NvLocalString(@"Speed", @"速度"):@"NvSpeed"},
                        @{NvLocalString(@"Volume", @"音量"):@"NvEditVolumn"},
                        @{NvLocalString(@"Audio Noise Suppression", @"声音降噪"):@"NvEditNoiseSuppression"},
                        @{NvLocalString(@"Copy", @"复制"):@"NvCopy"},
                        @{NvLocalString(@"Delete", @"删除"):@"NvEditDelete"}];
    
    self.dataArray2 = @[@{NvLocalString(@"Duration", @"时长"):@"NvSpeed"},@{NvLocalString(@"Motion", @"运动"):@"NvFlip"},@{NvLocalString(@"Color correction", @"校色"):@"NvColorCorrect"},@{NvLocalString(@"Filter", @"滤镜"):@"NvFilterIcon"},
    @{NvLocalString(@"Sticker", @"贴纸"):@"edit_clip_sticker"},
                        @{NvLocalString(@"Caption", @"字幕"):@"edit_clip_caption" },
    @{NvLocalString(@"Copy", @"复制"):@"NvCopy"},@{NvLocalString(@"Delete", @"删除"):@"NvEditDelete"}];
    [self addSubViews];
    
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    self.timelineData = [NvTimelineData sharedInstance];
    [self addLoadingImage];
}

- (void)addLoadingImage{
    if (self.dataArray.count != 0) {
        [self.dataArray removeAllObjects];
    }
    [NvTimelineUtils resetEditData:self.timeline editDataArray:[[NvTimelineData sharedInstance] editDataArray]];
    [NvTimelineUtils resetVideoFx:self.timeline videoFxDataArray:[[NvTimelineData sharedInstance] videoFxDataArray]];
    
    self.track = [self.timeline getVideoTrackByIndex:0];
    for (int i = 0; i < self.track.clipCount; i++) {
        [self.track setBuiltinTransition:i withName:@""];
        [self.track setPackagedTransition:i withPackageId:@""];
    }
    
    [self.dataArray addObjectsFromArray:self.timelineData.editDataArray];
    NvEditDataModel *firstModel = [self.dataArray firstObject];
    if (firstModel.isImage) {
        self.currentArray = self.dataArray2;
    }else{
        self.currentArray = self.dataArray1;
    }
    
    [self.collection reloadData];
    [self resetFilter];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_addMaterial) {
        _addMaterial = NO;
        [self addLoadingImage];
        NvEditDataModel *dataModel = self.dataArray[self.currentInt];
        if (dataModel.isImage) {
            self.currentArray = self.dataArray2;
        }else{
            self.currentArray = self.dataArray1;
        }
        [self. bottomView reloadData];
    }else{
        [NvTimelineUtils resetEditData:self.timeline editDataArray:[[NvTimelineData sharedInstance] editDataArray]];
    }
}

- (void)resetFilter {
    NSMutableArray *filters = [[NvTimelineData sharedInstance] videoFxDataArray];
    for (NvTimeFilterInfoModel *filter in filters) {
        filter.inPoint = 0;
        filter.outPoint = _timeline.duration;
    }
}

- (void)addSubViews{
    NvEditMaterialLayout *layout = [[NvEditMaterialLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(180*SCREENSCALE, 320*SCREENSCALE);
    layout.minimumLineSpacing = 24*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.delegate = self;
    _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0 * SCREENSCALE, 0 *SCREENSCALE, SCREENWIDTH, 320*SCREENSCALE) collectionViewLayout:layout];
    _collection.delegate = self;
    _collection.dataSource = self;
    _collection.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_collection];
    [_collection registerClass:[NvEditMaterialCollectionViewCell class] forCellWithReuseIdentifier:@"NvEditMaterialCollectionViewCell"];
    _collection.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlelongGesture:)];
    
    [_collection addGestureRecognizer:self.longPress];
    
    UIButton *finsh = [UIButton buttonWithType:UIButtonTypeCustom];
    [finsh setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finsh addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finsh];
    [finsh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finsh.mas_top).offset(-12*SCREENSCALE);
    }];
    
    UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc]init];
    layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout1.itemSize = CGSizeMake(65*SCREENSCALE, 80*SCREENSCALE);
    layout1.minimumLineSpacing = 5*SCREENSCALE;
    layout1.minimumInteritemSpacing = 0;
    _bottomView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 * SCREENSCALE, 430 *SCREENSCALE, SCREENWIDTH, 80*SCREENSCALE) collectionViewLayout:layout1];
    _bottomView.delegate = self;
    _bottomView.dataSource = self;
    _bottomView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_bottomView];
    [_bottomView registerClass:[NvEditBottomCollectionViewCell class] forCellWithReuseIdentifier:@"NvEditBottomCollectionViewCell"];
    _bottomView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@(80*SCREENSCALE));
        make.bottom.equalTo(self.line.mas_top).offset(-12*SCREENSCALE);
    }];
}

- (void)segmentation:(NSNotification *)notification{
    NSDictionary *dic= [notification userInfo];
    NSInteger integer = [dic[@"index"] integerValue];
    _collection.contentOffset = CGPointMake(integer * SCREENWIDTH/2, 0);
}

#pragma mark 功能待开发中提示
///Function to be developed prompt
- (void)toustTipView:(NSString *)title{
    [self presentAlertInfo:[NSString stringWithFormat:NvLocalString(@"Developing", @"Demo%@界面正在开发中，敬请期待。SDK内部已支持。"),title]];
}

- (void)presentAlertInfo:(NSString *)info {
    
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Tips" , @"提示")
                                  message:info
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:nil];

}

#pragma mark - 结束编辑点击事件
///End Edit click event
- (void)finshClick:(UIButton *)btn{
    [_context removeTimeline:_timeline];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 添加转场
///Add transition
- (void)addTransitionInfo {
    NvTransitionInfoModel *transitionInfo = NvTransitionInfoModel.new;
    if([[[NvTimelineData sharedInstance] transitionDataArray] count] > 0) {
        NvTransitionInfoModel *lastTransitionInfo = [[[NvTimelineData sharedInstance] transitionDataArray] lastObject];
        transitionInfo.packageId = lastTransitionInfo.packageId;
        transitionInfo.builtinName = lastTransitionInfo.builtinName;
        transitionInfo.imageUrl = lastTransitionInfo.imageUrl;
    }
    [[[NvTimelineData sharedInstance] transitionDataArray] insertObject:transitionInfo atIndex:self.currentInt+1];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _bottomView) {
        return self.currentArray.count;
    }
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.bottomView) {
        if (self.currentArray.count < indexPath.item) {
            return nil;
        }
    }
    if (collectionView == _bottomView) {
        NvEditBottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvEditBottomCollectionViewCell" forIndexPath:indexPath];
        cell.dict = self.currentArray[indexPath.item];
        return cell;
    }
    NvEditMaterialCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvEditMaterialCollectionViewCell" forIndexPath:indexPath];
    
    cell.model = self.dataArray[indexPath.item];
    cell.index = indexPath.row;
    cell.currentIndex = self.currentInt;
    cell.delegate = self;
    cell.leftView.transform = CGAffineTransformMakeScale(1, 1);
    cell.rightView.transform = cell.leftView.transform;
    cell.leftBtn.transform = CGAffineTransformMakeScale(1, 1);
    cell.rightBtn.transform = cell.leftBtn.transform;
    
    [cell setAddButtonHidden:cell.index != cell.currentIndex];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.currentArray.count < indexPath.item) {
        return;
    }
    if (collectionView == _bottomView) {
        NvEditDataModel *model = self.timelineData.editDataArray[self.currentInt];
        NSDictionary *dict = self.currentArray[indexPath.item];
        NSString *titleString = dict.allKeys[0];
        if ([titleString isEqualToString:NvLocalString(@"Copy", @"复制")]) {
            NvEditDataModel *clipModel = [model copy];
            clipModel.isLoading = YES;
            clipModel.thumImage = model.thumImage;
            [self.dataArray insertObject:clipModel atIndex:self.currentInt+1];
            [self.timelineData.editDataArray insertObject:clipModel atIndex:self.currentInt];

            NvTimeFilterInfoModel *filterInfo = [[[[NvTimelineData sharedInstance] videoFxDataArray] objectAtIndex:self.currentInt] copy];
            [[[NvTimelineData sharedInstance] videoFxDataArray] insertObject:filterInfo atIndex:self.currentInt];
            
            [self addTransitionInfo];

            [NvTimelineUtils resetEditData:self.timeline editDataArray:self.timelineData.editDataArray];
            self.currentInt++;
            [self.collection setContentOffset:CGPointMake(self.currentInt * 204 * SCREENSCALE, 0) animated:YES];
            [self.collection reloadData];
            return;
        }else if ( [titleString isEqualToString:NvLocalString(@"Delete", @"删除")]){
            if (self.dataArray.count == 1){
                [self presentAlertInfo:NvLocalString(@"Keep a clip", @"至少保留一个素材")];
                return;
            }
            [self.dataArray removeObjectAtIndex:self.currentInt];
            [self.timelineData.editDataArray removeObjectAtIndex:self.currentInt];
            [[[NvTimelineData sharedInstance] videoFxDataArray] removeObjectAtIndex:self.currentInt];
            [[[NvTimelineData sharedInstance] transitionDataArray] removeObjectAtIndex:self.currentInt];
            [NvTimelineUtils resetEditData:self.timeline editDataArray:self.timelineData.editDataArray];
            if (self.currentInt >= self.dataArray.count){
                self.currentInt = self.dataArray.count -1;
            }
            NvEditDataModel *model2 = self.timelineData.editDataArray[self.currentInt];
            self.currentArray = model2.isImage?self.dataArray2:self.dataArray1;
            [self.collection reloadData];
            [self.bottomView reloadData];
            if (self.currentInt == 0) {
                _collection.contentOffset =  CGPointMake(0, _collection.contentOffset.y);
            }else{
                _collection.contentOffset = CGPointMake(self.currentInt * 204 * SCREENSCALE, 0);
            }
            return;
        }
        if (model.isImage) {
            if ([titleString isEqualToString:NvLocalString(@"Color correction", @"校色")]) {
                NvEditColorCorrectViewController *vc = [[NvEditColorCorrectViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
                
            }else if ([titleString isEqualToString:NvLocalString(@"Filter", @"滤镜")]) {
                NvEditTailoringViewController *vc = [[NvEditTailoringViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([titleString isEqualToString:NvLocalString(@"Caption", @"字幕")]) {

                NvEditClipCaptionViewController *vc = [[NvEditClipCaptionViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([titleString isEqualToString:NvLocalString(@"Sticker", @"贴纸")]) {

                NvEditClipStickerViewController *vc = [[NvEditClipStickerViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                NvEditPictureViewController *vc = [[NvEditPictureViewController alloc]init];
                vc.editMode = _editMode;
                vc.model = model;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else if ([titleString isEqualToString:NvLocalString(@"Speed", @"速度")]){
            NvEditSpeedViewController *vc = [NvEditSpeedViewController new];
            vc.model = model;
            vc.currentIndex = self.currentInt;
            vc.editMode = _editMode;
            vc.title = titleString;
            [self.navigationController pushViewController:vc animated:YES];
        }else if([titleString isEqualToString:NvLocalString(@"Adjustment", @"调整")]){
            NvEditAdjustmentViewController *vc = [NvEditAdjustmentViewController new];
            vc.model = model;
            vc.currentIndex = self.currentInt;
            vc.editMode = _editMode;
            vc.title = titleString;
            vc.liveWindow = self.liveWindow;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            if ([titleString isEqualToString:NvLocalString(@"Color correction", @"校色")]) {
                
                NvEditColorCorrectViewController *vc = [[NvEditColorCorrectViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }else if ([titleString isEqualToString:NvLocalString(@"Volume", @"音量")]) {

                NvEditVolumeViewController *vc = [[NvEditVolumeViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }else if ([titleString isEqualToString:NvLocalString(@"Audio Noise Suppression", @"声音降噪")]) {

                NvEditNoiseSuppressionViewController *vc = [[NvEditNoiseSuppressionViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }else if ([titleString isEqualToString:NvLocalString(@"Caption", @"字幕")]) {

                NvEditClipCaptionViewController *vc = [[NvEditClipCaptionViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }else if ([titleString isEqualToString:NvLocalString(@"Sticker", @"贴纸")]) {

                NvEditClipStickerViewController *vc = [[NvEditClipStickerViewController alloc]init];
                vc.model = model;
                vc.currentIndex = self.currentInt;
                vc.editMode = _editMode;
                vc.title = titleString;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }

            __weak typeof(self) weakSelf = self;
            NvEditTailoringViewController *vc = [[NvEditTailoringViewController alloc]init];
            vc.model = model;
            vc.currentIndex = self.currentInt;
            vc.editMode = _editMode;
            vc.title = titleString;
            vc.editBlock = ^(NvEditDataModel *newModel ,BOOL type) {
                ///分割才会走这个回调
                ///Partition is going to make this call back
                if (type == 1) {
                    [weakSelf addTransitionInfo];
                    NvTimeFilterInfoModel *filterInfo = [[[[NvTimelineData sharedInstance] videoFxDataArray] objectAtIndex:weakSelf.currentInt] copy];
                    [[[NvTimelineData sharedInstance] videoFxDataArray] insertObject:filterInfo atIndex:weakSelf.currentInt + 1];
                    [weakSelf.dataArray insertObject:newModel atIndex:weakSelf.currentInt +1];
                }
                [weakSelf.collection reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    ///判断手势状态
    ///Judge gesture status
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            _longState = YES;
            ///判断手势落点位置是否在路径上
            ///Determine if the gestural landing point is on the path
            NSIndexPath *indexPath = [self.collection indexPathForItemAtPoint:[longGesture locationInView:self.collection]];
            if (indexPath == nil) {
                break;
            }
            ///在路径上则开始移动该路径上的cell
            ///On a path, the system starts to move cells on the path
            if (@available(iOS 9.0, *)) {
                [self.collection beginInteractiveMovementForItemAtIndexPath:indexPath];
                NvEditMaterialCollectionViewCell *cell = (NvEditMaterialCollectionViewCell *)[self.collection cellForItemAtIndexPath:indexPath];
                [cell setAddButtonHidden:YES];
            } else {
               
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            ///移动过程当中随时更新cell位置
            ///cell locations are updated at any time during the movement
            if (@available(iOS 9.0, *)) {
                [self.collection updateInteractiveMovementTargetPosition:[longGesture locationInView:self.collection]];
            } else {
                
            }
            break;
        case UIGestureRecognizerStateEnded:
            ///移动结束后关闭cell移动
            ///After the cell is moved, disable the cell movement
            if (@available(iOS 9.0, *)) {
                [self.collection endInteractiveMovement];
                NSIndexPath *indexPath = [self.collection indexPathForItemAtPoint:[longGesture locationInView:self.collection]];
                NvEditMaterialCollectionViewCell *cell = (NvEditMaterialCollectionViewCell *)[self.collection cellForItemAtIndexPath:indexPath];
                [cell setAddButtonHidden:NO];
                _longState = NO;
            } else {
                
            }
            break;
        default:
            if (@available(iOS 9.0, *)) {
                [self.collection cancelInteractiveMovement];
                _longState = NO;
            } else {
                
            }
            break;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    ///返回YES允许其item移动
    ///Returns YES to allow its item to be moved
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    ///取出源item数据
    ///Fetch the source item data
    id objc = [_dataArray objectAtIndex:sourceIndexPath.item];
    ///从资源数组中移除该数据
    ///Removes the data from the resource array
    [_dataArray removeObject:objc];
    ///将数据插入到资源数组中的目标位置上
    ///Inserts data into the target location in the resource array
    [_dataArray insertObject:objc atIndex:destinationIndexPath.item];
    
    [[[NvTimelineData sharedInstance] videoFxDataArray] exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];

    NvEditDataModel *model = self.timelineData.editDataArray[sourceIndexPath.item];
    [self.timelineData.editDataArray removeObject:model];
    [self.timelineData.editDataArray insertObject:model atIndex:destinationIndexPath.item];
    
    self.currentInt = destinationIndexPath.item;
    NvEditMaterialCollectionViewCell *cell = (NvEditMaterialCollectionViewCell *)[self.collection cellForItemAtIndexPath:sourceIndexPath];
    cell.index = sourceIndexPath.item;
    [self.collection reloadData];
    if (destinationIndexPath.item == 0) {
            self.collection.contentOffset = CGPointMake(0, 0);
    }else{
            self.collection.contentOffset = CGPointMake(destinationIndexPath.item * 204 * SCREENSCALE, 0);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewEndScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( !decelerate ) {
        [self scrollViewEndScroll:scrollView];
    }
}

- (void)scrollViewEndScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_collection]) {
        [_bottomView reloadData];
    }
}

#pragma mark - NvEditMaterialLayoutDelegate
- (void)nvEditMaterialLayout:(NvEditMaterialLayout *)nvEditMaterialLayout uiCollectionViewLayoutAttributes:(UICollectionViewLayoutAttributes *)layout{
    if (self.longState) {
        return;
    }
    NvEditMaterialCollectionViewCell *cell = (NvEditMaterialCollectionViewCell *)[_collection cellForItemAtIndexPath: layout.indexPath];
    if (layout.indexPath.item == 0 && self.dataArray.count == 1) {
        cell.leftView.transform = CGAffineTransformMakeScale(1, 1);
        cell.rightView.transform = cell.leftView.transform;
        cell.leftBtn.transform = CGAffineTransformMakeScale(1, 1);
        cell.rightBtn.transform = cell.leftBtn.transform;
        [cell setAddButtonHidden:NO];
        cell.currentIndex = 0;
        self.currentInt = 0;
        return;
    }
    
    if (cell.currentIndex == self.currentInt) {
        cell.leftView.transform = CGAffineTransformMakeScale(layout.alpha, 1);
        cell.rightView.transform = cell.leftView.transform;
        cell.leftBtn.transform = CGAffineTransformMakeScale(layout.alpha, layout.alpha);
        cell.rightBtn.transform = cell.leftBtn.transform;
    }

    if (abs((int)(_collection.contentOffset.x + _collection.frame.size.width/2) - (int)layout.center.x) < 3) {
        self.currentInt = layout.indexPath.item;
        NvEditDataModel *model = self.timelineData.editDataArray[self.currentInt];
        [self isImageHidden:model.isImage];

        for (int i = 0; i < _dataArray.count; i++) {
            NvEditMaterialCollectionViewCell *cell = (NvEditMaterialCollectionViewCell *)[_collection cellForItemAtIndexPath: [NSIndexPath indexPathForRow:i inSection:0]];
            cell.currentIndex = self.currentInt;
            [cell setAddButtonHidden:cell.currentIndex != cell.index];
        }
    }
    

}

#pragma mark - NvEditMaterialCollectionViewCellDelegate
- (void)addClipForIndex:(NSInteger)index {
    self.index = index;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"urlEdit"] boolValue]) {
        NvUrlVideoMaterialVC *vc = [[NvUrlVideoMaterialVC alloc] init];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NvAlbumViewController *album = [NvAlbumViewController new];
        album.delegate = self;
        NvBaseNavigationController *nav = [[NvBaseNavigationController alloc] initWithRootViewController:album];
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:nav animated:YES completion:NULL];
    }
}

#pragma mark - NvUrlVideoMaterialVCDelegate
- (void)selectVideo:(NSMutableArray *)videoPathArray {
    _addMaterial = YES;
    NSInteger index = self.index;
    for (NSDictionary *dict in videoPathArray) {
        NSString *path = dict[@"url"];
        int64_t duration = [dict[@"duration"] integerValue];
        NvEditDataModel *model = [NvEditDataModel new];
        model.isImage = NO;
        model.videoPath = path;
        model.trimIn = 0;
        model.trimOut = duration;
        model.duration = duration;
        [self.timelineData.editDataArray insertObject:model atIndex:(NSUInteger)index];
        NvTimeFilterInfoModel *filterInfo = [NvTimeFilterInfoModel new];
        [[[NvTimelineData sharedInstance] videoFxDataArray] insertObject:filterInfo atIndex:(NSUInteger)index];
        
        [self addTransitionInfo];
        [self.dataArray insertObject:model atIndex:index];
        index++;
    }
    
    [self.collection reloadData];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    [albumViewController dismissViewControllerAnimated:YES completion:NULL];
    _addMaterial = YES;
    __block NSInteger index = self.index;
    for (int i = 0;i < assets.count; i++) {
        NvAlbumAsset *asset = assets[i];
        if (asset.isLivePhoto) {
            NvEditDataModel *model = [NvEditDataModel new];
            model.isImage = NO;
            model.videoPath = asset.albumVideoPath;
            model.trimIn = 0;
            NvsAVFileInfo *fileInfo = [[NvsStreamingContext sharedInstance] getAVFileInfo:asset.albumVideoPath];
            model.trimOut = fileInfo.duration;
            model.duration = fileInfo.duration;
            [self.timelineData.editDataArray insertObject:model atIndex:(NSUInteger)index];
            NvTimeFilterInfoModel *filterInfo = [NvTimeFilterInfoModel new];
            [[[NvTimelineData sharedInstance] videoFxDataArray] insertObject:filterInfo atIndex:(NSUInteger)index];
            
            [self addTransitionInfo];
            [self.dataArray insertObject:model atIndex:index];
            index++;
            continue;
        }
        if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
            NvEditDataModel *model = [NvEditDataModel new];
            model.isImage = NO;
            model.videoPath = asset.asset.localIdentifier;
            model.trimIn = 0;
            model.trimOut = asset.asset.duration*NV_TIME_BASE;
            model.duration = asset.asset.duration*NV_TIME_BASE;
            [self.timelineData.editDataArray insertObject:model atIndex:(NSUInteger)index];
            NvTimeFilterInfoModel *filterInfo = [NvTimeFilterInfoModel new];
            [[[NvTimelineData sharedInstance] videoFxDataArray] insertObject:filterInfo atIndex:(NSUInteger)index];
            
            [self addTransitionInfo];
            [self.dataArray insertObject:model atIndex:index];
            index++;
        } else if (asset.asset.mediaType == PHAssetMediaTypeImage) {
            NvEditDataModel *model = [NvEditDataModel new];
            model.isImage = YES;
            model.isPhotoAlbum = YES;
            model.localIdentifier = asset.asset.localIdentifier;
            model.trimIn = 0;
            model.trimOut = 4*NV_TIME_BASE;
            [self.timelineData.editDataArray insertObject:model atIndex:(NSUInteger)index];
            NvTimeFilterInfoModel *filterInfo = [NvTimeFilterInfoModel new];
            [[[NvTimelineData sharedInstance] videoFxDataArray] insertObject:filterInfo atIndex:(NSUInteger)index];
            
            [self addTransitionInfo];
            [self.dataArray insertObject:model atIndex:index];
            index++;
        }
    }
    [self.collection reloadData];
}

- (void)nvAlbumViewControllerCancelClick:(NvAlbumViewController *)albumViewController {
    [albumViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)isImageHidden:(BOOL)hidden{
    if (hidden) {
        self.currentArray = self.dataArray2;
    }else{
        self.currentArray = self.dataArray1;
    }
    [self.bottomView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
