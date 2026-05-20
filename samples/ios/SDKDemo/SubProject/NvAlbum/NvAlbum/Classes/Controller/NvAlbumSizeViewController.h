//
//  NvSizeViewController.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvAlbumSizeView.h"

@interface NvAlbumSizeViewController : UIViewController

- (void)selectSizeTypeBlock:(void(^)(int type))block;

@end
