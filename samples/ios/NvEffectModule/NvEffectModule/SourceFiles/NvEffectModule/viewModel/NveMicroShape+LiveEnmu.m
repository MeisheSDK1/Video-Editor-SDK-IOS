//
//  NveMicroShape+LiveEnmu.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/12.
//

#import "NveMicroShape+LiveEnmu.h"

@implementation NveMicroShape (Enmu)

- (double)effectValue:(NveMicroShapeLiveType)type {
    switch (type) {
        case NveMicroShapeLiveType_headSize:
            return self.headSize;
        case NveMicroShapeLiveType_malarWidth:
            return self.malarWidth;
        case NveMicroShapeLiveType_jawWidth:
            return self.jawWidth;
        case NveMicroShapeLiveType_templeWidth:
            return self.templeWidth;
        case NveMicroShapeLiveType_eyeDistance:
            return self.eyeDistance;
        case NveMicroShapeLiveType_eyeAngle:
            return self.eyeAngle;
        case NveMicroShapeLiveType_philtrumLength:
            return self.philtrumLength;
        case NveMicroShapeLiveType_noseBridgeWidth:
            return self.noseBridgeWidth;
        case NveMicroShapeLiveType_noseHeadWidth:
            return self.noseHeadWidth;
        case NveMicroShapeLiveType_eyebrowThickness:
            return self.eyebrowThickness;
        case NveMicroShapeLiveType_eyebrowAngle:
            return self.eyebrowAngle;
        case NveMicroShapeLiveType_eyebrowXOffset:
            return self.eyebrowXOffset;
        case NveMicroShapeLiveType_eyebrowYOffset:
            return self.eyebrowYOffset;
        case NveMicroShapeLiveType_eyeWidth:
            return self.eyeWidth;
        case NveMicroShapeLiveType_eyeHeight:
            return self.eyeHeight;
        case NveMicroShapeLiveType_eyeArc:
            return self.eyeArc;
        case NveMicroShapeLiveType_eyeYOffset:
            return self.eyeYOffset;
    }
}

- (void)updateEffect:(NveMicroShapeLiveType)type value:(double)value {
    switch (type) {
        case NveMicroShapeLiveType_headSize:
            self.headSize = value;
            break;
        case NveMicroShapeLiveType_malarWidth:
            self.malarWidth = value;
            break;
        case NveMicroShapeLiveType_jawWidth:
            self.jawWidth = value;
            break;
        case NveMicroShapeLiveType_templeWidth:
            self.templeWidth = value;
            break;
        case NveMicroShapeLiveType_eyeDistance:
            self.eyeDistance = value;
            break;
        case NveMicroShapeLiveType_eyeAngle:
            self.eyeAngle = value;
            break;
        case NveMicroShapeLiveType_philtrumLength:
            self.philtrumLength = value;
            break;
        case NveMicroShapeLiveType_noseBridgeWidth:
            self.noseBridgeWidth = value;
            break;
        case NveMicroShapeLiveType_noseHeadWidth:
            self.noseHeadWidth = value;
            break;
        case NveMicroShapeLiveType_eyebrowThickness:
            self.eyebrowThickness = value;
            break;
        case NveMicroShapeLiveType_eyebrowAngle:
            self.eyebrowAngle = value;
            break;
        case NveMicroShapeLiveType_eyebrowXOffset:
            self.eyebrowXOffset = value;
            break;
        case NveMicroShapeLiveType_eyebrowYOffset:
            self.eyebrowYOffset = value;
            break;
        case NveMicroShapeLiveType_eyeWidth:
            self.eyeWidth = value;
            break;
        case NveMicroShapeLiveType_eyeHeight:
            self.eyeHeight = value;
            break;
        case NveMicroShapeLiveType_eyeArc:
            self.eyeArc = value;
            break;
        case NveMicroShapeLiveType_eyeYOffset:
            self.eyeYOffset = value;
            break;
    }
}

- (void)updateEffect:(NveMicroShapeLiveType)type packageId:(NSString *)packageId {
    switch (type) {
        case NveMicroShapeLiveType_headSize:
            self.headSizePackageId = packageId;
            break;
        case NveMicroShapeLiveType_malarWidth:
            self.malarWidthPackageId = packageId;
            break;
        case NveMicroShapeLiveType_jawWidth:
            self.jawWidthPackageId = packageId;
            break;
        case NveMicroShapeLiveType_templeWidth:
            self.templeWidthPackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyeDistance:
            self.eyeDistancePackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyeAngle:
            self.eyeAnglePackageId = packageId;
            break;
        case NveMicroShapeLiveType_philtrumLength:
            self.philtrumLengthPackageId = packageId;
            break;
        case NveMicroShapeLiveType_noseBridgeWidth:
            self.noseBridgeWidthPackageId = packageId;
            break;
        case NveMicroShapeLiveType_noseHeadWidth:
            self.noseHeadWidthPackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyebrowThickness:
            self.eyebrowThicknessPackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyebrowAngle:
            self.eyebrowAnglePackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyebrowXOffset:
            self.eyebrowXOffsetPackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyebrowYOffset:
            self.eyebrowYOffsetPackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyeWidth:
            self.eyeWidthPackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyeHeight:
            self.eyeHeightPackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyeArc:
            self.eyeArcPackageId = packageId;
            break;
        case NveMicroShapeLiveType_eyeYOffset:
            self.eyeYOffsetPackageId = packageId;
            break;
    }
}

@end
