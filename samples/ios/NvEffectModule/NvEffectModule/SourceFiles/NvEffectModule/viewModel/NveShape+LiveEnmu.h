//
//  NveShape+LiveEnmu.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/11.
//

#import <NveEffectKit/NveEffectKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NveShapeLiveType) {
    NveShapeLiveType_faceWidth,
    NveShapeLiveType_faceLength,
    NveShapeLiveType_faceSize,
    NveShapeLiveType_foreheadHeight,
    NveShapeLiveType_chinLength,
    NveShapeLiveType_eyeSize,
    NveShapeLiveType_eyeCornerStretch,
    NveShapeLiveType_noseWidth,
    NveShapeLiveType_noseLength,
    NveShapeLiveType_mouthSize,
    NveShapeLiveType_mouthCornerLift
};

@interface NveShape (Enmu)

- (void)updateEffect:(NveShapeLiveType)type value:(double)value;

- (double)effectValue:(NveShapeLiveType)type;

- (void)updateEffect:(NveShapeLiveType)type packageId:(NSString *)packageId;

@end

NS_ASSUME_NONNULL_END
