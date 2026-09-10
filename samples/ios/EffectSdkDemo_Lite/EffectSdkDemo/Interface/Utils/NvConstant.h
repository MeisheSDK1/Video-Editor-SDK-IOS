//
//  NvConstant.h
//  NvVideoEdit
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvAppEnv.h"


#define WeakObjc(o) @autoreleasepool{} __weak typeof(o) weak##o = o;

#define StrongObjc(o) @autoreleasepool{} __strong typeof(o) o = weak##o;

#pragma mark - Dispatch Main Async
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)                                                                                \
    if ([NSThread isMainThread]) {                                                                                     \
        block();                                                                                                       \
    } else {                                                                                                           \
        dispatch_async(dispatch_get_main_queue(), block);                                                              \
    }
#endif

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

static inline NSString *_Nullable NvLocalString(NSString * _Nullable key,NSString * _Nullable comment){
    return [NvAppEnv localizedString:key comment:comment];
}
static inline NSString *_Nullable NvAlbumLocalString(NSString * _Nullable key,NSString * _Nullable comment){
    return [NvAppEnv albumLocalizedString:key comment:comment];
}

static inline CGFloat NvScreen(NvEnvs envs) {
    return [NvAppEnv layout:envs];
}
static inline UIColor* _Nullable NvMainColor() {
    return [UIColor colorWithRed:0.094 green:0.106 blue:0.125 alpha:1.00];
}

static inline NSString* _Nullable NvLoaclPath(NSString * _Nullable folder) {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"meicam"];
    if (folder == nil) {
        return path;
    }
    return [path stringByAppendingPathComponent:folder];
}

UIKIT_EXTERN int64_t const NV_TIME_BASE;
UIKIT_EXTERN int64_t const MIN_EDIT_DURATION;
UIKIT_EXTERN int64_t const MAX_EDIT_DURATION;
UIKIT_EXTERN int64_t const MAX_RECORDING_DURATION;

/// Color
UIKIT_EXTERN NSString * _Nullable const NV_EFFECT_COLOR_DOUDONG;
UIKIT_EXTERN NSString * _Nullable const NV_EFFECT_COLOR_HUANJUE;
UIKIT_EXTERN NSString * _Nullable const NV_EFFECT_COLOR_LINHUNCHUQIAO;
UIKIT_EXTERN NSString * _Nullable const NV_EFFECT_COLOR_JINGXIANG;
UIKIT_EXTERN NSString * _Nullable const NV_EFFECT_COLOR_BOLANG;
UIKIT_EXTERN NSString * _Nullable const NV_EFFECT_COLOR_HEIMOFA;
UIKIT_EXTERN NSString * _Nullable const NV_EFFECT_COLOR_SLIDER_KNOB;
UIKIT_EXTERN NSString * _Nullable const NV_CAPTURE_PROGRESS_BACKGROUND;
UIKIT_EXTERN NSString * _Nullable const NV_CAPTURE_SPEEDBAR_COLOR;
UIKIT_EXTERN NSString * _Nullable const NV_CAPTURE_PRIVILEGE_COLOR;
UIKIT_EXTERN NSString * _Nullable const NV_EDIT_BACKGROUND_COLOR;
UIKIT_EXTERN NSString * _Nullable const NV_EDIT_FILTER_BACKGROUND_COLOR;
UIKIT_EXTERN NSString * _Nullable const NV_VOLUME_SLIDER_BACKGROUND_COLOR;

///Path
//UIKIT_EXTERN NSString * _Nullable const LOCALDIR;
UIKIT_EXTERN NSString * _Nullable const VIDEODIR;
UIKIT_EXTERN NSString * _Nullable const PHOTODIR;
UIKIT_EXTERN NSString * _Nullable const DRAFTDIR;
UIKIT_EXTERN NSString * _Nullable const COMMENTS;
UIKIT_EXTERN NSString * _Nullable const MUSICDIR;
UIKIT_EXTERN NSString * _Nullable const STICKERDIR;
UIKIT_EXTERN NSString * _Nullable const MUSICLISTDIR;
UIKIT_EXTERN NSString * _Nullable const STICKERLISTDIR;
UIKIT_EXTERN NSString * _Nullable const PROPSLISTDIR;
UIKIT_EXTERN NSString * _Nullable const PROPSDIR;



