//
//  CollectionLoopView.m
//  ScrollViewLoop
//
//  Created by 刘东旭 on 2019/9/25.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import "CollectionLoopView.h"
#import "LoopCollectionViewCell.h"

#define MaxCellCount 10000

@interface CollectionLoopView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation CollectionLoopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = self.bounds.size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.pagingEnabled = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[LoopCollectionViewCell class] forCellWithReuseIdentifier:@"LoopCollectionViewCell"];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)setContents:(NSArray<NvLoopViewModel *> *)contents {
    _contents = contents;
    if (_contents.count == 0) {
        [self.timer invalidate];
        return;
    }
    self.collectionView.contentOffset = CGPointMake((MaxCellCount/2-1)*self.bounds.size.width, 0);
    
    [self.timer invalidate];
    [self startTimer];
}

- (void)stopTimer {
    [self.timer invalidate];
}

- (void)startTimer {
    self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)timerAction:(NSTimer *)timer {
    if (self.collectionView.contentOffset.x >= self.collectionView.frame.size.width*(MaxCellCount-1) || self.collectionView.contentOffset.x <= 0) {
        self.collectionView.contentOffset = CGPointMake((MaxCellCount/2-1)*self.collectionView.frame.size.width, 0);
    } else {
        int64_t ofs = (int64_t)(self.collectionView.contentOffset.x+self.collectionView.frame.size.width)%(int64_t)(self.collectionView.frame.size.width);
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x+self.collectionView.frame.size.width-ofs, 0) animated:YES];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MaxCellCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LoopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LoopCollectionViewCell" forIndexPath:indexPath];
    if (self.contents.count != 0) {
        [cell setModel:self.contents[indexPath.item%self.contents.count]];
    } else {
        NSLog(@"self.contents.count == 0");
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionLoopView:didSelectIndex:)]) {
        if (self.contents.count == 0) {
            NSLog(@"self.contents.count == 0");
        } else {
            [self.delegate collectionLoopView:self didSelectIndex:(unsigned int)(indexPath.item%self.contents.count)];
        }
        
    }
}

@end
