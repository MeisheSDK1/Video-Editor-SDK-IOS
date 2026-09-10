//
//  NvMoreFilterViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMoreFilterViewController.h"
#import "NvMoreFilterCell.h"
#import "NvAssetManager.h"
#import "MJRefresh.h"
#import "NvAsset.h"
#import "NvTipsView.h"
#import "AFNetworking.h"
#import "NvReachability.h"
#import "NvSDKUtils.h"
#import "NvHttpRequest.h"
#import "NvBaseModel.h"

@interface NvMoreFilterViewController ()<UITableViewDelegate, UITableViewDataSource, NvAssetManagerDelegate,NvMoreFilterCellDelegate,NvHttpRequestDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NvBaseModel *model;

@property (nonatomic, strong) UIView *failureView;

@property (nonatomic, assign) BOOL isPull;

@property (nonatomic, strong) NvAssetManager *assetManager;

@property (nonatomic, strong) NSMutableArray *filters;

@end

@implementation NvMoreFilterViewController{
    
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NvSDKUtils getMoreTitleName:self.type];
    [self addSubViews];
    // Do any additional setup after loading the view.
    
    self.filters = NSMutableArray.new;
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    
    _failureView = [[UIView alloc]initWithFrame:self.view.frame];
    _failureView.hidden = YES;
    _failureView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_failureView];
    
    UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 186 * SCREANSCALE, SCREANWIDTH, 30 * SCREANSCALE)];
    labelTitle.textAlignment = NvsTextAlignmentCenter;
    labelTitle.text = NSLocalizedString(@"Failed to load", @"加载失败！");
    labelTitle.textColor = [UIColor nv_colorWithHexRGB:@"#D0021B"];
    labelTitle.font = [NvUtils fontWithSize:19 * SCREANSCALE];
    [_failureView addSubview:labelTitle];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(158 * SCREANSCALE, 256 * SCREANSCALE, SCREANWIDTH - 2 * 158 * SCREANSCALE, 30 * SCREANSCALE);
    [btn setTitle:NSLocalizedString(@"again", @"重试") forState:UIControlStateNormal];
    btn.titleLabel.font = [NvUtils fontWithSize:12 * SCREANSCALE];
    btn.layer.cornerRadius = 4;
    btn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [btn addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
    [_failureView addSubview:btn];
}

- (void)addSubViews{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[NvMoreFilterCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
        make.width.offset(SCREEN_WDITH);
    }];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.isPull = NO;
        [weakSelf.filters removeAllObjects];
        [weakSelf.assetManager downloadRemoteAssetsInfo:weakSelf.type aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL page:0 pageSize:NV_FILTER_PAGE_SIZE];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.isPull = YES;
        int page = (int)weakSelf.filters.count/NV_FILTER_PAGE_SIZE;
        [weakSelf.assetManager downloadRemoteAssetsInfo:weakSelf.type aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL page:page pageSize:NV_FILTER_PAGE_SIZE];
    }];
    
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filters.count;
}

- (NvMoreFilterCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NvMoreFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.type = self.type;
    cell.indexPath = indexPath;
    cell.delegate = self;
    if (self.filters.count != 0) {
        cell.model = self.filters[indexPath.row];
    }
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70 * SCREANSCALE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    _failureView.hidden = YES;
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    if (_isPull) {
        if (!hasNext) {
            NvTipsView *tip = [[NvTipsView alloc]initWithFrame:self.view.frame withTitle:NSLocalizedString(@"No more", @"没有更多了") withColor:[UIColor nv_colorWithHexRGB:@"#4D4F51"] withCenter:YES];
            [self.view addSubview:tip];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tip removeFromSuperview];
            });
            return;
        }
    }
    [self.filters removeAllObjects];
    NSArray *array = [self.assetManager getRemoteAssets:self.type aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL];
    for (NvAsset *asset in array) {
        NvBaseModel *model = [[NvBaseModel alloc]init];
        model.displayName = asset.name;
        model.coverName = [asset.coverUrl absoluteString];
        model.size = [NvSDKUtils getAssetPackageSizeString:asset.remotePackageSize];
        model.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
        model.packageId = asset.uuid;
        if ([asset isUsable]) {
            if ([asset hasUpdate]) {
                model.state = Update;
            }else{
                model.state = Finish;
            }
        }else{
            model.state = NODownload;
        }
        if (!self.isCapture) {
            if (self.editModel == NvEditMode9v16) {
                if ((asset.aspectRatio & AspectRatio_9v16) != AspectRatio_9v16) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode16v9){
                if ((asset.aspectRatio & AspectRatio_16v9) != AspectRatio_16v9) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode1v1){
                if ((asset.aspectRatio & AspectRatio_1v1) != AspectRatio_1v1) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode3v4) {
                if ((asset.aspectRatio & AspectRatio_3v4) != AspectRatio_3v4) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode4v3){
                if ((asset.aspectRatio & AspectRatio_4v3) != AspectRatio_4v3) {
                    model.state = NoUser;
                }
            }
        }
        [self.filters addObject:model];
    }
    [self.tableView reloadData];
}

- (void)onDonwloadAssetFailed:(NSString *)uuid{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.filters.count; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NvMoreFilterCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            NvBaseModel *item = cell.model;
            if ([item.packageId isEqualToString:uuid]) {
                item.state = DownloadError;
                NSMutableArray *array = NSMutableArray.new;
                [array addObject:indexPath];
                [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        NvTipsView *tip = [[NvTipsView alloc]initWithFrame:self.view.frame withTitle:NSLocalizedString(@"Download failed", @"下载失败，请检查网络设置") withColor:[UIColor nv_colorWithHexRGB:@"#4D4F51"] withCenter:YES];
        [self.view addSubview:tip];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tip removeFromSuperview];
        });
    });
}

- (void)onDownloadAssetProgress:(NSString *)uuid progress:(int)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.filters.count; i++) {
            NvMoreFilterCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            NvBaseModel *item = cell.model;
            if ([item.packageId isEqualToString:uuid]) {
                cell.download.progress = progress/100.f;
            }
        }
    });
}

- (void)onDonwloadAssetSuccess:(NSString *)uuid {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.filters.count; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NvMoreFilterCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            NvBaseModel *item = cell.model;
            if ([item.packageId isEqualToString:uuid]) {
                item.state = Finish;
                NSMutableArray *array = NSMutableArray.new;
                [array addObject:indexPath];
                [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    });
}

- (void)onGetRemoteAssetsFailed{
    [self.filters removeAllObjects];
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    _failureView.hidden = NO;
}

- (void)retry:(UIButton *)sender{
    [self.tableView.mj_header beginRefreshing];
    _failureView.hidden = YES;
}

- (void)nvMoreFilterCell:(NvMoreFilterCell *)nvMoreFilterCell nvBaseModel:(NvBaseModel *)baseModel{
    if ([self isNetwork]) {
        nvMoreFilterCell.download.progress = 0;
        baseModel.state = Downloading;
        [self.assetManager downloadAsset:baseModel.packageId];
    }else{
        NvTipsView *tip = [[NvTipsView alloc]initWithFrame:self.view.frame withTitle:NSLocalizedString(@"Download failed", @"下载失败，请检查网络设置") withColor:[UIColor nv_colorWithHexRGB:@"#4D4F51"] withCenter:YES];
        [self.view addSubview:tip];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tip removeFromSuperview];
        });
    }
    
}

- (BOOL)isNetwork{
    //检测网络
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    
    NvReachability *reach = [NvReachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable) {
        return NO;
    } else if (status == ReachableViaWiFi) {
        return YES;
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
