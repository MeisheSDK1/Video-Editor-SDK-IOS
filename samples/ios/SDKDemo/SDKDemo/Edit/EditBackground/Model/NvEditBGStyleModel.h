//
//  NvEditBGStyleModel.h
//  SDKDemo
//
//  Created by MS on 2020/10/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEditBGStyleModel : NSObject
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *packagePath;
@property (nonatomic, strong) NSString *packageName;
@property (nonatomic, strong) NSString *packageNameEn;
@property (nonatomic, assign) NSInteger ratio;
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
