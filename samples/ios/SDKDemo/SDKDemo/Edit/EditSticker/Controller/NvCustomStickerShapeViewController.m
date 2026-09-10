//
//  NvCustomStickerShapeViewController.m
//  SDKDemo
//
//  Created by dx on 2018/6/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCustomStickerShapeViewController.h"
#import "NvCustomStickerViewController.h"
#import "NvDragView.h"
#import "NvShapeButton.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvSDKCommon/NvUtils.h>

@interface NvCustomStickerShapeViewController ()<NvDragViewDelegate, NvShapeButtonDelegate>
///图片展示视图
///Picture display view
@property (nonatomic, strong) UIImageView *photoView;
///拖拽框
///Drag frame
@property (nonatomic, strong) NvDragView *dragView;
///自由形状
///Free shape
@property (nonatomic, strong) NvShapeButton *freeShapeButton;
///圆形
///circle
@property (nonatomic, strong) NvShapeButton *roundShapeButton;
///正方形
///square
@property (nonatomic, strong) NvShapeButton *squreShapeButton;
///完成按钮
///Finish button
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, strong) UIView *line;

@end

@implementation NvCustomStickerShapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Select content", @"选择内容");
    [self addSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addSubViews {
    [self initPhotoView];
    [self initFinishButton];
    [self initFreeShapeButton];
    [self initRoundShapeButton];
    [self initSqureShapeButton];
    [self initSeplineView];
    
}

- (void)initPhotoView {
    self.photoView = [[UIImageView alloc] init];
    [self.photoView setImage:self.selectedImage];
    self.photoView.userInteractionEnabled = YES;
    [self.view addSubview:self.photoView];
    [self setPhotoViewFrame];
    
    self.dragView = [[NvDragView alloc] initWithFrame:CGRectMake(self.photoView.bounds.size.width/4,
                                                                 self.photoView.bounds.size.height/4,
                                                                 self.photoView.bounds.size.width/2,
                                                                 self.photoView.bounds.size.width/2)];
    self.dragView.delegate = self;
    self.dragView.backgroundColor = [UIColor clearColor];
    [self.dragView addDragBar];
    [self.photoView addSubview:self.dragView];
    [self.photoView bringSubviewToFront:self.dragView];
}

- (void)initFinishButton {
    self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishButton setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [self.finishButton addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.finishButton.frame = CGRectMake(175*SCREENSCALE, 568*SCREENSCALE, 25*SCREENSCALE, 20*SCREENSCALE);
    
    [self.view addSubview:self.finishButton];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-12 * SCREENSCALE - INDICATOR);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.offset(25 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.finishButton.mas_top).offset(-12*SCREENSCALE);
    }];
}

- (void)initFreeShapeButton {
    NvShapeButtonItem *freeItem = NvShapeButtonItem.new;
    freeItem.imagePath = @"NvStickerCustom";
    freeItem.text = NvLocalString(@"Free", @"自由");
    freeItem.selected = YES;
    freeItem.shape = NV_SHAPE_FREE;
    self.freeShapeButton = [[NvShapeButton alloc] initWithFrame:CGRectMake(44*SCREENSCALE, 469*SCREENSCALE, 50*SCREENSCALE, 75*SCREENSCALE) item:freeItem];
    self.freeShapeButton.delegate = self;
    [self.view addSubview:self.freeShapeButton];
    
    [self.freeShapeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(44*SCREENSCALE));
        make.width.equalTo(@(50*SCREENSCALE));
        make.height.equalTo(@(75*SCREENSCALE));
        make.bottom.equalTo(self.line.mas_top);
    }];
}

- (void)initRoundShapeButton {
    NvShapeButtonItem *roundItem = NvShapeButtonItem.new;
    roundItem.imagePath = @"NvStickerCircle";
    roundItem.text = NvLocalString(@"Round", @"圆形");
    roundItem.selected = NO;
    roundItem.shape = NV_SHAPE_ROUND;
    self.roundShapeButton = [[NvShapeButton alloc] initWithFrame:CGRectMake(166*SCREENSCALE, 469*SCREENSCALE, 50*SCREENSCALE, 75*SCREENSCALE) item:roundItem];
    self.roundShapeButton.delegate = self;
    
    [self.view addSubview:self.roundShapeButton];
    [self.roundShapeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(50*SCREENSCALE));
        make.height.equalTo(@(75*SCREENSCALE));
        make.bottom.equalTo(self.freeShapeButton);
    }];
}

- (void)initSqureShapeButton {
    NvShapeButtonItem *squreItem = NvShapeButtonItem.new;
    squreItem.imagePath = @"NvStickerRect";
    squreItem.text = NvLocalString(@"Square", @"正方");
    squreItem.selected = NO;
    squreItem.shape = NV_SHAPE_SQUARE;
    self.squreShapeButton = [[NvShapeButton alloc] initWithFrame:CGRectMake(287*SCREENSCALE, 469*SCREENSCALE, 50*SCREENSCALE, 75*SCREENSCALE) item:squreItem];
    self.squreShapeButton.delegate = self;
    
    [self.view addSubview:self.squreShapeButton];
    
    [self.squreShapeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-44*SCREENSCALE));
        make.width.equalTo(@(50*SCREENSCALE));
        make.height.equalTo(@(75*SCREENSCALE));
        make.bottom.equalTo(self.freeShapeButton);
    }];
}

- (void)initSeplineView {
    float navbarHeight = 64*SCREENSCALE;
    UIView *sepline = [[UIView alloc] initWithFrame:CGRectMake(0, 521*SCREENSCALE - navbarHeight, SCREENWIDTH, SCREENSCALE)];
    sepline.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:sepline];
    [sepline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@(0));
        make.height.equalTo(@(0.5));
        make.bottom.equalTo(self.freeShapeButton.mas_top).offset(-12*SCREENSCALE);
    }];
}

- (void)setPhotoViewFrame {
    float centerPartHeight = 455*SCREENSCALE;
    if (self.selectedImage.size.width < self.selectedImage.size.height) {
        float height = SCREENWIDTH;
        float width = self.selectedImage.size.width/self.selectedImage.size.height*height;
        float x = (SCREENWIDTH - width)/2;
        float y = (centerPartHeight - height)/2;
        self.photoView.frame = CGRectMake(x, y, width, height);
    } else if (self.selectedImage.size.width > self.selectedImage.size.height) {
        float width = SCREENWIDTH;
        float height = self.selectedImage.size.height/self.selectedImage.size.width*width;
        float x = 0;
        float y = (centerPartHeight - height)/2;
        self.photoView.frame = CGRectMake(x, y, width, height);
    } else {
        float width = SCREENWIDTH;
        float height = SCREENWIDTH;
        float x = 0;
        float y = (centerPartHeight - height)/2;
        self.photoView.frame = CGRectMake(x, y, width, height);
    }
}

- (void)onButtonClicked:(NvShapeEnum)shape {
    if (shape == NV_SHAPE_FREE) {
        self.dragView.originRect = CGRectMake(0,0,self.photoView.bounds.size.width/2,self.photoView.bounds.size.width/2);
        [self.dragView setDragMode:freeMode];
        self.dragView.frame = CGRectMake(self.photoView.bounds.size.width/4,self.photoView.bounds.size.height/4,self.photoView.bounds.size.width/2,self.photoView.bounds.size.width/2);
        [self.freeShapeButton setSelect:YES];
        [self.roundShapeButton setSelect:NO];
        [self.squreShapeButton setSelect:NO];
    } else if (shape == NV_SHAPE_ROUND) {
        self.dragView.originRect = CGRectMake(0,0,self.photoView.bounds.size.width/2,self.photoView.bounds.size.width/2);
        [self.dragView setDragMode:roundMode];
        self.dragView.frame = CGRectMake(self.photoView.bounds.size.width/4,self.photoView.bounds.size.height/4,self.photoView.bounds.size.width/2,self.photoView.bounds.size.width/2);
        [self.freeShapeButton setSelect:NO];
        [self.roundShapeButton setSelect:YES];
        [self.squreShapeButton setSelect:NO];
    } else if (shape == NV_SHAPE_SQUARE) {
        self.dragView.originRect = CGRectMake(0,0,self.photoView.bounds.size.width/2,self.photoView.bounds.size.width/2);
        [self.dragView setDragMode:squreMode];
        self.dragView.frame = CGRectMake(self.photoView.bounds.size.width/4,self.photoView.bounds.size.height/4,self.photoView.bounds.size.width/2,self.photoView.bounds.size.width/2);
        [self.freeShapeButton setSelect:NO];
        [self.roundShapeButton setSelect:NO];
        [self.squreShapeButton setSelect:YES];
    }
}

-(void) finishButtonClicked:(UIButton *)sender{
    NvCustomStickerViewController *vc = [[NvCustomStickerViewController alloc] init];
    UIImage *photoImage = self.photoView.image;
    float x,y,w,h;
    x = self.dragView.frame.origin.x/self.photoView.bounds.size.width*photoImage.size.width;
    y = self.dragView.frame.origin.y/self.photoView.bounds.size.height*photoImage.size.height;
    w = self.dragView.frame.size.width/self.photoView.bounds.size.width*photoImage.size.width;
    h = self.dragView.frame.size.height/self.photoView.bounds.size.height*photoImage.size.height;
    UIImage *image = [self imageFromImage:self.photoView.image inRect:CGRectMake(x,y,w,h) isRound:self.dragView.mode == roundMode];
    vc.image = image;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect isRound:(BOOL)isRound {
    
    CGImageRef sourceImageRef = [image CGImage];
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    if (isRound) {
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.5);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGRect rectNew = CGRectMake(0, 0, rect.size.width, rect.size.height);
        CGContextAddEllipseInRect(context, rectNew);
        CGContextClip(context);
        
        [newImage drawInRect:rectNew];
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return newImage;
}

- (void)updateRect:(CGRect) rect {

    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
