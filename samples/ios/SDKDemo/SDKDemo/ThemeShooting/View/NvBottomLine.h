//
//  NvBottomLine.h
//  SDKDemo
//
//  Created by ms on 2020/8/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvThemeShootModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvBottomLine : UIView

@property (nonatomic, strong) NSArray <NvShotInfoModel *> *arr;
@property (nonatomic, assign) NSUInteger currentIndex;
-(void)deleteLastPath;
@end

NS_ASSUME_NONNULL_END
