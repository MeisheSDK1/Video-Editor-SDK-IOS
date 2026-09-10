//
//  NveRenderInput.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import "NveRenderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface NveRenderInput : NSObject

@property(nonatomic, strong) NveTexture *_Nullable texture; //!< \if ENGLISH Texture \else 输入的纹理 \endif

/*! \if ENGLISH Input pixelBuffer, also used for face detection
    \else 输入的pixelBuffer，同时用来做人脸检测
    \endif
 */
@property(nonatomic, strong) NveImageBuffer *_Nullable imageBuffer;

@property(nonatomic, strong) NveRenderConfig *config; //!< \if ENGLISH I/o configuration \else 输入输出配置 \endif

@property(nonatomic, assign) int64_t renderTimestamp;

@end

NS_ASSUME_NONNULL_END
