//
//  NvMusicTableView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMusicTableView.h"
#import "NVHeader.h"
#import "NvSelectMusicTableViewCell.h"

@interface NvMusicTableView() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *musicTableView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation NvMusicTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]init];
        self.imageView.hidden = YES;
        self.imageView.image = NvImageNamed(@"NvEditMusicNo");
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(96 * SCREENSCALE);
            make.centerX.equalTo(self.mas_centerX);
        }];
        
        self.textLabel = [[UILabel alloc]init];
        self.textLabel.hidden = YES;
        self.textLabel.text = NvLocalString(@"Noresources", @"无相关资源");
        self.textLabel.textColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
        self.textLabel.font = [NvUtils fontWithSize:12];
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(10 * SCREENSCALE);
            make.centerX.equalTo(self.imageView.mas_centerX);
        }];
        
        self.musicTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.musicTableView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.musicTableView.dataSource = self;
        self.musicTableView.delegate = self;
        self.musicTableView.rowHeight = 74*SCREENSCALE;
        [self.musicTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:self.musicTableView];
        [self.musicTableView registerClass:[NvSelectMusicTableViewCell class] forCellReuseIdentifier:@"NvSelectMusicTableViewCell"];
        [self.musicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setDataSource:(NSMutableArray <NvEditSelectMusicItem *>*)dataSource {
    if (dataSource.count == 0) {
        self.imageView.hidden = NO;
        self.textLabel.hidden = NO;
        self.musicTableView.hidden = YES;
    }else{
        self.imageView.hidden = YES;
        self.textLabel.hidden = YES;
        self.musicTableView.hidden = NO;
    }
    _dataSource = dataSource;
    [self.musicTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NvSelectMusicTableViewCell *cell = [self.musicTableView dequeueReusableCellWithIdentifier:@"NvSelectMusicTableViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell renderCellWithItem:self.dataSource[indexPath.row]];
    return cell;
}

- (void)nvSelectMusicTableViewCell:(NvSelectMusicTableViewCell *)cell playItem:(NvEditSelectMusicItem *)item {
    item.isPlay = !item.isPlay;
    [self.musicTableView reloadData];
    if ([self.delegate respondsToSelector:@selector(playItem:)]) {
        [self.delegate playItem:item];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
