//
//  NvStickerCollectionViewCell.h
//  ARFace
//
//  Created by xuewen on 11/1/17.
//  Copyright © 2017 CDV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NvStickerModel.h"

@interface NvStickerCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *stickerCover;

-(void)loadModel:(id<NvStickerModelDelegate>)model;

@end
