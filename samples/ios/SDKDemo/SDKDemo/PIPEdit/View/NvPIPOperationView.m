//
//  NvPIPOperationView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPOperationView.h"
#import "NvImageButton.h"

#import "NVDefineConfig.h"
#import "UIView+Dimension.h"
#import <NvSDKCommon/NvUtils.h>
#import <Masonry/Masonry.h>

@interface NvPIPOperationView ()

@property (nonatomic, strong) NvImageButton *replaceButton, *zoomInButton,*zoomOutButton,*rotationButton,*cutVideoButton;

@end

@implementation NvPIPOperationView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:77/255.0 green:79/255.0 blue:81/255.0 alpha:1];
        self.layer.cornerRadius = 8;
        
        self.replaceButton = [[NvImageButton alloc] init];
        [self.replaceButton addTarget:self action:@selector(replaceClick) forControlEvents:UIControlEventTouchUpInside];
        self.replaceButton.image = NvImageNamed(@"pip-replace");
        [self addSubview:self.replaceButton];
        [self.replaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(8*SCREENSCALE));
            make.top.equalTo(@(5*SCREENSCALE));
            make.bottom.equalTo(@(-5*SCREENSCALE));
        }];
        self.zoomInButton = [[NvImageButton alloc] init];
        [self.zoomInButton addTarget:self action:@selector(zoomInClick) forControlEvents:UIControlEventTouchUpInside];
        self.zoomInButton.image = NvImageNamed(@"pip-Magnifier-add");
        [self addSubview:self.zoomInButton];
        [self.zoomInButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.replaceButton.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(@(5*SCREENSCALE));
            make.bottom.equalTo(@(-5*SCREENSCALE));
        }];
        self.zoomOutButton = [[NvImageButton alloc] init];
        [self.zoomOutButton addTarget:self action:@selector(zoomOutClick) forControlEvents:UIControlEventTouchUpInside];
        self.zoomOutButton.image = NvImageNamed(@"pip-Magnifier-remove");
        [self addSubview:self.zoomOutButton];
        [self.zoomOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.zoomInButton.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(@(5*SCREENSCALE));
            make.bottom.equalTo(@(-5*SCREENSCALE));
        }];
        self.rotationButton = [[NvImageButton alloc] init];
        [self.rotationButton addTarget:self action:@selector(rotationClick) forControlEvents:UIControlEventTouchUpInside];
        self.rotationButton.image = NvImageNamed(@"pip-rotation");
        [self addSubview:self.rotationButton];
        [self.rotationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.zoomOutButton.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(@(5*SCREENSCALE));
            make.bottom.equalTo(@(-5*SCREENSCALE));
        }];
        self.cutVideoButton = [[NvImageButton alloc] init];
        [self.cutVideoButton addTarget:self action:@selector(cutVideoClick) forControlEvents:UIControlEventTouchUpInside];
        self.cutVideoButton.image = NvImageNamed(@"NvPipCut");
        [self addSubview:self.cutVideoButton];
        [self.cutVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.rotationButton.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(@(5*SCREENSCALE));
            make.bottom.equalTo(@(-5*SCREENSCALE));
            make.right.equalTo(@(-5*SCREENSCALE));
        }];
    }
    return self;
}

- (void)setHiddenCrop:(BOOL)hiddenCrop {
    _hiddenCrop = hiddenCrop;
    self.cutVideoButton.hidden = hiddenCrop;
    if (_hiddenCrop) {
        [self.rotationButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.zoomOutButton.mas_right).offset(8*SCREENSCALE);
            make.right.equalTo(@(-5*SCREENSCALE));
            make.top.equalTo(@(5*SCREENSCALE));
            make.bottom.equalTo(@(-5*SCREENSCALE));
        }];
    } else {
        [self.rotationButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.zoomOutButton.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(@(5*SCREENSCALE));
            make.bottom.equalTo(@(-5*SCREENSCALE));
        }];
        [self.cutVideoButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.rotationButton.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(@(5*SCREENSCALE));
            make.bottom.equalTo(@(-5*SCREENSCALE));
            make.right.equalTo(@(-5*SCREENSCALE));
        }];
    }
}

- (void)replaceClick {
    if ([self.delegate respondsToSelector:@selector(replace)]) {
        [self.delegate replace];
    }
}

- (void)zoomInClick {
    if ([self.delegate respondsToSelector:@selector(zoomIn)]) {
        [self.delegate zoomIn];
    }
}

- (void)zoomOutClick {
    if ([self.delegate respondsToSelector:@selector(zoomOut)]) {
        [self.delegate zoomOut];
    }
}

- (void)rotationClick {
    if ([self.delegate respondsToSelector:@selector(rotate)]) {
        [self.delegate rotate];
    }
}

- (void)cutVideoClick {
    if ([self.delegate respondsToSelector:@selector(cutVideo)]) {
        [self.delegate cutVideo];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
