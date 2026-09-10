//
//  NvModifyCompoundCaptionView.m
//  SDKDemo
//  复合字幕修改界面 Composite subtitle modification interface
//  Created by MS on 2019/5/20.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvModifyCompoundCaptionView.h"
#import "NvCompoundFontFamilyCollectionCell.h"
#import "NVHeader.h"

@interface NvModifyCompoundCaptionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic, strong) UICollectionView *fontFamilyCollectionView;
@property(nonatomic, strong) UICollectionView *fontColorCollectionView;
///颜色数据 Color data
@property(nonatomic, strong) NSMutableArray *fontColorArr;
///字体数组 Font array
@property(nonatomic, strong) NSMutableArray *fontFamilyArr;
@property(nonatomic, strong) UIView *inputAccessoryView;
@property(nonatomic, strong) UIButton *confirmButton;
@property(nonatomic, strong) NSMutableDictionary *fontFamilyDic;
@end

@implementation NvModifyCompoundCaptionView

- (instancetype )initWithFrame:(CGRect)frame compoundCaption:(NvsTimelineCompoundCaption *)caption selectedIndex:(NSInteger)index {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
        self.caption = caption;
        self.selectedIndex = index;
    }
    return self;
}

- (instancetype )initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}


- (void)initSubviews {
    [self loadLocalFontColor];
//    [self loadLocalFontFamily];
    self.model = [[NvCompoundCaptionModel alloc] init];
    [self addSubview:self.fontFamilyCollectionView];
    
    [self addSubview:self.textView];
    self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.fontFamilyCollectionView.mas_bottom).offset(10.f);
        make.bottom.equalTo(self.mas_bottom).offset(-20.f);
    }];
    [self.fontColorCollectionView registerClass:[NvColorCollectionViewCell class] forCellWithReuseIdentifier:@"NvColorCollectionViewCell"];
    [self.fontFamilyCollectionView registerClass:[NvCompoundFontFamilyCollectionCell class] forCellWithReuseIdentifier:@"NvCompoundFontFamilyCollectionCell"];
    
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInView)];
    recog.delegate = self;
    [self addGestureRecognizer:recog];
}

///加载本地颜色数据
///Load the local color data
- (void)loadLocalFontColor {
    self.fontColorArr = [NSMutableArray new];
    [[NvUtils captionColors] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NvCaptionColorItem *item = [NvCaptionColorItem new];
        item.isSelect = NO;
        item.colorString = obj;
        [self.fontColorArr addObject:item];
    }];
    [self.fontColorCollectionView reloadData];
    self.currentItem = self.fontColorArr.firstObject;
}

///加载本地字体
///Load local font
- (void)loadLocalFontFamily {
    ///(ios系统内字体不一定能被底层框架识别，所以现在只添加一个默认选项)
    ///(Fonts in ios are not necessarily recognized by the underlying framework, so just add a default option for now.)
    self.fontFamilyArr = [NSMutableArray array];
    NvCompoundCaptionModel *model = [[NvCompoundCaptionModel alloc] init];
    model.showName = @"默认";
    model.isSelected = YES;
    self.model = model;
    [self.fontFamilyArr addObject:model];
    ///需要事先将字体对应的中英文存到一个字典里
    ///The corresponding Chinese and English characters need to be stored in a dictionary in advance
    self.fontFamilyDic = [NSMutableDictionary dictionary];
    [self.fontFamilyDic setObject:@"杨任东竹石体" forKey:@"YRDZST-Semibold"];
    [self.fontFamilyDic setObject:@"方正书宋简体" forKey:@"FZSSJW--GB1-0"];
    [self.fontFamilyDic setObject:@"方正仿宋简体" forKey:@"FZFSJW--GB1-0"];
    [self.fontFamilyDic setObject:@"站酷文艺体" forKey:@"zcoolwenyiti"];
    [self.fontFamilyCollectionView reloadData];
}

///点击取消按钮方法
///Click the Cancel button method
- (void)cancelButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.delegate cancelButtonClicked:button];
    }
}

///点击确认按钮方法
///Click the Confirm button method
- (void)confirmButtonClicked:(UIButton *)button {
    
    self.model.text = self.textView.text;
    self.model.colorString = self.currentItem.colorString;
    if ([self.delegate respondsToSelector:@selector(confirmButtonClicked:model:)]) {
        [self.delegate confirmButtonClicked:button model:self.model];
    }
}

///取消键盘
///Cancel keyboard
- (void)tapInView {
    [self.textView resignFirstResponder];
}

#pragma mark - setter & getter
- (void)setCaption:(NvsTimelineCompoundCaption *)caption {
    _caption = caption;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    if (_caption) {
        NSString *text = [_caption getText:selectedIndex];
        self.textView.text = text;
        
        ///获取、设置字幕字体
        ///Gets and sets the subtitle font
        NSString *fontFamily = [_caption getFontFamily:selectedIndex];
        for (NvCompoundCaptionModel *model in self.fontFamilyArr) {
            if ([model.fontName containsString:fontFamily]) {
                
                NvCompoundCaptionModel *defaultModel = self.fontFamilyArr[0];
                defaultModel.isSelected = NO;
                model.isSelected = YES;
                self.model = model;
                self.textView.font = [UIFont fontWithName:model.iosFontName size:35*SCREENSCALE];
            }
        }
        [self.fontFamilyCollectionView reloadData];
        
        ///获取、设置字幕颜色
        ///Gets and sets the subtitles color
        NvsColor color = [_caption getTextColor:selectedIndex];
        self.textView.textColor = [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
        NvCaptionColorItem *item = [NvCaptionColorItem new];
        item.colorString = [NvUtils colorStringInARGBModeWithRGB:color];
        item.isSelect = YES;
        self.currentItem = item;

        [self.fontColorCollectionView reloadData];
        
    }
    _selectedIndex = selectedIndex;
}

- (void)setFontDataArr:(NSMutableArray *)fontDataArr {
    _fontDataArr = fontDataArr;
    NSArray *targetArr = @[@"YRDZST",@"FZSSJW",@"FZFSJW",@"zcoolwenyiti"];
    NSMutableArray *removeArr = [NSMutableArray array];
    for(NSString *fontName in _fontDataArr) {
        BOOL isTarget = NO;
        for (NSString *name in targetArr) {
            if ([fontName containsString:name]) {
                isTarget = YES;
                break;
            }
        }
        if(!isTarget){
            [removeArr addObject:fontName];
        }
    }
    [_fontDataArr removeObjectsInArray:removeArr];
    [self loadLocalFontFamily];
    for (int i=0; i<fontDataArr.count; i++) {
        NvCompoundCaptionModel *model = [[NvCompoundCaptionModel alloc] init];
        model.showName = [self.fontFamilyDic objectForKey:_fontDataArr[i]];
        model.fontName = _fontDataArr[i];
        NSString *fontFamily = _fontDataArr[i];
        model.iosFontName = [fontFamily substringWithRange:NSMakeRange([fontFamily rangeOfString:@"["].location + 1, [fontFamily rangeOfString:@"]"].location - [fontFamily rangeOfString:@"["].location - 1)];
        [self.fontFamilyArr insertObject:model atIndex:i+1];
    }
}

- (BOOL)isEuqualWithValue:(float)valueA floatValue:(float)valueB {
    if ((valueA- valueB)> -0.000001 && (valueA- valueB) < 0.000001)
        return true;
    else
        return false;
}

#pragma mark - collectionViewDelegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.fontColorCollectionView) {
        return self.fontColorArr.count;
    }
    return self.fontFamilyArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.fontColorCollectionView) {
        NvColorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvColorCollectionViewCell" forIndexPath:indexPath];
        [cell renderCellWithItem:self.fontColorArr[indexPath.item]];
        return cell;
    }
    
    NvCompoundFontFamilyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCompoundFontFamilyCollectionCell" forIndexPath:indexPath];
    for (NvCompoundCaptionModel *model in self.fontFamilyArr) {
        if (model == self.model) {
            model.isSelected = YES;
        }else{
            model.isSelected = NO;
        }
    }
    NvCompoundCaptionModel *model = self.fontFamilyArr[indexPath.item];
    cell.model = model;
    cell.titleLabel.font = [UIFont systemFontOfSize:12.f];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.fontColorCollectionView) {
        for (NvCaptionColorItem *item in self.fontColorArr) {
            item.isSelect = NO;
        }
        NvCaptionColorItem *item = self.fontColorArr[indexPath.item];
        item.isSelect = YES;
        self.currentItem = item;
        [self.fontColorCollectionView reloadData];
        self.textView.textColor = [UIColor nv_colorWithHexRGB:item.colorString];

    }else if (collectionView == self.fontFamilyCollectionView) {
        self.model = self.fontFamilyArr[indexPath.item];
        self.textView.font = [UIFont fontWithName:self.model.iosFontName size:35*SCREENSCALE];
        [self.fontFamilyCollectionView reloadData];
    }

}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.fontFamilyCollectionView]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

}
- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!(self.textView.text.length == 1 && text.length == 0 ) && !(!self.confirmButton.enabled && [text containsString:@" "] && text.length == 1) && !(!self.confirmButton.enabled && text.length<=0 && range.location==0 && range.length==0)) {
        self.confirmButton.alpha = 1;
        self.confirmButton.enabled = YES;
    } else {
        self.confirmButton.alpha = 0.4;
        self.confirmButton.enabled = NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

}

#pragma mark - lazyload
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        _textView.delegate = self;
        _textView.inputAccessoryView = self.inputAccessoryView;
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.tintColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        _textView.font = [UIFont systemFontOfSize:35*SCREENSCALE];
        _textView.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    return _textView;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        _inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 98*SCREENSCALE)];
        [_inputAccessoryView addSubview:self.fontColorCollectionView];
        _inputAccessoryView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#0C0D0E"];
        [self addButtons];
    }
    return _inputAccessoryView;
}

- (void)addButtons {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_inputAccessoryView addSubview:cancelButton];
    [cancelButton setImage:NvImageNamed(@"Nvback") forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_inputAccessoryView.mas_left).offset(13*SCREENSCALE);
        make.width.mas_equalTo(25*SCREENSCALE);
        make.top.equalTo(self->_fontColorCollectionView.mas_bottom).offset(15.f);
        make.height.mas_equalTo(20*SCREENSCALE);
    }];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [self.confirmButton setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateSelected];
    [_inputAccessoryView addSubview:self.confirmButton];

    [self.confirmButton addTarget:self action:@selector(confirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->_inputAccessoryView.mas_right).offset(-13*SCREENSCALE);
        make.width.mas_equalTo(25*SCREENSCALE);
        make.top.equalTo(self->_fontColorCollectionView.mas_bottom).offset(15.f);
        make.height.mas_equalTo(20*SCREENSCALE);
    }];
}

- (UICollectionView *)fontColorCollectionView {
    if (!_fontColorCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(25*SCREENSCALE, 25*SCREENSCALE);
        flowLayout.minimumLineSpacing = 33*SCREENSCALE;
        _fontColorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40) collectionViewLayout:flowLayout];
        _fontColorCollectionView.delegate = self;
        _fontColorCollectionView.dataSource = self;
        _fontColorCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    }
    return _fontColorCollectionView;
}

- (UICollectionView *)fontFamilyCollectionView {
    if (!_fontFamilyCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(97*SCREENSCALE, 49*SCREENSCALE);
        flowLayout.minimumLineSpacing = 12*SCREENSCALE;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 7*SCREENSCALE, 0, 0);
        _fontFamilyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,10, SCREENWIDTH, 50) collectionViewLayout:flowLayout];
        _fontFamilyCollectionView.delegate = self;
        _fontFamilyCollectionView.dataSource = self;
        _fontFamilyCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    }
    return _fontFamilyCollectionView;
}
@end
