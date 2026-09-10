//
//  NvJokeCaptionConvertor.h
//  NvJokeCaptionLib
//
//  Created by shizhouhu on 2018/10/23.
//  Copyright © 2018年 shizhouhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NvStreamingSdkCore/NvsTimeline.h>
#import <NvStreamingSdkCore/NvsLiveWindow.h>

FOUNDATION_EXPORT
@interface NvJokeCaptionConvertor : NSObject

/**
 * 构建歌词描述xml文件
 */
- (NSString*)buildJokeFxDesc;

/**
 * 以lrc歌词文件路径初始化歌词特效数据
 */
- (void)setupJokeFxDadaWithFilePath:(NSString*)lrcFilePath livewindow:(NvsLiveWindow*)livewindow timeline:(NvsTimeline*)timeline;

/**
 * 以歌词list初始化歌词特效数据
 */
- (void)setupJokeFxDadaWithList:(NSMutableArray*)lrcList livewindow:(NvsLiveWindow*)livewindow timeline:(NvsTimeline*)timeline;


/**
 *  获取到所有字幕的行数
 * @return  字幕行数
 */
- (int)getCaptionLineNumber;


/**
 * 设置某一个范围之内的行的颜色 从0开始
 * @param startLine  开始行号
 * @param endLine    结束行号 -1表示到结尾
 * @param color  需要设置的颜色RGBA 格式: "255,255,255,255"
 */
- (void)setFontColorRangeLine:(int)startLine endLine:(int)endLine color:(NSString*)color;

/**
 *  设置某一行的颜色
 * @param lineNumber  行号 从0开始
 * @param color  需要设置的颜色RGBA 格式: "255,255,255,255"
 */
- (void)setFontColorSingleLine:(int)lineNumber color:(NSString*)color;

/**
 *  设置某一行的字号
 * @param lineNumber  行号
 * @param fontSize  字号
 */
- (void)setFontSizeSingleLine:(int)lineNumber fontSize:(float)fontSize;
/**
 *  设置字幕字体
 * @param fontFamily  字体的fontFamily
 */
- (void)setFont:(NSString*)fontFamily;

/**
 * 以歌词list修改文字
 */
- (void)updateTextList:(NSMutableArray*)lrcList;

@end
