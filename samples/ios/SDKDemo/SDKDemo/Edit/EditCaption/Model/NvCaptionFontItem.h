//
//  NvCaptionFontItem.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/7.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvBaseModel.h"

@interface NvCaptionFontItem : NvBaseModel
///如果是字体代表字体的本地路径
///If it is a font, it indicates the local path of the font
//@property (nonatomic, strong) NSString *packagePath;
///如果是字体代表字体的网络路径
///If it is a font, it represents the network path of the font
@property (nonatomic, strong) NSString *packageNetPath;
@property (nonatomic, strong) NSString *fontName;

@property (nonatomic, assign) BOOL showName;
@property (nonatomic, assign) BOOL isApplyAll;
///如果被选择的是正在下载中，这个属性来标识是否最后点了这一项
///If the selected item is being downloaded, this property identifies whether it was last clicked
@property (nonatomic, assign) BOOL lastSelect;

@end
