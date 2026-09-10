//
//  NvPhotoAlbumPlayerView.m
//  SDKDemo
//
//  Created by MS on 2019/9/25.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoAlbumPlayerView.h"

@implementation NvPhotoAlbumPlayerView

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
