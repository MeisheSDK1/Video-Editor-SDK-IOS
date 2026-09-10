//
//  NvZoomEffectRenderCore.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/28.
//  Copyright © 2018 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NvStreamingSdkCore/NvsEffectSdkContext.h>
#import <CoreVideo/CVPixelBuffer.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvZoomEffectRenderCore : NSObject

- (void)initWithContext:(NvsEffectRenderCore *)core;
- (void)addNewRenderEffect:(NvsEffect *)effect;
- (void)removeRenderEffect:(NSString *)effectId;

-(NSArray<NvsEffect*>*)currentRenderEffectArray;

- (int)renderVideoEffect:(int)inputTex
                   width:(int)width
                  height:(int)height
        currentTimeStamp:(long)currentTimeStamp
           isFrontCamera:(BOOL)isFrontCamera
            isStillImage:(BOOL)isStillImage;

@property(nonatomic, strong) NSString *POSITION_COORDINATE;
@property(nonatomic, strong) NSString *TEXTURE_UNIFORM;
@property(nonatomic, strong) NSString *TEXTURE_COORDINATE;
@property(nonatomic, strong) NvsEffectSdkContext *effectSdkContext;

- (CVPixelBufferRef)getRenderResultPixelBuffer;

-(void)cleanUp;

@end

NS_ASSUME_NONNULL_END
