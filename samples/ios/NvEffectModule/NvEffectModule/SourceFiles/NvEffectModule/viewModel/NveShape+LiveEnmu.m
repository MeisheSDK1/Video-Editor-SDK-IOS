//
//  NveShape+LiveEnmu.m
//  NveEffectKit
//
//  Created by meishe on 2023/5/11.
//

#import "NveShape+LiveEnmu.h"

@implementation NveShape (Enmu)

- (double)effectValue:(NveShapeLiveType)type {
    switch (type) {
        case NveShapeLiveType_faceWidth:
            return self.faceWidth;
        case NveShapeLiveType_faceLength:
            return self.faceLength;
        case NveShapeLiveType_faceSize:
            return self.faceSize;
        case NveShapeLiveType_foreheadHeight:
            return self.foreheadHeight;
        case NveShapeLiveType_chinLength:
            return self.chinLength;
        case NveShapeLiveType_eyeSize:
            return self.eyeSize;
        case NveShapeLiveType_eyeCornerStretch:
            return self.eyeCornerStretch;
        case NveShapeLiveType_noseWidth:
            return self.noseWidth;
        case NveShapeLiveType_noseLength:
            return self.noseLength;
        case NveShapeLiveType_mouthSize:
            return self.mouthSize;
        case NveShapeLiveType_mouthCornerLift:
            return self.mouthCornerLift;
    }
}

- (void)updateEffect:(NveShapeLiveType)type value:(double)value {
    switch (type) {
        case NveShapeLiveType_faceWidth:
            self.faceWidth = value;
            break;
        case NveShapeLiveType_faceLength:
            self.faceLength = value;
            break;
        case NveShapeLiveType_faceSize:
            self.faceSize = value;
            break;
        case NveShapeLiveType_foreheadHeight:
            self.foreheadHeight = value;
            break;
        case NveShapeLiveType_chinLength:
            self.chinLength = value;
            break;
        case NveShapeLiveType_eyeSize:
            self.eyeSize = value;
            break;
        case NveShapeLiveType_eyeCornerStretch:
            self.eyeCornerStretch = value;
            break;
        case NveShapeLiveType_noseWidth:
            self.noseWidth = value;
            break;
        case NveShapeLiveType_noseLength:
            self.noseLength = value;
            break;
        case NveShapeLiveType_mouthSize:
            self.mouthSize = value;
            break;
        case NveShapeLiveType_mouthCornerLift:
            self.mouthCornerLift = value;
            break;
    }
}

- (void)updateEffect:(NveShapeLiveType)type packageId:(NSString *)packageId {
    if (!packageId) {
        return;
    }
    switch (type) {
        case NveShapeLiveType_faceWidth:
            self.faceWidthPackageId = packageId;
            break;
        case NveShapeLiveType_faceLength:
            self.faceLengthPackageId = packageId;
            break;
        case NveShapeLiveType_faceSize:
            self.faceSizePackageId = packageId;
            break;
        case NveShapeLiveType_foreheadHeight:
            self.foreheadHeightPackageId = packageId;
            break;
        case NveShapeLiveType_chinLength:
            self.chinLengthPackageId = packageId;
            break;
        case NveShapeLiveType_eyeSize:
            self.eyeSizePackageId = packageId;
            break;
        case NveShapeLiveType_eyeCornerStretch:
            self.eyeCornerStretchPackageId = packageId;
            break;
        case NveShapeLiveType_noseWidth:
            self.noseWidthPackageId = packageId;
            break;
        case NveShapeLiveType_noseLength:
            self.noseLengthPackageId = packageId;
            break;
        case NveShapeLiveType_mouthSize:
            self.mouthSizePackageId = packageId;
            break;
        case NveShapeLiveType_mouthCornerLift:
            self.mouthCornerLiftPackageId = packageId;
            break;
    }
}

@end
