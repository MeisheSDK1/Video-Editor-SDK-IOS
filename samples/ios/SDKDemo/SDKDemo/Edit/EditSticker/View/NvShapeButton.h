//
//  NvShapeButton.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/18.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    NV_SHAPE_FREE,
    NV_SHAPE_ROUND,
    NV_SHAPE_SQUARE
}NvShapeEnum;

@protocol NvShapeButtonDelegate <NSObject>

- (void)onButtonClicked:(NvShapeEnum)shape;
@end

@interface NvShapeButtonItem : NSObject

@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NvShapeEnum shape;
@property (nonatomic, assign) BOOL selected;
@end

@interface NvShapeButton : UIView

- (id)initWithFrame:(CGRect)frame item: (NvShapeButtonItem *)item;

@property (nonatomic, weak) id<NvShapeButtonDelegate> delegate;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *label;

- (void)setSelect:(BOOL)select;

@end
