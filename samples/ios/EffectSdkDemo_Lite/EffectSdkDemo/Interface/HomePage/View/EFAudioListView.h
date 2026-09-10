//
//  EFAudioListView.h
//  EffectSdkDemo
//
//  Created by LiYong on 2021/12/20.
//  Copyright © 2021 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AudioListBlock) (NSString * _Nullable );

NS_ASSUME_NONNULL_BEGIN

@interface EFAudioListView : UIView
@property (nonatomic,copy) AudioListBlock selectBlock;
- (void)reload;
@end

NS_ASSUME_NONNULL_END
