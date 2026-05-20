//
//  UIImage+Extension.m
//  jinyun
//
//  Created by 美摄 on 2019/3/21.
//  Copyright © 2019 美摄. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

//+ (UIImage *)imageFromString:(NSString*)string{
//    NSData *decodeData = [[NSData alloc]initWithBase64EncodedString:string options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
//    // 将NSData转为UIImage
//    UIImage *decodedImage = [UIImage imageWithData: decodeData];
//    return decodedImage;
//}

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius size:(CGSize)size{
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context,
                     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:cornerRadius].CGPath);
    CGContextClip(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    CGContextDrawPath(context, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

//- (UIImage *)changeImageWithColor:(UIColor *)color {
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(context, 0, self.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
//    CGContextClipToMask(context, rect, self.CGImage);
//    [color setFill];
//    CGContextFillRect(context, rect);
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}

#pragma mark -- Circle

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

- (UIImage *)drawCircleImage {
    CGFloat side = MIN(self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(side, side), NO, 1.0f);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
    CGContextAddPath(UIGraphicsGetCurrentContext(), [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, side, side)].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    CGFloat originX = -(self.size.width - side) / 2.f;
    CGFloat originY = -(self.size.height - side) / 2.f;
    [self drawInRect:CGRectMake(originX, originY, self.size.width, self.size.height)];
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

#pragma mark 按照传入的size进行图片裁剪
//Crop the image according to the passed size
- (UIImage *)modifyImageSize:(CGSize)size{
    CGImageRef sourceImageRef = [self CGImage];
    
    CGFloat imageWidth = self.size.width * self.scale;
    CGFloat imageHeight = self.size.height * self.scale;
    
    CGFloat offsetX = (imageWidth - size.height) / 2.0;
    CGFloat offsetY = (imageHeight - size.width) / 2.0;
    
    CGRect rect = CGRectMake(offsetY, offsetX, size.height, size.width);
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

#pragma mark 根据传入的size，对原图进行缩放
//The original image is scaled according to the size passed in
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
