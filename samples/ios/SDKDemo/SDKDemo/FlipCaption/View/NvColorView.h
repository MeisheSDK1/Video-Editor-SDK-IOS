//
//  NvColorView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionColorItem.h"
NS_ASSUME_NONNULL_BEGIN
@class NvColorView;

@protocol NvColorViewDelegate <NSObject>

- (void)colorView:(NvColorView *)colorView didSelectItem:(NvCaptionColorItem *)item;

@end



@interface NvColorView : UIView

@property (nonatomic, weak)id delegate;

@property (nonatomic, strong, readonly) NSMutableArray <NvCaptionColorItem *>*dataSource;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
