//
//  NvDownloadBtn.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvDownloadBtn.h"
#import "NVHeader.h"


@interface NvDownloadBtn ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) UIView *backView;

@end

@implementation NvDownloadBtn

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:12 * SCREENSCALE];
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        
        self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60 * SCREENSCALE, 27 * SCREENSCALE)];
        self.backView.userInteractionEnabled = NO;
        self.backView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        [self addSubview:_backView];
        
        self.progressLabel = [UILabel new];
        self.progressLabel.textColor = UIColor.whiteColor;
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
        self.progressLabel.backgroundColor = UIColor.clearColor;
        [self addSubview:self.progressLabel];
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self).offset(5 * SCREENSCALE);
            make.right.equalTo(self).offset(-5 * SCREENSCALE);
        }];

    }
    return self;
}

- (void)setProgressSize:(CGSize)progressSize {
    self.backView.frame = CGRectMake(0, 0, progressSize.width, progressSize.height);
}

- (void)setProgress:(CGFloat)progress{
    self.backView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
    if (self.progressColorStr.length > 0) {
        self.backView.backgroundColor = [UIColor nv_colorWithHexRGB:self.progressColorStr];
    }
    self.stateTitle = [NSString stringWithFormat:@"%d%%", (int)floor(progress * 100)];
    self.progressLayer.strokeEnd = progress;
}

#pragma mark - 创建进度的Layer
/*
 创建进度的Layer
 Create a layer of progress
 
 */
- (void)initProgressLayer
{
    [self layoutSubviews];
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    [progressPath moveToPoint:CGPointMake(0, CGRectGetMidY(self.backView.bounds))];
    [progressPath addLineToPoint:CGPointMake(self.backView.frame.size.width, CGRectGetMidY(self.backView.bounds))];
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.strokeColor = UIColor.whiteColor.CGColor;
    _progressLayer.lineWidth = self.backView.frame.size.height;
    _progressLayer.path = progressPath.CGPath;
    self.backView.layer.mask = _progressLayer;
    _progressLayer.strokeEnd = 0.0;
}

- (void)setStateTitle:(NSString *)stateTitle{
    if (!self.progressLayer) {
        [self initProgressLayer];
    }
    if ([stateTitle isEqualToString:NvLocalString(@"Download", @"下载")]) {
        self.enabled = YES;
        self.backView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
    }else if ([stateTitle isEqualToString:NvLocalString(@"Downloaded", @"已下载")]){
        self.enabled = NO;
        self.backView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FF6464"];
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FF6464"];
    }
    else if ([stateTitle isEqualToString:NvLocalString(@"Not adapted", @"不适配")]){
        self.enabled = NO;
        self.backView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
    }else if ([stateTitle isEqualToString:NvLocalString(@"again", @"重试")]){
        self.enabled = YES;
        _progressLayer.strokeEnd = 0.0;
        self.backView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#D0021B"];
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#D0021B"];
    }else if([stateTitle isEqualToString:NvLocalString(@"Update", @"更新")]){
        self.enabled = YES;
        self.backView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#13E7EF"];
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#13E7EF"];
        self.progressColorStr = @"#13E7EF";
    }
    
    self.progressLabel.text = stateTitle;

    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
