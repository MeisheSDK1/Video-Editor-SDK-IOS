//
//  UIImage+NvARSceneImage.m
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#import "UIImage+NvARSceneImage.h"

@implementation UIImage (NvARSceneImage)

- (UIImage *)drawRoundedRectImage:(CGFloat)cornerRadius width:(CGFloat)width height:(CGFloat)height {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 1.0f);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, width, height) cornerRadius:cornerRadius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    [self drawInRect:CGRectMake(0, 0, width, height)];
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

#pragma mark 按照传入的size进行图片裁剪
/// Crop the image according to the passed size
- (UIImage *)modifyImageSize:(CGSize)size{
    CGImageRef sourceImageRef = [self CGImage];//将UIImage转换成CGImageRef
    
    CGFloat imageWidth = self.size.width * self.scale;
    CGFloat imageHeight = self.size.height * self.scale;
    
    CGFloat offsetX = (imageWidth - size.height) / 2.0;
    CGFloat offsetY = (imageHeight - size.width) / 2.0;
    
    CGRect rect = CGRectMake(offsetY, offsetX, size.height, size.width);
    //按照给定的矩形区域进行剪裁
    //Crop to the given rectangular area
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

#pragma mark 根据传入的size，对原图进行缩放
///The original image is scaled according to the size passed in
- (UIImage*)scaleImageSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage*)newImage:(BOOL)flip displayRotation:(int)displayRotation{
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (flip) {
        
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformRotate(transform, displayRotation/180.f*M_PI);
    }
    if (!displayRotation) {
        transform = CGAffineTransformRotate(transform, displayRotation/180.f*M_PI);
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    if(displayRotation == 90 || displayRotation == 270) {
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
    }else{
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
