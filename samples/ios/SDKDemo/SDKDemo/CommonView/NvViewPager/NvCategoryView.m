#import "NvCategoryView.h"
#import <Masonry/Masonry.h>

@interface NvCategoryViewCollectionViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end;

@implementation NvCategoryViewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end

@interface NvCategoryView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *underline;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL selectedCellExist;
@end

static NSString * const NvHeaderViewCollectionViewCellIdentifier = @"SegmentHeaderViewCollectionViewCell";

@implementation NvCategoryView

-(void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectedIndex = self.originalIndex;
        _height = 40;
        _underlineHeight = 0;
        _cellSpacing = 10;
        _leftAndRightMargin = _cellSpacing;
        _shortUnderline = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.titleNormalColor = [UIColor grayColor];
        self.titleSelectedColor = [UIColor redColor];
        self.titleNomalFont = [UIFont systemFontOfSize:18];
        self.titleSelectedFont = [UIFont systemFontOfSize:20];
        [self setupSubViews];
        self.underline.backgroundColor = self.titleSelectedColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.originalIndex > 0) {
        self.selectedIndex = self.originalIndex;
    } else {
        _selectedIndex = 0;
        [self setupMoveLineDefaultLocation];
    }
}

#pragma mark - Public Method
- (void)changeItemWithTargetIndex:(NSUInteger)targetIndex {
    if (self.selectedIndex == targetIndex) {
        self.selectedIndex = targetIndex;
        return;
    }
    NvCategoryViewCollectionViewCell *selectedCell = [self getCell:self.selectedIndex];
    if (selectedCell) {
        selectedCell.titleLabel.textColor = self.titleNormalColor;
        selectedCell.titleLabel.font = self.titleNomalFont;
    }
    NvCategoryViewCollectionViewCell *targetCell = [self getCell:targetIndex];
    if (targetCell) {
        targetCell.titleLabel.textColor = self.titleSelectedColor;
        targetCell.titleLabel.font = self.titleSelectedFont;
    }
    self.selectedIndex = targetIndex;
}

- (void)insertFixedItemAtLastIndex:(NSString *)itemName imageName:(NSString *)imageName {
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.right.equalTo(self.mas_right).offset(-25*SCREENSCALE - 10*SCREENSCALE);
        make.height.mas_equalTo(self.height );
    }];
    
    self.backgroundColor = self.collectionView.backgroundColor;
    UIButton *fixedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fixedButton.backgroundColor = [UIColor clearColor];
    [self addSubview:fixedButton];
    [fixedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-5 * SCREENSCALE);
        make.width.mas_equalTo(25*SCREENSCALE);
        make.height.mas_equalTo(25*SCREENSCALE);
    }];
    if (itemName.length > 0) {
        [fixedButton setTitle:itemName forState:UIControlStateNormal];
    }
    else if (imageName.length > 0) {
        [fixedButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    [fixedButton addTarget:self action:@selector(fixedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Private Method
/*
 初始化界面
 Initialize the interface
 */
- (void)setupSubViews {
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.underline];
    [self addSubview:self.separator];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.height );
    }];
    [self.underline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.height - self.underlineHeight);
        make.height.mas_equalTo(self.underlineHeight);
    }];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)fixedButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(fixedItemClicked)]) {
        [self.delegate fixedItemClicked];
    }
}

#pragma mark - 根据参数返回当前cell
/*
 根据参数返回当前cell
 Return the current cell according to the parameters
 
 @param index 下标 index
 
 return 返回找到的cell
 Return the found cell
 */
- (NvCategoryViewCollectionViewCell *)getCell:(NSUInteger)index {
    return (NvCategoryViewCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

#pragma mark - 点击之后更新页面状态
/*
 点击之后更新页面状态
 Update page status after clicking
 
 */
- (void)layoutAndScrollToSelectedItem {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectIndex:)]) {
        [self.delegate didSelectIndex:self.selectedIndex];
    }
    
    NvCategoryViewCollectionViewCell *selectedCell = [self getCell:self.selectedIndex];
    if (selectedCell) {
        self.selectedCellExist = YES;
        [self updateMoveLineLocation];
    } else {
        /*
         这种情况下updateMoveLineLocation将在self.collectionView滚动结束后执行（代理方法scrollViewDidEndScrollingAnimation）
         In this case, updateMoveLineLocation will be executed after self.collectionView has finished scrolling (agent method scrollViewDidEndScrollingAnimation)
         */
        self.selectedCellExist = NO;
        
    }
}

#pragma mark - 更新下划线的默认状态
/*
 更新下划线的默认状态
 Update the default state of underscore
 
 */
- (void)setupMoveLineDefaultLocation {
    CGFloat cellWidth = [self getWidthWithContent:self.titles[0]];
    if (self.shortUnderline) {
        cellWidth = cellWidth/3.f;
    }
    [self.underline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(cellWidth);
        make.left.mas_equalTo(self.leftAndRightMargin);
    }];
}

#pragma mark - 更新下划线的状态
/*
 更新下划线的状态
 Update the status of the underscore
 
 */
- (void)updateMoveLineLocation {
    NvCategoryViewCollectionViewCell *cell = [self getCell:self.selectedIndex];
    CGFloat width = cell.titleLabel.width;
    if (self.shortUnderline) {
        width = width / 3.f;
    }
    [UIView animateWithDuration:0.15 animations:^{
        [self.underline mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.height - self.underlineHeight );
            make.height.mas_equalTo(self.underlineHeight);
            make.centerX.equalTo(cell.titleLabel);
            make.width.mas_equalTo(width);
        }];
        [self.collectionView setNeedsLayout];
        [self.collectionView layoutIfNeeded];
    }];
}

#pragma mark - 根据参数计算文字的宽度
/*
 根据参数计算文字的宽度
 Calculate the width of the text according to the parameters
 
 @param content 文本内容 content
 
 return 返回CGFloat值
 Return CGFloat value
 */
- (CGFloat)getWidthWithContent:(NSString *)content {
    CGRect rect = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, self.height )
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{NSFontAttributeName:self.titleSelectedFont}
                                        context:nil
    ];
    return ceilf(rect.size.width);
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = [self getWidthWithContent:self.titles[indexPath.row]];
    if ((self.frame.size.width-self.cellSpacing*2)/7 > itemWidth) {
        itemWidth = (self.frame.size.width-self.cellSpacing*2)/7;
    }
    return CGSizeMake(itemWidth, self.height );
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.cellSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, self.leftAndRightMargin, 0, self.leftAndRightMargin);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCategoryViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NvHeaderViewCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = self.titles[indexPath.row];
    cell.titleLabel.textColor = self.selectedIndex == indexPath.row ? self.titleSelectedColor : self.titleNormalColor;
    cell.titleLabel.font = self.selectedIndex == indexPath.row ? self.titleSelectedFont : self.titleNomalFont;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self changeItemWithTargetIndex:indexPath.row];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!self.selectedCellExist) {
        [self updateMoveLineLocation];
    }
}

#pragma mark - Setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (self.titles.count == 0) {
        return;
    }
    if (selectedIndex >= self.titles.count) {
        _selectedIndex = self.titles.count - 1;
    } else {
        _selectedIndex = selectedIndex;
    }
    [self layoutAndScrollToSelectedItem];
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor {
    _titleSelectedColor = titleSelectedColor;
    self.underline.backgroundColor = titleSelectedColor;
}

- (void)setHeight:(CGFloat)categoryViewHeight {
    _height = categoryViewHeight;
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.height );
    }];
    [self.underline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.height - self.underlineHeight );
    }];
}

- (void)setUnderlineHeight:(CGFloat)underlineHeight {
    _underlineHeight = underlineHeight;
    [self.underline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.height - self.underlineHeight );
    }];
}

- (void)setCellSpacing:(CGFloat)cellSpacing {
    _cellSpacing = cellSpacing;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setLeftAndRightMargin:(CGFloat)leftAndRightMargin {
    _leftAndRightMargin = leftAndRightMargin;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        [_collectionView registerClass:[NvCategoryViewCollectionViewCell class] forCellWithReuseIdentifier:NvHeaderViewCollectionViewCellIdentifier];
    }
    return _collectionView;
}

- (UIView *)underline {
    if (!_underline) {
        _underline = [[UIView alloc] init];
    }
    return _underline;
}

- (UIView *)separator {
    if (!_separator) {
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    }
    return _separator;
}

@end
