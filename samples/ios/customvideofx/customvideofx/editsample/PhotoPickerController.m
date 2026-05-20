#import "PhotoPickerController.h"

@implementation PhotoPickerCompletionHandler

@end

@interface PhotoPickerController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *allPhotos;
@property (nonatomic, strong) NSArray<PHAssetCollection *> *albums;
@property (nonatomic, strong) PHAssetCollection *currentCollection;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedAssets;
@property (nonatomic, assign) BOOL isAlbumListVisible;

@property (nonatomic, strong) UISegmentedControl *mediaTypeSegmentedControl;
@property (nonatomic, strong) UIView *segmentedContainer;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *albumTableView;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, assign) PHImageRequestID requestID;

@end

@implementation PhotoPickerController

- (instancetype)init {
    self = [super init];
    if (self) {
        _selectedAssets = [NSMutableArray array];
        _selectionMode = SelectionModeMultiple;
        _maxSelectionCount = 10;
        _mediaType = MediaTypeAll;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self requestPhotoLibraryPermission];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // 更新布局
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat spacing = 10;
    CGFloat itemSize = (self.view.bounds.size.width - spacing * 5) / 4;
    layout.itemSize = CGSizeMake(itemSize, itemSize);
}

#pragma mark - UI Setup

- (void)setupUI {
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        // Fallback on earlier versions
        self.view.backgroundColor = [UIColor blackColor];
    }
    [self setupNavigationBar];
    [self setupMediaTypeSelector];
    [self setupCollectionView];
    [self setupAlbumTableView];
}

- (void)setupNavigationBar {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(doneTapped)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.titleButton setTitle:@"所有照片" forState:UIControlStateNormal];
    [self.titleButton addTarget:self action:@selector(toggleAlbumList) forControlEvents:UIControlEventTouchUpInside];
    self.titleButton.frame = CGRectMake(0, 0, 200, 44);
    self.navigationItem.titleView = self.titleButton;
}

- (void)setupMediaTypeSelector {
    self.segmentedContainer = [[UIView alloc] init];
    if (@available(iOS 13.0, *)) {
        self.segmentedContainer.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        // Fallback on earlier versions
        self.segmentedContainer.backgroundColor = [UIColor blackColor];
    }
    self.segmentedContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.segmentedContainer];
    
    NSArray *items = @[@"全部", @"图片", @"视频", @"实况"];
    self.mediaTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    self.mediaTypeSegmentedControl.selectedSegmentIndex = 0;
    [self.mediaTypeSegmentedControl addTarget:self action:@selector(mediaTypeChanged:) forControlEvents:UIControlEventValueChanged];
    self.mediaTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.segmentedContainer addSubview:self.mediaTypeSegmentedControl];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.segmentedContainer.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.segmentedContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.segmentedContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.segmentedContainer.heightAnchor constraintEqualToConstant:44],
        
        [self.mediaTypeSegmentedControl.centerXAnchor constraintEqualToAnchor:self.segmentedContainer.centerXAnchor],
        [self.mediaTypeSegmentedControl.centerYAnchor constraintEqualToAnchor:self.segmentedContainer.centerYAnchor],
        [self.mediaTypeSegmentedControl.widthAnchor constraintEqualToAnchor:self.segmentedContainer.widthAnchor multiplier:0.9]
    ]];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat spacing = 10;
    CGFloat itemSize = (self.view.bounds.size.width - spacing * 5) / 4;
    layout.itemSize = CGSizeMake(itemSize, itemSize);
    layout.minimumInteritemSpacing = spacing;
    layout.minimumLineSpacing = spacing;
    layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    if (@available(iOS 13.0, *)) {
        self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        // Fallback on earlier versions
        self.collectionView.backgroundColor = [UIColor blackColor];
    }
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.segmentedContainer.bottomAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupAlbumTableView {
    self.albumTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -300, self.view.bounds.size.width, 300)];
    if (@available(iOS 13.0, *)) {
        self.albumTableView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        // Fallback on earlier versions
        self.albumTableView.backgroundColor = [UIColor blackColor];
    }
    self.albumTableView.layer.cornerRadius = 12;
    self.albumTableView.layer.masksToBounds = YES;
    self.albumTableView.layer.borderWidth = 1;
    self.albumTableView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.albumTableView.dataSource = self;
    self.albumTableView.delegate = self;
    [self.albumTableView registerClass:[AlbumCell class] forCellReuseIdentifier:@"AlbumCell"];
    [self.view addSubview:self.albumTableView];
}

#pragma mark - Photo Library Access

- (void)requestPhotoLibraryPermission {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            [self loadPhotos];
            break;
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self loadPhotos];
                    });
                }
            }];
            break;
        }
        default:
            [self showPermissionAlert];
            break;
    }
}

- (void)showPermissionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"需要相册权限"
                                                                   message:@"请在设置中开启相册访问权限"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Data Loading

- (void)loadPhotos {
    [self fetchAlbums];
    [self reloadMediaForType:self.mediaType];
    [self.collectionView reloadData];
}

- (void)fetchAlbums {
    NSMutableArray *albums = [NSMutableArray array];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                        subtype:PHAssetCollectionSubtypeAny
                                                                        options:nil];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                        subtype:PHAssetCollectionSubtypeAny
                                                                        options:nil];
    
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        if (collection.estimatedAssetCount > 0) {
            [albums addObject:collection];
        }
    }];
    
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        if (collection.estimatedAssetCount > 0) {
            [albums addObject:collection];
        }
    }];
    
    self.albums = albums;
    
    // 查找"所有照片"相册
    for (PHAssetCollection *collection in albums) {
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            self.currentCollection = collection;
            break;
        }
    }
}

- (void)reloadMediaForType:(MediaType)type {
    self.mediaType = type;
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
//    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:true]];
    
    switch (type) {
        case MediaTypeImage:
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d AND !((mediaSubtype & %d) != 0)", PHAssetMediaTypeImage, PHAssetMediaSubtypePhotoLive];
            break;
        case MediaTypeVideo:
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeVideo];
            break;
        case MediaTypeLivePhoto:
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d AND mediaSubtype & %d != 0", PHAssetMediaTypeImage, PHAssetMediaSubtypePhotoLive];
            break;
        default:
            break;
    }
    
    if (self.currentCollection) {
        self.allPhotos = [PHAsset fetchAssetsInAssetCollection:self.currentCollection options:fetchOptions];
    } else {
        self.allPhotos = [PHAsset fetchAssetsWithOptions:fetchOptions];
    }
    
    [self.collectionView reloadData];
}

- (void)resetSelection {
    [self.selectedAssets removeAllObjects];
    [self.collectionView reloadData];
    [self updateSelectionUI];
}

- (void)updateSelectionUI {
    self.navigationItem.rightBarButtonItem.enabled = self.selectedAssets.count > 0;
}

#pragma mark - Actions

- (void)toggleAlbumList {
    CGFloat topY = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.albumTableView.frame;
        frame.origin.y = self.isAlbumListVisible ? -300 : topY;
        self.albumTableView.frame = frame;
    }];
    self.isAlbumListVisible = !self.isAlbumListVisible;
}

- (void)cancelTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerDidCancel:)]) {
        [self.delegate photoPickerDidCancel:self];
    }
    if (self.completionHandler.didCancel) {
        self.completionHandler.didCancel();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPicker:didSelectAssets:)]) {
        [self.delegate photoPicker:self didSelectAssets:[self.selectedAssets copy]];
    }
    if (self.completionHandler.didFinishPicking) {
        self.completionHandler.didFinishPicking([self.selectedAssets copy]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaTypeChanged:(UISegmentedControl *)sender {
    MediaType type = (MediaType)sender.selectedSegmentIndex;
    [self reloadMediaForType:type];
}

- (void)selectCollection:(PHAssetCollection *)collection {
    self.currentCollection = collection;
    [self reloadMediaForType:self.mediaType];
    [self.titleButton setTitle:collection.localizedTitle ?: @"相册" forState:UIControlStateNormal];
}

- (void)handleICloudAsset:(PHAsset *)asset atIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"下载资源"
                                                                   message:@"该资源需要从iCloud下载"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:progressView];
    
    NSArray *progressConstraints = @[
        [NSLayoutConstraint constraintWithItem:progressView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:alert.view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:progressView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:alert.view
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:60],
        [NSLayoutConstraint constraintWithItem:progressView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:200]
    ];
    [alert.view addConstraints:progressConstraints];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (self.requestID != PHInvalidImageRequestID) {
            [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
            self.requestID = PHInvalidImageRequestID;
        }
    }];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressView.progress = progress;
            });
        };
        
        self.requestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                                          options:options
                                                                    resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:^{
                    if (imageData) {
                        [self toggleSelectionAtIndexPath:indexPath];
                    }
                }];
            });
        }];
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *videoOptions = [[PHVideoRequestOptions alloc] init];
        videoOptions.networkAccessAllowed = YES;
        videoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressView.progress = progress;
            });
        };
        
        self.requestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                                        options:videoOptions
                                                                  resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:^{
                    if (asset) {
                        [self toggleSelectionAtIndexPath:indexPath];
                    }
                }];
            });
        }];
    }
}

- (void)toggleSelectionAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.allPhotos.count) return;
    
    PHAsset *asset = [self.allPhotos objectAtIndex:indexPath.item];
    
    if (self.selectionMode == SelectionModeSingle) {
        [self.selectedAssets removeAllObjects];
        [self.selectedAssets addObject:asset];
        [self.collectionView reloadData];
        [self doneTapped]; // 单选模式直接返回
        return;
    }
    
    if ([self.selectedAssets containsObject:asset]) {
        [self.selectedAssets removeObject:asset];
    } else {
        if (self.selectionMode == SelectionModeMultiple && self.selectedAssets.count >= self.maxSelectionCount) {
            return;
        }
        [self.selectedAssets addObject:asset];
    }
    
    // 刷新受影响的单元格
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger i = 0; i < self.allPhotos.count; i++) {
        PHAsset *a = [self.allPhotos objectAtIndex:i];
        if ([self.selectedAssets containsObject:a] || [a isEqual:asset]) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
    }
    
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    [self updateSelectionUI];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    PHAsset *asset = [self.allPhotos objectAtIndex:indexPath.item];
    [cell configureWithAsset:asset];
    
    if ([self.selectedAssets containsObject:asset]) {
        NSInteger index = [self.selectedAssets indexOfObject:asset] + 1;
        [cell setSelected:YES index:index];
    } else {
        [cell setSelected:NO index:0];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self.allPhotos objectAtIndex:indexPath.item];
    
    // Check if the asset is in iCloud
    [asset isAssetInICloudWithCompletion:^(BOOL isInICloud) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isInICloud) {
                [self handleICloudAsset:asset atIndexPath:indexPath];
            } else {
                [self toggleSelectionAtIndexPath:indexPath];
            }
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    PHAssetCollection *album = [self.albums objectAtIndex:indexPath.row];
    [cell configureWithCollection:album];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PHAssetCollection *album = [self.albums objectAtIndex:indexPath.row];
    [self selectCollection:album];
    [self toggleAlbumList];
}

@end

#pragma mark - PhotoCell Implementation

@implementation PhotoCell {
    UIImageView *_imageView;
    UILabel *_selectionBadge;
    UILabel *_typeIndicator;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:_imageView];
    
    _selectionBadge = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 24, 4, 24, 24)];
    _selectionBadge.backgroundColor = [UIColor systemGreenColor];
    _selectionBadge.textColor = [UIColor whiteColor];
    _selectionBadge.textAlignment = NSTextAlignmentCenter;
    _selectionBadge.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    _selectionBadge.layer.cornerRadius = 12;
    _selectionBadge.layer.masksToBounds = YES;
    _selectionBadge.hidden = YES;
    [self.contentView addSubview:_selectionBadge];
    
    _typeIndicator = [[UILabel alloc] initWithFrame:CGRectMake(4, self.contentView.bounds.size.height - 20, self.contentView.bounds.size.width - 8, 16)];
    _typeIndicator.textColor = [UIColor whiteColor];
    _typeIndicator.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _typeIndicator.textAlignment = NSTextAlignmentRight;
    _typeIndicator.layer.shadowColor = [UIColor blackColor].CGColor;
    _typeIndicator.layer.shadowRadius = 2;
    _typeIndicator.layer.shadowOpacity = 0.8;
    _typeIndicator.layer.shadowOffset = CGSizeMake(0, 1);
    [self.contentView addSubview:_typeIndicator];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.contentView.bounds;
    _selectionBadge.frame = CGRectMake(self.contentView.bounds.size.width - 24, 4, 24, 24);
    _typeIndicator.frame = CGRectMake(4, self.contentView.bounds.size.height - 20, self.contentView.bounds.size.width - 8, 16);
}

- (void)configureWithAsset:(PHAsset *)asset {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                              targetSize:CGSizeMake(self.frame.size.width * 2, self.frame.size.height * 2)
                                             contentMode:PHImageContentModeAspectFill
                                                 options:options
                                           resultHandler:^(UIImage *result, NSDictionary *info) {
        self->_imageView.image = result;
    }];
    
    // Reset type indicator
    _typeIndicator.text = nil;
    
    if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        _typeIndicator.text = @"LIVE";
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        NSInteger minutes = (NSInteger)asset.duration / 60;
        NSInteger seconds = (NSInteger)asset.duration % 60;
        _typeIndicator.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    }
}

- (void)setSelected:(BOOL)selected index:(NSInteger)index {
    _selectionBadge.hidden = !selected;
    if (selected) {
        _selectionBadge.text = [NSString stringWithFormat:@"%ld", (long)index];
    }
}

@end

#pragma mark - AlbumCell Implementation

@implementation AlbumCell {
    UIImageView *_coverImageView;
    UILabel *_titleLabel;
    UILabel *_countLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    _coverImageView.layer.cornerRadius = 4;
    _coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_coverImageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_titleLabel];
    
    _countLabel = [[UILabel alloc] init];
    _countLabel.font = [UIFont systemFontOfSize:14];
    if (@available(iOS 13.0, *)) {
        _countLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        // Fallback on earlier versions
        _countLabel.textColor = [UIColor orangeColor];
    }
    _countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_countLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [_coverImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [_coverImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_coverImageView.widthAnchor constraintEqualToConstant:60],
        [_coverImageView.heightAnchor constraintEqualToConstant:60],
        
        [_titleLabel.leadingAnchor constraintEqualToAnchor:_coverImageView.trailingAnchor constant:16],
        [_titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        
        [_countLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [_countLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
    ]];
}

- (void)configureWithCollection:(PHAssetCollection *)collection {
    _titleLabel.text = collection.localizedTitle;
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    _countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)assets.count];
    
    if (assets.count > 0) {
        PHAsset *asset = [assets firstObject];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                  targetSize:CGSizeMake(120, 120)
                                                 contentMode:PHImageContentModeAspectFill
                                                     options:options
                                               resultHandler:^(UIImage *result, NSDictionary *info) {
            self->_coverImageView.image = result;
        }];
    } else {
        if (@available(iOS 13.0, *)) {
            _coverImageView.image = [UIImage systemImageNamed:@"photo.on.rectangle"];
        } else {
            _coverImageView.image = [UIImage imageNamed:@"placeholder"];
        }
        _coverImageView.contentMode = UIViewContentModeCenter;
        if (@available(iOS 13.0, *)) {
            _coverImageView.tintColor = [UIColor systemGray4Color];
            _coverImageView.backgroundColor = [UIColor systemGray5Color];
        } else {
            // Fallback on earlier versions
            _coverImageView.tintColor = [UIColor blueColor];
            _coverImageView.backgroundColor = [UIColor greenColor];
        }
    }
}

@end

#pragma mark - PHAsset iCloud Extension

@implementation PHAsset (iCloud)

- (void)isAssetInICloudWithCompletion:(void (^)(BOOL isInICloud))completion {
    if (!completion) return;
    
    __block BOOL isInICloud = NO;
    
    if (self.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:self options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            // 检查结果或错误信息
            if (info) {
                if (info[PHImageResultIsInCloudKey]) {
                    isInICloud = [info[PHImageResultIsInCloudKey] boolValue];
                }
                
                if (info[PHImageErrorKey]) {
                    // 如果有错误，可能是iCloud资源
                    isInICloud = YES;
                }
            }
            
            // 如果没有获取到资源，并且没有明确错误，也认为是iCloud资源
            if (!asset && !info[PHImageCancelledKey]) {
                isInICloud = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(isInICloud);
            });
        }];
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionOriginal;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = NO; // 故意设置为NO以检测iCloud资源
        
        [[PHImageManager defaultManager] requestImageDataForAsset:self
                                                         options:options
                                                   resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            // 检查结果或错误信息
            if (info) {
                if (info[PHImageResultIsInCloudKey]) {
                    isInICloud = [info[PHImageResultIsInCloudKey] boolValue];
                }
                
                if (info[PHImageErrorKey]) {
                    NSError *error = info[PHImageErrorKey];
                    if (@available(iOS 13, *)) {
                        if ([error.domain isEqualToString:PHPhotosErrorDomain] && error.code == PHPhotosErrorAccessRestricted) {
                            // iCloud访问限制
                            isInICloud = YES;
                        }
                    } else {
                        // Fallback on earlier versions
                        isInICloud = YES;
                    }
                }
            }
            
            // 如果没有获取到图片数据，并且没有明确错误，也认为是iCloud资源
            if (!imageData && !info[PHImageCancelledKey]) {
                isInICloud = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(isInICloud);
            });
        }];
    }
}

@end
