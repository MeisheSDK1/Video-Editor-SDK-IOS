//
//  MyCustomVideoFx.h
//  customvideofx
//
//  Created by xuewen on 8/2/17.
//  Copyright © 2017 cdv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsStreamingContext.h"

@interface MyCustomVideoFx : NSObject<NvsCustomVideoFxRenderer>

- (void)setSaturationGain:(float)saturationGain;
- (float) getSaturationGain;
- (float) getMinSaturationGain;
- (float) getMaxSaturationGain;
@end
