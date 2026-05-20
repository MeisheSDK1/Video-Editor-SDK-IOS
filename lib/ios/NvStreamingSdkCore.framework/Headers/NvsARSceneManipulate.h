//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 29. 2016
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \anchor ARSCENE_DETECTION_MODE */
/*!
 *  \if ENGLISH
 *   @name AR Scene detection mode.
 *  \else
 *   @name AR场景检测模式。
 *  \endif
 */
//!@{
typedef enum {
    NvsARSceneDetectionMode_Video = 0x01,           //!< \if ENGLISH video detection mode  \else 视频检测 \endif
    NvsARSceneDetectionMode_Image = 0x02,           //!< \if ENGLISH image detection mode  \else 图像检测 \endif
    NvsARSceneDetectionMode_SemiImage = 0x10,       //!< \if ENGLISH Semi-image detection mode  \else 半图像检测 \endif
    NvsARSceneDetectionMode_SingleThread = 0x04,    //!< \if ENGLISH single thread detection  \else 单线程检测 \endif
    NvsARSceneDetectionMode_MultiThread = 0x08,     //!< \if ENGLISH multi-thread detection  \else 多线程检测 \endif
} NvsARSceneDetectionMode;


/*! \anchor ARSCENE_DETECTION_MODE */
/*!
 *  \if ENGLISH
 *   @name Face action type
 *  \else
 *   @name 人脸动作类型
 *  \endif
 */
//!@{
typedef NS_ENUM(NSInteger,NvsFaceActionType){
    NvsFaceActionTypeInvalid = -1,
    NvsFaceActionTypeEyeBlink,
    NvsFaceActionTypeLipsPart,
    NvsFaceActionTypeHeadYaw,
    NvsFaceActionTypeHeadPitch,
    NvsFaceActionTypeBrowJump,
    NvsFaceActionTypeLipsUpward,
    NvsFaceActionTypeLipsPouted
};

/*! \anchor ARSCENE_DETECTION_MODE */
/*!
 *  \if ENGLISH
 *   @name Avatar Face action type
 *  \else
 *   @name Avatar动作类型
 *  \endif
 */
//!@{
typedef NS_ENUM(NSInteger,NvsAvatarActionType){
    NvsAvatarActionTypeInvalid = -1,
    NvsAvatarActionTypeEyeRightClose,                //!< \if ENGLISH right eye closed  \else 右眼闭合 \endif
    NvsAvatarActionTypeEyeRightDown,                 //!< \if ENGLISH right eye look down  \else 右眼下看 \endif
    NvsAvatarActionTypeEyeRightInward,               //!< \if ENGLISH right eye inward (left)  \else 右眼向内看(向左看) \endif
    NvsAvatarActionTypeEyeRightOutward,              //!< \if ENGLISH right eye  look out (right) \else 右眼向外看(向右看) \endif
    NvsAvatarActionTypeEyeRightUp,                   //!< \if ENGLISH right eye  look up \else 右眼向上看 \endif
    NvsAvatarActionTypeEyeRightNarrow,               //!< \if ENGLISH right eye squinting \else 右眼眯眼 \endif
    NvsAvatarActionTypeEyeRightWide,                 //!< \if ENGLISH right eye wide open  \else 右眼圆睁 \endif
    NvsAvatarActionTypeEyeLeftClose,                 //!< \if ENGLISH left eye closed  \else 左眼闭合 \endif
    NvsAvatarActionTypeEyeLeftDown,                  //!< \if ENGLISH left eye look down  \else 左眼下看 \endif
    NvsAvatarActionTypeEyeLeftInward,                //!< \if ENGLISH left eye  inward (right)  \else 左眼向内看(向右看) \endif
    NvsAvatarActionTypeEyeLeftOutward,               //!< \if ENGLISH left eye  look out (left) \else 左眼向外看(向左看) \endif
    NvsAvatarActionTypeEyeLeftUp,                    //!< \if ENGLISH left eye  look up  \else 左眼上看 \endif
    NvsAvatarActionTypeEyeLeftNarrow,                //!< \if ENGLISH left eye squinting  \else 左眼眯眼 \endif
    NvsAvatarActionTypeEyeLeftWide,                  //!< \if ENGLISH left eye  wide open \else 左眼圆睁 \endif
    NvsAvatarActionTypeJawForward,                   //!< \if ENGLISH Jaw Forward (mouth closed)  \else 下颚前突(嘴闭合) \endif
    NvsAvatarActionTypeJawRight,                     //!< \if ENGLISH right shift of jaw (mouth closed)  \else 下颚右移(嘴闭合) \endif
    NvsAvatarActionTypeJawLeft,                      //!< \if ENGLISH left shift of jaw (mouth closed)  \else 下颚左移(嘴闭合) \endif
    NvsAvatarActionTypeJawOpen,                      //!< \if ENGLISH lower jaw open downward (mouth open)  \else 下颚向下张开(嘴自然张开) \endif
    NvsAvatarActionTypeJawDown,                      //!< \if ENGLISH Jaw dropped  \else 下颚下降 \endif
    NvsAvatarActionTypeMouthClose,                   //!< \if ENGLISH mouth closure (lower jaw open downward)  \else 嘴形自然闭合(下颚向下张开) \endif
    NvsAvatarActionTypeMouthRound,                   //!< \if ENGLISH pout, lips protruding forward  \else 嘟嘴，嘴唇往前突 \endif
    NvsAvatarActionTypeMouthPucker,                  //!< \if ENGLISH pout, lips sticking out  \else 撅嘴，嘴唇往外翘 \endif
    NvsAvatarActionTypeMouthBulge,                   //!< \if ENGLISH strengthening  \else 嘴巴鼓气 \endif
    NvsAvatarActionTypeMouthBothLipRight,            //!< \if ENGLISH both lip right  \else 上下嘴唇右移 \endif
    NvsAvatarActionTypeMouthBothLipLeft,             //!< \if ENGLISH both lip left  \else 上下嘴唇左移 \endif
    NvsAvatarActionTypeMouthRightCornerUp,           //!< \if ENGLISH mouth right corner up  \else 右嘴角向上扬 \endif
    NvsAvatarActionTypeMouthLeftCornerUp,            //!< \if ENGLISH mouth left corner up  \else 左嘴角向上扬 \endif
    NvsAvatarActionTypeMouthRightCornerDown,         //!< \if ENGLISH mouth right corner down  \else 右嘴角向下撇 \endif
    NvsAvatarActionTypeMouthLeftCornerDown,          //!< \if ENGLISH mouth left corner down  \else 左嘴角向下撇 \endif
    NvsAvatarActionTypeMouthRightCornerBackward,     //!< \if ENGLISH mouth right corner backward  \else 右嘴角向后撇 \endif
    NvsAvatarActionTypeMouthLeftCornerBackward,      //!< \if ENGLISH mouth left corner backward  \else 左嘴角向后撇 \endif
    NvsAvatarActionTypeMouthRightCornerOutward,      //!< \if ENGLISH mouth right corner outward  \else 右嘴角水平向外移(右移) \endif
    NvsAvatarActionTypeMouthLeftCornerOutward,       //!< \if ENGLISH mouth left corner outward  \else 左嘴角水平向外移(左移) \endif
    NvsAvatarActionTypeMouthCornerShrink,            //!< \if ENGLISH mouth corner shrink  \else 嘴角微微收拢 \endif
    NvsAvatarActionTypeMouthLowerLipInward,          //!< \if ENGLISH mouth lower lip inward  \else 下嘴唇内卷 \endif
    NvsAvatarActionTypeMouthUpperLipInward,          //!< \if ENGLISH mouth upper lip inward  \else 上嘴唇内卷 \endif
    NvsAvatarActionTypeMouthLowerLipOutward,         //!< \if ENGLISH mouth lower lip outward  \else 下嘴唇外翻 \endif
    NvsAvatarActionTypeMouthUpperLipOutward,         //!< \if ENGLISH mouth upper lip outward  \else 上嘴唇外翻 \endif
    NvsAvatarActionTypeMouthLowerLipRightUp,         //!< \if ENGLISH mouth lower lip right up  \else 下嘴唇右上翘 \endif
    NvsAvatarActionTypeMouthLowerLipLeftUp,          //!< \if ENGLISH mouth lower lip left up  \else 下嘴唇左上翘 \endif
    NvsAvatarActionTypeMouthLowerLipRightDown,       //!< \if ENGLISH mouth lower lip right down  \else 下嘴唇右下垂 \endif
    NvsAvatarActionTypeMouthLowerLipLeftDown,        //!< \if ENGLISH mouth lower lip left down  \else 下嘴唇左下垂 \endif
    NvsAvatarActionTypeMouthUpperLipRightUp,         //!< \if ENGLISH mouth upper lip right up  \else 上嘴唇右上翘 \endif
    NvsAvatarActionTypeMouthUpperLipLeftUp,          //!< \if ENGLISH mouth upper lip left up  \else 上嘴唇左上翘 \endif
    NvsAvatarActionTypeMouthLipPart,                 //!< \if ENGLISH mouth lip part  \else 微张嘴 \endif
    NvsAvatarActionTypeEyebrowRightOuterDown,        //!< \if ENGLISH eyebrow right outer down  \else 右眉毛外垂 \endif
    NvsAvatarActionTypeEyebrowLeftOuterDown,         //!< \if ENGLISH eyebrow left outer down  \else 左眉毛外垂 \endif
    NvsAvatarActionTypeEyebrowBothInnerUp,           //!< \if ENGLISH eyebrow both inner up  \else 双眉向上内挑 \endif
    NvsAvatarActionTypeEyebrowBothInnerDown,         //!< \if ENGLISH eyebrow both inner down  \else 双眉向下内垂 \endif
    NvsAvatarActionTypeEyebrowRightOuterUp,          //!< \if ENGLISH eyebrow right outer up  \else 右眉外挑 \endif
    NvsAvatarActionTypeEyebrowLeftOuterUp,           //!< \if ENGLISH eyebrow left outer up  \else 左眉外挑 \endif
    NvsAvatarActionTypeCheekBothOutward,             //!< \if ENGLISH cheek both outward  \else 双面颊前突 \endif
    NvsAvatarActionTypeCheekRightUp,                 //!< \if ENGLISH cheek right up  \else 右面颊上提 \endif
    NvsAvatarActionTypeCheekLeftUp,                  //!< \if ENGLISH cheek left up  \else 左面颊上提 \endif
    NvsAvatarActionTypeNoseRightUp,                  //!< \if ENGLISH nose right up  \else 右鼻子上提 \endif
    NvsAvatarActionTypeNoseLeftUp,                   //!< \if ENGLISH nose left up  \else 左鼻子上提 \endif
    NvsAvatarActionTypeNoseBothWide,                 //!< \if ENGLISH nose both wide  \else 双鼻张开 \endif
    NvsAvatarActionTypeTongueOutward                 //!< \if ENGLISH tongue outward  \else 舌头伸出 \endif
};

typedef NS_ENUM(NSInteger,NvsToBeCheckedFunctionType) {
    NvsToBeCheckedFunctionType_Invalid = -1,
    NvsToBeCheckedFunctionType_Matte,           //!< \if ENGLISH Sebum-Clear  \else 去油光 \endif
    NvsToBeCheckedFunctionType_Count
};

/*! \if ENGLISH
 *  \brief Face feature info, landmarks is an array of CGPoints, visibilities is an array of float
 *  \else
 *  \brief 美妆特效渲染层数据, landmarks是CGPoints数组, visibilities是float数组
 *  \endif
 *  \since 2.15.0
 */
NVS_EXPORT @interface NvsFaceFeatureInfo : NSObject

@property (nonatomic, assign) int faceId;
@property (nonatomic, assign) NvsRect boundingBox;
@property (nonatomic, strong) NSMutableArray<NSValue *> *landmarks;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *visibilities;
@property (nonatomic, strong) NSMutableArray<NSValue *> *extraPoints;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *extraVisibilities;
@property (nonatomic, assign) float yaw;
@property (nonatomic, assign) float pitch;
@property (nonatomic, assign) float roll;
@property (nonatomic, strong) NSMutableArray<NSValue *> *vertices;  //Values is NvsPosition3D
@property (nonatomic, assign) NvsPosition3D rotation;
@property (nonatomic, assign) NvsPosition3D translation;

@property (nonatomic, strong) NSMutableArray<NSValue *> *extraVertices;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *faceActions;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *avatarExpressions;

@end

typedef NS_ENUM(NSInteger, NvsHandActionType) {
    NvsHandActionInvalid = -1,
    NvsHandActionOK = 0,        //!< \if ENGLISH OK \else OK \endif
    NvsHandActionScissor,       //!< \if ENGLISH Scissor \else 剪刀手 \endif
    NvsHandActionGood,          //!< \if ENGLISH Good \else Good \endif
    NvsHandActionPalm,          //!< \if ENGLISH Palm \else 手掌 \endif
    NvsHandActionPistol,        //!< \if ENGLISH Pistol \else 手枪 \endif
    NvsHandActionLove,          //!< \if ENGLISH Love \else 爱心 \endif
    NvsHandActionHoldup,        //!< \if ENGLISH Hold Up \else 举手 \endif
    NvsHandActionCongratulate,  //!< \if ENGLISH Congratulate \else 恭喜 \endif
    NvsHandActionFingerHeart,   //!< \if ENGLISH Finger Heart \else 指心 \endif
    NvsHandActionFingerIndex,   //!< \if ENGLISH Finger Index \else 食指 \endif
    NvsHandActionFist,          //!< \if ENGLISH Fist \else 拳头 \endif
    NvsHandAction666,           //!< \if ENGLISH 666 \else 666 \endif
    NvsHandActionBless,         //!< \if ENGLISH Bless \else 祝福 \endif
    NvsHandActionILoveYou,      //!< \if ENGLISH I Love You \else I Love You \endif
    NvsHandActionSSH,           //!< \if ENGLISH SSH \else 嘘 \endif
    NvsHandActionThree,         //!< \if ENGLISH Three \else 三 \endif
    NvsHandActionFour           //!< \if ENGLISH Four \else 四 \endif
};

NVS_EXPORT @interface NvsHandFeatureInfo : NSObject

@property (nonatomic, assign) int handId;
@property (nonatomic, assign) NvsRect boundingBox;
@property (nonatomic, assign) NvsHandActionType actionType;

@end

@protocol NvsARSceneManipulateDelegate <NSObject>
@optional

/*! \if ENGLISH
 *  \brief Get the callback of the original enclosing rectangle for the face.
 *  <br>Please pay special attention: this function is called in the background thread, not in the UI thread. Please consider thread safety issues!!
 *  \param faceIds Array of face tag
 *  \param boundingRects Array of face range
 *  \param count Count of face arrays. When the count is 0, the pointers of "faceIds" and "boundingRects" are nil.
 *  \else
 *  \brief 获取人脸的原始包围矩形框回调
 *  <br>请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param faceIds 人脸标记数组
 *  \param boundingRects 人脸范围数组
 *  \param count 人脸数组数量，当数量为0时，faceIds和boundingRects的指针为空
 *  \endif
 *  \since 2.7.0
*/
- (void)notifyFaceBoundingRectWithId:(int*)faceIds boundingRect:(NvsRect*)boundingRects faceCount:(int)count;

/*! \if ENGLISH
 *  \brief Get the callback of the face features for the face.
 *  <br>Please pay special attention: this function is called in the background thread, not in the UI thread. Please consider thread safety issues!!
 *  \param faceFeatureInfos Array of face feature info
 *  \else
 *  \brief 获取人脸特征信息回调
 *  <br>请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param faceFeatureInfos 人脸特征信息数组
 *  \endif
 *  \since 2.15.0
*/
- (void)notifyFaceFeatureInfos:(NSMutableArray<NvsFaceFeatureInfo *> *)faceFeatureInfos;

/*! \if ENGLISH
 *  \brief Get the callback of the hand features for the face.
 *  <br>Please pay special attention: this function is called in the background thread, not in the UI thread. Please consider thread safety issues!!
 *  \param handFeatureInfos Array of hand feature info
 *  \else
 *  \brief 获取手势特征信息回调
 *  <br>请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param handFeatureInfos 手势特征信息数组
 *  \endif
 *  \since 3.11.1
*/
- (void)notifyHandFeatureInfos:(NSArray<NvsHandFeatureInfo *> *)handFeatureInfos;

/*! \if ENGLISH
 *  \brief Notify if custom avatar realtime resources is preloaded or not.
    Note: This function can only be called in backend thread, not in UI thread.
          Please pay attention to thread safety.
 *  \param isPreloaded custom avatar realtime resources is preloaded or not.
 *  \else
 *  \brief 通知捏脸特效实时模式下所需预加载的资源是否已加载。
    请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param isPreloaded 资源是否已加载。
 *  \endif
 */
- (void)notifyCustomAvatarRealtimeResourcesPreloaded:(BOOL)isPreloaded;

/*! \if ENGLISH
 *  \brief Notify detection time spent.
    Note: This function can only be called in backend thread, not in UI thread.
          Please pay attention to thread safety.
 *  \param time detection time spent.
 *  \else
 *  \brief 通知人脸检测用时。
    请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param time 人脸检测用时。
 *  \endif
 */
- (void)notifyDetectionTimeCost:(float)time;


/*! \if ENGLISH
 *  \brief Notify total time spent.
    Note: This function can only be called in backend thread, not in UI thread.
          Please pay attention to thread safety.
 *  \param  time total time spent.
 *  \else
 *  \brief 通知总用时。
    请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param time 用时。
 *  \endif
 */
- (void)notifyTotalTimeCost:(float)time;

@end

/*! \if ENGLISH
 *  \brief AR scene processing interface
 *
 *  \warning In the NvsARSceneManipulate class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief AR场景处理接口
 *
 *  \warning NvsARSceneManipulate类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsARSceneManipulate : NSObject

@property (nonatomic, weak) id<NvsARSceneManipulateDelegate> delegate;

/*!
 *  \if ENGLISH
 *  \brief Set detection mode.
 *  \param mode detection mode, for all supported mode, please refer to [ARSCENE_DETECTION_MODE].
 *  \else
 *  \brief 设置检测模式。
 *  \param mode 检测模式, 当前支持的检测模式请参见[AR场景检测模式](@ref ARSCENE_DETECTION_MODE)。
 *  \endif
*/
- (void)setDetectionMode:(NvsARSceneDetectionMode)mode;

/*!
 *  \if ENGLISH
 *  \brief Reset tracking.
 *  \else
 *  \brief 重置跟踪。
 *  \endif
*/
- (void)resetTracking;

/*!
 *  \if ENGLISH
 *  \brief Reset skin color.
 *  \else
 *  \brief 重置肤色。
 *  \endif
*/
- (void)resetSkinColor;

/*!
 *  \if ENGLISH
 *  \brief Set automatically probe face orientation or not.
 *  \param autoProbe automatically probe or not.
 *  \else
 *  \brief 设置是否自动探测人脸朝向。
 *  \param autoProbe 是否自动探测人脸朝向。
 *  \endif
*/
- (void)setDetectionAutoProbe:(bool)autoProbe;

- (void)setInternalObject:(void *)internalObject;

/*!
 *  \if ENGLISH
 *  \brief Set disable detection smooth or not.
 *  \param disable disable or not.
 *  \else
 *  \brief 禁用平滑检测
 *  \param disable 禁用。
 *  \endif
*/
- (void)setDisableDetectionSmooth:(BOOL)disable;

/*!
 *  \if ENGLISH
 *  \brief Sets sound volume in AR.
 *  \param volume volume value, value range [0, 1].
 *  \else
 *  \brief 设置AR特效中音效音量
 *  \param volume 音量，取值范围[0, 1]
 *  \endif
 *  \since 3.8.0
*/
- (void)setSoundVolumeGain:(float)volume;

/*!
 *  \if ENGLISH
 *  \brief Gets sound volume in AR.
 *  \return Returns the sound volume.
 *  \else
 *  \brief 获取AR特效中音效音量
 *  \return 返回获取的音量
 *  \endif
 *  \since 3.8.0
*/
- (float)getSoundVolumeGain;

/*!
 *  \if ENGLISH
 *  \brief Sets music volume in AR.
 *  \param volume volume value, value range [0, 1].
 *  \else
 *  \brief 设置AR特效中音乐音量
 *  \param volume 音量，取值范围[0, 1]
 *  \endif
 *  \since 3.8.0
*/
- (void)setMusicVolumeGain:(float)volume;

/*!
 *  \if ENGLISH
 *  \brief Gets sound volume in AR.
 *  \return Returns the music volume.
 *  \else
 *  \brief 获取AR特效中音乐音量
 *  \return 返回获取的音量
 *  \endif
 *  \since 3.8.0
*/
- (float)getMusicVolumeGain;

/*!
 *  \if ENGLISH
 *  \brief The ability to check the phone for certain special effects.
 *  \param functionType Type of special effects ability, such as: degreasing, etc.
 *  \else
 *  \brief 检查手机是否有某种特效的能力。
 *  \param functionType 特效能力的类型，比如：去油光等。
 *  \endif
*/
- (BOOL)isFunctionAvailable:(NvsToBeCheckedFunctionType)functionType;

/*!
 *  \if ENGLISH
 *  \brief Face Landmark confidence threshold.
 *  \param thresh 阈值 默认0.
 *  \else
 *  \brief 人脸点位置信度阈值。
 *  \param thresh threshold, default is 0.
 *  \endif
*/
- (void)setFaceLandmarkConfidenceThresh:(float)thresh;

/*!
 *  \if ENGLISH
 *  \brief Set face landmark confidence thresh.
 *  \param thresh range[0-1], Default is 0.0。
 *  \else
 *  \brief 点位置信度阈值
 *  \param thresh 阈值范围[0,1], 默认值是0.0。
 *  \endif
*/
- (void)setFaceConfidenceThresh:(float)thresh;

/*!
 *  \if ENGLISH
 *  \brief Set Detection Force Interval.
 *  \param interval, detect intervel.
 *  \else
 *  \brief 强制检测帧间隔。
 *  \param interval, 强制检测帧间隔。
 *  \endif
*/
- (void)setDetectionForceInterval:(int)interval;

/*!
 *  \if ENGLISH
 *  \brief Set Detection Interval.
 *  \param interval, detect intervel.
 *  \else
 *  \brief 检测帧间隔。
 *  \param interval, 检测帧间隔。
 *  \endif
*/
- (void)setDetectionInterval:(int)interval;
@end
