//
//  NvBeautyLogic.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBeautyLogic.h"
#import "NvsStreamingContext.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvSDKCommon/NvInitArScence.h>

@interface NvBeautyLogic() {
    double _eyeEnlarging;
    double _cheekThinning;
}

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, assign) BOOL success;

@end

@implementation NvBeautyLogic

- (instancetype)init {
    self = [super init];
    if (self) {
        
        if (![NvInitArScence getInitArFace]) {
            if (ARSCENE_MS){
                [NvInitArScence initARFace:NvFaceMode_106];
            }else if (ARSCENE_MS_240){
                [NvInitArScence initARFace:NvFaceMode_240];
            }
        }
        self.streamingContext = [NvsStreamingContext sharedInstance];
        self.success = [NvInitArScence getInitArFace];
    }
    return self;
}

- (void)startBeauty {
    if (self.success) {
        [self removeFx:@"AR Scene"];
        self.arfaceVideoFx = [self.streamingContext appendBuiltinCaptureVideoFx:@"AR Scene"];
        [self.arfaceVideoFx setBooleanVal:@"Max Faces Respect Min" val:YES];
//        if (ARSCENE_ST_240 || ARSCENE_MS_240) {
//            // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//            [self.arfaceVideoFx setBooleanVal:@"Use Face Extra Info" val:YES];
//        }
        if (self.arfaceVideoFx) {
            [self.arfaceVideoFx setBooleanVal:@"Beauty Effect" val:YES];
            [self.arfaceVideoFx setBooleanVal:@"Beauty Shape" val:YES];
            [self.arfaceVideoFx setFloatVal:@"Beauty Reddening" val:0.5];
            self.strength = 0.75;
            self.eyeEnlarging = 0.5;
            self.cheekThinning = 0.5;
            BOOL highVersion = [NvInitArScence isHighVersionPhone];
            if(highVersion) {
                [self.arfaceVideoFx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
            }
        }
    } else {
        [self removeFx:@"Beauty"];
        self.fx = [self.streamingContext appendBuiltinCaptureVideoFx:@"Beauty"];
        if (self.fx) {
            [self.fx setFloatVal:@"Reddening" val:0.5];
            self.strength = 0.75;
        }
    }
}

- (void)removeFx:(NSString *)fxName {
    int count = [self.streamingContext getCaptureVideoFxCount];
    for (int i = 0; i < count; i++) {
        NvsCaptureVideoFx *fx = [self.streamingContext getCaptureVideoFxByIndex:i];
        int index = fx.index;
        if ([fxName isEqualToString:fx.bultinCaptureVideoFxName]) {
            [self.streamingContext removeCaptureVideoFx:index];
        }
    }
}

- (void)setStrength:(double)strength {
    _strength = strength;
    if (self.success) {
        [self.arfaceVideoFx setFloatVal:@"Beauty Strength" val:strength];
    } else {
        [self.fx setFloatVal:@"Strength" val:strength];
    }
}

- (void)setReddening:(double)reddening {
    _reddening = reddening;
    if (self.success) {
        [self.arfaceVideoFx setFloatVal:@"Beauty Reddening" val:reddening];
    } else {
        [self.fx setFloatVal:@"Reddening" val:reddening];
    }
}

- (void)setWhitening:(double)whitening {
    _whitening = whitening;
    if (self.success) {
        [self.arfaceVideoFx setFloatVal:@"Beauty Whitening" val:whitening];
    } else {
        [self.fx setFloatVal:@"Whitening" val:whitening];
    }
    
}

- (void)closeBeauty {
    if (self.success) {
        if (self.arfaceVideoFx) {
            [self.arfaceVideoFx setBooleanVal:@"Beauty Effect" val:NO];
            [self.arfaceVideoFx setBooleanVal:@"Beauty Shape" val:NO];
        }
    } else {
        if (self.fx.bultinCaptureVideoFxName.length > 0 || self.fx.captureVideoFxPackageId.length > 0) {
            [self.streamingContext removeCaptureVideoFx:self.fx.index];
            self.fx = nil;
        }else{
            self.fx = nil;
        }
    }
}

- (BOOL)beauty {
    return self.fx;
}

- (BOOL)enAbleAI {
    if (self.success) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setFaceOrnament:(NSString *)faceOrnament {
    _faceOrnament = faceOrnament;
    [self.arfaceVideoFx setStringVal:@"Scene Id" val:faceOrnament];
}

- (void)setEyeEnlarging:(double)eyeEnlarging {
    _eyeEnlarging = eyeEnlarging;
    [self.arfaceVideoFx setFloatVal:@"Eye Size Warp Degree" val:eyeEnlarging];
}

- (double)eyeEnlarging {
    return [self.arfaceVideoFx getFloatVal:@"Eye Size Warp Degree"];
}

//越接近-1越瘦脸，所以乘以-1来达到【-1，1】在这个区间越接近1越瘦脸
//the value closer to -1, the cheekThinning is thinner.
- (void)setCheekThinning:(double)cheekThinning {
    _cheekThinning = cheekThinning * -1;
    [self.arfaceVideoFx setFloatVal:@"Face Size Warp Degree" val:_cheekThinning];
}

- (double)cheekThinning {
    return [self.arfaceVideoFx getFloatVal:@"Face Size Warp Degree"];
}

- (void)closeFaceEffect {
    if (self.arfaceVideoFx) {
        [self.streamingContext removeCaptureVideoFx:self.arfaceVideoFx.index];
        self.arfaceVideoFx = nil;
    }
}

@end
