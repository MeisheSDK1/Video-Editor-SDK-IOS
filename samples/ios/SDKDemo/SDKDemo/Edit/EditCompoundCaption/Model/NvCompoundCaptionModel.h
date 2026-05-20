//
//  NvCompoundCaptionModel.h
//  SDKDemo
//
//  Created by MS on 2019/5/20.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvCompoundCaptionModel : NSObject
@property(nonatomic, strong) NSString *colorString;
///sdk代码实际用到的font
///The actual font used by the sdk code
@property(nonatomic, strong) NSString *fontName;
///ios代码实际用到的font
///The actual font used by the ios code
@property(nonatomic, strong) NSString *iosFontName;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) BOOL isSelected;
///cell上展示font名字
/////cell displays the font name
@property(nonatomic, strong) NSString *showName;

@end

NS_ASSUME_NONNULL_END
