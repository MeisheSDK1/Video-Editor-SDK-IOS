//
//  DefineConfig.h
//  demoTool
//
//  Created by ms20180425 on 2018/5/23.
//  Copyright © 2018年 ms20180425. All rights reserved.
//

#ifndef NVDefineConfig_h
#define NVDefineConfig_h
#include "NvLocalString.h"
typedef enum {
    NvEditMode16v9 = 0,
    NvEditMode1v1,
    NvEditMode9v16,
    NvEditMode3v4,
    NvEditMode4v3,
    NvEditMode21v9,
    NvEditMode9v21,
    NvEditMode18v9,
    NvEditMode9v18,
    NvEditMode7v6,
    NvEditMode6v7,
    NvEditMode2d39v1,
    NvEditMode2d55v1,
} NvEditMode;

#define NvCurrentBundle [NSBundle bundleForClass:[self class]]
#define NvCurrentAssetBundle [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:@"bundle" inDirectory:nil].firstObject]
//从主bundle中加载,万一加载不出来用下面的
//Load from the main bundle, in case it doesn't come out to use the following
#define NvImageNamed(imageName)  [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]

//从指定的bundle中加载，万一加载不出来用下面的
//Load from the specified bundle, in case it doesn't come out to use the following
#define NvImageNamedForBundle(imageName, bundle) [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil]


#define NV_FILTER_PAGE_SIZE 20
#define NV_TIME_BASE 1000000
//保存操作数据路径
// Save operation datapath
#define NV_TIMELINEDATA_SAVE_PATH  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/NvTimelineData"]

// 素材下载路径
// Asset download path
#define NV_ASSET_DOWNLOAD_PATH                                  @"/Documents/Asset"
#define NV_ASSET_DOWNLOAD_PATH_FILTER                           @"/Documents/Asset/Filter"
#define NV_ASSET_DOWNLOAD_PATH_THEME                            @"/Documents/Asset/Theme"
#define NV_ASSET_DOWNLOAD_PATH_CAPTION                          @"/Documents/Asset/Caption"
#define NV_ASSET_DOWNLOAD_PATH_CAPTION_RENDERER                 @"/Documents/Asset/CaptionRenderer"
#define NV_ASSET_DOWNLOAD_PATH_CAPTION_CONTEXT                  @"/Documents/Asset/CaptionContext"
#define NV_ASSET_DOWNLOAD_PATH_CAPTION_ANIMATION                @"/Documents/Asset/CaptionAnimation"
#define NV_ASSET_DOWNLOAD_PATH_CAPTION_INANIMATION              @"/Documents/Asset/CaptionInAnimation"
#define NV_ASSET_DOWNLOAD_PATH_CAPTION_OUTANIMATION             @"/Documents/Asset/CaptionOutAnimation"
#define NV_ASSET_DOWNLOAD_PATH_COMPOUND_CAPTION                 @"/Documents/Asset/CompoundCaption"
#define NV_ASSET_DOWNLOAD_PATH_ANIMATEDSTICKER                  @"/Documents/Asset/AnimatedSticker"
#define NV_ASSET_DOWNLOAD_PATH_TRANSITION                       @"/Documents/Asset/Transition"
#define NV_ASSET_DOWNLOAD_PATH_CAPTURE_SCENE                    @"/Documents/Asset/CaptureScene"
#define NV_ASSET_DOWNLOAD_PATH_FONT                             @"/Documents/Asset/Font"
#define NV_ASSET_DOWNLOAD_PATH_PARTICLE                         @"/Documents/Asset/Particle"
#define NV_ASSET_DOWNLOAD_PATH_FACE_STICKER                     @"/Documents/Asset/FaceSticker"
#define NV_ASSET_DOWNLOAD_PATH_CUSTOM_ANIMATED_STICKER          @"/Documents/Asset/CustomAnimatedSticker"
#define NV_ASSET_DOWNLOAD_PATH_FACE1_STICKER                    @"/Documents/Asset/Face1Sticker"
#define NV_CUSTOM_ANIMATED_STICKER_PIC                          @"/Documents/Asset/CustomAnimatedStickerPic"
#define NV_ASSET_DOWNLOAD_PATH_WATERMARK                        @"/Documents/Asset/Watermark"
#define NV_PATH_TEMP                                            @"/Documents/Temp"
#define NV_ASSET_DOWNLOAD_PATH_SUPERZOOM                        @"/Documents/Asset/Superzoom"
#define NV_ASSET_DOWNLOAD_PATH_ARSCENE                          @"/Documents/Asset/ARScene"
#define NV_ASSET_DOWNLOAD_PATH_ANIMATIONIN                        @"/Documents/Asset/Animationin"
#define NV_ASSET_DOWNLOAD_PATH_ANIMATIONOUT                       @"/Documents/Asset/Animationout"
#define NV_ASSET_DOWNLOAD_PATH_ANIMATIONCOMBINE                     @"/Documents/Asset/Animationcombine"
#define NV_ASSET_DOWNLOAD_PATH_STICKERANIMATIONIN                        @"/Documents/Asset/StickerAnimationin"
#define NV_ASSET_DOWNLOAD_PATH_STICKERANIMATIONOUT                       @"/Documents/Asset/StickerAnimationout"
#define NV_ASSET_DOWNLOAD_PATH_STICKERANIMATIONCOMBINE                     @"/Documents/Asset/StickerAnimationcombine"
#define NV_ASSET_DOWNLOAD_PATH_BACKGROUNDSTYLE                   @"/Documents/Asset/Backgroundstyle"
#define NV_ASSET_DOWNLOAD_PATH_MAKEUP @"/Documents/Asset/Makeup"
#define NV_ASSET_DOWNLOAD_PATH_BEAUTY_TEMPLATE @"/Documents/Asset/BeautyTemplate"
#define NV_ASSET_COPY_PATH_GIF @"/Documents/Asset/Gif"
#define NV_ASSET_COPY_PATH_MASTERKEYER_BACKGROUND_IMAGE @"/Documents/Asset/MasterKeyer/BGImage"
#define INANIMATIONCATEGORYID 8
#define OUTANIMATIONCATEGORYID 9
#define COMBINEANIMATIONCATEGORYID 10

#define NVWeakSelf __weak typeof(self) weakSelf = self;
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define SCREENSCALE (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCREENWIDTH / 768.0 : SCREENWIDTH / 375.0)

#define KScale6s(value) (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? (value * (SCREENWIDTH / 768.0)) : (value * (SCREENWIDTH / 375.0)))

#define SCREENSCALEHEIGHT (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCREENHEIGHT / 1024.0 : SCREENHEIGHT / 667.0)

#define FONT10 [UIFont systemFontOfSize:10];
#define FONT12 [UIFont systemFontOfSize:12];
#define FONT14 [UIFont systemFontOfSize:14];
#define FONT16 [UIFont systemFontOfSize:16];
#define NV_CAPTURE_SPEEDBAR_COLOR       @"52D3FF"
#define NV_CAPTURE_PROGRESS_BACKGROUND  @"EAEAEA"
#define STYLE_COLOR         [UIColor nv_colorWithHexARGB:@"#FF52D3FF"]
#define TEXT_DISABLE_COLOR  [UIColor nv_colorWithHexARGB:@"#FF999CB0"]
#define TEXT_ENABLE_COLOR   [UIColor whiteColor]

//#define NV_STATUSBARHEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

#define NV_STATUSBARHEIGHT \
({\
    CGFloat statusBarHeight = 0.0; \
    if (@available(iOS 13.0, *)) { \
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;\
        statusBarHeight = statusBarManager.statusBarFrame.size.height;\
    } else { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height; \
        _Pragma("clang diagnostic pop") \
    } \
    statusBarHeight; \
})

#define NV_NAV_BAR_HEIGHT 44

#define INDICATOR ((NV_STATUSBARHEIGHT>20)?34:0)

//视频录制保存的路径
// where the video recording is saved
#define LOCALDIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define VIDEO_PATH(string) [LOCALDIR stringByAppendingPathComponent:string]

//转码保存的路径
// Transcode saved path
#define CONVERTPATH [LOCALDIR stringByAppendingPathComponent:@"ConvertFile"]

//水印保存路径
// Save the watermark path
#define WATEMARK_PATH [LOCALDIR stringByAppendingPathComponent:@"warkmark"]

//画中画package保存路径
// picture in picture package save path
#define PIPPACKAGE_PATH [LOCALDIR stringByAppendingPathComponent:@"PIPPackage"]

//背景模块纯色背景转换为image 保存路径
// Background module Solid color background converts to image save path
#define BACKGROUND_PURECOLOR_PATH [LOCALDIR stringByAppendingPathComponent:@"BackgroundPureColor"]

//美型包路径
// Beautiful packet path
#define Beauty_Type_Path [LOCALDIR stringByAppendingPathComponent:@"BeautyType"]

//微整形包路径
// micro-shaping packet path
#define Beauty_Microshaping_Path [LOCALDIR stringByAppendingPathComponent:@"BeautyMicroshaping"]

//获取用户设置的value，参数是key
// Get the value set by the user
#define NV_UserInfo(key) [[NSUserDefaults standardUserDefaults] objectForKey:key];

//获取手机系统
// Get the phone system
#define  IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//#ifndef DEBUG
//#define NSLog(format, ...)
//#endif
#ifdef DEBUG  //在调试模式下
#define DebugLog(fmt, ...) NSLog((@"[Line-%d] %s " fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#else
#define DebugLog(...)
#endif

//16进制颜色值
// hex color value
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorWithRGBA(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
//video
// Max record time
#define RECORD_MAX_TIME 8.0           //最长录制时间
// Video recording folder
#define VIDEO_FOLDER @"videoFolder" //视频录制存放文件夹

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)
//视频拍摄默认滤镜packageId
// Video capture default filter packageId
#define DEFAULT_FILTER @""
#define DefaultFilterStrength 0.8

#define ARSCENE_ST NO
#define ARSCENE_ST_106_Advanced NO
#define ARSCENE_ST_240 NO
#define ARSCENE_FU NO
#define ARSCENE_MS NO
#define ARSCENE_MS_240 NO

//#define ARSCENE_AVATAR_TEST

#define DOLOADPACKAGEFINISH @"DOLOADPACKAGEFINISH"

#endif /* NVDefineConfig_h */
