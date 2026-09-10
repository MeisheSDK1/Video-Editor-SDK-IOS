//
//  NvPhotoAlbumProgressView.m
//  SDKDemo
//
//  Created by MS on 2019/10/9.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoAlbumProgressView.h"
#import "NVHeader.h"

@interface NvPhotoAlbumProgressView ()
@property (nonatomic, strong) UIColor* centerColor;
@property (nonatomic, strong) UIColor* arcBackColor;
@property (nonatomic, strong) UIColor* arcFinishColor;
@property (nonatomic, strong) UIColor* arcUnfinishColor;
//@property (nonatomic, assign) float percent;
@property (nonatomic, assign) float width;
@end

@implementation NvPhotoAlbumProgressView

- (id)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        _arcFinishColor = [UIColor nv_colorWithHexRGB:@"#3699FF"];
        _arcUnfinishColor = [UIColor nv_colorWithHexARGB:@"#903699FF"];
        _width = 0;
    }
    return self;
}

- (id)init {
    self= [super init];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        _width = 0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self addArcBackColor];
    [self drawArc];
    [self addCenterBack];
    [self addCenterLabel];
}


- (void)addArcBackColor{
    CGColorRef color = (_arcBackColor == nil) ? [UIColor lightGrayColor].CGColor : _arcBackColor.CGColor;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGSize viewSize = self.bounds.size;
    CGPoint center = CGPointMake(viewSize.width/2, viewSize.height/2);
    CGFloat radius = viewSize.width/2;
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, center.x, center.y);
    CGContextAddArc(contextRef, center.x, center.y, radius, 0, 2*M_PI, 0);
    CGContextSetFillColorWithColor(contextRef, color);
    CGContextFillPath(contextRef);
}

- (void)drawArc {
    CGColorRef color = (_arcFinishColor == nil) ? [UIColor redColor].CGColor : _arcFinishColor.CGColor;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGSize viewSize = self.bounds.size;
    CGPoint center = CGPointMake(viewSize.width/2, viewSize.height/2);
    CGFloat radius = viewSize.width / 2;
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, center.x, center.y);
    float startAngle = -M_PI/2;
    if (_progressValue == 100) {
        CGContextAddArc(contextRef, center.x, center.y, radius, startAngle, 2*M_PI, 0);
    }else{
        float endAngle = 3*M_PI/2*_progressValue/100;
        color = (_arcUnfinishColor == nil) ? [UIColor blueColor].CGColor : _arcUnfinishColor.CGColor;
        CGContextAddArc(contextRef, center.x, center.y, radius, startAngle, endAngle, 0);
    }
    CGContextSetFillColorWithColor(contextRef, color);
    CGContextFillPath(contextRef);
    
}
-(void)addCenterBack{
    float width = (_width == 0) ? 2*SCREENSCALE : _width;
    CGColorRef color = (_centerColor == nil) ? [ UIColor whiteColor].CGColor : _centerColor.CGColor;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGSize viewSize = self.bounds.size;
    CGPoint center = CGPointMake(viewSize.width/2, viewSize.height/2);
    CGFloat radius = viewSize.width / 2 - width;
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, center.x, center.y);
    
    CGContextAddArc(contextRef, center.x, center.y, radius, 0, 2*M_PI, 0);
    CGContextSetFillColorWithColor(contextRef, color);
    CGContextFillPath(contextRef);
    
}



- (void)addCenterLabel{
    NSString *percent = @"";
    float fontSize = 12*SCREENSCALE;
    UIColor *arcColor = [UIColor nv_colorWithHexRGB:@"#3699FF"];
    if (_progressValue == 1) {
        percent = @"100%";
    }else {
        percent = [NSString stringWithFormat:@"%.f%%",_progressValue];
    }
    CGSize viewSize = self.bounds.size;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:fontSize],NSFontAttributeName,arcColor,NSForegroundColorAttributeName,[UIColor clearColor],NSBackgroundColorAttributeName,paragraph,NSParagraphStyleAttributeName, nil];
    [percent drawInRect:CGRectMake(0, (viewSize.height - fontSize)/2, viewSize.width, fontSize) withAttributes:attributes];
    
}

- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
     [self setNeedsDisplay];
}

@end

