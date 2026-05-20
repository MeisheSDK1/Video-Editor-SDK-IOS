//
//  NvChangeVoiceBottomView.h
//  SDKDemo
//
//  Created by ms on 2021/3/10.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 音频特效 Audio special effects
typedef NS_ENUM(NSInteger, ChangeVoiceType) {
    ChangeVoiceNone = 0,            ///< 无
    ChangeVoiceMenVoice,            ///< 男声
    ChangeVoiceReverberation ,      ///< 混响
    ChangeVoiceElectronics,         ///< 电子
    ChangeVoiceAuditorium,          ///< 礼堂
    ChangeVoiceWomenVoice,          ///< 女声
    ChangeVoiceCartoon,             ///< 卡通
    ChangeVoiceEchoes,              ///< 回声
    ChangeVoiceMonster,             ///< 怪兽
};


NS_ASSUME_NONNULL_BEGIN


@interface NvChangeVoiceBottomView : UIView


/// 选中回调 Selected callback
@property (nonatomic, copy) void(^selectItemClick)(ChangeVoiceType, NSString *);

@end

NS_ASSUME_NONNULL_END
