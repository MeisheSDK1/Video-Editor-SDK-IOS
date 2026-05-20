//
//  NvBubbleLabel.m
//  SDKDemo
//
//  Created by ms20221114 on 2023/2/28.
//  Copyright © 2023 meishe. All rights reserved.
//

#import "NvBubbleLabel.h"

@implementation NvBubbleLabel

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines{
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    textRect.origin.y = bounds.origin.y+(bounds.size.height - textRect.size.height)/2.0 - 3*SCREENSCALE;
    
    return textRect;
}

- (void)drawTextInRect:(CGRect)rect{
    CGRect textRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:textRect];
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat selfWidth = rect.size.width;
    CGFloat selfHeight = rect.size.height;

    CGSize arrowSize = CGSizeMake(6*SCREENSCALE, 6*SCREENSCALE);
    
    CGFloat bottomContetMaxY = selfHeight - arrowSize.height;

    CGFloat cornerRadius = bottomContetMaxY/2.0;// 圆角角度
    
    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 矩形填充颜色
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);

    CGContextMoveToPoint(context, cornerRadius, 0);

    CGContextAddArcToPoint(context, selfWidth, 0, selfWidth, bottomContetMaxY, cornerRadius);
    CGContextAddArcToPoint(context, selfWidth, bottomContetMaxY, 0, bottomContetMaxY, cornerRadius);
    
    CGContextAddLineToPoint(context, selfWidth/2 + arrowSize.width/2, bottomContetMaxY);
    CGContextAddArcToPoint(context, selfWidth/2.0, selfHeight, selfWidth/2 - arrowSize.width/2, bottomContetMaxY, 2);
    CGContextAddArcToPoint(context, selfWidth/2 - arrowSize.width/2, bottomContetMaxY, selfWidth/2 - arrowSize.width/2, bottomContetMaxY, 2);
    
    CGContextAddArcToPoint(context, 0, bottomContetMaxY, 0, bottomContetMaxY - cornerRadius, cornerRadius);
    CGContextAddArcToPoint(context, 0, 0, cornerRadius, 0, cornerRadius);

    CGContextDrawPath(context, kCGPathFill);
    // 必须要在调用super之前绘制完成否则会出现当前view中的文字无法显示问题。
    [super drawRect:rect];
}

@end
