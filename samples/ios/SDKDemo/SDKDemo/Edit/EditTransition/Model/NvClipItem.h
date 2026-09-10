//
//  NvClipItem.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/6/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsVideoClip.h"
#import "NvsVideoTransition.h"
@import UIKit;

@interface NvClipItem : NSObject

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *transitionImage;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, strong) NSString *transitionImageUrl;
///是否被加载显示过
///Whether the load is displayed
@property (nonatomic, assign) BOOL isLoading;
///是否是图片
///Picture or not
@property (nonatomic, assign) BOOL isImage;
///图片的路径标志
///The path of the picture
@property (nonatomic, strong) NSString *localIdentifier;
///是否是相册的图片
///Whether it is a photo album
@property (nonatomic, assign) BOOL isPhotoAlbum;
///视频文件路径
///Video file path
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
///是否有转场
///Whether there is a transition
@property (nonatomic, assign) BOOL isHaveTransision;
@property (nonatomic, strong) NvsVideoClip *clip;
@property (nonatomic, strong) NvsVideoTransition *transition;
@property (nonatomic, assign) BOOL isLast;

@end
