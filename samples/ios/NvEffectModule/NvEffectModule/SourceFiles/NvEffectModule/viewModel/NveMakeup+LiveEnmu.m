//
//  NveMakeup+LiveEnmu.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/16.
//

#import "NveMakeup+LiveEnmu.h"

@implementation NveMakeup (Enmu)

- (void)updateEffect:(NveMakeupLiveType)type value:(double)value {
    switch (type) {
        case NveMakeupLiveType_lip:
            self.lip = value;
            break;
        case NveMakeupLiveType_eyeshadow:
            self.eyeshadow = value;
            break;
        case NveMakeupLiveType_eyebrow:
            self.eyebrow = value;
            break;
        case NveMakeupLiveType_eyelash:
            self.eyelash = value;
            break;
        case NveMakeupLiveType_eyeliner:
            self.eyeliner = value;
            break;
        case NveMakeupLiveType_blusher:
            self.blusher = value;
            break;
        case NveMakeupLiveType_brighten:
            self.brighten = value;
            break;
        case NveMakeupLiveType_shadow:
            self.shadow = value;
            break;
        case NveMakeupLiveType_eyeball:
            self.eyeball = value;
            break;
    }
}

- (double)effectValue:(NveMakeupLiveType)type {
    switch (type) {
        case NveMakeupLiveType_lip:
            return self.lip;
        case NveMakeupLiveType_eyeshadow:
            return self.eyeshadow;
        case NveMakeupLiveType_eyebrow:
            return self.eyebrow;
        case NveMakeupLiveType_eyelash:
            return self.eyelash;
        case NveMakeupLiveType_eyeliner:
            return self.eyeliner;
        case NveMakeupLiveType_blusher:
            return self.blusher;
        case NveMakeupLiveType_brighten:
            return self.brighten;
        case NveMakeupLiveType_shadow:
            return self.shadow;
        case NveMakeupLiveType_eyeball:
            return self.eyeball;
    }
}

- (void)updateEffect:(NveMakeupLiveType)type packageId:(NSString *)packageId {
    switch (type) {
        case NveMakeupLiveType_lip:
            self.lipPackageId = packageId;
            break;
        case NveMakeupLiveType_eyeshadow:
            self.eyeshadowPackageId = packageId;
            break;
        case NveMakeupLiveType_eyebrow:
            self.eyebrowPackageId = packageId;
            break;
        case NveMakeupLiveType_eyelash:
            self.eyelashPackageId = packageId;
            break;
        case NveMakeupLiveType_eyeliner:
            self.eyelinerPackageId = packageId;
            break;
        case NveMakeupLiveType_blusher:
            self.blusherPackageId = packageId;
            break;
        case NveMakeupLiveType_brighten:
            self.brightenPackageId = packageId;
            break;
        case NveMakeupLiveType_shadow:
            self.shadowPackageId = packageId;
            break;
        case NveMakeupLiveType_eyeball:
            self.eyeballPackageId = packageId;
            break;
    }
}

- (NSString *)packageIdForType:(NveMakeupLiveType)type {
    switch (type) {
        case NveMakeupLiveType_lip:
            return self.lipPackageId;
        case NveMakeupLiveType_eyeshadow:
            return self.eyeshadowPackageId;
        case NveMakeupLiveType_eyebrow:
            return self.eyebrowPackageId;
        case NveMakeupLiveType_eyelash:
            return self.eyelashPackageId;
        case NveMakeupLiveType_eyeliner:
            return self.eyelinerPackageId;
        case NveMakeupLiveType_blusher:
            return self.blusherPackageId;
        case NveMakeupLiveType_brighten:
            return self.brightenPackageId;
        case NveMakeupLiveType_shadow:
            return self.shadowPackageId;
        case NveMakeupLiveType_eyeball:
            return self.eyeballPackageId;
    }
}

- (void)updateEffect:(NveMakeupLiveType)type color:(UIColor *)color {
    switch (type) {
        case NveMakeupLiveType_lip:
            self.lipColor = color;
            break;
        case NveMakeupLiveType_eyeshadow:
            self.eyeshadowColor = color;
            break;
        case NveMakeupLiveType_eyebrow:
            self.eyebrowColor = color;
            break;
        case NveMakeupLiveType_eyelash:
            self.eyelashColor = color;
            break;
        case NveMakeupLiveType_eyeliner:
            self.eyelinerColor = color;
            break;
        case NveMakeupLiveType_blusher:
            self.blusherColor = color;
            break;
        case NveMakeupLiveType_brighten:
            self.brightenColor = color;
            break;
        case NveMakeupLiveType_shadow:
            self.shadowColor = color;
            break;
        case NveMakeupLiveType_eyeball:
            self.eyeballColor = color;
            break;
    }
}

@end
