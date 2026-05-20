//
//  NvClipModel.h
//  NvMimoDemo
//
//  Created by MS on 2019/8/12.
//  Copyright © 2019 MS. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "NvMimoAlbumItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvCaptionModel : NSObject <NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, assign) int64_t duration;
@property (nonatomic, assign) int64_t inPoint;
@end

@interface NvSubTrackFilterModel : NSObject <NSCopying>
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSString *trackVideoPath;
@property (nonatomic, strong) NSString *trackConvertPath;
@property (nonatomic, assign) CGFloat slowSpeedValue;
///The Chinese here are interpreting the variable names without translation
@property (nonatomic, assign) int64_t trimIn;                //裁剪入点(微秒)
@property (nonatomic, assign) int64_t trimOut;               //裁剪出点(微秒)
@property (nonatomic, assign) CGFloat assetDuration; //选择资源的实际时长(微秒)
@property (nonatomic, assign) BOOL isImage;
    //是否是图片
@end

@interface NvShotRepeatModel : NSObject <NSCopying>
@property (nonatomic, assign) CGFloat start;
@property (nonatomic, assign) CGFloat end;
@property (nonatomic, assign) CGFloat count;
@property (nonatomic, assign) CGFloat originDuration;
@end

@interface NvShotSpeedModel : NSObject <NSCopying>
@property (nonatomic, assign) CGFloat start;
@property (nonatomic, assign) CGFloat end;
@property (nonatomic, assign) CGFloat speed0;
@property (nonatomic, assign) CGFloat speed1;
@end

@interface NvShotModel : NSObject <NSCopying,NSMutableCopying>
@property (nonatomic, assign) CGFloat shot;
@property (nonatomic, assign) CGFloat track;
// Specified duration (microseconds)
@property (nonatomic, assign) CGFloat duration;      //规定的时长(微秒)
// Actual duration to select the resource (in microseconds)
@property (nonatomic, assign) CGFloat assetDuration; //选择资源的实际时长(微秒)
@property (nonatomic, assign) CGFloat transLen;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, copy) NSString *compoundCaption;
//reverse indicates if the clip is replayed in reverse. Defaults to false
@property (nonatomic, assign) BOOL reverse; //reverse表示片段视频是否倒放，默认为false
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *trans;
@property (nonatomic, strong) UIImage * _Nullable coverImage;
@property (nonatomic, strong) NvMimoAlbumAsset * _Nullable asset;
/// Define this property when there is not enough time in the selected video
@property (nonatomic, assign) CGFloat slowSpeedValue; //选中视频时间不够时，定义此属性
///The Chinese here are interpreting the variable names without translation
@property (nonatomic, strong) NSArray <NvShotSpeedModel *> *speed;   //速度信息
@property (nonatomic, strong) NSArray <NvShotRepeatModel *> *repeat; //重复信息
@property (nonatomic, strong) NSString *videoPath;           //视频文件路径
@property (nonatomic, strong) NSString *convertPath;         //倒放转码视频路径
@property (nonatomic, strong) NSString *mainTrackFilter;
@property (nonatomic, strong) NSArray <NvSubTrackFilterModel *> *subTrackFilter;
@property (nonatomic, assign) BOOL isBlur;                   //是否背景模糊
@property (nonatomic, assign) int64_t start;                 //timeline 起点(微秒)
@property (nonatomic, assign) int64_t trimIn;                //裁剪入点(微秒)
@property (nonatomic, assign) int64_t trimOut;               //裁剪出点(微秒)
@property (nonatomic, assign) float volume;                  //音量
@property (nonatomic, assign) BOOL mute;                    //静音
@property (nonatomic, assign) BOOL isImage;                 //是否是图片
@property (nonatomic, strong) NSString *localIdentifier;    //图片的路径标志
@property (nonatomic, assign) BOOL isPhotoAlbum;            //是否是相册的图片
@property (nonatomic, assign) BOOL selected;
@end

@interface NvShotTranslationModel : NSObject <NSCopying>
@property (nonatomic, copy) NSString * originalText;
@property (nonatomic, copy) NSString * targetLanguage;
@property (nonatomic, copy) NSString * targetText;
@end

@interface NvThemeModel : NSObject <NSCopying>
@property (nonatomic, assign) BOOL isSelected;          //是否选中
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *music;
@property (nonatomic, copy) NSString *supportedAspectRatio;
@property (nonatomic, copy) NSString *endingFilter;
@property (nonatomic, copy) NSString *endingWatermark;
@property (nonatomic, copy) NSString *timelineFilter;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *titleFilter;
@property (nonatomic, copy) NSString *titleCaption;         //片头字幕
@property (nonatomic, assign) CGFloat titleCaptionDuration; //片头字幕持续时间
@property (nonatomic, assign) CGFloat titleFilterDuration;
@property (nonatomic, assign) CGFloat musicDuration;
@property (nonatomic, assign) CGFloat shotsNumber;
@property (nonatomic, assign) CGFloat endingFilterLen;
@property (nonatomic, strong) NSArray <NvShotTranslationModel *>*translation;    //主题名字翻译
@property (nonatomic, strong) NSArray <NvShotTranslationModel *>*tagTranslation; //主题所属分类翻译
@property (nonatomic, strong) NSArray <NvShotModel *> *shotInfos;
@property (nonatomic, strong) NSArray <NvCaptionModel *> *captionArr;
@end

NS_ASSUME_NONNULL_END
