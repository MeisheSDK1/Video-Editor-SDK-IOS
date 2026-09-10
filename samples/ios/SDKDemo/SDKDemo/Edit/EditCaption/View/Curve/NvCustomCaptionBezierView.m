//
//  NvCustomCaptionBezierView.m
//  SDKDemo
//
//  Created by ms on 2021/5/21.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCustomCaptionBezierView.h"
#import "NVHeader.h"
@interface NvCustomCaptionBezierView ()
@property (nonatomic, strong)UILabel *titleLab;
@property (nonatomic, strong)UIView *bezierBgView;
@property (nonatomic, strong) NSMutableArray *pointArr;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *controlLayer1;
@property (nonatomic, strong) CAShapeLayer *controlLayer2;
@property (nonatomic, strong) NvButton *controlOneBtn;
@property (nonatomic, strong) NvButton *controlTwoBtn;
@property (nonatomic, strong) NSMutableArray *controlArr;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UIView *lineView;
@end

#define BezierHeight 140
#define PointControlWidth 13

@implementation NvCustomCaptionBezierView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.pointArr = [NSMutableArray array];
        self.shapeLayer = [CAShapeLayer layer];
        self.controlArr = [NSMutableArray array];
        [self initUI];
        self.backgroundColor = [UIColor nv_colorWithHexString:@"#202020"];
    }
    return self;
}

-(void)initUI{
    _titleLab = [[UILabel alloc] init];
    _titleLab.font = [UIFont systemFontOfSize:11];
    _titleLab.textColor = [UIColor whiteColor];
    _titleLab.backgroundColor = [UIColor clearColor];
    _titleLab.text = NvLocalString(@"Custom curve", @"自定义曲线");
    _titleLab.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_titleLab];
    _bezierBgView = [[UIView alloc] init];
    _bezierBgView.hidden = YES;
    _bezierBgView.backgroundColor = [UIColor nv_colorWithHexString:@"#333333"];
    [self addSubview:_bezierBgView];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25.0f);
        make.right.mas_equalTo(-25.0f);
        make.height.mas_equalTo(30.0f);
        make.top.mas_equalTo(20.0f);
    }];
    [_bezierBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLab.mas_bottom).offset(10.0f);
        make.left.mas_equalTo(25.0f);
        make.right.mas_equalTo(-25.0f);
        make.height.mas_equalTo(140.0f);
    }];

    CGFloat vertailX = (kScreenWidth - 50 - 5) / 4.0 + 1;
    CGFloat vertailY = (BezierHeight - 5) / 4.0 + 1;
    CGFloat startX = 0.0f;
    CGFloat startY = 0;
    for (int i =0; i<5; i++) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(startX + i * vertailX, startY, 0.5, BezierHeight);
        view.backgroundColor = [UIColor whiteColor];
        view.alpha = 0.5;
        [_bezierBgView addSubview:view];
    }
    for (int j = 0; j< 5; j ++) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, startY + j * vertailY, kScreenWidth - 50, 0.5);
        view.backgroundColor = [UIColor whiteColor];
        view.alpha = 0.5;
        [_bezierBgView addSubview:view];
    }
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(-5, BezierHeight-5, 10, 10);
    leftBtn.layer.masksToBounds = YES;
    leftBtn.layer.cornerRadius = 2.5;
    leftBtn.backgroundColor = [UIColor whiteColor];
    [_bezierBgView addSubview:leftBtn];
    leftBtn.layer.cornerRadius = 5.0f;
    leftBtn.layer.masksToBounds = YES;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(kScreenWidth - 50.0 - 5, -5, 10, 10);
    rightBtn.layer.masksToBounds = YES;
    rightBtn.layer.cornerRadius = 2.5;
    rightBtn.backgroundColor = [UIColor whiteColor];
    rightBtn.layer.cornerRadius = 5.0f;
    rightBtn.layer.masksToBounds = YES;
    [_bezierBgView addSubview:rightBtn];
    [self.pointArr addObject:leftBtn];
    [self.pointArr addObject:rightBtn];
    self.controlOneBtn = [self createPointButton];
    self.controlOneBtn.frame = CGRectMake(-PointControlWidth / 2.0,-PointControlWidth / 2.0 , PointControlWidth, PointControlWidth);
    self.controlOneBtn.tag = 0;
    self.controlTwoBtn = [self createPointButton];
    self.controlTwoBtn.frame = CGRectMake(kScreenWidth-PointControlWidth / 2.0 - 50,BezierHeight -PointControlWidth / 2.0, PointControlWidth, PointControlWidth);
    self.controlTwoBtn.tag = 1;
    [self.controlArr addObject:self.controlOneBtn];
    [self.controlArr addObject:self.controlTwoBtn];
    [self addSubview:self.finishBtn];
    [self addSubview:self.lineView];
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.finishBtn.mas_top).offset(-12 * SCREENSCALE);
    }];
}


- (NvButton *)createPointButton {
    NvButton *button = [NvButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = PointControlWidth / 2.0;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanPointButton:)];
    [button addGestureRecognizer:pan];
    [_bezierBgView addSubview:button];
    button.expandCofficient = 2;
    return button;
}

- (void)setupSelectedDefault:(CGPoint)leftPoint with:(CGPoint)rightPoint{
    NvButton *controlbtn = self.controlArr.firstObject;
    NvButton *controlbtn1 = self.controlArr[1];
    
    if (!CGPointEqualToPoint(leftPoint, CGPointZero)){
        controlbtn.center = CGPointMake(leftPoint.x * _bezierBgView.viewWidth, _bezierBgView.viewHeight - leftPoint.y * _bezierBgView.viewHeight) ;
    }
    
    if (!CGPointEqualToPoint(rightPoint, CGPointZero)) {
        controlbtn1.center = CGPointMake(rightPoint.x * _bezierBgView.viewWidth, _bezierBgView.viewHeight - rightPoint.y * _bezierBgView.viewHeight) ;
    }
    
    [self.shapeLayer removeFromSuperlayer];
    [self.controlLayer1 removeFromSuperlayer];
    [self.controlLayer2 removeFromSuperlayer];
    ///重新绘制
    ///redraw
    [self drawBezier];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bezierBgView.hidden = NO;
    });
}

-(void)drawBezier{
    NvButton *btn = self.pointArr.firstObject;
    NvButton *btn1 = self.pointArr[1];
    CGPoint startPoint = CGPointMake(btn.viewCenterX, btn.viewCenterY) ;
    CGPoint endPoint = CGPointMake(btn1.viewCenterX, btn1.viewCenterY) ;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:startPoint];
    NvButton *controlbtn = self.controlArr.firstObject;
    NvButton *controlbtn1 = self.controlArr[1];
    CGPoint control1 = CGPointMake(controlbtn.viewCenterX, controlbtn.viewCenterY) ;
    CGPoint control2 = CGPointMake(controlbtn1.viewCenterX, controlbtn1.viewCenterY) ;
    [linePath addCurveToPoint:endPoint controlPoint1:control1 controlPoint2:control2];
    self.shapeLayer.path = linePath.CGPath;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.lineWidth = 2.0f;
    [self.bezierBgView.layer addSublayer:self.shapeLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.fromValue = 0;
    animation.toValue = @1;
    animation.duration = 0.01;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = NO;
    [self.shapeLayer addAnimation:animation forKey:@"stroke"];
    
    UIBezierPath *controlLinePath1 = [UIBezierPath bezierPath];
    [controlLinePath1 moveToPoint:startPoint];
    [controlLinePath1 addLineToPoint:control1];
    CAShapeLayer *controlLayer1 = [CAShapeLayer layer];
    controlLayer1.path = controlLinePath1.CGPath;
    controlLayer1.fillColor = [UIColor clearColor].CGColor;
    controlLayer1.strokeColor = [UIColor nv_colorWithHexString:@"#4A90E2"].CGColor;
    controlLayer1.lineWidth = 1.0f;
    self.controlLayer1 = controlLayer1;
    [self.bezierBgView.layer addSublayer:controlLayer1];
    
    UIBezierPath *controlLinePath2 = [UIBezierPath bezierPath];
    [controlLinePath2 moveToPoint:endPoint];
    [controlLinePath2 addLineToPoint:control2];
    CAShapeLayer *controlLayer2 = [CAShapeLayer layer];
    controlLayer2.path = controlLinePath2.CGPath;
    controlLayer2.fillColor = [UIColor clearColor].CGColor;
    controlLayer2.strokeColor = [UIColor nv_colorWithHexString:@"#4A90E2"].CGColor;
    controlLayer2.lineWidth = 1.0f;
    self.controlLayer2 = controlLayer2;
    [self.bezierBgView.layer addSublayer:controlLayer2];
}

- (void)didPanPointButton:(UIPanGestureRecognizer *)sender {
    ///获取当前滑动的按钮和索引
    ///Gets the currently sliding button and index
    UIView *view = sender.view;
    if (![view isKindOfClass:[UIButton class]]) {
        return;
    }
    UIButton *button = (UIButton *)view;

    ///设置坐标点的拖拽区间
    ///Sets the drag interval for coordinate points
    CGPoint point = [sender translationInView:_bezierBgView];

    CGRect rect = button.frame;
    CGFloat comY = rect.origin.y + point.y;
    CGFloat maxY = -PointControlWidth / 2.0f;
    CGFloat minY = BezierHeight - PointControlWidth / 2.0f;
    if (comY < maxY) {
        rect.origin.y = maxY;
    }else if (comY > minY) {
        rect.origin.y = minY;
    }else {
        rect.origin.y += point.y;
    }
    ///曲线点x轴方向移动
    ///The curve point is moving in the x direction
    CGFloat comX = rect.origin.x + point.x;
    CGFloat minX = -PointControlWidth / 2.0f;;
    CGFloat maxX = kScreenWidth - 50 - PointControlWidth / 2.0f ;
    if (comX < minX) {
        rect.origin.x = minX;
    }else if (comX > maxX) {
        rect.origin.x = maxX;
    }else {
        rect.origin.x += point.x;
    }
    button.frame = CGRectMake(rect.origin.x,rect.origin.y , PointControlWidth, PointControlWidth);

    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed ) {
        [self applyCurveAnimation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(dragEnd)]) {
            [self.delegate dragEnd];
        }
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        ///删除旧的曲线
        ///Delete the old curve
        [self.shapeLayer removeFromSuperlayer];
        [self.controlLayer1 removeFromSuperlayer];
        [self.controlLayer2 removeFromSuperlayer];
        ///重新绘制
        ///redraw
        [self drawBezier];
        
    }
    [sender setTranslation:CGPointZero inView:self];
}
- (UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        [_finishBtn addTarget:self action:@selector(nvAddCaptionViewFinishEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    }
    return _lineView;
}

-(void)applyCurveAnimation{
    NvButton *controlbtn = self.controlArr.firstObject;
    NvButton *controlbtn1 = self.controlArr[1];
    CGPoint control1 = CGPointMake(controlbtn.viewCenterX, controlbtn.viewCenterY) ;
    CGPoint control2 = CGPointMake(controlbtn1.viewCenterX, controlbtn1.viewCenterY) ;
    CGPoint controlLeft = CGPointMake(control1.x / _bezierBgView.viewWidth,(_bezierBgView.viewHeight - control1.y) / _bezierBgView.viewHeight);
    CGPoint controlRight = CGPointMake(control2.x / _bezierBgView.viewWidth,(_bezierBgView.viewHeight - control2.y) / _bezierBgView.viewHeight);
    if (self.delegate && [self.delegate respondsToSelector:@selector(NvCustomCaptionBezierViewDidFinishedWithControlLeft:ControlRight:)]) {
        [self.delegate NvCustomCaptionBezierViewDidFinishedWithControlLeft:controlLeft ControlRight:controlRight];
    }
}

-(void)nvAddCaptionViewFinishEvent{
    [self applyCurveAnimation];
    
    [self removeFromSuperview];
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    CGPoint pointTemp = [self.bezierBgView convertPoint:point fromView:self];
    if (CGRectContainsPoint(CGRectMake(self.controlTwoBtn.frame.origin.x-10, self.controlTwoBtn.frame.origin.y-10, self.controlTwoBtn.frame.size.width*3, self.controlTwoBtn.frame.size.height*3), pointTemp)) {
        return self.controlTwoBtn;
    }
    if (CGRectContainsPoint(CGRectMake(self.controlOneBtn.frame.origin.x-10, self.controlOneBtn.frame.origin.y-10, self.controlOneBtn.frame.size.width*3, self.controlOneBtn.frame.size.height*3), pointTemp)) {
        return self.controlOneBtn;
    }
    return view;
}

@end
