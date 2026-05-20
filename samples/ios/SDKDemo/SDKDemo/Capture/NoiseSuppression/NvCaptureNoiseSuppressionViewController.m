//
//  NvCaptureNoiseSuppressionViewController.m
//  SDKDemo
//
//  Created by ms20221114 on 2022/12/28.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvCaptureNoiseSuppressionViewController.h"
#import "NvNoiseSuppressionCell.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvTimelineUtils.h"

@interface NvCaptureNoiseSuppressionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <NvBaseModel *>*dataArr;
@property (nonatomic, strong) NvsCaptureAudioFx *audioFx;

@end

@implementation NvCaptureNoiseSuppressionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self setupUI];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark -- 添加主视图 Add master view
- (void)setupUI{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(32*SCREENSCALE, 32*SCREENSCALE);
    layout.minimumInteritemSpacing= 36*SCREENSCALE;
    layout.minimumLineSpacing = (SCREENWIDTH - 130*SCREENSCALE - 32*5*SCREENSCALE)/4 ;
    layout.sectionInset = UIEdgeInsetsMake(0, 65.5*SCREENSCALE, 0, 65.5*SCREENSCALE);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 175 * SCREENSCALE) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[NvNoiseSuppressionCell class] forCellWithReuseIdentifier:@"NvNoiseSuppressionCell"];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(44*SCREENSCALE);
        make.height.offset(35*SCREENSCALE);
    }];
}

#pragma mark -- 加载数据 Load data
- (void)loadData{
    self.dataArr = [NSMutableArray array];
    
    NSArray *imgArr = @[@"NvCaptureNoiseSuppression_none",@"NvCaptureNoiseSuppression_1",@"NvCaptureNoiseSuppression_2",@"NvCaptureNoiseSuppression_3",@"NvCaptureNoiseSuppression_4"];
    NSArray *imgArr1 = @[@"NvCaptureNoiseSuppression_none_select",@"NvCaptureNoiseSuppression_1_select",@"NvCaptureNoiseSuppression_2_select",@"NvCaptureNoiseSuppression_3_select",@"NvCaptureNoiseSuppression_4_select"];
    for (int i = 0; i < imgArr.count; i++) {
        NvBaseModel *model = [NvBaseModel new];
        model.selected = NO;
        
        NSString *stirng = imgArr[i];
        model.coverDefault = stirng;
        stirng = imgArr1[i];
        model.coverName = stirng;
        [self.dataArr addObject:model];
    }
    
    NvBaseModel *model = self.dataArr.firstObject;
    model.selected = YES;
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvNoiseSuppressionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvNoiseSuppressionCell" forIndexPath:indexPath];
    [cell renderCaptureCellWithModel:self.dataArr[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvBaseModel *model in self.dataArr) {
        model.selected = NO;
    }
    NvBaseModel *model = self.dataArr[indexPath.item];
    model.selected = YES;
    [self.collectionView reloadData];
    
    if (indexPath.item == 0){
        [[NvSDKUtils getSDKContext] removeCaptureAudioFx:self.audioFx.index];
        self.audioFx = nil;
    }else{
        if (!self.audioFx){
            self.audioFx = [[NvSDKUtils getSDKContext] appendBuiltinCaptureAudioFx:NoiseSuppressionFx];
        }
        
        int level = (int)indexPath.item;
        [self.audioFx setIntVal:NoiseSuppressionLevel val:level];
    }
}

@end
