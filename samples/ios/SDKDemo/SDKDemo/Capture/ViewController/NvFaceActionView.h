//
//  NvFaceActionView.h
//  SDKDemo
//
//  Created by kirk on 2022/6/23.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsARSceneManipulate.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvFaceActionView : UIView <NvsARSceneManipulateDelegate>

+(NvFaceActionView*)createFaceActionView;

@end

NS_ASSUME_NONNULL_END
