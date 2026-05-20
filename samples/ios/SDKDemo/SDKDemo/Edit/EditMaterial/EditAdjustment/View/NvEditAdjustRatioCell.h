//
//  NvEditAdjustRatioCell.h
//  SDKDemo
//
//  Created by MS on 2020/12/2.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface NvEditAdjustRatioModel : NSObject
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *selectedImgName;
@property (nonatomic, strong) NSString *normalImgName;
@end

@interface NvEditAdjustRatioCell : UICollectionViewCell
@property (nonatomic, strong) NvEditAdjustRatioModel *model;
@end

NS_ASSUME_NONNULL_END
