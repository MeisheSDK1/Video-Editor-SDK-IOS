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

/*! \anchor OBJECT_TRACKING_TYPE */
/*!
 *  \if ENGLISH
 *   @name Object tracking type.
 *  \else
 *   @name 物体跟踪类型。
 *  \endif
*/
//!@{
typedef enum
{
    NvsObjectTrackingType_Face = 0,         //!< \if ENGLISH Detects faces \else 检测人脸 \endif
    NvsObjectTrackingType_Animal            //!< \if ENGLISH Detects animal \else 检测动物 \endif
} NvsObjectTrackingType;
//!@}

/*! \anchor OBJECT_LAND_MARK_TYPE */
/*!
 *  \if ENGLISH
 *   @name Object landmark type.
 *  \else
 *   @name 物体关键点类型。
 *  \endif
*/
//!@{
typedef enum
{
    NvsObjectLandmarkType_Face = 0,         //!< \if ENGLISH face landmark \else 人脸关键点 \endif
    NvsObjectLandmarkType_Animal            //!< \if ENGLISH animal landmark \else 动物关键点 \endif
} NvsObjectLandmarkType;
//!@}

/*! \anchor ACTION_TYPE */
/*!
 *  \if ENGLISH
 *   @name Detected action type options.
 *  \else
 *   @name 检测到的动作类型。
 *  \endif
*/
//!@{
typedef enum
{
    NvsObjectActionType_Face_Detect = 0x00000001L,              //!< \if ENGLISH face detected \else 检测到脸 \endif
    NvsObjectActionType_Face_Lips_Upward = 0x00000040L,         //!< \if ENGLISH lips upward \else 嘴角上扬 \endif
    NvsObjectActionType_Face_Lips_Pouted = 0x00000080L,         //!< \if ENGLISH face lips pouted \else 嘟嘴 \endif
    NvsObjectActionType_Eye_Blink = 0x00000002L,                //!< \if ENGLISH eye blink \else 眨眼 \endif
    NvsObjectActionType_Mouth_Ah = 0x00000004L,                 //!< \if ENGLISH mouth open \else 嘴巴大张 \endif
    NvsObjectActionType_Head_Yaw = 0x00000008L,                 //!< \if ENGLISH head yaw \else 摇头 \endif
    NvsObjectActionType_Head_Pitch = 0x00000010L,               //!< \if ENGLISH head pitch \else 点头 \endif
    NvsObjectActionType_Brow_Jump = 0x00000020L,                //!< \if ENGLISH brow jump \else 眉毛挑动 \endif

    NvsObjectActionType_Hand_Detect = 0x00000100L,              //!< \if ENGLISH hand detected \else 检测到手 \endif
    NvsObjectActionType_Hand_OK = 0x00000200L,                  //!< \if ENGLISH ok hand \else OK手势 \endif
    NvsObjectActionType_Hand_Scissor = 0x00000400L,             //!< \if ENGLISH scissor hand \else 剪刀手 \endif
    NvsObjectActionType_Hand_Good = 0x00000800L,                //!< \if ENGLISH good hand \else 大拇哥 \endif
    NvsObjectActionType_Hand_Palm = 0x00001000L,                //!< \if ENGLISH hand palm \else 手掌 \endif
    NvsObjectActionType_Hand_Pistol = 0x00002000L,              //!< \if ENGLISH pistol hand \else 手枪手势 \endif
    NvsObjectActionType_Hand_Love = 0x00004000L,                //!< \if ENGLISH love hand \else 爱心手势 \endif
    NvsObjectActionType_Hand_Holdup = 0x00008000L,              //!< \if ENGLISH holdup hand \else 托手手势 \endif
    NvsObjectActionType_Hand_Congratulate = 0x00020000L,        //!< \if ENGLISH congratulate hand \else 恭贺（抱拳) \endif
    NvsObjectActionType_Hand_Finger_Heart = 0x00040000L,        //!< \if ENGLISH finger heart \else 单手比爱心 \endif
    NvsObjectActionType_Hand_Finger_Index = 0x00100000L,        //!< \if ENGLISH finger index \else 食指指尖 \endif
    NvsObjectActionType_Hand_Fist = 0x00200000L,                //!< \if ENGLISH fist \else  拳头手势\endif
    NvsObjectActionType_Hand_666 = 0x00400000L,                 //!< \if ENGLISH 666 hand \else 666 \endif
    NvsObjectActionType_Hand_Bless = 0x00800000L,               //!< \if ENGLISH bless \else 双手合十 \endif
    NvsObjectActionType_Hand_ILoveYou = 0x010000000000L,        //!< \if ENGLISH  i love you \else 手势ILoveYou \endif
    NvsObjectActionType_Hand_Ssh = 0x400000000000L              //!< \if ENGLISH shush \else  手势嘘\endif
}NvsObjectDetectActionType;
//!@}

@protocol NvsARFaceContextDelegate <NSObject>
@optional

/*! \if ENGLISH
 *  \brief Notifies that the face props starts loading.
 *  \param itemPath Face props path.
 *  \else
 *  \brief 通知人脸道具开始加载。
 *  \param itemPath 人脸道具路径。
 *  \endif
 */
- (void)notifyFaceItemLoadingBegin:(NSString *)itemPath ;

/*! \if ENGLISH
 *  \brief Notifies the completion of loading face props.
 *  \else
 *  \brief 通知人脸道具加载完成。
 *  \endif
 */
- (void)notifyFaceItemLoadingFinish ;

/*! \if ENGLISH
 *  \brief Notifies that face props loading fails.
 *  \param itemPath Face props path.
 *  \param error error id.
 *  \else
 *  \brief 通知人脸道具加载失败。
 *  \param itemPath 人脸道具路径。
 *  \param error 错误值。
 *  \endif
 */
- (void)notifyFaceItemLoadingFailed:(NSString *)itemPath error:(int) error ;

/*! \if ENGLISH
 *  \brief Notifies that item landmark.
 *  \param landmark object landmark.
 *  \param objectCount object count.
 *  \param type (face or animal).
 *  \param timestamp landmark timestamp.
 *  \else
 *  \brief 点位回调。
 *  \param landmark 点位数据。
 *  \param objectCount 具有点位的物体数量。
 *  \param type 具有点位的物体类型(人脸或者猫脸)。
 *  \param timestamp 获取到点位时间戳。
 *  \endif
 */
- (void)notifyObjectLandmark:(NSArray*)landmark size:(int)objectCount type:(NvsObjectLandmarkType)type timeStamp:(int64_t)timestamp;

/*! \if ENGLISH
 *  \brief Notifies that detected an human action.
 *  \param actionType which type detected,[Detected action type options](@ref ACTION_TYPE).
 *  \else
 *  \brief 回调检测到的动作。
 *  \param actionType 检测到的动作类型，[检测到的动作类型](@ref ACTION_TYPE)。
 *  \endif
 */
- (void)notifyDetectedAction:(long long)actionType ;
@end

/*!
 *  \if ENGLISH
 *  \brief ARFace context
 *  \warning In the NvsARFaceContext class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief ARFace上下文
 *  \warning NvsARFaceContext类中，所有public API都在UI线程使用！！！
 *  \endif
 */
@interface NvsARFaceContext : NSObject

@property (nonatomic, weak) id<NvsARFaceContextDelegate> delegate;

- (void)setInternalContext:(void *)internalContext;

/*! \if ENGLISH
 *  \brief Check if face is being tracked.
 *  \return Returns a boolean value. true means face is being tracked, false means the opposite.
 *  \else
 *  \brief 当前是否有人脸跟踪。
 *  \return 返回布尔值。值为true表示当前有人脸跟踪，false表示当前没有人脸跟踪。
 *  \endif
 */
- (bool)isFaceTracking;

/*! \if ENGLISH
 *  \brief Check if object of certain type is being tracked.
 *  \param trackingType Tracking object type.
 *  \return Returns a boolean value. true means object of certain type is being tracked, false means the opposite.
 *  \else
 *  \brief 当前是否有指定类型物体被跟踪。
 *  \param trackingType 跟踪物体类型。
 *  \return 返回布尔值。值为true表示当前有指定类型的物体被跟踪，false表示当前没有指定物体类型的物体被跟踪。
 *  \endif
 */
- (bool)isObjectTracking:(NvsObjectTrackingType)trackingType;

/*! \if ENGLISH
 *  \brief Reload current sticker.
 *  \else
 *  \brief 重新加载当前贴纸。
 *  \endif
 */
- (void)setReloadCurSticker;

@end
