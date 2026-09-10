//
//  UIImage+Clip.m
//  ImageDemo
//
//  Created by default on 2018/7/17.
//  Copyright © 2018年 default. All rights reserved.
//

#import "UIImage+Clip.h"

@implementation UIImage (Clip)

- (UIImage *)thumWithSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)rotateWithOrientation:(UIImageOrientation)orientation{

    CGAffineTransform transform = CGAffineTransformIdentity;
    CGSize size = self.size;
    switch (orientation) {
        case UIImageOrientationUp:
            return self;
            break;
        case UIImageOrientationUpMirrored:
            //图片原本状态 取镜像
            // The original state of the image is mirrored
            
            //平移
            // translation
            transform = CGAffineTransformMakeTranslation(size.width, size.height);
            
            //顺时针旋转180度
            // Rotate 180 degrees clockwise
            transform = CGAffineTransformRotate(transform, M_PI);
            
            break;
        case UIImageOrientationDown:
            //将图像旋转180°
            // Rotate the image 180°
            
            //平移 translation
            transform = CGAffineTransformMakeTranslation(size.width, 0);
            
            //缩放，如果为负数则是将图片翻转，此处为沿Y轴翻转
            // Scale. If it is negative, it flips the image. In this case, it flips along the Y-axis
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDownMirrored:
            //将图片旋转180°后取镜像
            // Rotate the image 180° to get the mirror image
            break;
        case UIImageOrientationLeft:
            //将图片逆时针旋转90° 此处用transform也可以实现 只是执行到第二步 “transform = CGAffineTransformRotate(transform, -M_PI/2);”的时候坐标系已经被翻转不方便计算，所以采用和CGContext结合的方式进行变换
            // Rotate the image by 90° counterclockwise. This is also possible with transform. Just go to the second step: "transform = CGAffineTransformRotate(transform, -M_PI/2);". The coordinate system has been flipped and it's not easy to compute, so I'm going to combine it with the CGContext
            size = CGSizeMake(size.height, size.width);
            //平移
            // translation
            transform = CGAffineTransformMakeTranslation(size.width,0);
            transform = CGAffineTransformRotate(transform, M_PI/2);
            break;
        case UIImageOrientationLeftMirrored:
            size = CGSizeMake(size.height, size.width);
            //平移
            // translation
            transform = CGAffineTransformMakeTranslation(size.width,0);
            transform = CGAffineTransformRotate(transform, M_PI/2);
            break;
        case UIImageOrientationRight:
            size = CGSizeMake(size.height, size.width);
            //平移
            // translation
            transform = CGAffineTransformMakeTranslation(0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI/2);
            break;
        case UIImageOrientationRightMirrored:
           
            size = CGSizeMake(size.height, size.width);
            //平移
            // translation
            transform = CGAffineTransformMakeTranslation(0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI/2);
            break;
        default:
            break;
    }
    UIGraphicsBeginImageContext(size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    switch (orientation) {
        case UIImageOrientationLeft:
            //将上述已经经过一次变化后的图形进行变换
            // Transform the graph that has been changed once above
        case UIImageOrientationRight:
            CGContextTranslateCTM(contextRef,0.0,size.height);
            CGContextScaleCTM(contextRef, 1.0, -1.0);
            break;
        default:
            break;
    }
    
    CGContextConcatCTM(contextRef, transform);

    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
