//
//  NvAudioListView.h
//  AudioEqualizer
//
//  Created by ms on 2022/1/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvAudioListView : UIView
@property (nonatomic, copy) void(^selectBlock)(NSString *, NSUInteger);
@end

NS_ASSUME_NONNULL_END
