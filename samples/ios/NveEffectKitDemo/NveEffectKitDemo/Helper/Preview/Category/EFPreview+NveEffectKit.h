//
//  EFPreview+NveEffectKit.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/9.
//

#import "EFPreview.h"
#import <NveEffectKit/NveEffectKit.h>
#import "NvDisplayView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EFPreview (NveEffectKit) <NvDisplayProtocol>

- (void)displayRenderOutput:(NveRenderOutput *)output presentationTimeStamp:(CMTime)presentationTimeStamp duration:(CMTime)duration;

@end

NS_ASSUME_NONNULL_END
