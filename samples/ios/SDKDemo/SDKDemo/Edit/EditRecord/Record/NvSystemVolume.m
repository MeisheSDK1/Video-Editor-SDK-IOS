//
//  NvSystemVolume.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvSystemVolume.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface NvSystemVolume()

@property (nonatomic, strong) UISlider* volumeViewSlider;

@end

@implementation NvSystemVolume

+ (instancetype)instence {
    __block NvSystemVolume *systemVolume;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemVolume = [[NvSystemVolume alloc] initWithFrame:CGRectMake(-100, -100, 100, 100)];
    });
    return systemVolume;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        ///自定义MPVolumeView 高度不能改变其他都可以
        ///You can't change the height of your custom MPVolumeView
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:self.bounds];
        ///把自定义的MPVolumeView贴在view上
        ///Attach your custom MPVolumeView to the view
        volumeView.tag = 1001;
        [self addSubview: volumeView];

        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                self.volumeViewSlider.backgroundColor = [UIColor yellowColor];
                break;
            }
        }

    }
    return self;
}

- (void)setVolume:(float)volume {
    self.volumeViewSlider.value = volume;
}

- (float)volume {
    return self.volumeViewSlider.value > 0 ? self.volumeViewSlider.value : [AVAudioSession sharedInstance].outputVolume;
}

@end
