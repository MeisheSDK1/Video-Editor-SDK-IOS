//
//  NvEditBGColorModel.h
//  SDKDemo
//
//  Created by MS on 2020/10/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEditBGColorModel : NSObject
@property (nonatomic, assign) float r;
@property (nonatomic, assign) float g;
@property (nonatomic, assign) float b;
@property (nonatomic, strong) NSString *colorImgPath;
@property (nonatomic, assign) BOOL isSelect;
@end

NS_ASSUME_NONNULL_END
