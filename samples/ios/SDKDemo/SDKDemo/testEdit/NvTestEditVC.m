//
//  NvTestEditVC.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/12.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvTestEditVC.h"
#import "NvTestEditTCell.h"
#import <NvAlbum/NvAlbumSizeViewController.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvEditViewController.h"

@interface NvTestEditVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation NvTestEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:NvImageNamed(@"Nvback") forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT);
        make.left.equalTo(self.view).offset(13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    UIButton *importBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [importBtn setTitle:NvLocalString(@"urlEditing_home_import", nil) forState:UIControlStateNormal];
    importBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [importBtn addTarget:self action:@selector(importBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:importBtn];
    [importBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backBtn);
        make.right.equalTo(self.view).offset(-13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60*SCREENSCALE;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[NvTestEditTCell class] forCellReuseIdentifier:@"NvTestEditTCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backBtn.mas_bottom).offset(0 * SCREENSCALE);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.dataArray = [NSMutableArray array];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:VIDEO_PATH(@"testedit") error:nil];
    for (NSString *string in array) {
        NvTestEditInfoModel *info = [[NvTestEditInfoModel alloc] init];
        info.displayName = string;
        info.path = [VIDEO_PATH(@"testedit") stringByAppendingPathComponent:string];
        
        [self.dataArray addObject:info];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)importBtnClick{
    BOOL state = false;
    for (NvTestEditInfoModel *info in self.dataArray) {
        if (info.isSelected) {
            state = true;
            break;
        }
    }
    
    if (!state) {
        [NvToast showInfoWithMessage:@"请选择素材"];
        return;
    }
    
    NvAlbumSizeViewController *sizeVC = [NvAlbumSizeViewController new];
    sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:sizeVC animated:NO completion:NULL];
    __weak typeof(self)weakSelf = self;
    [sizeVC selectSizeTypeBlock:^(int type) {
        [NvToast showLoading];
        
        NSMutableArray *videoPathArray = [NSMutableArray array];
        for (NvTestEditInfoModel *info in weakSelf.dataArray) {
            if (info.isSelected) {
                [videoPathArray addObject:info.path];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NvToast dismiss];
            NvEditViewController *vc  = [[NvEditViewController alloc]init];
            vc.editMode = (NvEditMode)type;
            vc.selectPath = videoPathArray;
            vc.isFromAlbum = NO;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NvTestEditTCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NvTestEditTCell" forIndexPath:indexPath];
    [cell renderCellWithItem:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NvTestEditInfoModel *info = self.dataArray[indexPath.row];
    info.isSelected = !info.isSelected;
    [tableView reloadData];
}

@end
