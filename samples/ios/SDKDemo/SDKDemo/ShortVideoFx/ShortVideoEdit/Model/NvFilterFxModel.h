//
//  NvFilterFxModel.h
//  SDKDemo
//
//  Created by 刘东旭 on 2019/1/9.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import "NvBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvFilterFxModel : NvBaseModel

@property (nonatomic, assign) BOOL showName;
///如果被选择的是正在下载中，这个属性来标识是否最后点了这一项
///If the selected item is being downloaded, this property identifies whether it was last clicked
@property (nonatomic, assign) BOOL lastSelect;
///包裹内置的图片路径
///Wrap the built-in picture path
@property (nonatomic, strong) NSString *imagePath;

@end

NS_ASSUME_NONNULL_END
