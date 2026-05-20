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
*  \brief Mask region type
*  \else
*  \brief 构成蒙版的区域类型
*  \endif
*  \since 2.16.0
*/
typedef enum {
    NvsMaskRegionType_Polygon = 0,      //!< \if ENGLISH polygon region \else 多边形区域 \endif
    NvsMaskRegionType_CubicCurve,       //!< \if ENGLISH region composed of cubic curve \else 三阶贝塞尔曲线围成的区域 \endif
    NvsMaskRegionType_Ellipse2D,        //!< \if ENGLISH ellipse region \else 椭圆区域 \endif
    NvsMaskRegionType_Mirror,           //!< \if ENGLISH mirror region \else 镜面区域 \endif
} NvsMaskRegionType;

/*! \if ENGLISH
 *  \brief Ellipse
 *  \else
 *  \brief 椭圆
 *  \endif
 *  \since 2.16.0
 */
typedef struct {
    NvsPosition2D center;
    float a, b, theta;
} NvsMaskEllipse2D;

/*! \if ENGLISH
 *  \brief Mirror
 *  \else
 *  \brief 镜面
 *  \endif
 *  \since 3.3.0
 */
typedef struct {
    NvsPosition2D center;
    float distance, theta;
} NvsMaskMirror;

/*! \if ENGLISH
 *  \brief 2d transfrom
 *  \else
 *  \brief 二维变换
 *  \endif
 *  \since 2.16.0
 */
typedef struct {
    NvsPosition2D anchor;
    NvsPosition2D scale;
    float rotation;
    NvsPosition2D translation;
} NvsMaskTransform2D;

/*! \if ENGLISH
 *  \brief Sub Region information
 *  <br> points is an array of CGPoint
 *  \else
 *  \brief 子区域信息
 *  <br> points是CGPoint的数组
 *  \endif
 *  \since 2.16.0
 */
NVS_EXPORT @interface NvsMaskSubRegionInfo : NSObject

@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSMutableArray<NSValue *> *points;
@property (nonatomic, assign) NvsMaskEllipse2D ellipse2d;
@property (nonatomic, assign) NvsMaskMirror mirror;
@property (nonatomic, assign) NvsMaskTransform2D transform2d;

@end

/*! \if ENGLISH
 *  \brief Mask Region information
 *  \else
 *  \brief 蒙版区域信息
 *  \endif
 *  \since 2.16.0
 */
NVS_EXPORT @interface NvsMaskRegionInfo : NvsArbitraryData
@property (nonatomic, strong) NSMutableArray<NvsMaskSubRegionInfo *> *regionInfoArray;
@end


