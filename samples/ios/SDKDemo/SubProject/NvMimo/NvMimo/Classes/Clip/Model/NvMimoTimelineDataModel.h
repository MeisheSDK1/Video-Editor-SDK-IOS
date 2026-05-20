//
//  NvMimoTimelineDataModel.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/6/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NvsStreamingContext.h"
#import "NvsTimelineCaption.h"
#import "NvsVideoClip.h"
#import <Photos/Photos.h>

@interface NvMimoEditDataModel : NSObject <NSCopying>
///The Chinese here are interpreting the variable names without translation
@property(strong, nonatomic) NSString *videoPath;           //视频文件路径
@property (strong, nonatomic) PHAsset *asset;               //相册视频，调整模块使用
@property(assign, nonatomic) BOOL isBlur;                   //是否背景模糊
@property(assign, nonatomic) float speed;                   //片段的倍速
@property(assign, nonatomic) int64_t trimIn;                //裁剪入点
@property(assign, nonatomic) int64_t trimOut;               //裁剪出点
@property(assign, nonatomic) int64_t duration;              //时长
@property(assign, nonatomic) float volume;                  //音量
@property (nonatomic, assign) BOOL mute;                    //静音
@property (nonatomic, assign) BOOL isImage;                 //是否是图片
@property (nonatomic, strong) NSString *localIdentifier;    //图片的路径标志
@property (nonatomic, assign) BOOL isPhotoAlbum;            //是否是相册的图片
@property (nonatomic, strong) NSString *uuid;               //uuid
@property (nonatomic, assign) float brightness;             //亮度
@property (nonatomic, assign) float contrast;               //对比度
@property (nonatomic, assign) float saturation;             //饱和度
@property (nonatomic, assign) float Sharpen;                //锐度
@property (nonatomic, assign) float Vignette;               //暗角
@property (nonatomic, assign) float rotation;               //旋转角度
@property (nonatomic, assign) float scaleX;                 //水平缩放 说明：值正负表示水平翻转
@property (nonatomic, assign) float scaleY;                 //垂直缩放 说明：值正负示垂直翻转
@property (nonatomic, assign) CGFloat pan;                  //调整模块：平移
@property (nonatomic, assign) CGFloat scan;                 //调整模块：放大
@property (nonatomic, assign) BOOL hasMotion;               //图片是否运动
@property (nonatomic, assign) BOOL isArea;                  //是否是区域显示
@property (nonatomic, assign) BOOL isDefault;               //图片是否默认值,直接导入，没有改变过
@property (nonatomic, assign) NvsRect startRect;            //图片运动开始区域
@property (nonatomic, assign) NvsRect endRect;              //图片运动结束区域
@property (nonatomic, assign) BOOL isLoading;               //是否被加载显示过
@property (nonatomic, strong) UIImage *thumImage;           //缩略图
@property (nonatomic, assign) NvsStreamingEngineImageClipMotionMode motionMode; //图片运动模式

@end

@interface NvMimoCaptionInfoModel : NSObject <NSCopying>

@property (nonatomic, assign) NvsCategory category;         //字幕类型
@property (nonatomic, assign) NvsRoleInTheme roleInTheme;   //字幕在主题中的角色
@property (nonatomic, strong) NSString *text;               //文字
@property (nonatomic, assign) float alpha;  //(0-1)         //透明度
@property (nonatomic, strong) NSString *colorString;        //颜色
@property (nonatomic, assign) CGPoint anchorPoint;          //位置
@property (nonatomic, assign) CGFloat rotation;             //旋转角度
@property (nonatomic, assign) CGFloat scale;                //缩放
@property (nonatomic, assign) CGPoint translation;          //平移
@property (nonatomic, strong) NSString *uuid;               //uuid
@property (nonatomic, strong) NSString *styleId;            //类型
@property (nonatomic, assign) int64_t inPoint;              //时间线入点
@property (nonatomic, assign) int64_t outPoint;             //时间线出点
@property (nonatomic, assign) BOOL isDrawOutline;           //是否描边
@property (nonatomic, strong) NSString *outlineColorString; //描边颜色
@property (nonatomic, assign) float outlineAlpha;           //描边透明度
@property (nonatomic, assign) CGFloat outlineWidth;         //描边宽度
@property (nonatomic, strong) NSString *fontFilePath;       //字体文件路径
@property (nonatomic, assign) NvsTextAlignment alignment;   //对齐
@property (nonatomic, assign) BOOL isBold;                  //粗体
@property (nonatomic, assign) BOOL isItalic;                //斜体
@property (nonatomic, assign) BOOL isDrawShadow;            //阴影

@end


@interface NvMimoStickerInfoModel : NSObject

@property (nonatomic, assign) CGPoint anchor;               //锚点
@property (nonatomic, assign) CGFloat rotation;             //旋转角度
@property (nonatomic, assign) CGFloat scale;                //缩放
@property (nonatomic, assign) CGPoint translation;          //平移
@property (nonatomic, strong) NSString *packageId;          //包id
@property (nonatomic, strong) NSString *uuid;               //uuid
@property (nonatomic, assign) BOOL isCustomSticer;
@property (nonatomic, strong) NSString *customImagePath;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) CGFloat volume;               //音量
@property (nonatomic, assign) BOOL isSlient;                //是否无声

@end


@interface NvMimoParticleInfoModel : NSObject

@property (nonatomic, strong) NSString *name;                   //名称
@property (nonatomic, assign) int64_t inPoint;                  //入点
@property (nonatomic, assign) int64_t outPoint;                 //出点
@property (nonatomic, strong) NSMutableArray *particleLocation; //粒子特效位置数组
@property (nonatomic, strong) NSMutableArray *emitterName;      //发射器名字
@property (nonatomic, assign) float particleRateValue;          //粒子发射速率
@property (nonatomic, assign) float particleSizeValue;          //粒子大小
@property (nonatomic, strong) NSString *uuid;                   //uuid
@property (nonatomic, strong) NSString *color;//颜色

@end

@interface NvMimoTimeFilterInfoModel : NSObject <NSCopying>

@property (nonatomic, assign) int64_t inPoint;              //入点
@property (nonatomic, assign) int64_t outPoint;             //出点
@property (nonatomic, strong) NSString *name;               //名称
@property (assign, nonatomic) BOOL addInReverseMode;        //是否倒放
@property (nonatomic, strong) NSString *uuid;               //uuid
@property (nonatomic, assign) BOOL isShortVideo;                //是否是用于特效的滤镜
@property (nonatomic, assign) float strength;               //滤镜强度
@property (nonatomic, assign) BOOL strokeOnly;
@property (nonatomic, assign) BOOL grayscale;

@end

@interface NvMimoWatermarkInfoModel : NSObject
@property (nonatomic, strong) NSString *imageUrl;           //图片名称
@property (nonatomic, assign) BOOL isCaf;                   //是否是caf特效水印
@property (nonatomic, assign) int displayWidth;             //图片宽度
@property (nonatomic, assign) int displayHeight;            //图片高度
@property (nonatomic, assign) float opacity;                //图片透明度
@property (nonatomic, assign) int position;                 //图片位置
@property (nonatomic, assign) int marginX;                  //图片x平移
@property (nonatomic, assign) int marginY;                  //图片y平移
@property (nonatomic, assign) float sceneWidth;             //livewindow宽度
@property (nonatomic, assign) float sceneHeight;            //livewindow图片宽度
@property (nonatomic, assign) int64_t inPoint;              //水印添加的开始时间
@property (nonatomic, assign) int64_t outPoint;             //水印添加的持续时长
@end

@interface NvMimoTransitionInfoModel : NSObject

@property (nonatomic, strong) NSString *builtinName;        //内建转场名字
@property (nonatomic, strong) NSString *packageId;          //包id
@property (nonatomic, strong) NSString *uuid;               //uuid
@property (nonatomic, strong) NSString *imageUrl;

@end

@interface NvMimoDubbingInfoModel : NSObject<NSCopying>

@property (nonatomic, strong) NSString *dubbingFilePath;    //配音文件
@property (nonatomic, assign) int64_t inPoint;              //入点
@property (nonatomic, assign) int64_t trimIn;               //裁剪入点
@property (nonatomic, assign) int64_t duration;             //文件时长
@property (nonatomic, assign) float speed;                  //速度
@property (nonatomic, assign) float volume;                 //音量
@property (nonatomic, strong) NSString *builtInFxName;      //特效名字

@end

@interface NvMimoDubbingModel : NSObject<NSCopying>

@property (nonatomic, strong) NSMutableArray<NvMimoDubbingInfoModel *> *dubbingInfoModels;  //配音model
@property (nonatomic, assign) float volume;                                             //配音轨道音量

@end

@interface NvMimoMusicInfoModel : NSObject

@property (nonatomic, strong) NSString *musicPath;          //音乐地址
@property (nonatomic, assign) int64_t trimIn;               //裁剪入点
@property (nonatomic, assign) int64_t trimOut;              //裁剪出点
@property (nonatomic, assign) int64_t duration;             //时长
@property (nonatomic, assign) float volume;                 //声音
@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *musicAuthorName;
@property (nonatomic, strong) UIImage *musicCoverImage;
@property (nonatomic, assign) BOOL isBGM;                   //是否是单段背景音乐
@property (nonatomic, assign) int64_t inPoint;              //时间线入点
@property (nonatomic, assign) int64_t outPoint;             //时间线出点
@property (nonatomic, assign) BOOL isFade;                  //是否淡入淡出
@end

@interface NvMimoThemeInfoModel : NSObject<NSCopying>

@property (nonatomic, strong) NSString *themeName;          //主题名称
@property (nonatomic, assign) float volume;                 //主题音乐音量
@property (nonatomic, strong) NSString *themeString;        //主题文本
@property (nonatomic, assign) NvsRoleInTheme thenmeRoleInTheme; //字幕在主题的位置
@property (nonatomic, assign) BOOL isChange;                //用户是否修改过主题字幕

@end

