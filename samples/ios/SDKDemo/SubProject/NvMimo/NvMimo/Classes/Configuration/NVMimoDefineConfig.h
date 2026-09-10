//
//  NVMimoDefineConfig.h
//  demoTool
//
//  Created by ms20180425 on 2018/5/23.
//  Copyright © 2018年 ms20180425. All rights reserved.
//

#ifndef NVMimoDefineConfig_h
#define NVMimoDefineConfig_h

typedef enum {
    NvEditMode16v9 = 0,
    NvEditMode1v1,
    NvEditMode9v16,
    NvEditMode3v4,
    NvEditMode4v3,
    NvEditMode2d39v1,
    NvEditMode2d55v1
} NvMimoEditMode;

#define NV_FILTER_PAGE_SIZE 10
#define NV_TIME_BASE 1000000

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

#define SCREANSCALE [UIScreen mainScreen].bounds.size.width / 375.0
#define SCREANWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREANHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREANBOUNDS [UIScreen mainScreen].bounds
#define FONT12 [UIFont systemFontOfSize:12];
#define FONT14 [UIFont systemFontOfSize:14];
#define FONT16 [UIFont systemFontOfSize:16];
#define NV_CAPTURE_SPEEDBAR_COLOR       @"52D3FF"
#define NV_CAPTURE_PROGRESS_BACKGROUND  @"EAEAEA"
#define STYLE_COLOR         [UIColor nv_colorWithHexARGB:@"#FF52D3FF"]
#define TEXT_DISABLE_COLOR  [UIColor nv_colorWithHexARGB:@"#FF999CB0"]
#define TEXT_ENABLE_COLOR   [UIColor whiteColor]


#define SCREEN_WDITH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGTH [[UIScreen mainScreen] bounds].size.height

#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define NV_STATUSBARHEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NV_NAV_BAR_HEIGHT 44

#define INDICATOR ((NV_STATUSBARHEIGHT>20)?34:0)


#define LOCALDIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define VIDEO_PATH(string) [LOCALDIR stringByAppendingPathComponent:string]


#define CONVERTPATH [LOCALDIR stringByAppendingPathComponent:@"ConvertFile"]


#define WATEMARK_PATH [LOCALDIR stringByAppendingPathComponent:@"warkmark"]


#define PIPPACKAGE_PATH [LOCALDIR stringByAppendingPathComponent:@"PIPPackage"]


#define NV_UserInfo(key) [[NSUserDefaults standardUserDefaults] objectForKey:key];


#define SCREANSCALE [UIScreen mainScreen].bounds.size.width / 375.0
#define SCREANSCALEHEIGHT [UIScreen mainScreen].bounds.size.height / 667.0


#define  IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorWithRGBA(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
//video
#define RECORD_MAX_TIME 8.0
#define VIDEO_FOLDER @"videoFolder" 

#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...) 
#endif

#endif /* NVMimoDefineConfig_h */
