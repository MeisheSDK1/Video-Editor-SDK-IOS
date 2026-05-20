//
//  NvFlipCaptionFontView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionFontItem.h"
NS_ASSUME_NONNULL_BEGIN
@class NvFlipCaptionFontView;
@class NvBaseModel;

@protocol NvFlipCaptionFontViewDelegate <NSObject>

- (void)flipCaptionFont:(NvFlipCaptionFontView *)fontView didSelectItem:(NvBaseModel *)item;
- (void)flipCaptionFont:(NvFlipCaptionFontView *)fontView okClickItem:(NvBaseModel *)item;

@end



@interface NvFlipCaptionFontView : UIView

@property (nonatomic, weak)id delegate;
@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)updateProgress:(float)progress uuid:(NSString *)uuid;
- (void)downloadFailduuid:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
