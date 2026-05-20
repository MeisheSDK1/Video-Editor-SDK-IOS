//
//  NvSuperZoom.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/29.
//  Copyright © 2018 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NvStreamingSdkCore/NvsEffectSdkContext.h>
#import <CoreVideo/CVPixelBuffer.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvSuperZoomDelegate <NSObject>

- (void)finishRender;
- (void)updateRenderProgress:(float)progress;

@end


@interface NvSuperZoom : NSObject

@property (nonatomic, weak  ) id<NvSuperZoomDelegate> delegate;

- (instancetype)initWithEffectRenderCore:(NvsEffectRenderCore *)renderCore;

- (BOOL)start:(NSString *)effectName
   effectPath:(NSString *)effectPath
   imageWidth:(int)imageWidth
  imageHeight:(int)imageHeight
      anchorX:(float)anchorX
      anchorY:(float)anchorY;

- (void)stop;

- (int)render:(int)textureId
isFrontCamera:(BOOL)isFrontCamera;

- (BOOL)renderEnded;

- (int)getEffectDuration;

-(NSArray<NvsEffect*>*)currentRenderEffectArray;

- (CVPixelBufferRef)getRenderResultPixelBuffer;

-(void)cleanUp;

@end

NS_ASSUME_NONNULL_END
