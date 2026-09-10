//
//  NvSizeView.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvMimoUtils.h"
@class NvMimoSizeView;

@protocol NvMimoSizeViewDelegate

@optional
- (void)nvSizeView:(NvMimoSizeView *)nvSizeView selectType:(NvMimoEditMode)type;

@end

@interface NvMimoSizeView : UIView

@property (nonatomic, weak)id delegate;
@property (nonatomic, copy) NSString *supportedAspectRatio;
@end
