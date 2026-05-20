//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jul 21. 2020
//   Author:        Meishe video team
//================================================================================

#pragma once

#import "NvsCommonDef.h"
#import "NvsArbitraryData.h"

/*! \if ENGLISH
 *  \brief Ellipse
 *  \else
 *  \brief NvsControlHandle
 *  \endif
 *  \since 3.5.0
 */
typedef struct {
    NvsPosition2D endPt;
    NvsPosition2D bwdCtlPt;
    NvsPosition2D fwdCtlPt;
} NvsControlHandle;

/*! \if ENGLISH
 *  \brief Mirror
 *  \else
 *  \brief 镜面
 *  \endif
 *  \since 3.5.0
 */
typedef struct {
    NvsControlHandle topLeftHdl;
    NvsControlHandle bottomLeftHdl;
    NvsControlHandle bottomRightHdl;
    NvsControlHandle topRightHdl;
} NvsControlUnit;

/*! \if ENGLISH
 *  \brief Mask Region information
 *  \else
 *  \brief MeshWarp信息
 *  \endif
 *  \since 3.5.0
 */
NVS_EXPORT @interface NvsMeshWarpInfo : NvsArbitraryData

@property(assign, nonatomic) NSUInteger rows;
@property(assign, nonatomic) NSUInteger cols;
@property(assign, nonatomic) NvsRect refBounding;
@property(strong, nonatomic) NSMutableArray <NSValue*>*controlUnits;//value is NvsControlUnit

@end


