//
//  EFBufferDisplayView.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/9.
//

#import "EFBufferDisplayView.h"

@interface EFBufferDisplayView ()

@property(nonatomic, strong, readwrite) AVSampleBufferDisplayLayer *displayLayer;

@end

@implementation EFBufferDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.displayLayer = (AVSampleBufferDisplayLayer *)self.layer;
        [self.displayLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
        [self.displayLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return self;
}

+ (Class)layerClass {
    return [AVSampleBufferDisplayLayer class];
}

@end
