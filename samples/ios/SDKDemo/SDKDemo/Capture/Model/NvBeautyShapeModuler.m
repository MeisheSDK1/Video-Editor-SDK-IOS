//
//  NvBeautyShapeModuler.m
//  SDKDemo
//
//  Created by 美摄 on 2022/4/15.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvBeautyShapeModuler.h"

@implementation NvBeautyShapeModuler
static NvBeautyShapeModuler *sharedInstance = nil;

+ (NvBeautyShapeModuler *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvBeautyShapeModuler alloc] init];
    });
    
    return sharedInstance;
}

//美型、微整形 根据特效名字获取degree 名字
//Beauty type, micro shaping according to the special effect name to obtain the degree name
- (NSString *)getDegreeNameOfFxName:(NSString *)fxName {
    if ([[self getFacemeshShapeFxNames] containsObject:fxName]) {
        NSInteger index = [[self getFacemeshShapeFxNames] indexOfObject:fxName];
        return [[self getFacemeshShapeDegrees] objectAtIndex:index];
    }else if ([[self getWarpShapeFxNames] containsObject:fxName]){
        NSInteger index = [[self getWarpShapeFxNames] indexOfObject:fxName];
        return [[self getWarpShapeDegrees] objectAtIndex:index];
    }
    return nil;
}

- (NSArray *)getFacemeshShapeFxNames {
    return @[@"Face Mesh Eye Size Custom Package Id",
             @"Face Mesh Eye Corner Stretch Custom Package Id",
             @"Face Mesh Face Size Custom Package Id",
             @"Face Mesh Face Width Custom Package Id",
             @"Face Mesh Face Length Custom Package Id",
             @"Face Mesh Forehead Height Custom Package Id",
             @"Face Mesh Hairline Height Custom Package Id",
             @"Face Mesh Malar Width Custom Package Id",
             @"Face Mesh Jaw Width Custom Package Id",
             @"Face Mesh Chin Length Custom Package Id",
             @"Face Mesh Eyebrow Width Custom Package Id",
             @"Face Mesh Eye Distance Custom Package Id",
             @"Face Mesh Nose Length Custom Package Id",
             @"Face Mesh Nose Width Custom Package Id",
             @"Face Mesh Mouth Size Custom Package Id",
             @"Face Mesh Mouth Width Custom Package Id",
             @"Face Mesh Mouth Corner Lift Custom Package Id",
             @"Face Mesh Temple Width Custom Package Id",
             @"Face Mesh Head Size Custom Package Id",
             @"Face Mesh Eye Angle Custom Package Id",
             @"Face Mesh Nose Bridge Width Custom Package Id",
             @"Face Mesh Philtrum Length Custom Package Id",
             @"Face Mesh Eye Arc Custom Package Id",
             @"Face Mesh Eye Width Custom Package Id",
             @"Face Mesh Eye Height Custom Package Id",
             @"Face Mesh Eye Y Offset Custom Package Id",
             @"Face Mesh Eyebrow Angle Custom Package Id",
             @"Face Mesh Eyebrow Thickness Custom Package Id",
             @"Face Mesh Eyebrow X Offset Custom Package Id",
             @"Face Mesh Eyebrow Y Offset Custom Package Id",
             @"Face Mesh Nose Head Width Custom Package Id"];
}

- (NSArray *)getWarpShapeFxNames {
    return @[@"Warp Eye Size Custom Package Id",
             @"Warp Eye Corner Stretch Custom Package Id",
             @"Warp Face Size Custom Package Id",
             @"Warp Face Width Custom Package Id",
             @"Warp Face Length Custom Package Id",
             @"Warp Forehead Height Custom Package Id",
             @"Warp Hairline Height Custom Package Id",
             @"Warp Malar Width Custom Package Id",
             @"Warp Jaw Width Custom Package Id",
             @"Warp Chin Length Custom Package Id",
             @"Warp Eyebrow Width Custom Package Id",
             @"Warp Eye Distance Custom Package Id",
             @"Warp Nose Length Custom Package Id",
             @"Warp Nose Width Custom Package Id",
             @"Warp Mouth Size Custom Package Id",
             @"Warp Mouth Width Custom Package Id",
             @"Warp Mouth Corner Lift Custom Package Id",
             @"Warp Temple Width Custom Package Id",
             @"Warp Head Size Custom Package Id",
             @"Warp Eye Angle Custom Package Id",
             @"Warp Nose Bridge Width Custom Package Id",
             @"Warp Philtrum Length Custom Package Id"];

}

- (NSArray *)getFacemeshShapeDegrees {
    return @[@"Face Mesh Eye Size Degree",
             @"Face Mesh Eye Corner Stretch Degree",
             @"Face Mesh Face Size Degree",
             @"Face Mesh Face Width Degree",
             @"Face Mesh Face Length Degree",
             @"Face Mesh Forehead Height Degree",
             @"Face Mesh Hairline Height Degree",
             @"Face Mesh Malar Width Degree",
             @"Face Mesh Jaw Width Degree",
             @"Face Mesh Chin Length Degree",
             @"Face Mesh Eyebrow Width Degree",
             @"Face Mesh Eye Distance Degree",
             @"Face Mesh Nose Length Degree",
             @"Face Mesh Nose Width Degree",
             @"Face Mesh Mouth Size Degree",
             @"Face Mesh Mouth Width Degree",
             @"Face Mesh Mouth Corner Lift Degree",
             @"Face Mesh Temple Width Degree",
             @"Face Mesh Head Size Degree",
             @"Face Mesh Eye Angle Degree",
             @"Face Mesh Nose Bridge Width Degree",
             @"Face Mesh Philtrum Length Degree",
             @"Face Mesh Eye Arc Degree",
             @"Face Mesh Eye Width Degree",
             @"Face Mesh Eye Height Degree",
             @"Face Mesh Eye Y Offset Degree",
             @"Face Mesh Eyebrow Angle Degree",
             @"Face Mesh Eyebrow Thickness Degree",
             @"Face Mesh Eyebrow X Offset Degree",
             @"Face Mesh Eyebrow Y Offset Degree",
             @"Face Mesh Nose Head Width Degree"];

}

- (NSArray *)getWarpShapeDegrees {
    return @[@"Eye Size Warp Degree",
             @"Eye Corner Stretch Degree",
             @"Face Size Warp Degree",
             @"Face Width Warp Degree",
             @"Face Length Warp Degree",
             @"Forehead Height Warp Degree",
             @"Hairline Height Warp Degree",
             @"Malar Width Warp Degree",
             @"Jaw Width Warp Degree",
             @"Chin Length Warp Degree",
             @"Eyebrow Width Warp Degree",
             @"Eye Distance Warp Degree",
             @"Nose Length Warp Degree",
             @"Nose Width Warp Degree",
             @"Mouth Size Warp Degree",
             @"Mouth Width Warp Degree",
             @"Mouth Corner Lift Degree",
             @"Temple Width Warp Degree",
             @"Head Size Warp Degree",
             @"Eye Angle Warp Degree",
             @"Nose Bridge Width Warp Degree",
             @"Philtrum Length Warp Degree"];

}

@end
