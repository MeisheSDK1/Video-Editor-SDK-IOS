//
//  NvConstant.m
//  NvVideoEdit
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import "NvConstant.h"

int64_t const NV_TIME_BASE = 1000000;
int64_t const MIN_EDIT_DURATION = 3000000;
int64_t const MAX_EDIT_DURATION = 60000000;
int64_t const MAX_RECORDING_DURATION = 60000000; 

/// Color
NSString * const  NV_EFFECT_COLOR_DOUDONG           = @"FCB600";
NSString * const  NV_EFFECT_COLOR_HUANJUE           = @"FF4D97";
NSString * const  NV_EFFECT_COLOR_LINHUNCHUQIAO     = @"00ABFC";
NSString * const  NV_EFFECT_COLOR_JINGXIANG         = @"00FCE0";
NSString * const  NV_EFFECT_COLOR_BOLANG            = @"F8FC00";
NSString * const  NV_EFFECT_COLOR_HEIMOFA           = @"5C00FC";
NSString * const  NV_EFFECT_COLOR_SLIDER_KNOB       = @"52D3FF";
NSString * const  NV_CAPTURE_PROGRESS_BACKGROUND    = @"EAEAEA";
NSString * const  NV_CAPTURE_SPEEDBAR_COLOR         = @"52D3FF";
NSString * const  NV_EDIT_BACKGROUND_COLOR          = @"181C24";
NSString * const  NV_CAPTURE_PRIVILEGE_COLOR        = @"18DEFE";
NSString * const  NV_EDIT_FILTER_BACKGROUND_COLOR   = @"151517";
NSString * const  NV_VOLUME_SLIDER_BACKGROUND_COLOR = @"999CB0";

/// Path
NSString * const VIDEODIR       = @"videos";
NSString * const PHOTODIR       = @"photos";
NSString * const DRAFTDIR       = @"drafts";
NSString * const COMMENTS       = @"comments";
NSString * const MUSICDIR       = @"musicDownload";
NSString * const STICKERDIR     = @"stickerDownload";
NSString * const MUSICLISTDIR   = @"musiclist";
NSString * const STICKERLISTDIR = @"stickerlist";
NSString * const PROPSLISTDIR   = @"propslist";
NSString * const PROPSDIR       = @"propsDownload";
