//
//  NvAlbumWebmViewController.m
//  NvAlbum
//
//  Created by MS on 2022/2/16.
//

#import "NvAlbumWebmViewController.h"
#import "UIColor+NvColor.h"
#import <Masonry/Masonry.h>

@interface NvAlbumWebmViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *>*dataSource;
@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *>*selectItems;
@end

@implementation NvAlbumWebmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addSubviews];
    [self loadData:self.sourcePath];
    [self.tableView reloadData];
}

- (void)addSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AlbumWebmCellId"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-100);
        } else {
            // Fallback on earlier versions
            make.top.mas_equalTo(self.view.mas_top);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
        }
        
    }];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor yellowColor]];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(finishBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.layer.cornerRadius = 30.f;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(10);
        make.height.mas_equalTo(60);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.left.equalTo(self.view.mas_left).offset(20);
    }];
}

- (void)finishBtnClicked {
    if ([self.delegate respondsToSelector:@selector(nvAlbumWebmViewController:selectAssets:)]) {
        [self.delegate nvAlbumWebmViewController:self selectAssets:self.selectItems];
    }
}

- (void)loadData:(NSString *)path {
    self.dataSource = [NSMutableArray array];
    self.selectItems = [NSMutableArray array];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (![manager fileExistsAtPath:path isDirectory:&isDir]) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
    for (NSString *fileName in enumerator.allObjects) {
        NvAlbumAsset *asset = [NvAlbumAsset new];
        asset.isSelected = NO;
        asset.albumVideoPath = fileName;
        [self.dataSource addObject:asset];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumWebmCellId" forIndexPath:indexPath];
    NvAlbumAsset *asset = self.dataSource[indexPath.row];
    cell.textLabel.text = asset.albumVideoPath;
    if (asset.isSelected) {
        cell.backgroundColor = [UIColor blueColor];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NvAlbumAsset *asset = self.dataSource[indexPath.row];
    if ([self.selectItems containsObject:asset]) {
        asset.isSelected = NO;
        [self.selectItems removeObject:asset];
    }else{
        asset.isSelected = YES;
        [self.selectItems addObject:asset];
    }
    [self.tableView reloadData];
}

#pragma mark - keep portrait
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return  UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - lazyload

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _tableView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
