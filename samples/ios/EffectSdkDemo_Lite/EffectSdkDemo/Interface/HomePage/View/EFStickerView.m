//
//  EFStickerView.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#import "EFStickerView.h"

@interface EFStickerView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *stickerCollectionView;

@end

@implementation EFStickerView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    self.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer* _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBg:)];
    _tap.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self addGestureRecognizer:_tap];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(60*SCREENSCALE, 60*SCREENSCALE);
    layout.minimumLineSpacing = 30*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 16*SCREENSCALE, 0, 0);
    self.stickerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 62*SCREENSCALE - SafeAreaBottomHeight, SCREENWIDTH, 60*SCREENSCALE) collectionViewLayout:layout];
    self.stickerCollectionView.delegate = self;
    self.stickerCollectionView.dataSource = self;
    self.stickerCollectionView.alwaysBounceHorizontal = YES;
    self.stickerCollectionView.showsHorizontalScrollIndicator = NO;
    self.stickerCollectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.stickerCollectionView];
    [self.stickerCollectionView registerClass:[NvStickerCollectionViewCell class] forCellWithReuseIdentifier:@"NvStickerCollectionViewCell"];
    
    self.stickerCollectionView.hidden = YES;
}

-(void)setStickerArray:(NSArray<id<NvStickerModelDelegate>> *)stickerArray{
    if (_stickerArray != stickerArray) {
        _stickerArray = stickerArray;
        self.stickerCollectionView.hidden = NO;
    }
}

-(void)tapBg:(UITapGestureRecognizer*)tap{
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerViewDidDismiss:)]) {
        [self.delegate stickerViewDidDismiss:self];
    }
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view != self/* || [touch.view.superview isKindOfClass:NvStickerCollectionViewCell.class] || [touch.view.superview.superview isKindOfClass:UICollectionView.class]*/) {
        return NO;
    }
    
    return YES;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        return _stickerArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
        NvStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvStickerCollectionViewCell" forIndexPath:indexPath];
    
    id<NvStickerModelDelegate> stickerModel = [_stickerArray objectAtIndex:indexPath.row];
    [cell loadModel:stickerModel];
        return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        id<NvStickerModelDelegate> stickerModel = [_stickerArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSeletedItem:stickerView:)]) {
        [self.delegate didSeletedItem:stickerModel stickerView:self];
    }
}

@end
