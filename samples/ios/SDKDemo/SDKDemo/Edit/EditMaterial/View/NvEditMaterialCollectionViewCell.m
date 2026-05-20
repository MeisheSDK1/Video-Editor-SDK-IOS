//
//  NvEditMaterialCollectionViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditMaterialCollectionViewCell.h"
#import "NVHeader.h"
#import <Photos/Photos.h>
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvEditMaterialCollectionViewCell ()

@property (nonatomic, strong) UIImageView *previewView;
@property (nonatomic, strong) dispatch_queue_t getImageQueue;

@end


@implementation NvEditMaterialCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _getImageQueue = dispatch_queue_create("getImageQueue", DISPATCH_QUEUE_SERIAL);
        [self addSubViews];
    }
    return self;
}

- (void)setCoverImage:(UIImage *)coverImage{
    _coverImage = coverImage;
    self.previewView.image = coverImage;
}

- (void)setModel:(NvEditDataModel *)model{
    _model = model;
    if (model.isLoading && model.thumImage) {
        self.previewView.image = model.thumImage;
        return;
    }
    if (model.isImage) {
        if (model.isPhotoAlbum) {
            if ([model.localIdentifier hasSuffix:@"gif"]) {
                NSData *data = [NSData dataWithContentsOfFile:model.localIdentifier];
                self.previewView.image = [UIImage imageWithData:data];
                model.thumImage = self.previewView.image;
            } else {
                BOOL useOriginalFile = [model.localIdentifier hasPrefix:@"meicam://"];
                NSString *localIdentifier = useOriginalFile ? model.videoPath : model.localIdentifier;
                PHFetchResult<PHAsset *> *phresult = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:localIdentifier] options:nil];
                if (phresult.count <= 0) {
                    localIdentifier = useOriginalFile ? model.localIdentifier : model.videoPath;
                    phresult = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:localIdentifier] options:nil];
                }
                if (phresult.count > 0) {
                    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
                    requestOptions.version = useOriginalFile ? PHImageRequestOptionsVersionOriginal : PHImageRequestOptionsVersionCurrent;
                    requestOptions.synchronous = NO;
                    PHAsset *phasset = phresult.lastObject;
                    [[PHImageManager defaultManager] requestImageForAsset:phasset
                                                               targetSize:CGSizeMake(180, 320)
                                                              contentMode:PHImageContentModeAspectFill
                                                                  options:requestOptions
                                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        self.previewView.image = result;
                        model.thumImage = result;
                        model.isLoading = YES;
                    }
                    ];
                }
            }
        }else{
            model.isLoading = YES;
            self.previewView.image = [UIImage imageWithContentsOfFile:model.localIdentifier];
            model.thumImage = self.previewView.image;
        }
    }else{
        model.isLoading = YES;
        if ([model.videoPath hasSuffix:@"gif"]) {
            NSData *data = [NSData dataWithContentsOfFile:model.videoPath];
            self.previewView.image = [UIImage imageWithData:data];
            model.thumImage = self.previewView.image;
        } else {
            [NvToast showLoadingInView:self];
            NvsStreamingContext *context = [NvSDKUtils getSDKContext];
            dispatch_async(self.getImageQueue, ^{
                NvsVideoFrameRetriever *Retriever = [context createVideoFrameRetriever:model.videoPath];
                UIImage *image = [Retriever getFrameAtTime:model.trimIn videoFrameHeightGrade:NvsVideoFrameHeightGrade480];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.previewView.image = image;
                    model.thumImage = image;
                    [NvToast dismissInView:self];
                });
            });
        }
    }
}

- (void)addSubViews{
    
    self.previewView = [[UIImageView alloc]init];
    self.previewView.image = NvImageNamed(@"EditMaterialImageDefault");
    self.previewView.contentMode = UIViewContentModeScaleAspectFill;
    self.previewView.clipsToBounds = YES;
    
    self.leftView = [[UIImageView alloc]init];
    self.leftView.image = NvImageNamed(@"NvEditpreviewLine");
    
    self.rightView = [[UIImageView alloc]init];
    self.rightView.image = NvImageNamed(@"NvEditpreviewLine");
    
    self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftBtn setImage:NvImageNamed(@"NvEditpreviewAdd") forState:UIControlStateNormal];
    
    
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightBtn setImage:NvImageNamed(@"NvEditpreviewAdd") forState:UIControlStateNormal];
    
    [self addSubview:self.previewView];
    [self.previewView addSubview:self.leftView];
    [self.previewView addSubview:self.rightView];
    [self addSubview:self.leftBtn];
    [self addSubview:self.rightBtn];
    
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.equalTo(self.mas_height);
        make.left.equalTo(self.mas_left);
    }];
    
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.previewView.mas_height);
        make.width.offset(8 * SCREENSCALE);
        make.left.equalTo(self.previewView.mas_left);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.previewView.mas_height);
        make.width.offset(8 * SCREENSCALE);
        make.right.equalTo(self.previewView.mas_right);
    }];
    
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(40 * SCREENSCALE);
        make.width.offset(40 * SCREENSCALE);
        make.centerY.equalTo(self.leftView.mas_centerY);
        make.centerX.equalTo(self.leftView.mas_centerX);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(40 * SCREENSCALE);
        make.width.offset(40 * SCREENSCALE);
        make.centerY.equalTo(self.rightView.mas_centerY);
        make.centerX.equalTo(self.rightView.mas_centerX);
    }];
    __weak typeof(self)weakSelf = self;
    [self.leftBtn nv_BtnClickHandler:^{
        if ([weakSelf.delegate respondsToSelector:@selector(addClipForIndex:)]) {
            [weakSelf.delegate addClipForIndex:weakSelf.index];
        }
    }];
    
    [self.rightBtn nv_BtnClickHandler:^{
        if ([weakSelf.delegate respondsToSelector:@selector(addClipForIndex:)]) {
            [weakSelf.delegate addClipForIndex:weakSelf.index+1];
        }
    }];
    
    if (self.currentIndex == self.index) {
        self.leftView.hidden = NO;
        self.rightView.hidden = NO;
        self.leftBtn.hidden = NO;
        self.rightBtn.hidden = NO;
    } else {
        self.leftView.hidden = YES;
        self.rightView.hidden = YES;
        self.leftBtn.hidden = YES;
        self.rightBtn.hidden = YES;
    }
}

- (void)setAddButtonHidden:(Boolean)hidden {
    self.leftView.hidden = hidden;
    self.rightView.hidden = hidden;
    self.leftBtn.hidden = hidden;
    self.rightBtn.hidden = hidden;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}


@end
