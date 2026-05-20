//
//  NvMimoPopView.h
//  NvMimoDemo
//
//  Created by MS on 2020/7/29.
//  Copyright © 2020 MS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,NvMimoPopDirection){
    NvMimoPopDirection_Bottom         = 0,
    NvMimoPopDirection_Center         = 1
};
@interface NvMimoPopView : UIView
@property(nonatomic,weak)UIView* contentView;
@property(nonatomic,strong)UIView* bgView;
@property(nonatomic, assign)CGFloat progressValue;
@property(nonatomic, copy)NSString *title;
-(void)setupSubviews;

-(void)showWithDirection:(NvMimoPopDirection)direction completion:(void (^ __nullable)(void))completion;

-(void)dismissCompletion:(void (^ __nullable)(void))completion;

-(void)bgClicked:(UIGestureRecognizer*)gesture;
@end

NS_ASSUME_NONNULL_END
