//
//  NvYYAnimatedImageView.m
//  SDKDemo
//
//  Created by meishe01 on 2024/4/19.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvYYAnimatedImageView.h"
#import "YYWebImage.h"

@implementation NvYYAnimatedImageView

-(void)setNVImagePath:(NSString *)NVImagePath{
    
    [self nv_configImagePath:NVImagePath placeHolder:@"NvDefaultProps"];
}

- (void)nv_configImagePath:(NSString *)imagePath placeHolder:(NSString *)placeHolder{
    
    if (imagePath.nv_isNotEmpty && !imagePath.nv_isValidURL) {
        
        NSFileManager * fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:imagePath]) {
        
            if ([imagePath hasSuffix:@".webp"] || [imagePath hasSuffix:@".gif"]) {
                
                NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
                YYImage *image = [YYImage imageWithData:imageData];
                self.image = image;
            }else{
                
                self.image = NvImageNamed(imagePath);
            }
            return;
        }
    }
    UIImage * placeIamge = placeHolder.nv_isNotEmpty ? NvImageNamed(placeHolder) : nil;
    [self yy_setImageWithURL:[NSURL URLWithString:imagePath] placeholder:placeIamge];
}
@end
