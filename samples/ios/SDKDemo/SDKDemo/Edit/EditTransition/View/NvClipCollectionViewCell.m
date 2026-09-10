//
//  NvClipCollectionViewCell.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/6/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvClipCollectionViewCell.h"
#import "NVHeader.h"
#import <UIButton+YYWebImage.h>
#import <Photos/Photos.h>
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvClipCollectionViewCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) dispatch_queue_t getImageQueue;

@end

@implementation NvClipCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _getImageQueue = dispatch_queue_create("getImageQueue", DISPATCH_QUEUE_SERIAL);
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.imageView = [UIImageView new];
        self.imageView.layer.cornerRadius = 4 * SCREENSCALE;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.nameLabel = [UILabel nv_labelWithText:@"无" fontSize:15 textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
        self.transitionButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:[UIImage new]];
        self.transitionButton.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        self.transitionButton.layer.cornerRadius = 3 * SCREENSCALE;
        self.transitionButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
        [self.contentView addSubview:self.transitionButton];
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(@0);
            make.width.offset(71*SCREENSCALE);
            make.height.offset(41*SCREENSCALE);
        }];
        [self.transitionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right).offset(8 * SCREENSCALE);
            make.centerY.equalTo(self.contentView);
            make.height.offset(18*SCREENSCALE);
            make.width.offset(18*SCREENSCALE);
        }];
    }
    return self;
}

- (void)renderCellWithClipItem:(NvClipItem *)item {
    if (item.isSelect) {
        self.transitionButton.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.transitionButton.layer.borderWidth = 1;
    } else {
        self.transitionButton.layer.borderWidth = 0;
    }
    if (item.isLoading && item.image) {
        self.imageView.image = item.image;
    }else{
        if (item.isImage) {
            if (item.isPhotoAlbum) {
                PHFetchResult<PHAsset *> *phresult = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:item.localIdentifier] options:nil];
                if (phresult.count > 0) {
                    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
                    requestOptions.synchronous = NO;
                    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                    PHAsset *phasset = phresult.lastObject;
                    __weak typeof(self)weakSelf = self;
                    [[PHImageManager defaultManager] requestImageForAsset:phasset
                                                               targetSize:CGSizeMake(71, 41)
                                                              contentMode:PHImageContentModeAspectFill
                                                                  options:requestOptions
                                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                weakSelf.imageView.image = result;
                                                                item.image = result;
                                                                item.isLoading = YES;
                                                            }
                     ];
                }
            }else{
                item.isLoading = YES;
                self.imageView.image = [UIImage imageWithContentsOfFile:item.localIdentifier];
                item.image = self.imageView.image;
            }
        }else{
            item.isLoading = YES;
            if ([item.videoPath hasSuffix:@"gif"]) {
                self.imageView.image = [UIImage imageWithContentsOfFile:item.videoPath];
                item.image = self.imageView.image;
            } else {
                [NvToast showLoadingInView:self];
                dispatch_async(self.getImageQueue, ^{
                    NvsVideoFrameRetriever *Retriever = [[NvsStreamingContext sharedInstance] createVideoFrameRetriever:item.videoPath];
                    UIImage *image = [Retriever getFrameAtTime:item.trimIn videoFrameHeightGrade:NvsVideoFrameHeightGrade480];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = image;
                        item.image = image;
                        [NvToast dismissInView:self];
                    });
                });
            }
            
        }
    }
//    self.imageView.image = item.image;
    if (item.isLast) {
        self.transitionButton.hidden = YES;
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(@0);
            make.height.equalTo(@(42*SCREENSCALE));
        }];
    } else {
        self.transitionButton.hidden = NO;
        if ([item.transitionImageUrl containsString:@"http"]) {
            [self.transitionButton yy_setImageWithURL:[NSURL URLWithString:item.transitionImageUrl] forState:UIControlStateNormal placeholder:nil];
            
        }else{
            [self.transitionButton setImage:[UIImage imageNamed:item.transitionImageUrl] forState:UIControlStateNormal];
        }
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(@0);
            make.height.equalTo(@(42*SCREENSCALE));
            make.right.equalTo(@(-30*SCREENSCALE));
        }];
    }
    self.nameLabel.text = item.name;
}

@end
