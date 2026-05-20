//
//  NvSearchViewController.h
//  SDKDemo
//
//  Created by chengww on 2020/11/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
@class NvSearchBarOption;
NS_ASSUME_NONNULL_BEGIN

@interface NvSearchViewController : NvBaseViewController

/// 初始化
/// initialization
- (instancetype)init NS_UNAVAILABLE;

/// 初始化
/// initialization
/// @param controller 搜索内容的控制器 Search content controller
/// @param options 配置选项 Configuration options
- (instancetype)initWithPredicateController: (UIViewController  *)controller
                        searchBarConfiguare: (NvSearchBarOption *)options;
@end

NS_ASSUME_NONNULL_END
