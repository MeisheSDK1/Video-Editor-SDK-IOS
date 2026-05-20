//
//  NvAlbumSizeViewController.h
//  meishe
//
//  Created by 刘东旭 on 2019/5/29.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import "NvAlbumBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvAlbumProgressViewController : NvAlbumBaseViewController

@property (nonatomic, assign) float progress;
// Show the number of images, default is no
@property (nonatomic, copy) NSString *titleStr; //显示第几张图片，默认为否
- (void)setCancelBlock:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
