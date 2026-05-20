//
//  NvVoiceBottomModel.h
//  SDKDemo
//
//  Created by ms on 2021/3/15.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvVoiceBottomModel : NSObject

@property (nonatomic, copy) NSString *selectedImage;
@property (nonatomic, copy) NSString *unselectedImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
