//
//  NvEditSelectMusicItem.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NvEditSelectMusicItem : NSObject

@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *musicPath;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) float duration;

@end
