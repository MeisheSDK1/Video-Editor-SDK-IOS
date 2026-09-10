// Objective-C
#import "PhotoPickerViewController.h"

@interface PhotoPickerCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *videoMark;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation PhotoPickerCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];

        _videoMark = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width-28, self.contentView.bounds.size.height-20, 24, 16)];
        _videoMark.text = @"🎬";
        _videoMark.font = [UIFont systemFontOfSize:14];
        _videoMark.textAlignment = NSTextAlignmentRight;
        _videoMark.hidden = YES;
        [self.contentView addSubview:_videoMark];

        _selectView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width-28, 4, 24, 24)];
        _selectView.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1];
        _selectView.layer.cornerRadius = 12;
        _selectView.hidden = YES;
        [self.contentView addSubview:_selectView];

        _selectLabel = [[UILabel alloc] initWithFrame:_selectView.bounds];
        _selectLabel.textColor = [UIColor whiteColor];
        _selectLabel.font = [UIFont boldSystemFontOfSize:14];
        _selectLabel.textAlignment = NSTextAlignmentCenter;
        [_selectView addSubview:_selectLabel];

        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(4, self.contentView.bounds.size.height-6, self.contentView.bounds.size.width-8, 2)];
        _progressView.progress = 0;
        _progressView.hidden = YES;
        [self.contentView addSubview:_progressView];
    }
    return self;
}
@end

typedef NS_ENUM(NSUInteger, PhotoPickerType) {
    PhotoPickerTypeAll,
    PhotoPickerTypeImage,
    PhotoPickerTypeVideo
};

@interface PhotoPickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<PHAsset *> *assets;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedAssets;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) PhotoPickerType pickerType;
@property (nonatomic, strong) NSArray<NSString *> *typeTitles;
@property (nonatomic, strong) UIView *topBar;
@end

@implementation PhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.typeTitles = @[@"All", @"Images", @"Videos"];
    self.pickerType = PhotoPickerTypeAll;
    self.selectedAssets = [NSMutableArray array];
    self.imageManager = [[PHCachingImageManager alloc] init];

    // Top bar
    self.topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    self.topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topBar];

    CGFloat btnW = self.view.bounds.size.width/3;
    for (int i=0; i<3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(i*btnW, 20, btnW, 40);
        [btn setTitle:self.typeTitles[i] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(typeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self.topBar addSubview:btn];
    }

    // Done button
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(self.view.bounds.size.width-80, 24, 70, 32);
    doneBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneBtn.layer.cornerRadius = 16;
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:doneBtn];

    // CollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = (self.view.bounds.size.width-5*5)/4;
    layout.itemSize = CGSizeMake(itemW, itemW);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height-60) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[PhotoPickerCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];

    [self fetchAssets];
}

- (void)typeChanged:(UIButton *)sender {
    self.pickerType = sender.tag;
    [self fetchAssets];
}

- (void)fetchAssets {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    switch (self.pickerType) {
        case PhotoPickerTypeImage:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
            break;
        case PhotoPickerTypeVideo:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
            break;
        default:
            break;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
    NSMutableArray *arr = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        [arr addObject:asset];
    }];
    self.assets = arr;
    [self.selectedAssets removeAllObjects];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    PHAsset *asset = self.assets[indexPath.item];
    cell.videoMark.hidden = asset.mediaType != PHAssetMediaTypeVideo;
    cell.selectView.hidden = YES;
    cell.progressView.hidden = YES;
    cell.selectLabel.text = @"";
    NSInteger selIndex = [self.selectedAssets indexOfObject:asset];
    if (selIndex != NSNotFound) {
        cell.selectView.hidden = NO;
        cell.selectLabel.text = [NSString stringWithFormat:@"%ld", selIndex+1];
    }
    CGSize size = CGSizeMake(cell.bounds.size.width*2, cell.bounds.size.height*2);
    [self.imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        cell.imageView.image = result;
    }];
    return cell;
}

- (BOOL)isAssetInICloud:(PHAsset *)asset {
    return asset.sourceType == PHAssetSourceTypeCloudShared;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.assets[indexPath.item];
    PhotoPickerCell *cell = (PhotoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSInteger selIndex = [self.selectedAssets indexOfObject:asset];
    if (selIndex != NSNotFound) {
        [self.selectedAssets removeObject:asset];
        [collectionView reloadData];
        return;
    }
    // 检查iCloud
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            cell.progressView.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.progressView.progress = progress;
        });
    };
    [self.imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.progressView.hidden = YES;
            if (data) {
                [self.selectedAssets addObject:asset];
                [collectionView reloadData];
            }
        });
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)doneAction {
    if (self.completionHandler) {
        self.completionHandler([self.selectedAssets copy]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
