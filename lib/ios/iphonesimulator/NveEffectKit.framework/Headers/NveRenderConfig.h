//
//  NveRenderConfig.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NveTextureLayout) {
    NveTextureLayout_bottom_up,
    NveTextureLayout_up_down
};

typedef NS_ENUM(NSInteger, NvePixelFormatType) {
    NvePixelFormatType_none,
    NvePixelFormatType_bgra,
    NvePixelFormatType_nv12,
    NvePixelFormatType_yuv420
};

@interface NveTexture : NSObject

/// 纹理ID
@property(nonatomic, assign) GLuint textureId;

/// 纹理宽高
@property(nonatomic, assign) CGSize size;

///出纹理方向
@property(nonatomic, assign) NveTextureLayout textureLayout;

@end

@interface NveImageBuffer : NSObject

// 镜像
@property(nonatomic, assign) BOOL mirror;

// 旋转角度
@property(nonatomic, assign) float displayRotation;

// 原始图片的朝向，即AVCaptureConnection的videoOrientation值
@property(nonatomic, assign) AVCaptureVideoOrientation imageOrientation;

// buffer
@property(nonatomic, assign) CVPixelBufferRef _Nullable pixelBuffer;

+ (CVPixelBufferRef)convertI420toNV12:(CVPixelBufferRef)srcBufferRef;

@end

typedef NS_ENUM(NSInteger, NveRenderMode) {
    NveRenderMode_texture_texture,
    NveRenderMode_buffer_texture,
    NveRenderMode_buffer_buffer
};

@interface NveRenderConfig : NSObject

/// 渲染模式
@property(nonatomic, assign) NveRenderMode renderMode;

/// 输出纹理方向
@property(nonatomic, assign) NveTextureLayout outputTextureLayout;

/// 输出Buffer格式， .none： 不指定，和输入保持一致
@property(nonatomic, assign) NvePixelFormatType outputFormatType;

/// 输出到输入Buffer
@property(nonatomic, assign) BOOL overlayInputBuffer;

// 当前图像是否来源于前置摄像头，默认为 NO
@property(nonatomic, assign) BOOL isFromFrontCamera;

@property(nonatomic, assign) BOOL autoMotion;

@end

NS_ASSUME_NONNULL_END
