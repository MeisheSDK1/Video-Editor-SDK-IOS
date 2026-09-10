//
//  NvBaseModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger,DownloadState){
    NODownload,
    DownloadError,
    Downloading,
    Finish,
    Update,
    NoUser,
};
@interface NvBaseModel : NSObject

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) NSString *coverName;
@property (nonatomic, strong) NSString *coverDefault;
@property (nonatomic, assign) CGFloat value;   //滤镜值 // Filter value
@property (nonatomic, assign) BOOL isNothing;  //是否是无 Is it nothing
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *displayNameZhCn;
@property (nonatomic, strong) NSString *builtinName;
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, strong) NSString *packagePath;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *draw;
@property (nonatomic, assign) DownloadState state;
@property (nonatomic, assign) NSInteger categoryId;//如果素材有分类，设置不同的值。如粒子会有人脸、手势、全屏、触摸4中分类 // Set different values if assets are categorized. For example, particles will have face, gesture, full screen, touch 4 categories

@end

