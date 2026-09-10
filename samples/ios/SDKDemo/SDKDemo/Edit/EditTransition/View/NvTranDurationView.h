//
//  NvTranDurationView.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/4/8.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvTranDurationViewDelegate <NSObject>

@optional

- (void)updateValue:(CGFloat)value withState:(UIControlEvents)state;

- (void)saveValue:(CGFloat)value withSave:(BOOL)save;

@end

@interface NvTranDurationView : UIView

@property (nonatomic, weak) id<NvTranDurationViewDelegate> delegate;

- (void)updateValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
