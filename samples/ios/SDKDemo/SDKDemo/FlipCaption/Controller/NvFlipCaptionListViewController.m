//
//  NvFlipCaptionListViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFlipCaptionListViewController.h"
#import "NvBottomView.h"
#import "NvFlipCaptionTableViewCell.h"
#import "NvFlipCaptionModel.h"
#import "NvFlipCaptionColor.h"
#import "NvFlipCaptionColorViewController.h"
#import "NVDefineConfig.h"

@interface NvFlipCaptionListViewController ()<UITableViewDataSource, UITableViewDelegate, NvFlipCaptionTableViewCellDelegate>

@property (nonatomic, strong) NvFlipCaptionModel *selectModel;
@property (nonatomic, strong) NvBottomView *bottomView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *rightButtonItem;
@property (nonatomic, strong) NvFlipCaptionTableViewCell *cell;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *editButton;

@end

@implementation NvFlipCaptionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"flipCaption.EditCaption", @"编辑字幕");
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:NvImageNamed(@"NvioncolorpaletteIonicons") style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClicked)];

    self.rightButtonItem = rightBarButtonItem;
    
    self.bottomView = [NvBottomView new];
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    UITableViewController *tableViewControoler = [[UITableViewController alloc] init];
    [self addChildViewController:tableViewControoler];
    [tableViewControoler didMoveToParentViewController:self];
    self.tableView = tableViewControoler.tableView;
    self.tableView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[NvFlipCaptionTableViewCell class] forCellReuseIdentifier:@"NvFlipCaptionTableViewCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(@0);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
}

- (void)leftNavButtonClick:(UIButton *)button {
    [self.dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isEdit = NO;
        obj.isSelect = NO;
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnClicked {
    NvFlipCaptionColorViewController *flipColorVC = [[NvFlipCaptionColorViewController alloc] init];
    flipColorVC.delegate = self;
    flipColorVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:flipColorVC animated:YES completion:nil];
}

- (void)bottomViewOkClick:(NvBottomView *)bottomView {
    [self.dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isEdit = NO;
        obj.isSelect = NO;
    }];
    if ([self.delegate respondsToSelector:@selector(flipCaptionListViewController:editCaptionDataSource:)]) {
        [self.delegate flipCaptionListViewController:self editCaptionDataSource:self.dataSource];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkEditContent:(BOOL *)isSelect isEdit:(BOOL *)isEdit {
    [self.dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            *isSelect = YES;
        }
        if (obj.isEdit) {
            *isEdit = YES;
        }
    }];
}

- (void)checkRightButton {
    BOOL isSelect,isEdit;
    [self checkEditContent:&isSelect isEdit:&isEdit];
    if (isEdit) {
        self.navigationItem.rightBarButtonItem = nil;
    } else if (isSelect) {
        self.navigationItem.rightBarButtonItem = self.rightButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - 设置颜色
///Set color
- (void)flipCaptionColorViewController:(NvFlipCaptionColorViewController *)flipCaptionColorViewController didSelectItem:(NvCaptionColorItem *)item {
    [self.dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            obj.colorString = item.colorString;
        }
    }];
    [self.tableView reloadData];
}

- (void)flipCaptionColorViewController:(NvFlipCaptionColorViewController *)flipCaptionColorViewController okClickItem:(NvCaptionColorItem *)item {
    [self.dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            obj.isSelect = NO;
            obj.isEdit = NO;
        }
    }];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NvFlipCaptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NvFlipCaptionTableViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    NvFlipCaptionModel *model = self.dataSource[indexPath.row];
    [cell renderCellWithItem:model];
    return cell;
}

#pragma mark Cell
- (void)flipCaptionTableViewCell:(NvFlipCaptionTableViewCell *)flipCaptionTableViewCell changeIndexModel:(NvFlipCaptionModel *)model textViewString:(NSString *)text {
    model.text = text;
    self.selectModel = model;
    model.isEdit = !model.isEdit;
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = self.rightButtonItem;
}

- (void)flipCaptionTableViewCell:(NvFlipCaptionTableViewCell *)flipCaptionTableViewCell clickIndexModel:(NvFlipCaptionModel *)model {
    self.textView.hidden = YES;
    [self.editButton setImage:NvImageNamed(@"NvNoteSimpleLineIcons") forState:UIControlStateNormal];
    self.selectModel.isEdit = NO;
    model.isEdit = YES;
    self.cell = flipCaptionTableViewCell;
    [flipCaptionTableViewCell renderCellWithItem:model];
    [flipCaptionTableViewCell.textView becomeFirstResponder];
    self.textView = flipCaptionTableViewCell.textView;
    self.editButton = flipCaptionTableViewCell.editButton;
    self.selectModel = model;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)flipCaptionTableViewCell:(NvFlipCaptionTableViewCell *)flipCaptionTableViewCell selectForIndexModel:(NvFlipCaptionModel *)model {
    model.isSelect = !model.isSelect;
    if (!model.isSelect) {
        model.isEdit = NO;
    }
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = nil;
    [self checkRightButton];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
