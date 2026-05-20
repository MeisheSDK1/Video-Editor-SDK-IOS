//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2021. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 07. 2021
//   Author:        Meishe video team
//================================================================================

#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \if ENGLISH
 *  \brief clip data
 *  \else
 *  \brief 片段数据
 *  \endif
 *  \since 3.2.0
 */
NVS_EXPORT @interface NvsClipData : NSObject

@property (nonatomic) float pan;    //!< \if ENGLISH pan For details, please refer to the topic of [Pan and Scan] (\ref Pan_Scan.md). \else 摇摄 具体请参见[摇摄与扫描(Pan and Scan)] (\ref Pan_Scan.md)专题。\endif
@property (nonatomic) float scan;    //!< \if ENGLISH scan For details, please refer to the topic of [Pan and Scan] (\ref Pan_Scan.md). \else 扫描 具体请参见[摇摄与扫描(Pan and Scan)] (\ref Pan_Scan.md)专题。\endif
@property (nonatomic) NSString* mediaPath;    //!< \if ENGLISH media path \else 资源路径 \endif
@property (nonatomic) NSString* imageFillMode;    //!< \if ENGLISH image fill mode，include "fit", "letterBox", "crop" and "stretch" \else 图片填充模式,包括"fit","letterBox","crop"和"stretch" \endif

@end

/*! \if ENGLISH
*   \brief Capture scene informations.
*   \else
*   \brief 拍摄场景资源信息。
*   \endif
*   \since 3.2.0
*/

NVS_EXPORT @interface NvsCaptureSceneInfo : NSObject

@property (nonatomic, strong) NSMutableArray<NvsClipData *> *backgroundClipArray;
@property (nonatomic, strong) NSMutableArray<NvsClipData *> *foregroundClipArray;

@end
