//
//  NvThemeShootModel.h
//  SDKDemo
//
//  Created by ms on 2020/8/3.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvBaseModel.h"
@class NvPackageInfoModel, NvShotInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvThemeShootModel : NSObject<NSCopying>
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *packageUrl;
@property (nonatomic, copy) NSString *zipUrl;
@property (nonatomic, assign) BOOL isDownload;
/// 是否是本地片段
/// Local fragment or not
@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, strong) NvPackageInfoModel *packageInfoModel;
@end

@interface NvAlertModel : NvBaseModel<NSCopying>

/// 英文
/// English
@property (nonatomic, strong) NSString *originalText;

/// 默认语言
/// Default language
@property (nonatomic, strong) NSString *targetLanguage;

/// 中文
/// Chinese
@property (nonatomic, strong) NSString *targetText;

@end

@interface NvSpeedModel : NvBaseModel<NSCopying>

/// 开始变速的时间
/// Time to start shifting
@property (nonatomic, assign) int64_t start;

/// 结束变速的时间
/// Time to end the shift
@property (nonatomic, assign) int64_t end;

/// 开始的变速
/// Initial change of speed
@property (nonatomic, assign) double speed0;

/// 结束的变速
/// End shift
@property (nonatomic, assign) double speed1;

@end

@interface NvPackageInfoModel : NSObject<NSCopying>
@property (nonatomic, copy) NSString *ID;

/// 全轨滤镜
/// Full track filter
@property (nonatomic, copy) NSString * timelineFilter;
/// 安装包
/// Installation package
@property (nonatomic, strong) NSMutableArray *childrenIDs;

/// 模板名称
/// Template name
@property (nonatomic, strong) NSString *name;

/// 模板封面图
/// Template cover
@property (nonatomic, strong) NSString *cover;

/// 模板预览视频
/// Template preview video
@property (nonatomic, strong) NSString *preview;

/// 模板片段数量
/// Number of template fragments
@property (nonatomic, assign) NSInteger shotsNumber;

/// 音乐名称
/// Music name
@property (nonatomic, assign) NSString *music;

/// 是否需要代码控制音乐，默认为0
/// Whether code is required to control music. The default value is 0
@property (nonatomic, assign) BOOL needControlMusic;

/// 控制音乐减弱时间长度，当needControlMusic为1时需写此属性
/// Controls the length of music fade. Write this property when needControlMusic is set to 1
@property (nonatomic, assign) int64_t musicFadingTime;

/// 音乐持续时间，脚本里所有时间都按照毫秒写的
/// The duration of the music. All The Times in the script are in milliseconds
@property (nonatomic, assign) int64_t musicDuration;

/// 片头滤镜
/// Header filter
@property (nonatomic, strong) NSString *titleFilter;

/// 片头滤镜持续时间
/// Header filter duration
@property (nonatomic, assign) int64_t titleFilterDuration;

/// 片头字幕
/// Opening credits
@property (nonatomic, strong) NSString *titleCaption;

/// 片头字幕持续时间
/// Opening credits duration
@property (nonatomic, assign) int64_t titleCaptionDuration;

/// 片尾压黑滤镜
/// End press black filter
@property (nonatomic, strong) NSString *endingFilter;

/// 片尾压黑滤镜持续时间
/// End press black filter duration
@property (nonatomic, assign) int64_t endingFilterLen;

@property (nonatomic, copy) NSString *supportedAspectRatio;
@property (nonatomic, strong) NSArray *translation;
@property (nonatomic, strong) NSArray <NvShotInfoModel *>*shotInfos;
@property (nonatomic, strong) NSMutableArray *realCaptureVideos;

/// 片头效果封面，若有片头滤镜或者片头字幕，需要做片头封面 255*255
/// Title effect cover, if there is a title filter or title, need to make the title cover 255*255
@property (nonatomic, strong) NSString *titleCover;

/// 片尾效果封面，若有片尾滤镜或者片尾字幕，需要做片尾封面 255*255
/// End effect cover, if there is a end filter or end caption, need to make the end cover 255*255
@property (nonatomic, strong) NSString *endingCover;

/// 模版生成时长
/// Template generation time
@property (nonatomic, assign) int64_t duration;

/// 片尾字幕
/// End caption
@property (nonatomic, strong) NSString *endingCaption;

/// 片尾字幕持续时间
/// End caption duration
@property (nonatomic, assign) int64_t endingCaptionDuration;
@end

@interface NvShotInfoModel : NSObject<NSCopying>

/// 镜头号
/// Lens number
@property (nonatomic, assign) NSInteger shot;

/// 片段持续时间
/// Segment duration
@property (nonatomic, assign) int64_t duration;

/// 片段内滤镜
/// In-fragment filter
@property (nonatomic, strong) NSString *filter;

/// 转场
/// Transition
@property (nonatomic, copy) NSString *trans;

/// 提示信息
/// Prompt message
@property (nonatomic, strong) NSArray<NvAlertModel *> *alertInfo;

/// 片段视频
/// Episodic video
@property (nonatomic, copy) NSString *source;

/// 录制视频路径
/// Recording video path
@property (nonatomic, copy) NSString *sourcePath;

/// 提示图片
/// Prompt picture
@property (nonatomic, copy) NSString *alertImage;

/// 提示图片
/// Prompt picture
@property (nonatomic, copy) NSString *alertImagePath;

/// 变速
/// Speed change
@property (nonatomic, strong) NSArray <NvSpeedModel *> *speed;

/// 片段在时间线上的入点
/// The entry point in the timeline
@property (nonatomic, assign) int64_t shotStart;

/// 要添加转场的位置点
/// The point at which you want to add a transition
@property (nonatomic, assign) int transIndex;


/// 片段组合字幕
/// Fragment composition captioning
@property (nonatomic, copy) NSString *compoundCaption;


@end

NS_ASSUME_NONNULL_END
