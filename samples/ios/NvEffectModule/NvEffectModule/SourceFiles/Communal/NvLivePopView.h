//
//  NvLivePopView.h
//  NvVideoEditor
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, NvLivePopDirection) {
    NvLivePopDirection_Bottom = 0,
    NvLivePopDirection_Center = 1
};

@protocol NvLivePopViewDelegate <NSObject>

- (void)popViewDismissWithContentView:(UIView *)contentView;

@end

@interface NvLivePopView : UIView

@property(nonatomic, weak) UIView *contentView;
@property(nonatomic, strong) UIView *bgView;

+ (void)showView:(UIView *)view direction:(NvLivePopDirection)direction completion:(void (^__nullable)(void))completion dismissDelegate:(id<NvLivePopViewDelegate>)dismissDelegate;

+ (void)dismiss;

- (void)setupSubviews;

- (void)showWithDirection:(NvLivePopDirection)direction completion:(void (^__nullable)(void))completion;

- (void)showWithDirection:(NvLivePopDirection)direction completion:(void (^__nullable)(void))completion dismissCallback:(void (^__nullable)(void))dismissCallback;

- (void)dismissCompletion:(void (^__nullable)(void))completion;

- (void)bgClicked:(UIGestureRecognizer *__nullable)gesture;

@end

NS_ASSUME_NONNULL_END
