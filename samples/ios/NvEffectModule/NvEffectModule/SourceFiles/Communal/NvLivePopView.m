//
//  NvLivePopView.m
//  NvVideoEditor
//
//  Created by chengww on 2021/11/1.
//  Copyright © 2021 MEISHE. All rights reserved.
//

#import "NvLivePopView.h"
#import "NvLiveAppEnv.h"

@interface NvLivePopView () <UIGestureRecognizerDelegate>

@property(nonatomic, assign) NvLivePopDirection presentDirection;

@property(nonatomic, copy) void (^__nullable dismissCallback)(void);

@end

UIView *tmpContentView = nil;
NvLivePopView *tmpPopView = nil;

@implementation NvLivePopView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, NvScreen(kWidth), NvScreen(kHeight))];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

+ (void)showView:(UIView *)view direction:(NvLivePopDirection)direction completion:(void (^__nullable)(void))completion dismissDelegate:(id<NvLivePopViewDelegate>)dismissDelegate {
    tmpContentView = view;
    NvLivePopView *popView = [[NvLivePopView alloc] init];
    tmpPopView = popView;
    [popView addSubview:view];
    popView.contentView = view;
    [popView showWithDirection:direction
                    completion:completion
               dismissCallback:^{
                   if (dismissDelegate) {
                       [dismissDelegate popViewDismissWithContentView:view];
                   }
                   [view removeFromSuperview];
                   tmpContentView = nil;
                   tmpPopView = nil;
               }];
}

+ (void)dismiss {
    if (tmpPopView) {
        [tmpPopView dismissCompletion:nil];
    }
}

- (void)setupSubviews {
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NvScreen(kWidth), NvScreen(kHeight))];
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.f];
    _bgView.alpha = 0.f;
    UITapGestureRecognizer *_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgClicked:)];
    _tap.delegate = self;
    [_bgView addGestureRecognizer:_tap];
    [self addSubview:_bgView];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint localPoint = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(self.contentView.frame, localPoint)) {
        return NO;
    }
    return YES;
}

- (void)bgClicked:(UIGestureRecognizer *)gesture {
    [self dismissCompletion:nil];
}

- (void)showWithDirection:(NvLivePopDirection)direction completion:(void (^__nullable)(void))completion {
    [self showWithDirection:direction completion:completion dismissCallback:nil];
}
- (void)showWithDirection:(NvLivePopDirection)direction completion:(void (^__nullable)(void))completion dismissCallback:(void (^__nullable)(void))dismissCallback {
    self.presentDirection = direction;
    CGRect frame = self.contentView.frame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];

    self.dismissCallback = dismissCallback;

    if (direction == NvLivePopDirection_Bottom) {
        self.contentView.center = CGPointMake(NvScreen(kWidth) * 0.5, NvScreen(kHeight) + frame.size.height);
        frame.origin.y = NvScreen(kHeight) - frame.size.height; // - NvScreen(kSafeAreaBottomHeight);
    } else {
        self.contentView.center = self.center;
        self.contentView.alpha = 0.f;
    }

    [UIView animateWithDuration:0.25
        animations:^{
            if (direction == NvLivePopDirection_Bottom) {
                self.contentView.frame = frame;
            } else {
                self.contentView.alpha = 1.f;
            }
            self.bgView.alpha = 1.f;
        }
        completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
}

- (void)dismissCompletion:(void (^__nullable)(void))completion {
    CGRect frame = self.contentView.frame;
    frame.origin.y = NvScreen(kHeight);
    [UIView animateWithDuration:0.25
        animations:^{
            if (self.presentDirection == NvLivePopDirection_Bottom) {
                self.contentView.frame = frame;
            } else {
                self.contentView.alpha = 0.f;
            }
            self.bgView.alpha = 0.f;
        }
        completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (completion) {
                completion();
            }
            if (self.dismissCallback) {
                self.dismissCallback();
                self.dismissCallback = nil;
            }
        }];
}

- (void)dealloc {
    //    NSLog(@"%s", __FUNCTION__);
}

@end
