//
//  NvFilterSegTitleView.m
//  SDKDemo
//
//  Created by 美摄 on 2019/8/30.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvFilterSegTitleView.h"
#import "NVDefineConfig.h"
#import "NVHeader.h"

@interface NvFilterSegTitleView()
@property(nonatomic,weak)id<NvFilterSegTitleViewDelegate> delegate;
@property(nonatomic,assign)NSInteger selectedIndex;
@property(nonatomic,strong)NSMutableArray* btArray;
@end

@implementation NvFilterSegTitleView

-(instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray*)titleArray delegate:(id<NvFilterSegTitleViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedIndex = 0;
        self.delegate = delegate;
        [self setupBtArrayWithTitles:titleArray height:35 * SCREENSCALE];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray*)titleArray customHeight:(CGFloat)height delegate:(id<NvFilterSegTitleViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedIndex = 0;
        self.delegate = delegate;
        [self setupBtArrayWithTitles:titleArray height:height];
    }
    return self;
}

#pragma mark - 设置标签视图和高度
/*
 设置标签视图和高度
 Set label view and height
 
 @param titleArray 标签数组
 titleArray
 
 @param height 高度
 height
 
 */
-(void)setupBtArrayWithTitles:(NSArray*)titleArray height:(CGFloat)height{
    float btWidth = CGRectGetWidth(self.frame)/titleArray.count;
    self.btArray = [NSMutableArray array];
    for (NSInteger i = 0; i<titleArray.count; i++) {
        NSString* title = [titleArray objectAtIndex:i];
        UIButton* bt = [[UIButton alloc] initWithFrame:CGRectMake(btWidth*i, 0, btWidth, height)];
        [bt setTitle:title forState:(UIControlStateNormal)];
        [bt addTarget:self action:@selector(segBtClicked:) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:bt];
        bt.tag = i;
        bt.titleLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
        [bt setTitleColor:self.selectedIndex == i?[UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1.0]:[UIColor colorWithWhite:1 alpha:0.6] forState:(UIControlStateNormal)];
        [self.btArray addObject:bt];
    }
}

#pragma mark - 标签按钮点击事件
/*
 标签按钮点击事件
 Tab button click event
 
 @param bt 按钮
 button
 */
-(void)segBtClicked:(UIButton*)bt{
    if (bt.tag != self.selectedIndex) {
        UIButton* orBt = [self.btArray objectAtIndex:self.selectedIndex];
        UIColor *unselectColor = self.customUnSelectedColor.length > 0 ? [UIColor nv_colorWithHexRGBA:self.customUnSelectedColor] : [UIColor colorWithWhite:1 alpha:0.6];
        [orBt setTitleColor:unselectColor forState:UIControlStateNormal];
        self.selectedIndex = bt.tag;
        [bt setTitleColor:[UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1.0] forState:(UIControlStateNormal)];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didselectedIndex:)]) {
            [self.delegate didselectedIndex:bt.tag];
        }
    }
}

-(void)updateSelectedIndex:(NSInteger)index{
    if (index != self.selectedIndex) {
        UIButton* orBt = [self.btArray objectAtIndex:self.selectedIndex];
        UIColor *unselectColor = self.customUnSelectedColor.length > 0 ? [UIColor nv_colorWithHexRGBA:self.customUnSelectedColor] : [UIColor colorWithWhite:1 alpha:0.6];
        [orBt setTitleColor:unselectColor forState:UIControlStateNormal];
        self.selectedIndex = index;
        UIButton* bt = [self.btArray objectAtIndex:self.selectedIndex];
        [bt setTitleColor:[UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    }
}

- (void)setCustomUnSelectedColor:(NSString *)customUnSelectedColor {
    _customUnSelectedColor = customUnSelectedColor;
    for (UIButton *button in self.btArray) {
        if (button.tag != self.selectedIndex) {
            [button setTitleColor:[UIColor nv_colorWithHexRGBA:customUnSelectedColor] forState:UIControlStateNormal];
        }
    }
}
@end
