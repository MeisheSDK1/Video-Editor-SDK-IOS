//
//  NveBeauty+LiveEnmu.m
//  NveEffectKit
//
//  Created by meishe on 2023/5/11.
//

#import "NveBeauty+LiveEnmu.h"
#import "NvLiveEffectModule.h"
#import <YYModel/YYModel.h>

@implementation NveBeauty (Enmu)

- (double)effectValue:(NveBeautyLiveType)type {
    switch (type) {
        case NveBeautyLiveType_whitening:
            return self.whitening;
        case NveBeautyLiveType_whitening_1:
            return self.whitening;
        case NveBeautyLiveType_reddening:
            return self.reddening;
        case NveBeautyLiveType_strength:{
            NSObject *tempModel = [self getEffectParam:@"Beauty Strength" type:NveParamType_float];
            NSDictionary *tempDict = [tempModel yy_modelToJSONObject];
            CGFloat tempValue = [tempDict[@"value"] floatValue];
            return tempValue;
        }
        case NveBeautyLiveType_strength_1:
            return self.strength;
        case NveBeautyLiveType_strength_2:
            return self.strength;
        case NveBeautyLiveType_strength_3:
            return self.strength;
        case NveBeautyLiveType_matte:
            return self.matte;
        case NveBeautyLiveType_removeNasolabialFolds:
            return self.removeNasolabialFolds;
        case NveBeautyLiveType_removeDarkCircles:
            return self.removeDarkCircles;
        case NveBeautyLiveType_brightenEyes:
            return self.brightenEyes;
        case NveBeautyLiveType_whitenTeeth:
            return self.whitenTeeth;
        case NveBeautyLiveType_sharpen:
            return self.sharpen;
        case NveBeautyLiveType_definition:
            return self.definition;
    }
    return 1.0;
}

- (void)updateEffect:(NveBeautyLiveType)type value:(double)value {
    switch (type) {
        case NveBeautyLiveType_whitening:
            self.whitening = value;
            [self setEffectParam:@"Whitening Lut Enabled" type:NveParamType_bool value:@(NO)];
            [self setEffectParam:@"Whitening Lut File" type:NveParamType_string value:@""];
            break;
        case NveBeautyLiveType_whitening_1:{
            self.whitening = value;
            NSString *whitenLutPath = [[[NSBundle bundleForClass:[NvLiveEffectModule class]] bundlePath] stringByAppendingPathComponent:@"whitenLut.bundle"];
            NSString *lutPath = [whitenLutPath stringByAppendingPathComponent:@"WhiteB.mslut"];
            [self setEffectParam:@"Whitening Lut Enabled" type:NveParamType_bool value:@(YES)];
            [self setEffectParam:@"Whitening Lut File" type:NveParamType_string value:lutPath];
        }
            break;
        case NveBeautyLiveType_reddening:
            self.reddening = value;
            break;
        case NveBeautyLiveType_strength:
            self.strength = value;
            [self setEffectParam:@"Advanced Beauty Intensity" type:NveParamType_float value:@(0)];
            [self setEffectParam:@"Beauty Strength" type:NveParamType_float value:@(value)];
            break;
        case NveBeautyLiveType_strength_1:
            self.strength = value;
            [self setEffectParam:@"Advanced Beauty Enable" type:NveParamType_bool value:@(YES)];
            [self setEffectParam:@"Advanced Beauty Type" type:NveParamType_int value:@(0)];
            [self setEffectParam:@"Beauty Strength" type:NveParamType_float value:@(0)];
            [self setEffectParam:@"Advanced Beauty Intensity" type:NveParamType_float value:@(value)];
            break;
        case NveBeautyLiveType_strength_2:
            self.strength = value;
            [self setEffectParam:@"Advanced Beauty Enable" type:NveParamType_bool value:@(YES)];
            [self setEffectParam:@"Advanced Beauty Type" type:NveParamType_int value:@(1)];
            [self setEffectParam:@"Beauty Strength" type:NveParamType_float value:@(0)];
            [self setEffectParam:@"Advanced Beauty Intensity" type:NveParamType_float value:@(value)];
            break;
        case NveBeautyLiveType_strength_3:
            self.strength = value;
            [self setEffectParam:@"Advanced Beauty Enable" type:NveParamType_bool value:@(YES)];
            [self setEffectParam:@"Advanced Beauty Type" type:NveParamType_int value:@(2)];
            [self setEffectParam:@"Beauty Strength" type:NveParamType_float value:@(0)];
            [self setEffectParam:@"Advanced Beauty Intensity" type:NveParamType_float value:@(value)];
            break;
        case NveBeautyLiveType_strength_4:
            self.strength = value;
            [self setEffectParam:@"Advanced Beauty Enable" type:NveParamType_bool value:@(YES)];
            [self setEffectParam:@"Advanced Beauty Type" type:NveParamType_int value:@(3)];
            [self setEffectParam:@"Beauty Strength" type:NveParamType_float value:@(0)];
            [self setEffectParam:@"Advanced Beauty Intensity" type:NveParamType_float value:@(value)];
            break;
        case NveBeautyLiveType_matte:
            self.matte = value;
            break;
        case NveBeautyLiveType_removeNasolabialFolds:
            self.removeNasolabialFolds = value;
            break;
        case NveBeautyLiveType_removeDarkCircles:
            self.removeDarkCircles = value;
            break;
        case NveBeautyLiveType_brightenEyes:
            self.brightenEyes = value;
            break;
        case NveBeautyLiveType_whitenTeeth:
            self.whitenTeeth = value;
            break;
        case NveBeautyLiveType_sharpen:
            self.sharpen = value;
            break;
        case NveBeautyLiveType_definition:
            self.definition = value;
            break;
    }
}

@end
