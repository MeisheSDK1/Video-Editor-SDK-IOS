//
//  NvEditBGBlurModel.h
//  SDKDemo
//
//  Created by MS on 2020/10/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEditBGBlurModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, assign) float radius;
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
