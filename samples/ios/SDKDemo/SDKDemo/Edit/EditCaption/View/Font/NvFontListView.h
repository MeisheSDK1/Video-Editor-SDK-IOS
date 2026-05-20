//
//  NvFontListView.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionFontItem.h"
#import "NVHeader.h"
@class NvFontListView;

@protocol NvFontListViewDelegate
@optional
- (void)okClick;
- (void)applyFontToAllCaption:(BOOL)applyToAllCaption;
- (void)nvFontListView:(NvFontListView *)nvFontListView blodClick:(UIButton *)sender;
- (void)nvFontListView:(NvFontListView *)nvFontListView italicClick:(UIButton *)sender;
- (void)nvFontListView:(NvFontListView *)nvFontListView underLineClick:(UIButton *)sender;
- (void)selectFont:(NvCaptionFontItem *)item;
- (void)moreFontClick;

@end

@interface NvFontListView : UIView

@property (weak, nonatomic) id delegate;
@property (nonatomic, assign) BOOL containFinishButton;
@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, strong) NSMutableArray *dataSource;
///设置渲染列表数据
///Set the render list data
- (void)renderListWithItems:(NSMutableArray <NvCaptionFontItem *>*)dataSource;
///设置默认列表数据
///Set the default list data
- (void)setDefauleDataSource:(NSMutableArray *)dataSource;
///设置默认按钮
///Set default button
- (void)setDefaultFontBoldButton:(BOOL)isBold italic:(BOOL)isItalic shadow:(BOOL)isShadow underline:(BOOL)isUnderline;
@property (nonatomic, strong) UILabel *styleApplyLabel;
@property (nonatomic, strong) NvButton *applyButton;
@property (nonatomic, strong) NvCaptionFontItem *currentItem;

@property (nonatomic, strong) UIButton *boldButton;
@property (nonatomic, strong) UIButton *italicButton;
@property (nonatomic, strong) UIButton *underLineButton;

- (void)updateProgress:(float)progress uuid:(NSString *)uuid;
- (void)downloadFailduuid:(NSString *)uuid;

@end
