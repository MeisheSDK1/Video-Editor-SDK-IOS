//
//  NvTimelineDataModel.h
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
#import "NvKeyframeInfo.h"
#import "SDKDemo-Swift.h"
#import "NvVolumeKeyFrameInfo.h"
#import "NvAjustFxParamModel.h"
typedef NS_ENUM(NSInteger,NvBackgroundFxCategory)
{
    NvBackgroundFxColor,       //画布颜色 Canvas color
    NvBackgroundFxStyle,       //画布样式 Canvas style
    NvBackgroundFxBlur,        //画布模糊 Canvas blur
};

@interface NvPropertyBackgroundEffectModel : NSObject <NSCopying>
//是否用了背景特效 Whether background effects are used
@property (nonatomic, assign) BOOL isUseBackgroudEffect;
@property (nonatomic, assign) float colorR;
@property (nonatomic, assign) float colorG;
@property (nonatomic, assign) float colorB;
@property (nonatomic, assign) float colorA;
//模糊半径 Blur radius
@property (nonatomic, assign) float radius;
//图片路径 Picture path
@property (nonatomic, strong) NSString *imageFile;
@property (nonatomic, assign) NvBackgroundFxCategory backgroundCategory;
//素材是否被选中过 // Whether the material is selected
@property (nonatomic, assign) BOOL isSelected;

///clip的旋转 Rotation of clip
@property (nonatomic, assign) float transformX;
@property (nonatomic, assign) float transformY;
@property (nonatomic, assign) float scaleX;
@property (nonatomic, assign) float scaleY;
@property (nonatomic, assign) float rotation;
@property (nonatomic, assign) float opacity;
@property (nonatomic, assign) float anchorX;
@property (nonatomic, assign) float anchorY;
//是否用了属性特技 Whether attributes are used
@property (nonatomic, assign) BOOL isUsePropertyEffect;

@end

typedef NS_ENUM(NSInteger,NvAnimationCategory)
{
    NvAnimationCategoryIn,            //入动画  In animation
    NvAnimationCategoryOut,           //出动画  Out animation
    NvAnimationCategoryCombine,       //组合动画  Composite animation
};
@interface NvAnimationInfoModel : NSObject<NSCopying>
//名称 Name
@property (nonatomic, copy) NSString *name;
//资源Id Resource Id
@property (nonatomic, copy) NSString *packageId;
//动画开始时间 Animation start time
@property (nonatomic, assign) int64_t animationStart;
//动画结束时间 Animation end time
@property (nonatomic, assign) int64_t animationEnd;
//片段位置 Segment position
@property (nonatomic, assign) int index;
//动画时长 Animation duration
@property (nonatomic, assign) CGFloat animationValue;
//相册视频，调整模块使用 Photo album video, adjustment module used
@property (strong, nonatomic) PHAsset *asset;
//缩略图 thumbnail
@property (nonatomic, strong) UIImage *thumImage;
//素材是否被选中过 Whether the material has been selected
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isPostPackage;
//是否需要展示蒙层 Whether the mask needs to be displayed
@property (nonatomic, assign) CGRect maskRect;
//是否用了属性特技 Whether attributes were used
@property (nonatomic, assign) BOOL isUsePropertyEffect;
//第二个特效的packageId
@property (nonatomic, copy) NSString *packageId2;
//动画开始时间 Animation start time
@property (nonatomic, assign) int64_t animationStart2;
//动画结束时间 Animation end time
@property (nonatomic, assign) int64_t animationEnd2;
//第二特效是否是post 特效
@property (nonatomic, assign) BOOL isPostPackage2;
//动画类型 Animation type
@property (nonatomic, assign) NvAnimationCategory animationCategory;
@end

@interface NvKeyFrameFilterModel : NSObject <NSCopying>
@property (nonatomic, strong) NSString *fxParam;     //设置关键帧fxParam Set the key frame fxParam
@property (nonatomic, strong) NSString *name;        //内置滤镜名 Built-in filter name
@property (nonatomic, strong) NSString *packageId;   //外置滤镜包名 External filter package name
@property (nonatomic, assign) BOOL isBuiltIn;        //是否是内置滤镜 Whether it has a built-in filter
@property (nonatomic, assign) CGFloat value;         //设置关键帧float value 值 Sets the float value of the keyframe
@property (nonatomic, assign) int64_t time;          //设置关键帧时间 Set the keyframe time
@property (nonatomic, assign) BOOL strokeOnly;
@property (nonatomic, assign) BOOL grayscale;
@end

@interface NvKeyFrameStickerModel : NSObject <NSCopying>
@property (nonatomic, assign) int64_t pos;           //关键帧相对贴纸的时间点 The point in time when the keyframe is relative to the sticker
@property (nonatomic, assign) int64_t time;          //关键帧相对时间线的时间点 The point in time when the keyframe is relative to the timeline
@property (nonatomic, assign) CGPoint anchor;        //锚点 Anchor point
@property (nonatomic, assign) CGFloat rotation;      //旋转角度 Angle of rotation
@property (nonatomic, assign) CGFloat scale;         //缩放 scale
@property (nonatomic, assign) CGPoint translation;   //平移 translation
@end

@class NvCaptionInfoModel, NvStickerInfoModel;
@interface NvEditDataModel : NSObject <NSCopying>
@property (nonatomic, strong) NSMutableArray <NvKeyFrameFilterModel *>*filterKeyFrames;
@property(strong, nonatomic) NSString *videoPath;           //视频文件路径 Video file path
@property(strong, nonatomic) NSString *convertPath;           //视频转码文件路径 Video transcoding file path
@property (strong, nonatomic) PHAsset *asset;               //相册视频，调整模块使用 Photo album video, adjustment module used
@property(assign, nonatomic) BOOL isBlur;                   //是否背景模糊 Background blur or not
@property(assign, nonatomic) float speed;                   //片段的倍速 The doubling speed of the segment
@property (nonatomic, assign) BOOL keepAudioPitchNormalChangeSpeed; //普通变速时是否保持音调 Whether to maintain pitch when changing gears normally
@property(assign, nonatomic) int64_t trimIn;                //裁剪入点 Clipping entry point
@property(assign, nonatomic) int64_t trimOut;               //裁剪出点 Clipping point
@property(assign, nonatomic) int64_t duration;              //时长 duration
@property(assign, nonatomic) float volume;                  //音量 volume
@property(assign, nonatomic) int audioNoiseSuppressionLevel; //声音降噪 Sound reduction

/// 音量关键帧数组 Volume keyframe array
@property (nonatomic, strong) NSMutableArray <NvVolumeKeyFrameInfo *> *keyFramesArray;
@property (nonatomic, assign) BOOL mute;                    //静音 mute
@property (nonatomic, assign) BOOL isImage;                 //是否是图片 Picture or not
@property (nonatomic, assign) BOOL isFromAlbum;             //是否来自相册 Is it from an album?
@property (nonatomic, strong) NSString *localIdentifier;    //图片的路径标志 The path of the picture
@property (nonatomic, assign) BOOL isPhotoAlbum;            //是否是相册的图片 Whether it is a photo album
@property (nonatomic, strong) NSString *uuid;               //uuid
@property (nonatomic, assign) float brightness;             //亮度 brightness
@property (nonatomic, assign) float contrast;               //对比度 Contrast ratio
@property (nonatomic, assign) float saturation;             //饱和度 saturation
@property (nonatomic, assign) float Sharpen;                //锐度 sharpness
@property (nonatomic, assign) float Vignette;               //暗角 Dark Angle

@property (nonatomic, assign) float highlight;             //高光 highlight
@property (nonatomic, assign) float shadow;                //阴影 shadow
@property (nonatomic, assign) float temperature;           //色温 Color temperature
@property (nonatomic, assign) float tint;                  //色调 hue
@property (nonatomic, assign) float blackpoint;                //褪色 fade
@property (nonatomic, assign) float intensity;               //噪点程度 Degree of noise
@property (nonatomic, assign) float density;               //噪点密度 Noise density
@property (nonatomic, assign) BOOL grayscale;               //噪点程度 yes 单色 The noise level is yes monochromatic

@property (nonatomic, assign) float rotation;               //旋转角度 Angle of rotation
@property (nonatomic, assign) float scaleX;                 //水平缩放 说明：值正负表示水平翻转 Horizontal scaling description: A value of plus or minus indicates a horizontal flip
@property (nonatomic, assign) float scaleY;                 //垂直缩放 说明：值正负示垂直翻转 Vertical Scaling description: Positive or negative values indicate vertical flipping
@property (nonatomic, assign) CGFloat pan;                  //调整模块：平移 Adjustment module: translation
@property (nonatomic, assign) CGFloat scan;                 //调整模块：放大 Adjustment module: Enlarge
@property (nonatomic, assign) BOOL hasMotion;               //图片是否运动 Whether the picture is moving
@property (nonatomic, assign) BOOL isArea;                  //是否是区域显示 Whether zone display
@property (nonatomic, assign) BOOL isDefault;               //图片是否默认值,直接导入，没有改变过 Image is the default value, imported directly, has not changed
@property (nonatomic, assign) NvsRect startRect;            //图片运动开始区域 Picture motion start area
@property (nonatomic, assign) NvsRect endRect;              //图片运动结束区域 Picture motion end area
@property (nonatomic, assign) BOOL isLoading;               //是否被加载显示过 Whether the load is displayed
@property (nonatomic, strong) UIImage *thumImage;           //缩略图 thumbnail
@property (nonatomic, assign) NvsStreamingEngineImageClipMotionMode motionMode; //图片运动模式 Picture motion mode
@property (nonatomic, assign) float musicEndPos;//每段录制时音乐播放的结束时间点(dou视频) The end time point of the music playback at the time of each recording

@property (nonatomic, assign) float musicStartPos;//每段录制时音乐播放的开始时间点(dou视频) The start time of music playback for each recording (dou video)
@property (nonatomic, strong) NvPropertyBackgroundEffectModel *backgroundEffectModel;
@property (nonatomic, strong) NvAnimationInfoModel *animationInfoModel;
@property (nonatomic, strong) NvMaskModel *maskInfoModel;
@property (nonatomic, strong) NSMutableArray *curveSpeeds;
@property (nonatomic, strong) NSString *curveSpeedsId;

//调整（画面裁剪） Adjust (screen cropping)
@property (nonatomic, strong) NvSourceInfo *sourceInfo;
@property (nonatomic, strong) NvCropperModel *cropperModel;
/**
 * 已添加字幕信息 Subtitle information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvCaptionInfoModel *> *captionDataArray;
/**
 * 已添加贴纸信息 Sticker information has been added
 */
@property(strong, nonatomic) NSMutableArray<NvStickerInfoModel *> *stickerDataArray;
@end

typedef enum : NSUInteger {
    Normal,
    Modular,
} NvCaptionType;

typedef enum : NSUInteger {
    LetterSpaceLess,
    LetterSpaceStandard,
    LetterSpaceMore,
    LetterSpacelarge
} NvCaptionLetterSpaceType;

typedef enum : NSUInteger {
    InOutput,
    Caption
} NvCaptionAnimationType;

@interface NvCaptionAnimationModel : NSObject <NSCopying>

@property (nonatomic, assign) NvCaptionAnimationType type;
@property (nonatomic, strong) NSString *inputId;               //入动画 in animation
@property (nonatomic, strong) NSString *outputId;              //出动画 out animation
@property (nonatomic, strong) NSString *captionId;             //组合动画 Composite animation
@property (nonatomic, assign) int inputDuration;   //入动画时长 in Animation duration
@property (nonatomic, assign) int outputDuration;  //出动画时长 out Animation duration
@property (nonatomic, assign) int captionDuration; //组合动画时长  Composite Animation duration
@end

@interface NvCaptionSpan : NSObject <NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@property (nonatomic, strong) NSObject *value;
@end

@interface NvCaptionInfoModel : NSObject <NSCopying>

@property (nonatomic, assign) NvCaptionType type;         //字幕类型,Normal:普通字幕，Modular:拼装字幕 Captioning type: Normal: common captioning, Modular: modular captioning
@property (nonatomic, strong) NSString *renderId;         //花字 Flowery character
@property (nonatomic, strong) NSString *contextId;        //气泡 bubble
@property (nonatomic, strong) NvCaptionAnimationModel *animationModel;    //动画 animation
@property (nonatomic, assign) NvsCategory category;         //字幕类型 Subtitle type
@property (nonatomic, assign) NvsRoleInTheme roleInTheme;   //字幕在主题中的角色 The role of subtitles in the subject
@property (nonatomic, strong) NSString *text;               //文字 text
@property (nonatomic, assign) NvsColor textColor;           //文字颜色 Text color
@property (nonatomic, assign) BOOL isModifyTextColor;       //是否修改过文字颜色 Whether the text color has been changed
@property (nonatomic, assign) BOOL isModifyTextBgColor;       //是否修改过文字背景颜色 Whether the text background color has been changed
@property (nonatomic, assign) NvsColor textBgColor;         //文字背景颜色 Text background color
@property (nonatomic, assign) float textBgRadius;           //文字背景圆角值 Text background fillet value
@property (nonatomic, assign) BOOL isModifyTextBgRadius;    //是否修改过文字背景圆角值 Whether the background fillet value has been changed
@property (nonatomic, assign) float boundaryMargin;           //文字边界 Text boundary
@property (nonatomic, assign) CGPoint anchorPoint;          //位置 position
@property (nonatomic, assign) BOOL isUserRotation;          //用户旋转过角度 The user rotated the Angle
@property (nonatomic, assign) CGFloat rotation;             //旋转角度 Angle of rotation
@property (nonatomic, assign) BOOL isUserScale;             //用户旋转过角度 The user rotated the Angle
@property (nonatomic, assign) CGFloat scale;                //缩放 scale
@property (nonatomic, assign) CGFloat fontSize;             //字体大小 Font size
@property (nonatomic, assign) BOOL isUserTranslation;       //用户旋转过角度 The user rotated the Angle
@property (nonatomic, assign) CGPoint translation;          //平移 translation
@property (nonatomic, strong) NSString *uuid;               //uuid
@property (nonatomic, strong) NSString *styleId;            //类型 type
@property (nonatomic, assign) int64_t inPoint;              //时间线入点 Timeline entry point
@property (nonatomic, assign) int64_t outPoint;             //时间线出点 Timeline exit point
@property (nonatomic, assign) BOOL isUserDrawOutline;       //用户是否描边 Whether the user strokes
@property (nonatomic, assign) BOOL isDrawOutline;           //是否描边 Stroke or not
@property (nonatomic, assign) NvsColor outlineColor;
@property (nonatomic, assign) CGFloat outlineWidth;         //描边宽度 Stroke width
@property (nonatomic, assign) BOOL isUserOpacity;             //用户改变过透明度 The user changed the transparency
@property (nonatomic, assign) float opacity;         //透明度 transparency
@property (nonatomic, strong) NSString *fontFilePath;       //字体文件路径 Font file path
@property (nonatomic, assign) BOOL isUserAlignment;         //用户点过对齐 User points over alignment
@property (nonatomic, assign) NvsTextAlignment alignment;   //对齐 align
@property (nonatomic, assign) float letterSpace;            //字间距 Word spacing
@property (nonatomic, assign) NvCaptionLetterSpaceType letterSpaceType;            //字间距 Word spacing
@property (nonatomic, assign) BOOL isModifyLetterSpace;       //是否修该过字间距 Whether to correct the spacing
@property (nonatomic, assign) float letterLineSpace;        //行间距 Line spacing
@property (nonatomic, assign) BOOL isUserBold;                  //用户点过粗体 The user clicked in bold
@property (nonatomic, assign) BOOL isUserItalic;                //用户点过斜体 The user has clicked italics
@property (nonatomic, assign) BOOL isUserDrawShadow;            //用户点过阴影 The user clicked on the shadow
@property (nonatomic, assign) BOOL isUserUnderLine;            //用户点过下划线 The user underlined
@property (nonatomic, assign) BOOL isBold;                  //粗体 bold
@property (nonatomic, assign) BOOL isItalic;                //斜体 italic
@property (nonatomic, assign) BOOL isDrawShadow;            //阴影 shadow
@property (nonatomic, assign) BOOL isUnderLine;            //下划线 underline
@property (nonatomic, assign) CGPoint shadowOffset;         //阴影偏移量 Shadow offset
@property (nonatomic, strong) NSString *shadowColorString;  //阴影颜色 Shadow color
@property (nonatomic, assign) NvsColor shadowColor;
@property (nonatomic, assign) BOOL isVerticalLayout;        //是否是竖版字幕 Whether it is vertical subtitles
@property (nonatomic, assign) BOOL isVerticalKeyFrame;      //是否是在关键帧里设置竖版字幕 Whether to set vertical subtitles in the keyframe
/// 关键帧数组 Keyframe array
@property (nonatomic, strong) NSMutableArray <NvKeyframeInfo *> *keyFramesArray;
/// 关键帧特效名称，删除的时候使用 Keyframe effect name, used when deleting
@property (nonatomic, strong) NSArray<NSString *> *keyArray;
//部分选中字幕信息 Partially select subtitle information
@property (nonatomic, strong) NSMutableArray <NvCaptionSpan *> *textSpanArray;

@end


@interface NvInnerCompoundCaptionModel : NSObject <NSCopying>

@property (nonatomic, assign) NSInteger index;              //复合字幕子字幕的index Composite subtitle index
@property (nonatomic, strong) NSString *text;               //复合字幕子字幕的文本 Compound subtitle text
@property (nonatomic, strong) NSString *fontFamily;             //复合字幕子字幕的字体 Compound subtitle font
@property (nonatomic, strong) NSString *colorString;        //复合字幕子字幕的颜色 Compound subtitle color
@property (nonatomic, assign) BOOL hasTextBgColor;       //是否有背景色 Whether there is a background color
@property (nonatomic, assign) NvsColor textBgColor;         //文字背景颜色 Text background color
@property (nonatomic, assign) float textBgRadius;           //文字背景圆角值 Text background fillet value
@property (nonatomic, assign) BOOL isUserDrawOutline;       //用户是否描边 Whether the user strokes
@property (nonatomic, assign) BOOL isDrawOutline;           //是否描边 Stroke or not
@property (nonatomic, assign) BOOL isItalic;                //斜体 italic
@property (nonatomic, assign) NvsColor outlineColor;
@property (nonatomic, assign) CGFloat outlineWidth;         //描边宽度 Stroke width
@property (nonatomic, assign) BOOL isSelected;       //是否被选中 Be selected or not

@end

@interface NvCompoundCaptionInfoModel : NSObject <NSCopying>

@property (nonatomic, assign) NSInteger captionCount;       //获取该复合字幕中子字幕的数量 Gets the number of subtitles for the composite subtitle
@property (nonatomic, assign) BOOL clipAffinityEnabled;     //是否开启复合字幕与视频片段之间的亲和度 Whether to enable affinity between composite subtitles and video clips
@property (nonatomic, assign) int64_t inPoint;              //复合字幕在时间线上显示的入点（单位微秒） The entry point (in microseconds) that composite subtitles display on the timeline.
@property (nonatomic, assign) int64_t outPoint;             //复合字幕在时间线显示上的出点（单位微秒） The exit point of the composite title on the timeline display in microseconds
@property (nonatomic, assign) CGPoint translationOffset;    //复合字幕平移的水平和垂直的偏移值 Compound the horizontal and vertical offsets of the subtitles translation
@property (nonatomic, assign) CGPoint anchorPoint;          //复合字幕位置 Composite title position
@property (nonatomic, assign) CGFloat rotation;             //复合字幕旋转角度 Compound subtitles rotation Angle
@property (nonatomic, assign) CGFloat scale;                //复合字幕缩放 Composite subtitle scaling
@property (nonatomic, strong) NSString *packageId;          //复合字幕资源Id Compound subtitles resource Id
@property (nonatomic, copy) NSString *packagePath;          //复合字幕资源路径 Compound subtitles resource path
@property (nonatomic, strong) NSString *fontName;           //字体名 Font name
@property (nonatomic, strong) NSString *uuid;               //唯一标识符 Unique identifier
@property (nonatomic, strong) NSMutableArray <NvInnerCompoundCaptionModel *>*captionArr; //子字幕信息数组 Array of subtitle information
@property(nonatomic, assign)int selectedIndex; //当前选中的哪个子字幕  Which subtitle is currently selected
@property(nonatomic, assign)BOOL isSelectedSubCaption; //是否选中子字幕 Whether subtitle is selected
@end


typedef enum : NSUInteger {
    StickerInOutput,
    StickerCom
} NvStickerAnimation;

@interface NvStickerAnimationInfo : NSObject <NSCopying>

@property (nonatomic, assign) NvStickerAnimation type;
@property (nonatomic, strong) NSString *inputId;               //入动画 in animation
@property (nonatomic, strong) NSString *outputId;              //出动画 out animation
@property (nonatomic, strong) NSString *stickerId;             //组合动画 Composite animation
@property (nonatomic, assign) int inputDuration;   //入动画时长 in Animation duration
@property (nonatomic, assign) int outputDuration;  //出动画时长 out Animation duration
@property (nonatomic, assign) int stickerDuration; //组合动画时长 Composite Animation duration
@end


@interface NvStickerInfoModel : NSObject

@property (nonatomic, assign) CGPoint anchor;               //锚点 Anchor point
@property (nonatomic, assign) CGFloat rotation;             //旋转角度 Angle of rotation
@property (nonatomic, assign) CGFloat scale;                //缩放 scale
@property (nonatomic, assign) CGPoint translation;          //平移 translation
@property (nonatomic, strong) NvStickerAnimationInfo *stickerAnimationInfo; //贴纸动画 Sticker animation
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, strong) NSString *packagePath;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL isCustomSticer;
@property (nonatomic, strong) NSString *customImagePath;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) CGFloat volume;               //音量 volume
@property (nonatomic, assign) BOOL isSlient;                //是否无声 Silent or not
@property (nonatomic, assign) BOOL isHorizontalFlip;        //是否水平翻转 Whether to flip horizontally
    

/// 关键帧数组 Keyframe array
@property (nonatomic, strong) NSMutableArray <NvKeyFrameStickerModel *>*keyFramesArray;

/// 关键帧特效名称，删除的时候使用 Keyframe effect name, used when deleting
@property (nonatomic, strong) NSArray *keyArray;
@end


@interface NvParticleInfoModel : NSObject

@property (nonatomic, strong) NSString *name;                   //名称 name
@property (nonatomic, assign) int64_t inPoint;                  //入点 in point
@property (nonatomic, assign) int64_t outPoint;                 //出点 out point
@property (nonatomic, strong) NSMutableArray *particleLocation; //粒子特效位置数组 Particle effect position array
@property (nonatomic, strong) NSMutableArray *emitterName;      //发射器名字 Transmitter name
@property (nonatomic, assign) float particleRateValue;          //粒子发射速率 Particle emission rate
@property (nonatomic, assign) float particleSizeValue;          //粒子大小 Particle size
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *color;//颜色

@end

@interface NvTimeFilterInfoModel : NSObject <NSCopying>
@property (nonatomic, assign) NSInteger categoryId;
@property (nonatomic, assign) NSInteger kindId;
@property (nonatomic, assign) int64_t inPoint;              //入点 in point
@property (nonatomic, assign) int64_t outPoint;             //出点 out point
@property (nonatomic, strong) NSString *name;               //名称 name
@property (nonatomic, assign) BOOL addInReverseMode;        //是否倒放 Inverted or not
@property (nonatomic, strong) NSString *uuid;               //uuid
@property (nonatomic, assign) BOOL isShortVideo;                //是否是用于短视频的滤镜 Is it a filter for playing videos
@property (nonatomic, assign) float strength;               //滤镜强度 Filter strength
@property (nonatomic, assign) BOOL strokeOnly;
@property (nonatomic, assign) BOOL grayscale;
@property (nonatomic, strong) NSMutableArray <NvAjustFxParamModel *> *expModels; //可调节表达式参数列表model Adjustable expression parameter list model
@end

@interface NvBuiltInWatermarkEffectModel : NSObject
@property (nonatomic, strong) NSString *effectName;
@property (nonatomic, assign) float intensity;
@property (nonatomic, assign) float unitSize; //马赛克效果单位大小 Mosaic effect unit size
@end

@interface NvWatermarkInfoModel : NSObject
@property (nonatomic, strong) NSString *imageUrl;           //图片名称 Picture name
@property (nonatomic, assign) BOOL isCaf;                   //是否是caf特效水印 Whether it is caf special effect watermark
@property (nonatomic, assign) BOOL isBuiltInEffect; //是否是内建特效（如：马赛克、模糊） Built-in effects (e.g., Mosaic, blur)
@property (nonatomic, strong) NvBuiltInWatermarkEffectModel *builtInEffect;
@property (nonatomic, assign) int displayWidth;             //图片宽度 Picture width
@property (nonatomic, assign) int displayHeight;            //图片高度 Picture height
@property (nonatomic, assign) float opacity;                //图片透明度 Picture transparency
@property (nonatomic, assign) int position;                 //图片位置 Picture position
@property (nonatomic, assign) int marginX;                  //图片x平移 Picture x translation
@property (nonatomic, assign) int marginY;                  //图片y平移 Picture y translation
@property (nonatomic, assign) float sceneWidth;             //livewindow宽度 livewindow width
@property (nonatomic, assign) float sceneHeight;            //livewindow高度 livewindow height
@property (nonatomic, assign) int64_t inPoint;              //水印添加的开始时间 The start time of watermark addition
@property (nonatomic, assign) int64_t outPoint;             //水印添加的持续时长 Duration of watermark addition
@end

@interface NvTransitionInfoModel : NSObject<NSCopying>

@property (nonatomic, strong) NSString *builtinName;        //内建转场名字 Built in transfer name
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) int64_t duration;            //转场时间 Transition time

@end

@interface NvDubbingInfoModel : NSObject<NSCopying>

@property (nonatomic, strong) NSString *dubbingFilePath;    //配音文件 Dubbing file
@property (nonatomic, assign) int64_t inPoint;              //入点 in point
@property (nonatomic, assign) int64_t trimIn;               //裁剪入点 Clipping entry point
@property (nonatomic, assign) int64_t duration;             //文件时长 File duration
@property (nonatomic, assign) float speed;                  //速度 speed
@property (nonatomic, assign) float volume;                 //音量 volume
@property (nonatomic, strong) NSString *builtInFxName;      //特效名字 Special effects name
@property(assign, nonatomic) int audioNoiseSuppressionLevel; //声音降噪 Sound reduction
@end

@interface NvDubbingModel : NSObject<NSCopying>

@property (nonatomic, strong) NSMutableArray<NvDubbingInfoModel *> *dubbingInfoModels;  //配音model Dubbing model
@property (nonatomic, assign) float volume;                                             //配音轨道音量 Dub track volume
@end

@interface NvMusicInfoModel : NSObject

@property (nonatomic, strong) NSString *musicPath;          //音乐地址 Music address
@property (nonatomic, assign) int64_t trimIn;               //裁剪入点 Clipping in point
@property (nonatomic, assign) int64_t trimOut;              //裁剪出点 Clipping out point
@property (nonatomic, assign) int64_t duration;             //时长 duration
@property (nonatomic, assign) float volume;                 //声音 sound
@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *musicAuthorName;
@property (nonatomic, strong) UIImage *musicCoverImage;
@property (nonatomic, assign) BOOL isBGM;                   //是否是单段背景音乐 Is it a single piece of background music
@property (nonatomic, assign) int64_t inPoint;              //时间线入点 Timeline in point
@property (nonatomic, assign) int64_t outPoint;             //时间线出点 Timeline out point
@property (nonatomic, assign) BOOL isFade;                  //是否淡入淡出 Whether to fade in and out
@end

@interface NvThemeInfoModel : NSObject<NSCopying>

@property (nonatomic, strong) NSString *themeName;          //主题名称 Subject name
@property (nonatomic, assign) float volume;                 //主题音乐音量 Theme music volume
@property (nonatomic, strong) NSString *themeString;        //主题文本 Topic text
@property (nonatomic, assign) NvsRoleInTheme thenmeRoleInTheme; //字幕在主题的位置 Subtitles in the location of the subject
@property (nonatomic, assign) BOOL isChange;                //用户是否修改过主题字幕 Whether the user has modified the theme subtitles

@end



