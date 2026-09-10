//
//  PEImageView.h
//  QKPictureEditor
//
//  Created by 刘东旭 on 2023/10/29.
//

#import <UIKit/UIKit.h>
#import <YYImage/YYAnimatedImageView.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvImageView : YYAnimatedImageView

-(void)setImagePath:(NSString *)imagePath;
-(void)setImagePath:(NSString *)imagePath placeholderImage:(nullable UIImage*)image;

@end

NS_ASSUME_NONNULL_END
