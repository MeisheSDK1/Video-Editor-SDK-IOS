//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2019. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Apr 20. 2019
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <UIKit/UIImage.h>
#import "NvsCommonDef.h"

typedef enum {
    NvsIconGeneratorFlag_KeyFrame = 1,
    NvsIconGeneratorFlag_PHAssetResizeNone = 2,
    NvsIconGeneratorFlag__AccurateTolerance = 4,
} NvsIconGeneratorFlags;


/*! \if ENGLISH
 *  \brief Picture get callback.
 *  \else
 *  \brief 图片获取回调
 *  \endif
*/
@protocol NvsIconGeneratorDelegate<NSObject>

/*! \if ENGLISH
 *  \brief Picture get callback.
 *  \param icon Current icon
 *  \param timestamp Current timestamp
 *  \param taskId Current taskId
 *  \else
 *  \brief 图片获取回调
 *  \param icon 当前图片
 *  \param timestamp 当前的时间点
 *  \param taskId 当前任务
 *  \endif
*/
- (void)didIconReady:(UIImage *)icon timestamp:(int64_t)timestamp taskId:(int64_t)taskId;

@end

/*! \if ENGLISH
 *  \brief NvsIconGenerator.
 *  \else
 *  \brief 图片获取类
 *  \endif
*/
NVS_EXPORT @interface NvsIconGenerator : NSObject

@property (nonatomic, weak) id<NvsIconGeneratorDelegate> delegate; //!< \if Agent callback for image acquisition \else 图片获取的代理回调 \endif

/*! \if ENGLISH
 *  \brief Initialization.
 *  \return Returns the NvsIconGenerator object.
 *  \else
 *  \brief 初始化
 *  \return 返回对象实例
 *  \endif
*/
- (instancetype)init;

/*! \if ENGLISH
 *  \brief Get picture from cache.
 *  \param mediaFilePath Resource path
 *  \param timestamp Current time
 *  \param flags Flag field. If there is no special requirement, please fill in 0.Please refer to NvsIconGeneratorFlags
 *  \return Returns the UIImage.
 *  \else
 *  \brief 从缓存中获取图片
 *  \param mediaFilePath 资源路径
 *  \param timestamp 当前的时间点
 *  \param flags 标志字段，如无特殊需求请填写0,请参见NvsIconGeneratorFlags
 *  \return 返回图片
 *  \endif
*/
- (UIImage *)getIconFromCache:(NSString *)mediaFilePath timestamp:(int64_t)timestamp flags:(int)flags;

/*! \if ENGLISH
 *  \brief Get pictures from original sources.
 *  \param mediaFilePath Resource path
 *  \param timestamp Current time
 *  \param flags Flag field. If there is no special requirement, please fill in 0.Please refer to NvsIconGeneratorFlags
 *  \return Returns taskId
 *  \else
 *  \brief 从原始资源中获取图片
 *  \param mediaFilePath 资源路径
 *  \param timestamp 当前的时间点
 *  \param flags 标志字段，如无特殊需求请填写0,请参见NvsIconGeneratorFlags
 *  \return 返回任务id
 *  \endif
*/
- (int64_t)getIcon:(NSString *)mediaFilePath timestamp:(int64_t)timestamp flags:(int)flags;

/*! \if ENGLISH
 *  \brief Cancel current task.
 *  \param taskId taskId
 *  \else
 *  \brief 取消当前任务
 *  \param taskId 任务id
 *  \endif
*/
- (void)cancelTask:(int64_t)taskId;

@end

