//
//  EFPreview+NveEffectKit.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/9.
//

#import "EFPreview+NveEffectKit.h"

@implementation EFPreview (NveEffectKit)

- (void)displayRenderOutput:(NveRenderOutput *)output presentationTimeStamp:(CMTime)presentationTimeStamp duration:(CMTime)duration {
    if (output.texture.textureId != 0) {
        [self newFrameReadyTexture:output.texture.textureId size:output.texture.size];
    } else {
        //unsupport buffer
    }
}

@end
