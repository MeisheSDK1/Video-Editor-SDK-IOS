//
//  PEImageView.m
//  QKPictureEditor
//
//  Created by 刘东旭 on 2023/10/29.
//

#import "NvImageView.h"
#import <YYWebImage/YYWebImage.h>

@implementation NvImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

-(void)setImagePath:(NSString *)imagePath {
    [self setImagePath:imagePath placeholderImage:nil];
}

-(void)setImagePath:(NSString *)imagePath placeholderImage:(nullable UIImage*)image {
    if (imagePath.length == 0) {
        self.image = image;
        return;
    }
    NSURL *fileUrl;
    if ([imagePath hasPrefix:@"http"]) {
        fileUrl = [NSURL URLWithString:imagePath];
    } else {
        fileUrl = [NSURL fileURLWithPath:imagePath];
    }
    [self yy_setImageWithURL:fileUrl placeholder:image options:YYWebImageOptionProgressive completion:nil];
}

@end
