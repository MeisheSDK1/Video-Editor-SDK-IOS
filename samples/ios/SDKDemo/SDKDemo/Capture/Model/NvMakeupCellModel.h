//
//  NvMakeupCellModel.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvMakeupCellModel : NSObject
@property (nonatomic, strong) NSString *displayName;    //英文名称 English name
@property (nonatomic, strong) NSString *displayNameZhCn;//中文名称 Chinese name
@property (nonatomic, assign) BOOL hasBgColor;          //根据此字段判断cell是否需要背景颜色，并改变cell布局 Determine whether the cell needs a background color based on this field and change the cell layout
@property (nonatomic, strong) NSString *bgColorStr;     //cell 背景颜色（rgba） cell Background Color (rgba)
@property (nonatomic, strong) NSString *labelColorStr;  //cell label背景颜色（rgba） cell label Background Color (rgba)
@property (nonatomic, strong) NSString *textColorStr;   //cell label文字颜色（rgba） cell label Text Color (rgba)
@property (nonatomic, strong) NSString *coverImage;     //封面图片 Cover picture
@property (nonatomic, assign) NSInteger level;          //数据处于第几层级（整妆0，单妆1） What level is the data in (whole makeup 0, single makeup 1)
@property (nonatomic, assign) BOOL selected;            //是否选中 Whether to check
@property (nonatomic, strong) id makeup;
@property (nonatomic, assign) DownloadState state;
@end

@interface NvMakeupLevelModel : NSObject
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *displayNameZhCn;
@property (nonatomic, assign) NSInteger kind;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, assign) NSInteger materialType;
@property (nonatomic, strong) NSMutableArray <NvMakeupCellModel *>*contents;
@property (nonatomic, assign) NSInteger requestPageNum;
@end

NS_ASSUME_NONNULL_END
