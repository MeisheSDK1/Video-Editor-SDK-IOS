//
//  NvLiveFunctionModel.h
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/19.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 功能类型
*/
typedef enum{
    FunctionFilter = 0,       ///< 滤镜
    FunctionArscene,          ///< 人脸道具
    FunctionBeauty,           ///< 美颜
    FunctionMakeup,           ///< 美妆
    FunctionMatting,          ///< 抠像
    FunctionQuit,             ///< 退出
}FunctionType;

@interface NvLiveFunctionModel : NSObject

/// 功能类型
@property (nonatomic, assign) FunctionType functionType;

/// 未选中图标
@property (nonatomic, strong) NSString *cover_unselected;

/// 选中图标
@property (nonatomic, strong) NSString *cover_selected;

/// 是否选中
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, strong) NSString *name;

@end

NS_ASSUME_NONNULL_END
