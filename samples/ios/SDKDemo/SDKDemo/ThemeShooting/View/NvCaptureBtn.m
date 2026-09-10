//
//  NvCaptureBtn.m
//  SDKDemo
//
//  Created by ms on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCaptureBtn.h"
#import "NVHeader.h"
static CGFloat const center = 39;
static CGFloat const Radius = 39;

@interface NvCaptureBtn()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *tranLayer;
@property (nonatomic, strong) CAShapeLayer *innerLayer;

@property (nonatomic, strong) dispatch_source_t timer;

@end


@implementation NvCaptureBtn

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, 78.0f, 78.0f);
        self.circleLayer = [CAShapeLayer layer];
        self.circleLayer.bounds = self.layer.bounds;
        self.circleLayer.position = CGPointMake(39.0, 39.0f);
        self.circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        self.circleLayer.fillColor = [UIColor clearColor].CGColor;
        self.circleLayer.strokeColor = [UIColor nv_colorWithHexString:@"#ffffff"].CGColor;
        self.circleLayer.path = [self _path].CGPath;
        self.circleLayer.lineWidth = 3;
        self.circleLayer.lineCap = kCALineCapRound;
        self.circleLayer.strokeStart = 0;
        self.circleLayer.strokeEnd = 1;
        [self.layer addSublayer:self.circleLayer];
        
        self.tranLayer = [CAShapeLayer layer];
        self.tranLayer.bounds = self.layer.bounds;
        self.tranLayer.position = CGPointMake(39.0, 39.0f);
        self.tranLayer.anchorPoint = CGPointMake(0.5, 0.5);
        self.tranLayer.fillColor = [UIColor clearColor].CGColor;
        self.tranLayer.strokeColor = [UIColor nv_colorWithHexString:@"#4A90E2"].CGColor;
        self.tranLayer.path = [self _path].CGPath;
        self.tranLayer.lineWidth = 3;
        self.tranLayer.lineCap = kCALineCapRound;
        self.tranLayer.strokeStart = 0;
        self.tranLayer.strokeEnd = 0;
        [self.layer addSublayer:self.tranLayer];
        
        self.innerLayer = [CAShapeLayer layer];
        self.innerLayer.bounds = CGRectMake(0, 0, 70 , 70);
        self.innerLayer.position = CGPointMake(39, 39);
        self.innerLayer.backgroundColor = [UIColor nv_colorWithHexString:@"#4A90E2"].CGColor;
        self.innerLayer.cornerRadius = 35.0f;
        self.innerLayer.masksToBounds = YES;
        [self.layer addSublayer:self.innerLayer];
        
        self.percentageLabel = [UILabel new];
        self.percentageLabel.font = [UIFont systemFontOfSize:13.0f];
        self.percentageLabel.textAlignment = NSTextAlignmentCenter;
        self.percentageLabel.textColor =  [UIColor nv_colorWithHexString:@"#4A90E2"];
        [self addSubview:self.percentageLabel];
        
        [self.percentageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.mas_equalTo(60.0f);
            make.height.mas_equalTo(30.0f);
        }];
        self.completeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"download_complete"]];
        self.completeImage.hidden = YES;
        self.completeImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.completeImage];
        [self.completeImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.height.mas_equalTo(45.0f);
        }];
        
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    self.tranLayer.strokeEnd = progress;
}


- (UIBezierPath *)_path
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(center, center) radius:Radius startAngle:-M_PI_2 endAngle:1.5*M_PI clockwise:YES];
    return path;
}


- (UIBezierPath *)innerPath
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(center, center) radius:Radius - 5 startAngle:-M_PI_2 endAngle:1.5*M_PI clockwise:YES];
    return path;
}

-(void)beginRecord{
    self.innerLayer.bounds = CGRectMake(0, 0, 76 , 76);
    self.innerLayer.backgroundColor = [UIColor nv_colorWithHexString:@"#ffffff"].CGColor;
    self.innerLayer.cornerRadius = 38.0f;
    self.innerLayer.masksToBounds = YES;
    self.percentageLabel.hidden = NO;
    self.tranLayer.hidden = NO;
}

-(void)stopRecord{
    self.innerLayer.bounds = CGRectMake(0, 0, 70 , 70);
    self.innerLayer.backgroundColor = [UIColor nv_colorWithHexString:@"#4A90E2"].CGColor;
    self.innerLayer.cornerRadius = 35.0f;
    self.innerLayer.masksToBounds = YES;
    self.percentageLabel.hidden = YES;
    self.tranLayer.hidden = YES;
    self.tranLayer.strokeEnd = 0;
}

@end
