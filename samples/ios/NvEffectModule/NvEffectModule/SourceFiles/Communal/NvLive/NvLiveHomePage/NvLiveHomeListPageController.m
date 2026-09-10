//
//  NvLiveHomeListPageController.m
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/12.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import "NvLiveHomeListPageController.h"
#import "NvLiveHomeListCollectionCell.h"
#import "NvLiveViewController.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveAppEnv.h"
#import "Masonry.h"
#import "NvLiveARSceneUtils.h"

@interface NvLiveHomeListPageController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) Class liveClass;

@end

@implementation NvLiveHomeListPageController

-(instancetype)initWithLive:(Class)vcClass {
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.liveClass = vcClass;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [[NSMutableArray alloc]init];
    [self addTopView];
    [self addMainView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[NvLiveARSceneUtils imageNamed:@"MSHomeLive"] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(60);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(- NvScreen(kSafeAreaBottomHeight) - 50);
    }];
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
       [weakself configData];
    });
}

#pragma mark 生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark 配置数据
- (void)configData{
    NvLiveUserModel *userModel = [[NvLiveUserModel alloc]init];
    userModel.name = NvLocalString(@"meishe_user", @"美摄用户");
    userModel.userId = @"13131311";
    userModel.avatar = @"";
    
    NvLiveModel *model_1 = [[NvLiveModel alloc]init];
    model_1.pullUrl = @"";
    model_1.pushUrl = @"";
    model_1.title = NvLocalString(@"cheer_together", @"我们一起加油");
    model_1.coverUrl = @"MSUser1";
    model_1.online = YES;
    model_1.onlineUsers = @"10w";
    model_1.userInfo = userModel;
    
    [self.dataArray addObject:model_1];
    
    [self.collectionView reloadData];
}

#pragma mark 添加头部视图
- (void)addTopView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NvScreen(kWidth), NvScreen(kSafeAreaTopHeight))];
    [self.view addSubview:topView];
    
    NSArray* colors = @[(__bridge id)[UIColor nv_colorWithHexRGB:@"#9F7CFF"].CGColor,
                        (__bridge id)[UIColor nv_colorWithHexRGB:@"#5784FF"].CGColor];
    
    //创建CAGradientLayer 对象
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    //设置CAGradientLayer 对象的位置大小和承接视图等同
    gradientLayer.frame = CGRectMake(0, 0, topView.bounds.size.width, topView.bounds.size.height);
    //设置渐变色(即颜色数组)
    gradientLayer.colors = colors;
    //变化位置或变化点
    gradientLayer.locations = @[@(0.0f),@(1.0f)];
    //渐变方向
    gradientLayer.startPoint = CGPointMake(0, 0.3);
    gradientLayer.endPoint = CGPointMake(0.9, 0.8);
    gradientLayer.masksToBounds = YES;
    gradientLayer.cornerRadius = 0;
    //添加
    [topView.layer addSublayer:gradientLayer];
    
    UILabel *titleLabel = UILabel.new;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = NvLocalString(@"Hot", @"热门");
    titleLabel.textColor = UIColor.whiteColor;
    [topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(topView).offset(-10);
        make.centerX.equalTo(topView);
    }];
}

#pragma mark 添加主视图
- (void)addMainView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(189, 189);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, NvScreen(kSafeAreaTopHeight), NvScreen(kWidth), NvScreen(kHeight) - NvScreen(kSafeAreaTopHeight)) collectionViewLayout:layout];
    [self.collectionView registerClass:NvLiveHomeListCollectionCell.class forCellWithReuseIdentifier:@"NvLiveHomeListCollectionCell"];
    self.collectionView.backgroundColor = UIColor.whiteColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(15, 15, 0,  15* NvScreen(kScale));
    [self.view addSubview:self.collectionView];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NvLiveHomeListCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvLiveHomeListCollectionCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.dataArray[indexPath.item]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}


#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NvLiveModel *model = self.dataArray[indexPath.item];
//    MSPullVC *vc = [[MSPullVC alloc]init];
//    vc.liveModel = model;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)buttonClick{
    NvLiveUserModel *userModel = [[NvLiveUserModel alloc]init];
    userModel.name = @"美摄用户";
    userModel.userId = @"13131311";
    userModel.avatar = @"http://p3.pstatp.com/large/1279000618534e578d4a";
    
    NvLiveModel *model_1 = [[NvLiveModel alloc]init];
    model_1.pullUrl = @"";
    model_1.pushUrl = @"";
    model_1.title = @"我们一起加油";
    model_1.coverUrl = @"http://p3.pstatp.com/large/1279000618534e578d4a";
    model_1.online = YES;
    model_1.onlineUsers = @"10万";
    model_1.userInfo = userModel;
    
    id controller = [[self.liveClass alloc] initLiveModel:model_1];
    if (controller) {
        [self.navigationController pushViewController:controller animated:true];
    }
}

@end
