//
//  NvRecordingView.m
//  
//
//  Created by 刘东旭 on 2019/3/26.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "NvRecordingView.h"
#import <Masonry/Masonry.h>
#import <UIColor+NvColor.h>

@interface NvRecordingView()

@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) CGSize size_t;

@end

@implementation NvRecordingView

#define NvCenterViewWidthScale 0.7

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.size_t = self.frame.size;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 5;
        self.layer.borderColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5].CGColor;
        
        self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*NvCenterViewWidthScale, frame.size.height*NvCenterViewWidthScale)];
        self.centerView.center = self.center;
        self.centerView.backgroundColor = UIColor.redColor;
        [self addSubview:self.centerView];
        [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.equalTo(self).multipliedBy(NvCenterViewWidthScale);
        }];
        self.centerView.layer.cornerRadius = self.frame.size.width*NvCenterViewWidthScale/2;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
        [self addGestureRecognizer:longTap];
    }
    return self;
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    if (self.captureModel == NvCapturePhotoModel) {
        if ([self.delegate respondsToSelector:@selector(takePhoto)]) {
            [self.delegate takePhoto];
        }
        return;
    }
    if (self.isAnimating) {
        [self stopAnimation];
    } else {
        [self startAnimation];
    }
}

- (void)longTap:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.captureModel == NvCapturePhotoModel) {
            if ([self.delegate respondsToSelector:@selector(takePhoto)]) {
                [self.delegate takePhoto];
            }
            return;
        }
        if (self.isAnimating) {
            [self stopAnimation];
        } else {
            [self startAnimation];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.captureModel == NvCapturePhotoModel) {
            return;
        }
        if (self.isAnimating) {
            [self stopAnimation];
        } else {
            [self startAnimation];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
 
    }
}

- (void)startAnimation {
    if ([self.delegate respondsToSelector:@selector(recordingViewAllowStartRecording:)]) {
        BOOL allow = [self.delegate recordingViewAllowStartRecording:self];
        if (allow) {
            self.isAnimating = YES;
            if ([self.delegate respondsToSelector:@selector(startRecording)]) {
                [self.delegate startRecording];
            }
            [self.centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.width.height.equalTo(self).multipliedBy(0.3);
            }];
            
            self.centerView.layer.cornerRadius = 3;
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.centerView setNeedsLayout];
                self.transform = CGAffineTransformMakeScale(1.6, 1.6);
            } completion:^(BOOL finished) {
                self.layer.borderColor            = [[UIColor nv_colorWithHexARGB:@"#33FE0000"] CGColor];
                CAAnimationGroup *group           = [CAAnimationGroup animation];
                group.duration                    = 0.8;
                group.repeatCount                 = HUGE_VAL;
                CABasicAnimation *widthAnimation  = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
                widthAnimation.fromValue          = @10;
                widthAnimation.toValue            = @5;
                widthAnimation.duration           = 0.4;
                widthAnimation.fillMode           = kCAFillModeForwards;
                
                CABasicAnimation *widthAnimation1 = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
                widthAnimation1.fromValue         = @5;
                widthAnimation1.toValue           = @10;
                widthAnimation1.duration          = 0.4;
                widthAnimation1.beginTime         = 0.4;
                widthAnimation1.fillMode          = kCAFillModeForwards;
                group.animations                  = [NSArray arrayWithObjects:widthAnimation,widthAnimation1, nil];
                [self.layer addAnimation:group forKey:@"borderWidths"];
                
            }];
        }
    }
}

- (void)stopAnimation {
    [self.centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(self).multipliedBy(NvCenterViewWidthScale);
    }];
    [self.layer removeAllAnimations];
    self.centerView.layer.cornerRadius = self.size_t.width*NvCenterViewWidthScale/2;
    [UIView animateWithDuration:0.3 animations:^{
        [self.centerView setNeedsLayout];
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        if ([self.delegate respondsToSelector:@selector(stopRecording)]) {
            [self.delegate stopRecording];
        }
    }];
}

- (void)callbackAndStopAnimation {
    if ([self.delegate respondsToSelector:@selector(stopRecording)]) {
        [self.delegate stopRecording];
    }
    [self.centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(self).multipliedBy(NvCenterViewWidthScale);
    }];
    [self.layer removeAllAnimations];
    self.centerView.layer.cornerRadius = self.size_t.width*NvCenterViewWidthScale/2;
    [UIView animateWithDuration:0.3 animations:^{
        [self.centerView setNeedsLayout];
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

@end
