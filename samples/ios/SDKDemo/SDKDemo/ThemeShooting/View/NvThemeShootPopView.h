//
//  NvThemeShootPopView.h
//  SDKDemo
//
//  Created by ms on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,NvThemeShootPopDirection){
    NvThemeShootPopDirection_Bottom         = 0,
    NvThemeShootPopDirection_Center         = 1
};
@interface NvThemeShootPopView : UIView
@property(nonatomic,weak)UIView* contentView;
@property(nonatomic,strong)UIView* bgView;
@property(nonatomic, assign)CGFloat progressValue;
@property(nonatomic, copy)NSString *title;
-(void)setupSubviews;

-(void)showWithDirection:(NvThemeShootPopDirection)direction completion:(void (^ __nullable)(void))completion;

-(void)dismissCompletion:(void (^ __nullable)(void))completion;

-(void)bgClicked:(UIGestureRecognizer*)gesture;
@end

NS_ASSUME_NONNULL_END
