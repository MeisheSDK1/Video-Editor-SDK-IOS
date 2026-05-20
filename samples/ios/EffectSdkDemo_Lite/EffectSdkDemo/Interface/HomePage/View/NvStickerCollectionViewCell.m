//
//  NvStickerCollectionViewCell.m
//  ARFace
//
//  Created by xuewen on 11/1/17.
//  Copyright © 2017 CDV. All rights reserved.
//

#import "NvStickerCollectionViewCell.h"
#import "Masonry.h"



@interface NvStickerCollectionViewCell ()

@end

@implementation NvStickerCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.stickerCover = [[UIImageView alloc] initWithFrame:frame];
        self.stickerCover.contentMode =  UIViewContentModeScaleAspectFill;
        [self addSubview:self.stickerCover];
        
        [self.stickerCover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.layer.cornerRadius = 30*SCREENSCALE;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 0;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)loadModel:(id<NvStickerModelDelegate>)model{
    self.stickerCover.image = model.coverImageObject;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [UIColor orangeColor];
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor colorWithRed:0x3d/255.0f green:0xb5/255.0f blue:0xfe/255.0f alpha:1.0] CGColor];
    }else{
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 0;
    }
}

@end
