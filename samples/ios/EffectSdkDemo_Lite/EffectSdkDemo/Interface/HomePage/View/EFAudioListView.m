//
//  EFAudioListView.m
//  EffectSdkDemo
//
//  Created by LiYong on 2021/12/20.
//  Copyright © 2021 美摄. All rights reserved.
//

#import "EFAudioListView.h"

@interface EFAudioListView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tv;
@property (nonatomic,strong)NSDictionary *info;
@property (nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation EFAudioListView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tv];
        self.dataSource = [NvUtils getMusicList];
        self.info = self.dataSource.firstObject;
    }
    return self;
}

- (void)cancelAction:(UIButton *)sender{
    [self removeFromSuperview];
}
- (void)reload{
    [self.tv reloadData];
}
- (UIImageView *)getaccessoryView:(BOOL)selected{
    if (!selected) {
        return [[UIImageView alloc]init];
    }
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_selected"]];
    imageView.frame = CGRectMake(0, 0, 20, 15);
    return imageView;
}
#pragma -mark tv delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary * info = self.dataSource[indexPath.row];
    
    cell.textLabel.text = [info objectForKey:@"name"];
    if ([self.info isEqual:info]) {
        cell.accessoryView = [self getaccessoryView:YES];
        cell.textLabel.textColor = [UIColor nv_colorWithHexRGB:@"#ffaa33"];
    }else{
        cell.accessoryView = [self getaccessoryView:NO];
        cell.textLabel.textColor = UIColor.blackColor;
    }

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.;;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * info = self.dataSource[indexPath.row];
    
    if ([info isEqual:self.info]) {
        return;
    }
    self.info = info;
    if (self.selectBlock) {
        self.selectBlock([info objectForKey:@"local_path"]);
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.tv.frame = self.bounds;
}
- (UITableView *)tv{
    if (!_tv) {
        _tv = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tv.delegate = self;
        _tv.dataSource = self;
        [_tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        UIButton * footerView = [UIButton buttonWithType:UIButtonTypeCustom];
        [footerView setTitle:@"cancel" forState:UIControlStateNormal];
        footerView.frame = CGRectMake(0, 0, self.frame.size.width, 40);
        [footerView setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [footerView addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        _tv.tableFooterView = footerView;
    }
    return _tv;
}
@end
