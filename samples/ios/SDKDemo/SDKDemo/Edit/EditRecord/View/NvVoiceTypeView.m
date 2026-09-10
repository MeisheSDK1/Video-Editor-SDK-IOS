//
//  NvVoiceTypeView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvVoiceTypeView.h"
#import "NVHeader.h"
#import "NvVoiceTypeCollectionViewCell.h"

@interface NvVoiceTypeView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UIButton *okButton;

@property (nonatomic, strong) UIView *line;

@end

@implementation NvVoiceTypeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.dataSource = [NSMutableArray array];
        NvVoiceItem *noneItem = [NvVoiceItem new];
        noneItem.name = NvLocalString(@"None", @"无");
        noneItem.imagePath = @"NvsFilterNone";
        noneItem.isSelect = YES;
        [self.dataSource addObject:noneItem];
        NvVoiceItem *femaleVoiceItem = [NvVoiceItem new];
        femaleVoiceItem.name = NvLocalString(@"Female voice", @"女声");
        femaleVoiceItem.builtinName = @"Female Voice";
        femaleVoiceItem.imagePath = @"NvfemaleVoice";
        [self.dataSource addObject:femaleVoiceItem];
        NvVoiceItem *hallItem = [NvVoiceItem new];
        hallItem.name = NvLocalString(@"Hall", @"礼堂");
        hallItem.builtinName = @"Fast Cartoon Voice";
        hallItem.imagePath = @"Nvhall";
        [self.dataSource addObject:hallItem];
        NvVoiceItem *reverberationItem = [NvVoiceItem new];
        reverberationItem.name = NvLocalString(@"Reverb", @"混响");
        reverberationItem.imagePath = @"Nvreverberation";
        reverberationItem.builtinName = @"Audio Reverb";
        [self.dataSource addObject:reverberationItem];
        NvVoiceItem *electronicItem = [NvVoiceItem new];
        electronicItem.name = NvLocalString(@"Wahwah", @"电子");
        electronicItem.builtinName = @"Audio Wahwah";
        electronicItem.imagePath = @"Nvelectronic";
        [self.dataSource addObject:electronicItem];
        NvVoiceItem *maleVoiceItem = [NvVoiceItem new];
        maleVoiceItem.name = NvLocalString(@"Male Voice", @"男声");
        maleVoiceItem.imagePath = @"NvmaleVoice";
        maleVoiceItem.builtinName = @"Male Voice";
        [self.dataSource addObject:maleVoiceItem];
        NvVoiceItem *cartoonItem = [NvVoiceItem new];
        cartoonItem.name = NvLocalString(@"Cartoon", @"卡通");
        cartoonItem.builtinName = @"Cartoon Voice";
        cartoonItem.imagePath = @"Nvcartoon";
        [self.dataSource addObject:cartoonItem];
        NvVoiceItem *echoItem = [NvVoiceItem new];
        echoItem.name = NvLocalString(@"Echo", @"回声");
        echoItem.imagePath = @"Nvecho";
        echoItem.builtinName = @"Audio Echo";
        [self.dataSource addObject:echoItem];
        NvVoiceItem *monsterItem = [NvVoiceItem new];
        monsterItem.name = NvLocalString(@"Monster", @"怪兽");
        monsterItem.builtinName = @"Monster Voice";
        monsterItem.imagePath = @"Nvmonster";
        [self.dataSource addObject:monsterItem];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(49*SCREENSCALE, 76*SCREENSCALE);
        flowLayout.minimumLineSpacing = 26*SCREENSCALE;
        flowLayout.minimumInteritemSpacing = 0*SCREENSCALE;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 13 * SCREENSCALE, 0, 0);
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[NvVoiceTypeCollectionViewCell class] forCellWithReuseIdentifier:@"NvVoiceTypeCollectionViewCell"];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0*SCREENSCALE));
            make.top.equalTo(self.mas_top).offset(5*SCREENSCALE);
            make.right.equalTo(@(-12*SCREENSCALE));
            make.height.equalTo(@(76*SCREENSCALE));
        }];
        [self.collectionView reloadData];
        self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        [self addSubview:self.okButton];
        [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(@(-15*SCREENSCALE));
            }
            make.centerX.equalTo(self);
            make.width.equalTo(@(SCREENWIDTH));
            make.height.equalTo(@(20*SCREENSCALE));
        }];
        __weak typeof(self)weakSelf = self;
        [self.okButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(voiceTypeView:okClick:)]) {
                [weakSelf.delegate voiceTypeView:weakSelf okClick:weakSelf.okButton];
            }
        }];
        
        self.line = [UIView new];
        self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.okButton.mas_top).offset(-12*SCREENSCALE);
        }];
    }
    return self;
}

-(void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvVoiceTypeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvVoiceTypeCollectionViewCell" forIndexPath:indexPath];
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvVoiceItem *item in self.dataSource) {
        item.isSelect = NO;
    }
    NvVoiceItem *item = self.dataSource[indexPath.item];
    item.isSelect = YES;
    [self.collectionView reloadData];
    if ([self.delegate respondsToSelector:@selector(voiceTypeView:didSelectItem:)]) {
        [self.delegate voiceTypeView:self didSelectItem:self.dataSource[indexPath.item]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
