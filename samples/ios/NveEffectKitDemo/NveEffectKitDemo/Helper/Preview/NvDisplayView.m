//
//  NvDisplayView.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/15.
//

#import "NvDisplayView.h"
#import "EFPreview+NveEffectKit.h"
#import "EFBufferDisplayView+NveEffectKit.h"

@implementation NvDisplayView

+ (UIView<NvDisplayProtocol> *)bufferDisplayViewWithFrame:(CGRect)frame {
    EFBufferDisplayView *preview = [[EFBufferDisplayView alloc] initWithFrame:frame];
    return preview;
}

+ (UIView<NvDisplayProtocol> *)textureDisplayViewWithFrame:(CGRect)frame glContext:(EAGLContext *)glContext {
    EFPreview *preview = [[EFPreview alloc] initWithFrame:frame glContext:glContext];
    return preview;
}

@end
