//
//  NvSizeViewController.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvMimoSizeView.h"

@interface NvMimoSizeViewController : UIViewController

- (void)selectSizeTypeBlock:(void(^)(NvMimoEditMode type))block;
@property (nonatomic, copy) NSString *supportedAspectRatio;
@property (nonatomic, strong) NvMimoSizeView *sizeView;
@end
