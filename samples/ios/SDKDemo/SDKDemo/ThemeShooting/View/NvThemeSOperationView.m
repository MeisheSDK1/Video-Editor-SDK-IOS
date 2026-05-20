//
//  NvThemeSOperationView.m
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvThemeSOperationView.h"
#import "NvThemeShootFilterCVCell.h"
#import "NvFilterDataSource.h"
#import "NvCaptureFilterModel.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvCompoundCaptionTVCell.h"
#import "NvCompoundCaptionModel.h"
#import <NvBaseCommon/NvBaseViewController.h>

@interface NvThemeSOperationView()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, strong) NvCaptureFilterModel *currentModel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *captionArray;

@end

@implementation NvThemeSOperationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = [NSMutableArray array];
        self.captionArray = [NSMutableArray array];
        self.backgroundColor = UIColor.blackColor;
        [self addMainView];
    }
    return self;
}

#pragma mark 添加主视图
///Add master view
- (void)addMainView{
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FF1A1A1A"];
    [self addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.offset(44*SCREENSCALE);
    }];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"nv_beautyType_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(15 * SCREENSCALE);
        make.centerY.equalTo(headerView);
        make.height.equalTo(headerView);
        make.width.equalTo(backBtn.mas_height);
    }];
    
    self.titleLab = [UILabel new];
    self.titleLab.textColor = UIColor.whiteColor;
    self.titleLab.font = [NvUtils fontWithSize:16 * SCREENSCALE];
    [headerView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerView);
    }];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.rowHeight = 40 * SCREENSCALE;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:NvCompoundCaptionTVCell.class forCellReuseIdentifier:@"NvCompoundCaptionTVCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_bottom).offset(0*SCREENSCALE);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.offset(80*SCREENSCALE);
    }];
    
    self.slider = [UISlider new];
    [self.slider setThumbImage:[UIImage imageNamed:@"Nvslider"] forState:UIControlStateNormal];
    [self.slider setMinimumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
    [self.slider setMaximumTrackTintColor:UIColor.whiteColor];
    self.slider.maximumValue = 1;
    self.slider.minimumValue = 0;
    [self.slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:(UIControlEventValueChanged)];
    [self addSubview:self.slider];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49 * SCREENSCALE, 70*SCREENSCALE);
    layout.minimumLineSpacing = 10*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 15*SCREENSCALE, 0, 15*SCREENSCALE);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[NvThemeShootFilterCVCell class] forCellWithReuseIdentifier:@"NvThemeShootFilterCVCell"];
    [self addSubview:self.collectionView];
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-80*SCREENSCALE);
        }else{
            make.bottom.offset((-INDICATOR)-90*SCREENSCALE);
        }
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(80 * SCREENSCALE);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.collectionView.mas_top).offset(-5);
        make.left.equalTo(self).offset(50*SCREENSCALE);
        make.right.equalTo(self).offset(-50*SCREENSCALE);
        make.height.mas_equalTo(10*SCREENSCALE);
    }];
}

#pragma mark 配置滤镜数据
///Configure filter data
- (void)configFilterArray:(AspectRatio)ratio{
    NvCaptureFilterModel *model = [[NvCaptureFilterModel alloc]init];
    model.selected = NO;
    model.displayName = NvLocalString(@"None", @"无");
    model.coverName = @"NvsFilterNone";
    
    [self.dataArray addObject:model];
    
    NvAssetManager *assetManager = [NvAssetManager sharedInstance];
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"];
    [assetManager searchReservedAssets:ASSET_FILTER bundlePath:itemPath];
    [assetManager searchLocalAssets:ASSET_FILTER];

    NSArray *array = [assetManager getUsableAssets:ASSET_FILTER aspectRatio:ratio categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    for (NvAsset *asset in array) {
        if ([self isFilterExist:asset.uuid]){
            continue;
        }
        NvCaptureFilterModel *filter = [[NvCaptureFilterModel alloc]init];
        if ([asset isReserved]) {
            [self initReservedAssetName:asset];
            filter.displayName = NvLocalString(asset.displayName, @"");
            filter.coverName = asset.coverUrl;
            filter.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
            filter.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
            filter.packageId = asset.uuid;
            filter.value = 1;
            [self.dataArray addObject:filter];
        }
    }
}

#pragma mark 配置要显示的滤镜
///Configure the filters to display
- (void)configFilter:(NSString *)filter withValue:(CGFloat)value{
    self.currentModel = nil;
    if (filter && filter.length != 0) {
        for (NvCaptureFilterModel *model in self.dataArray) {
            if ([model.packageId isEqual:filter]) {
                model.selected = YES;
                self.currentModel = model;
            }else{
                model.selected = NO;
            }
        }
        
        if (self.currentModel) {
            self.slider.hidden = NO;
            self.currentModel.value = value;
            self.slider.value = self.currentModel.value;
        }else{
            for (NvCaptureFilterModel *model in self.dataArray) {
                model.selected = NO;
            }
            NvCaptureFilterModel *model = self.dataArray.firstObject;
            model.selected = YES;
            self.slider.hidden = YES;
        }
    }else{
        for (NvCaptureFilterModel *model in self.dataArray) {
            model.selected = NO;
        }
        NvCaptureFilterModel *model = self.dataArray.firstObject;
        model.selected = YES;
        self.slider.hidden = YES;
    }
    
    [self.collectionView reloadData];
}

#pragma mark 配置导航标题
///Configure navigation title
- (void)configTitle:(NSString *)title{
    self.titleLab.text = [NSString stringWithFormat:@"%@-编辑",title];
}

#pragma mark 配置界面
///Configuration interface
- (void)configFilter:(BOOL)filter withCaption:(BOOL)caption{
    self.collectionView.hidden = !filter;
    self.slider.hidden = !filter;
    self.tableView.hidden = !caption;
}

#pragma mark 配置字幕数组
///Configure subtitle array
- (void)configCaptionArray:(NSMutableArray *)captionArray{
    self.captionArray = captionArray;
    [self.tableView reloadData];
}

#pragma mark 返回
///return
- (void)backBtnClick{
    self.hidden = YES;
}

#pragma mark 滑动事件
///Slip event
- (void)sliderValueChanged{
    self.currentModel.value = self.slider.value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(themeSOperationView:withValue:)]) {
        [self.delegate themeSOperationView:self withValue:self.currentModel.value];
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvThemeShootFilterCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvThemeShootFilterCVCell" forIndexPath:indexPath];
    [cell renderCellWithFilterModel:self.dataArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvCaptureFilterModel *model in self.dataArray) {
        model.selected = NO;
    }
    
    self.currentModel = self.dataArray[indexPath.item];
    self.currentModel.selected = YES;
    
    self.slider.value = self.currentModel.value;
    
    [collectionView reloadData];
    
    if ([self.currentModel.displayName isEqualToString:NvLocalString(@"None", @"无")] ||
        [self.currentModel.displayName isEqualToString:@"无"]) {
        self.slider.hidden = YES;
    }else{
        self.slider.hidden = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(themeSOperationView:withModel:)]) {
        [self.delegate themeSOperationView:self withModel:self.currentModel];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.captionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NvCompoundCaptionTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NvCompoundCaptionTVCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.captionArray[indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NvCompoundCaptionModel *model = self.captionArray[indexPath.row];
    self.index = indexPath.row;
    if (self.delegate && [self.delegate respondsToSelector:@selector(themeSOperationView:withCaption:)]) {
        [self.delegate themeSOperationView:self withCaption:model.showName];
    }
}


- (BOOL)isFilterExist:(NSString *)uuid {
    for (NvCaptureFilterModel *item in self.dataArray) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}

- (void)initReservedAssetName:(NvAsset *)asset {
    if ([asset isReserved]) {
        if ([asset.uuid isEqualToString:@"0FBCC8A1-C16E-4FEB-BBDE-D04B91D98A40"]) {
            asset.displayName = NvLocalString(@"Fair",@"白皙");
        }
        if ([asset.uuid isEqualToString:@"6439CF7E-42D5-4239-8187-358323292FF4"]) {
            asset.displayName = NvLocalString(@"Ice Cream",@"冰激凌");
        }
        if ([asset.uuid isEqualToString:@"FAE50247-F14C-40CE-AD43-29CA3E604838"]) {
            asset.displayName = NvLocalString(@"Morning Sunlight LUT",@"晨曦");
        }
        if ([asset.uuid isEqualToString:@"BD9D5DA9-581E-4B80-95D4-218D95FC78F2"]) {
            asset.displayName = NvLocalString(@"Wind Whispers",@"风语");
        }
        if ([asset.uuid isEqualToString:@"394EB525-1B7A-4AA1-BBAD-3FD75527A60C"]) {
            asset.displayName = NvLocalString(@"B&W 2",@"黑白");
        }
        if ([asset.uuid isEqualToString:@"D1C01CF7-CA73-4CB7-A6B7-630B5FF9EC74"]) {
            asset.displayName = NvLocalString(@"ziran",@"自然");
        }
        if ([asset.uuid isEqualToString:@"12FCD2E7-1F80-4DFC-A8FD-C820CF754855"]) {
            asset.displayName = NvLocalString(@"ins Reyes LUT",@"雷耶斯");
        }
        if ([asset.uuid isEqualToString:@"D65436B7-D19F-47E0-9A2A-28CECC73D4F2"]) {
            asset.displayName = NvLocalString(@"Honey peach",@"蜜桃");
        }
        if ([asset.uuid isEqualToString:@"B7F1F498-B310-4E2D-9A75-7D8AFBBC71D8"]) {
            asset.displayName = NvLocalString(@"Chelsea LUT",@"切尔西");
        }
        if ([asset.uuid isEqualToString:@"C9CE10F1-7C77-423C-BB7F-7F090C33D5C5"]) {
            asset.displayName = NvLocalString(@"Youth",@"青春");
        }
        if ([asset.uuid isEqualToString:@"F7204261-41D8-454A-99DC-3522444739EB"]) {
            asset.displayName = NvLocalString(@"ins Jaipur",@"斋普尔");
        }
        if ([asset.uuid isEqualToString:@"E1202F90-F2C8-4A14-BFCB-8F62BBD72F56"]) {
            asset.displayName = NvLocalString(@"Tsukiji",@"筑地");
        }
    }
}

@end
