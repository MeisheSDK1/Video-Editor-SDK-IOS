//
//  NvEditCorrectColorItem.h
//  SDKDemo
//
//  Created by ms on 2020/11/26.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEditCorrectColorItem : NSObject
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *slecteImage;
@property (nonatomic, strong) NSString *unslecteImage;
@property (nonatomic, strong) NSString *builtenName;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) float currentValue;
@property (nonatomic, assign) float minValue;
@property (nonatomic, assign) float maxValue;
@end

NS_ASSUME_NONNULL_END
