//
//  DefineConfig.h
//  demoTool
//
//  Created by ms20180425 on 2018/5/23.
//  Copyright © 2018年 ms20180425. All rights reserved.
//

#ifndef NVDefineConfig_h
#define NVDefineConfig_h

typedef enum {
    NvEditMode16v9 = 0,
    NvEditMode1v1,
    NvEditMode9v16,
    NvEditMode3v4,
    NvEditMode4v3
} NvEditMode;

#define NV_FILTER_PAGE_SIZE 10

// 素材下载路径
#define NV_ASSET_DOWNLOAD_PATH                                  @"/Documents/Asset"
#define NV_ASSET_DOWNLOAD_PATH_FILTER                           @"/Documents/Asset/Filter"
#define NV_ASSET_DOWNLOAD_PATH_THEME                            @"/Documents/Asset/Theme"
#define NV_ASSET_DOWNLOAD_PATH_CAPTION                          @"/Documents/Asset/Caption"
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

// UI
#define SCREENSCALE [UIScreen mainScreen].bounds.size.width / 375.0
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define SafeAreaTopHeight ((SCREENHEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"] ? 88 : 64)
#define SafeAreaBottomHeight ((SCREENHEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"]  ? 30 : 0)

#define SCREENSCALEHEIGHT [UIScreen mainScreen].bounds.size.height / 667.0

#define FONT12 [UIFont systemFontOfSize:12];
#define FONT14 [UIFont systemFontOfSize:14];
#define FONT16 [UIFont systemFontOfSize:16];
#define STYLE_COLOR         [UIColor nv_colorWithHexARGB:@"#FF52D3FF"]
#define TEXT_DISABLE_COLOR  [UIColor nv_colorWithHexARGB:@"#FF999CB0"]
#define TEXT_ENABLE_COLOR   [UIColor whiteColor]

//isiPhoneX
#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define NV_STATUSBARHEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NV_NAV_BAR_HEIGHT 44

#define INDICATOR ((NV_STATUSBARHEIGHT>20)?34:0)

//视频录制保存的路径
//Path where the video recording is saved
#define LOCALDIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define VIDEO_PATH(string) [LOCALDIR stringByAppendingPathComponent:string]

//转码保存的路径
//Transcode the saved path
#define CONVERTPATH [LOCALDIR stringByAppendingPathComponent:@"ConvertFile"]

//水印保存路径
//The watermark holds the path
#define WATEMARK_PATH [LOCALDIR stringByAppendingPathComponent:@"warkmark"]

//画中画package保存路径
//Picture in picture package save path
#define PIPPACKAGE_PATH [LOCALDIR stringByAppendingPathComponent:@"PIPPackage"]

//获取用户设置的value，参数是key
//Gets the value set by the user; the argument is key
#define NV_UserInfo(key) [[NSUserDefaults standardUserDefaults] objectForKey:key];

//获取手机系统
//Get the phone system
#define  IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//调试模式下做判断
//Make decisions in debug mode
#ifdef DEBUG
#define TLog(format, ...) printf("%s\n\n",[[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String])
#else
#define TLog(format, ...)
#endif


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorWithRGBA(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
//video
#define RECORD_MAX_TIME 8.0           //最长录制时间 Maximum recording time
#define VIDEO_FOLDER @"videoFolder" //视频录制存放文件夹 Video recording is stored in a folder

#ifdef DEBUG

//#define NSLog( s, ... ) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String] );

#else

//#define NSLog( s, ... )

#endif
#endif /* NVDefineConfig_h */

#define USING_AUDIO_ENGINE
