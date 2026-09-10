//
//  NvMimoPlayerView.m
//  NvMimoDemo
//
//  Created by MS on 2020/7/28.
//  Copyright © 2020 MS. All rights reserved.
//

#import "NvMimoPlayerView.h"

@implementation NvMimoPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end
