//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Feb 22. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <UIKit/UIView.h>
#import "NvsMultiThumbnailSequenceView.h"

/*! \if ENGLISH
 *  \brief Thumbnail sequence
 *
 *  Note: Please do not use this control for new code, please use the NvsMultiThumbnailSequenceView control!
 *  The sequence of thumbnails, that is, the video is scaled to some extent, to statically shorten the displayed sequence. During video edition, by previewing the video sequence, users can set the start time, duration, and aspect ratio of the sequence. At the same time, the subtitles and the cropped video are precisely added at the corresponding time slot position according to the thumbnail.
 *  \warning NvsThumbnailSequenceView类中，所有public API都在UI线程使用！！！
 *  \else
 *  \brief 缩略图序列
 *
 *  注意：新的代码请不要再使用这个控件，请使用NvsMultiThumbnailSequenceView控件！
 *  缩略图序列，即视频按照某种程度缩放，来静态缩略显示的序列。视频编辑时，通过预览定位视频序列，可以设置序列的开始时间，时长，缩略图横纵比等。同时，依照缩略图在对应时段位置精确添加字幕和裁剪视频。
 *  \warning NvsThumbnailSequenceView类中，所有public API都在UI线程使用！！！
 *  \endif
 *  \since 1.1.0
 *  \deprecated
*/
NVS_EXPORT @interface NvsThumbnailSequenceView : UIView

@property (nonatomic) NSString *mediaFilePath;                          //!< \if ENGLISH The absolute path to media files \else 媒体文件的绝对路径 \endif
@property (nonatomic) int64_t startTime;                                //!< \if ENGLISH Sequence start time (in microseconds) \else 序列开始时间（单位微秒 \endif
@property (nonatomic) int64_t duration;                                 //!< \if ENGLISH Sequence duration (in microseconds) \else 序列时长（单位微秒） \endif
@property (nonatomic) float thumbnailAspectRatio;                       //!< \if ENGLISH Thumbnail aspect ratio \else 缩略图横纵比 \endif
@property (nonatomic) BOOL stillImageHint;                              //!< \if ENGLISH Whether it is a still image \else 是否是静态图片 \endif
@property (nonatomic) NvsThumbnailImageFillMode thumbnailImageFillMode; //!< \if ENGLISH Thumbnail image fill mode \else  缩略图图片填充模式 \endif


- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end

