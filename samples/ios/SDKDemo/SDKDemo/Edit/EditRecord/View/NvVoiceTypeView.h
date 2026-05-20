//
//  NvVoiceTypeView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvVoiceItem.h"
@class NvVoiceTypeView;

@protocol NvVoiceTypeViewDelegate

- (void)voiceTypeView:(NvVoiceTypeView *)voiceTypeView didSelectItem:(NvVoiceItem *)item;
- (void)voiceTypeView:(NvVoiceTypeView *)voiceTypeView okClick:(UIButton *)button;

@end

@interface NvVoiceTypeView : UIView

@property (nonatomic, weak)id delegate;
@property (nonatomic, strong)NSMutableArray *dataSource;

@end
