//
//  NvAdjustFxParamView.m
//  SDKDemo
//
//  Created by Meishe on 2022/8/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvAdjustFxParamView.h"
#import "NvAdjustFxParamCell.h"
#import "NvsExpressionParam.h"
#import "NvBubbleLabel.h"
#import "BLItemSlider.h"
#import "NvAdjustFxParamNewCell.h"
#import "NvCustomColorControl.h"

@interface NvAdjustFxParamView ()<UICollectionViewDelegate,UICollectionViewDataSource,NvAdjustFxParamCellDelegate>
@property (nonatomic, strong) NSArray *fxParams;
@property (nonatomic, strong) NSDictionary *transDic;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NvBubbleLabel *bubbleLabel;
@end

@implementation NvAdjustFxParamView

- (instancetype)initWithFrame:(CGRect)frame fxParams:(NSArray *)fxParams translation:(NSDictionary *)translation {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGBA:@"#00000014"];
        self.dataSource = [NSMutableArray array];
        self.fxParams = fxParams;
        self.transDic = translation;
        [self updateDatasource];
        [self addSubviews];
    }
    return self;
}

- (void)updateFxParams:(NSArray *)fxParams translation:(NSDictionary *)translation {
    self.fxParams = fxParams;
    self.transDic = translation;
    [self updateDatasource];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
}

- (void)updateDatasource {
    [self.dataSource removeAllObjects];
    for (NvsExpressionParam *item in self.fxParams) {
        NvAjustFxParamModel *model = [NvAjustFxParamModel new];
        model.type = (NvAjustFxParamCategory)item.type;
        model.name = item.name;
        model.translationName = self.transDic[item.name];
        if (model.type == NvAjustFxParamCategoryInt) {
            NvsExpressionIntParam *expression = (NvsExpressionIntParam *)item;
            model.defaultValue = expression.intParam.defaultValue;
            model.minValue = expression.intParam.minValue;
            model.maxValue = expression.intParam.maxValue;
            model.currentValue = model.defaultValue;
        }else if (model.type == NvAjustFxParamCategoryFloat){
            NvsExpressionFloatParam *expression = (NvsExpressionFloatParam *)item;
            model.defaultValue = expression.floatParam.defaultValue;
            model.minValue = expression.floatParam.minValue;
            model.maxValue = expression.floatParam.maxValue;
            model.currentValue = model.defaultValue;
        }else if (model.type == NvAjustFxParamCategoryColor){
            NvsExpressionColorParam *expression = (NvsExpressionColorParam *)item;
            model.r = expression.colorParam.defaultColor.r;
            model.g = expression.colorParam.defaultColor.g;
            model.b = expression.colorParam.defaultColor.b;
            model.a = expression.colorParam.defaultColor.a;
        }
        NSLog(@"可调参数 Adjustable parameter%@  min %f max %f",model.name,model.minValue,model.maxValue);
        [self.dataSource addObject:model];
    }
}

- (void)updateInfoFxParams:(NSArray *)fxParams{
    [self.dataSource removeAllObjects];
    for (NvAjustFxParamModel *item in fxParams) {
        NvAjustFxParamModel *model = [NvAjustFxParamModel new];
        model.type = item.type;
        model.name = item.name;
        model.translationName = self.transDic[item.name];
        if (model.type == NvAjustFxParamCategoryInt) {
            model.defaultValue = item.defaultValue;
            model.minValue = item.minValue;
            model.maxValue = item.maxValue;
            model.currentValue = item.currentValue;
        }else if (model.type == NvAjustFxParamCategoryFloat){
            model.defaultValue = item.defaultValue;
            model.minValue = item.minValue;
            model.maxValue = item.maxValue;
            model.currentValue = item.currentValue;
        }else if (model.type == NvAjustFxParamCategoryColor){
            model.r = item.r;
            model.g = item.g;
            model.b = item.b;
            model.a = item.a;
        }
        [self.dataSource addObject:model];
    }
    
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
}

- (void)addSubviews {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(self.bounds.size.width, 35*SCREENSCALE);
    layout.minimumLineSpacing = 12*SCREENSCALE;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[NvAdjustFxParamCell class] forCellWithReuseIdentifier:@"NvAdjustFxParamViewCell"];
    [self.collectionView registerClass:[NvAdjustFxParamNewCell class] forCellWithReuseIdentifier:@"NvAdjustFxParamNewCell"];
    
    [self addSubview:self.collectionView];
    
    self.bubbleLabel = [[NvBubbleLabel alloc] init];
    self.bubbleLabel.font = [UIFont systemFontOfSize:13];
    self.bubbleLabel.textAlignment = NSTextAlignmentCenter;
    self.bubbleLabel.textColor = [UIColor blackColor];
    self.bubbleLabel.backgroundColor = [UIColor clearColor];
    self.bubbleLabel.hidden = YES;
    [self addSubview:self.bubbleLabel];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.newStyle){
        NvAdjustFxParamNewCell *cell = (NvAdjustFxParamNewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"NvAdjustFxParamNewCell" forIndexPath:indexPath];
        cell.delegate = self;
        NvAjustFxParamModel *model = self.dataSource[indexPath.item];
        [cell renderCellWithModel:model];
        return cell;
    }
    NvAdjustFxParamCell *cell = (NvAdjustFxParamCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"NvAdjustFxParamViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    NvAjustFxParamModel *model = self.dataSource[indexPath.item];
    [cell renderCellWithModel:model];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - NvAdjustFxParamCellDelegate

- (void)nvAdjustFxParamCell:(NvAdjustFxParamCell *)cell valueChanged:(NvAjustFxParamModel *)model {
    if (self.newStyle) {
        self.bubbleLabel.hidden = NO;
        self.bubbleLabel.text = cell.slider.valueLabel.text;
        if ([cell isKindOfClass:NvAdjustFxParamNewCell.class]){
            NvAdjustFxParamNewCell *newCell = (NvAdjustFxParamNewCell *)cell;
            if (newCell.changeColor){
                self.bubbleLabel.text = newCell.colorStr;
            }
            
            [self.bubbleLabel sizeToFit];
            CGSize size = self.bubbleLabel.size;
            self.bubbleLabel.frame = CGRectMake(0, 0, size.width+20*SCREENSCALE, 28*SCREENSCALE);
            
            CGPoint point = CGPointZero;
            if (newCell.changeColor){
                point = [cell convertPoint:cell.colorSlider.imageView.center toView:self];
                point.x += CGRectGetMinX(cell.colorSlider.frame);
                point.y -= cell.colorSlider.imageView.frame.size.height;
            }else{
                point = [cell convertPoint:cell.slider.valueLabel.center toView:self];
                point.x += CGRectGetMinX(cell.slider.frame);
            }
            
            self.bubbleLabel.center = point;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(nvAdjustFxParamView:valueChanged:)]) {
        [self changeModel:model];
        [self.delegate nvAdjustFxParamView:self valueChanged:self.dataSource];
    }
}

- (void)nvAdjustFxParamCell:(NvAdjustFxParamCell *)cell endChange:(NvAjustFxParamModel *)model {
    if ([self.delegate respondsToSelector:@selector(nvAdjustFxParamView:endChange:)]) {
        [self changeModel:model];
        [self.delegate nvAdjustFxParamView:self endChange:self.dataSource];
    }
    
    if (self.newStyle){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayaf) object:nil];
        [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
    }
}

- (void)delayaf{
    self.bubbleLabel.hidden = YES;
}

- (void)cancelAnimation{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayaf) object:nil];
    [self delayaf];
}

- (void)changeModel:(NvAjustFxParamModel *)model {
    for (NvAjustFxParamModel *item in self.dataSource) {
        if ([item.name isEqualToString:model.name]) {
            if (item.type == NvAjustFxParamCategoryColor) {
                item.r = model.r;
                item.g = model.g;
                item.b = model.b;
                item.a = model.a;
            }else if (item.type == NvAjustFxParamCategoryInt || item.type == NvAjustFxParamCategoryFloat){
                item.currentValue = model.currentValue;
            }
            
        }
    }
}

@end
