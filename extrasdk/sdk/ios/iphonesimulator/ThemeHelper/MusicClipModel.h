//
//  MusicClipModel.h
//  ThemeHelper
//
//  Created by ms20180425 on 2019/12/26.
//  Copyright © 2019 ms20180425. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicClipModel : NSObject
/// 音乐时长
@property (nonatomic, assign) int64_t duration;

/// 最大片段时长
@property (nonatomic, assign) int64_t clipMaxDuration;

/// 节奏点位
@property (nonatomic, strong) NSMutableArray *points;

/// 是否重置音乐，使用模板自带音乐
@property (nonatomic, assign) BOOL resetMusic;

/// 是否需要禁掉主题音乐
@property (nonatomic, assign) BOOL banThemeMusic;

@end

NS_ASSUME_NONNULL_END
