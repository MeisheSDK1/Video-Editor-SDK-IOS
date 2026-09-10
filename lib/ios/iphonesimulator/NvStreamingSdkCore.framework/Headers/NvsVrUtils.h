//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2023. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 6 . 2023
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

NVS_EXPORT @interface NvsVertex3D : NSObject
    @property(assign) float x;
    @property(assign) float y;
    @property(assign) float z;
@end
NVS_EXPORT @interface NvsVertexSpherical : NSObject
    @property(assign) float polarAngle;
    @property(assign) float azimuthAngle;
@end

NVS_EXPORT @interface NvsVrUtils : NSObject

+ (NSArray<NvsVertex3D *> *) mapPanoramicVerticesFromLocateToWorldLocateSpcaeRotation:
                                                    (float)locateSpaceRotaion
                                                    locateSpaceScale:(NvsPosition2D)locateSpaceScale
                                                    locateSpaceCenter:(NvsPosition2D)locateSpaceCenter
                                                    locateVertices:(NSArray<NvsVertexSpherical *> *)locateVertices;

+ (NSArray<NvsVertexSpherical *> *) mapPanoramicVerticesFromWorldToLocateLocateSpcaeRotation:
                                                    (float)locateSpaceRotaion
                                                    locateSpaceScale:(NvsPosition2D)locateSpaceScale
                                                    locateSpaceCenter:(NvsPosition2D)locateSpaceCenter
                                                    locateVertices:(NSArray<NvsVertex3D*> *)worldVertices;

@end
