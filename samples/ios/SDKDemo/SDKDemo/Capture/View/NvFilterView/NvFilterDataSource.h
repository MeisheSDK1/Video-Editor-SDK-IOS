//
//  NvFilterDataSource.h
//  SDKDemo
//
//  Created by 美摄 on 2019/8/29.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvFilterView.h"
#import "NvTimelineDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvFilterDataSource : NSObject <NvFilterViewDelegate>

/// 根据素材支持的比例初始化滤镜数据
/// Initialize the filter data according to the proportion supported by the material
/// @param ratio 比例  ratio
-(instancetype)initWithAspectRatio:(AspectRatio)ratio;

/// 根据素材支持的比例设置滤镜数据
/// Set filter data according to the proportion supported by the material
/// @param ratio 比例  ratio
-(void)setupFilterDataWithAspectRatio:(AspectRatio)ratio;

/// 根据素材支持的比例初始化滤镜数据，并且添加内建滤镜
/// Initialize the filter data according to the proportion supported by the material
/// @param ratio 比例  ratio
-(instancetype)initWithBuiltinFilterAndAspectRatio:(AspectRatio)ratio;

/// 滤镜数据  Filter data
@property (nonatomic, strong) NSMutableArray *filterDataSource;

/// 卡通滤镜数据 Cartoon filter data
@property (nonatomic, strong) NSMutableArray *cartoonFilterDataSource;
@end

NS_ASSUME_NONNULL_END
