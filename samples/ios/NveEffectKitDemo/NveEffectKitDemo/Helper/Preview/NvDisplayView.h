//
//  NvDisplayView.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/15.
//

#import <UIKit/UIKit.h>
#import <NveEffectKit/NveEffectKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvDisplayProtocol <NSObject>

- (void)displayRenderOutput:(NveRenderOutput *)output presentationTimeStamp:(CMTime)presentationTimeStamp duration:(CMTime)duration;

- (void)cleanUp;

@end

@interface NvDisplayView : UIView

+ (UIView<NvDisplayProtocol> *)bufferDisplayViewWithFrame:(CGRect)frame;

+ (UIView<NvDisplayProtocol> *)textureDisplayViewWithFrame:(CGRect)frame glContext:(EAGLContext *)glContext;

@end

NS_ASSUME_NONNULL_END
