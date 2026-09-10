//
//  JYPopView.m
//  jinyun
//
//  Created by 美摄 on 2019/4/1.
//  Copyright © 2019 美摄. All rights reserved.
//

#import "NvPopView.h"
#import "NVDefineConfig.h"
@interface NvPopView()<UIGestureRecognizerDelegate>

@property(nonatomic,assign)NvPopDirection presentDirection;

@end

@implementation NvPopView

-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _bgView.alpha = 0.f;
    //
    UITapGestureRecognizer* _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgClicked:)];
    _tap.delegate = self;
    [_bgView addGestureRecognizer:_tap];
    [self addSubview:_bgView];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint localPoint = [gestureRecognizer locationInView:self];
    if(CGRectContainsPoint(self.contentView.frame,localPoint)){
        return NO;
    }
    return YES;
}

-(void)bgClicked:(UIGestureRecognizer*)gesture{
    [self dismissCompletion:nil];
}

-(void)showWithDirection:(NvPopDirection)direction completion:(void (^ __nullable)(void))completion{
    self.presentDirection = direction;
    CGRect frame = self.contentView.frame;
    
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    if (direction == NvPopDirection_Bottom) {
        self.contentView.center = CGPointMake(SCREENWIDTH*0.5, SCREENHEIGHT+frame.size.height);
        frame.origin.y = SCREENHEIGHT - frame.size.height;
    }else{
        self.contentView.center = self.center;
        self.contentView.alpha = 0.f;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (direction == NvPopDirection_Bottom) {
            self.contentView.frame = frame;
        }else{
            self.contentView.alpha = 1.f;
        }
        self.bgView.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
    
}

-(void)dismissCompletion:(void (^ __nullable)(void))completion{
    CGRect frame = self.contentView.frame;
    frame.origin.y = SCREENHEIGHT;
    [UIView animateWithDuration:0.25 animations:^{
        if (self.presentDirection == NvPopDirection_Bottom) {
            self.contentView.frame = frame;
        }else{
            self.contentView.alpha = 0.f;
        }
        self.bgView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

@end
