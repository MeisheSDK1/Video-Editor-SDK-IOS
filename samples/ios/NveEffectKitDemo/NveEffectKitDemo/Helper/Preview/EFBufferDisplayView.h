//
//  EFBufferDisplayView.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/9.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EFBufferDisplayView : UIView

@property(nonatomic, readonly) AVSampleBufferDisplayLayer *displayLayer;

@end

NS_ASSUME_NONNULL_END
