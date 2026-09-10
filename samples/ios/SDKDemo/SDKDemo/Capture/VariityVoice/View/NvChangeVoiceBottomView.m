//
//  NvChangeVoiceBottomView.m
//  SDKDemo
//
//  Created by ms on 2021/3/10.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvChangeVoiceBottomView.h"
#import "NVHeader.h"
#import "NvChangeVoiceBottomCell.h"
#import "NvVoiceBottomModel.h"

static NSString *const NvChangeVoiceBottomCellID = @"NvChangeVoiceBottomCellID";
@interface NvChangeVoiceBottomView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *bottomView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *fxArray;
@end



@implementation NvChangeVoiceBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDate];
        [self configUI];
    }
    return self;
}

#pragma mark - 数据初始化
/*
 数据初始化
 Data initialization
 
 */
-(void)initDate{
    NSArray *unselected = @[@"ChangeVoiceNone",@"ManVoice",@"reverberation", @"ChangeVoiceElectronics",@"Auditorium",@"womenVoice",@"ChangeVoiceCartoon",@"Echoes",@"Monster"];
    NSArray *selected = @[@"unselectedChangeVoiceNone",@"unselectedManVoice",@"unselectedreverberation", @"unselectedChangeVoiceElectronics",@"unselectedAuditorium",@"unselectedwomenVoice",@"unselectedChangeVoiceCartoon",@"unselectedEchoes",@"unselectedMonster"];
    NSArray *titles = @[NvLocalString(@"None", @"无"),NvLocalString(@"Male", @"男声"),NvLocalString(@"Reverb", @"混响"),NvLocalString(@"Wahwah", @"电子"),NvLocalString(@"Hall", @"礼堂"),NvLocalString(@"Female", @"女声"),NvLocalString(@"Catoon", @"卡通"),NvLocalString(@"Echo", @"回声"),NvLocalString(@"Monster", @"怪兽")];
    
    self.dataArray = [NSMutableArray array];
    for (int i = 0; i < selected.count; i ++) {
        NvVoiceBottomModel *model = [NvVoiceBottomModel new];
        model.isSelected = NO;
        if (i==0) {
            model.isSelected = YES;
        }
        model.selectedImage = selected[i];
        model.unselectedImage = unselected[i];
        model.title = titles[i];
        [self.dataArray addObject:model];
    }
    
    self.fxArray = @[@"none",@"Male Voice", @"Audio Reverb",@"Audio Wahwah",@"Fast Cartoon Voice",@"Female Voice",@"Cartoon Voice",@"Audio Echo",@"Monster Voice"];
}

#pragma mark - 界面初始化
/*
 界面初始化
 Interface initialization
 
 */
-(void)configUI{
    
    UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc]init];
    layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout1.itemSize = CGSizeMake(55 *SCREENSCALE, 60.0 *SCREENSCALE);
    layout1.minimumLineSpacing = 3*SCREENSCALE;
    layout1.minimumInteritemSpacing = 0;
    _bottomView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 * SCREENSCALE, 25.0 *SCREENSCALE, SCREENWIDTH, 90*SCREENSCALE) collectionViewLayout:layout1];
    _bottomView.delegate = self;
    _bottomView.dataSource = self;
    _bottomView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_bottomView];
    [_bottomView registerClass:[NvChangeVoiceBottomCell class] forCellWithReuseIdentifier:NvChangeVoiceBottomCellID];
    _bottomView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UICollectionView Delegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NvChangeVoiceBottomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NvChangeVoiceBottomCellID forIndexPath:indexPath];
    cell.bottomModel = self.dataArray[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    for (int i = 0; i < self.dataArray.count; i ++) {
        NvVoiceBottomModel *model = self.dataArray[i];
        if (i == indexPath.item) {
            model.isSelected = YES;
        }else{
            model.isSelected = NO;
        }
    }
    [collectionView reloadData];
    
    if (self.selectItemClick) {
        self.selectItemClick(indexPath.item, self.fxArray[indexPath.item]);
    }
    
}

@end

