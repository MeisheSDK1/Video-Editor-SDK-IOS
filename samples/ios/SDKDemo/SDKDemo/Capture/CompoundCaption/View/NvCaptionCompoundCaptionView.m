//
//  NvCaptionCompoundCaptionView.m
//  SDKDemo
//
//  Created by ms on 2021/6/29.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCaptionCompoundCaptionView.h"
#import "NvCompoundCaptionModel.h"
#import "NvCaptionColorItem.h"
#import "NvCompoundFontCell.h"
#import "NvCompoundColorCell.h"

@interface NvCaptionCompoundCaptionView ()<UICollectionViewDelegate, UICollectionViewDataSource,UITextViewDelegate>

@property(nonatomic, strong) NSMutableArray *fontColorArr;
@property(nonatomic, strong) NSMutableArray *fontFamilyArr;

@property(nonatomic, strong) UITextView *textView;
@property (nonatomic, strong)UIButton *inputBtn;
@property (nonatomic, strong)UIView *inputLine;
@property (nonatomic, strong)UIButton *styleBtn;
@property (nonatomic, strong)UIView *styleLine;
@property(nonatomic, strong) UICollectionView *fontCollectionView;
@property(nonatomic, strong) UICollectionView *colorCollectionView;
@property(nonatomic, strong) NSMutableDictionary *fontFamilyDic; //中英文字体对照 // Check the Chinese and English fonts

@property (nonatomic, strong)UIButton *confirmBtn;

@property (nonatomic, assign) CGFloat beginY;

@property (nonatomic, assign) BOOL isStyle;

@property (nonatomic, strong) UIView *bgView;

@end

@implementation NvCaptionCompoundCaptionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        self.isStyle = YES;
        [self initSubviews];
        [self addNotification];
        [self initData];
    }
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideFrame:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillChangeFrame:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间 The duration of the animation
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame Keyboard frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyboardF.size.height;
    CGRect frame = self.bgView.frame;
    
    if(self.isStyle){
        frame.origin.y = SCREENHEIGHT - keyBoardHeight - 200;
    }else{
        frame.origin.y = SCREENHEIGHT - keyBoardHeight - 80;
    }
    if(self.keyboardClick){
        CGFloat tempHeight = keyBoardHeight + CGRectGetMaxY(frame) - CGRectGetMinY(frame);
        self.keyboardClick(tempHeight);
    }
    [UIView animateWithDuration:duration animations:^{
        self.bgView.frame = frame;
    }];
}

-(void)keyboardWillHideFrame:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间 The duration of the animation
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.bgView.frame;
    frame.origin.y = kScreenHeight - self.bgView.viewHeight;
    [UIView animateWithDuration:duration animations:^{
        self.bgView.frame = frame;
    }];
}

-(void)initData{
    [self loadLocalFontColor];
}

-(void)initSubviews{
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT - (180 * SCREENSCALE + INDICATOR), SCREENWIDTH, 180 * SCREENSCALE + INDICATOR) ];
    self.bgView.backgroundColor = [UIColor nv_colorWithHexString:@"#181818"];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(5.0f);
        make.left.mas_equalTo(self.bgView).offset(10.0);
        make.height.mas_equalTo(35.0);
        make.right.mas_equalTo(self.bgView).offset(-10.0f);
    }];
    _inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_inputBtn setTitle:NvLocalString(@"Input", @"输入") forState:UIControlStateNormal];
    [_inputBtn setTitleColor:[UIColor nv_colorWithHexString:@"#B4B4B4"] forState:UIControlStateNormal];
    _inputBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_inputBtn addTarget:self action:@selector(inputBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_inputBtn];
    [_inputBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView.mas_bottom).offset(5.0);
        make.left.mas_equalTo(self.textView.mas_left);
        make.height.mas_equalTo(25.0);
        make.width.mas_equalTo(40.0);
    }];
    _inputLine = [[UIView alloc] init];
    _inputLine.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:_inputLine];
    [_inputLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.inputBtn.mas_bottom).offset(5.0);
        make.centerX.mas_equalTo(self.inputBtn);
        make.height.mas_equalTo(2.0);
        make.width.mas_equalTo(20.0);
    }];
    _styleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_styleBtn setTitle:NvLocalString(@"Style", @"样式") forState:UIControlStateNormal];
    [_styleBtn setTitleColor:[UIColor nv_colorWithHexString:@"#B4B4B4"] forState:UIControlStateNormal];
    _styleBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_styleBtn addTarget:self action:@selector(styleBtnBClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_styleBtn];
    [_styleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputBtn.mas_right).offset(10.0);
        make.centerY.mas_equalTo(self.inputBtn);
        make.height.mas_equalTo(25.0);
        make.width.mas_equalTo(40.0);
    }];
    _styleLine = [[UIView alloc] init];
    _styleLine.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:_styleLine];
    [_styleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.styleBtn.mas_bottom).offset(5.0);
        make.centerX.mas_equalTo(self.styleBtn);
        make.height.mas_equalTo(2.0);
        make.width.mas_equalTo(20.0);
    }];
    
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmBtn setImage:[UIImage imageNamed:@"capture_input_confirm"] forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_confirmBtn];
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView).offset(-13.0);
        make.top.mas_equalTo(self.textView.mas_bottom).offset(13.0);
        make.height.mas_equalTo(21.0);
        make.width.mas_equalTo(21.0);
    }];
    
    [self.bgView addSubview:self.colorCollectionView];
    [self.colorCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-40.0);
        make.left.mas_equalTo(15.0);
        make.right.mas_equalTo(-15.0);
        make.height.mas_equalTo(35.0);
    }];
    
    [self.bgView addSubview:self.fontCollectionView];
    [self.fontCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.colorCollectionView.mas_top).offset(-20.0);
        make.left.mas_equalTo(self.colorCollectionView.mas_left);
        make.right.mas_equalTo(self.colorCollectionView.mas_right);
        make.height.mas_equalTo(35.0);
    }];
    
}

-(void)confirmBtnClicked:(UIButton *)btn{
    NSString *str = [self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (str && str.length > 0) {
        self.model.text = self.textView.text;
        self.model.colorString = self.currentItem.colorString;
        if (self.selectItemClick) {
            self.selectItemClick(self.model, self.selectedIndex,YES);
        }
        [self removeFromSuperview];
    }else{
        [NvToast showInfoWithMessage:NvLocalString(@"Subtitle is empty", @"您输入的字幕为空，请重新输入")];
    }
}

-(void)inputBtnClicked:(UIButton *)sender{
    [_inputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _inputLine.backgroundColor = [UIColor whiteColor];
    [_styleBtn setTitleColor:[UIColor nv_colorWithHexString:@"#B4B4B4"] forState:UIControlStateNormal];
    _styleLine.backgroundColor = [UIColor clearColor];
    [self.textView becomeFirstResponder];
    self.isStyle = NO;
}

-(void)styleBtnBClicked:(UIButton *)sender{
    [_styleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _styleLine.backgroundColor = [UIColor whiteColor];
    [_inputBtn setTitleColor:[UIColor nv_colorWithHexString:@"#B4B4B4"] forState:UIControlStateNormal];
    _inputLine.backgroundColor = [UIColor clearColor];
    [self.textView resignFirstResponder];
    self.isStyle = YES;
}

- (void)applyEffect {
    NSString *str = [self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (str && str.length > 0) {
        self.model.text = self.textView.text;
        self.model.colorString = self.currentItem.colorString;
        if (self.selectItemClick) {
            self.selectItemClick(self.model, self.selectedIndex, NO);
        }
    }
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242424"];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.tintColor = [UIColor nv_colorWithHexRGB:@"#808080"];
        _textView.font = [UIFont systemFontOfSize:14*SCREENSCALE];
        _textView.textColor = [UIColor nv_colorWithHexRGB:@"#808080"];
        _textView.keyboardAppearance = UIKeyboardAppearanceDark;
        _textView.layer.masksToBounds = YES;
        _textView.delegate = self;
        _textView.layer.cornerRadius = 3.0f;
    }
    return _textView;
}
- (UICollectionView *)fontCollectionView {
    if (!_fontCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(61*SCREENSCALE, 30*SCREENSCALE);
        flowLayout.minimumLineSpacing = 9*SCREENSCALE;
        _fontCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40) collectionViewLayout:flowLayout];
        _fontCollectionView.delegate = self;
        _fontCollectionView.dataSource = self;
        _fontCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [_fontCollectionView registerClass:[NvCompoundFontCell class] forCellWithReuseIdentifier:@"NvCompoundFontCell"];
    }
    return _fontCollectionView;
}

- (UICollectionView *)colorCollectionView {
    if (!_colorCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(20*SCREENSCALE, 29*SCREENSCALE);
        flowLayout.minimumLineSpacing = 0*SCREENSCALE;
        _colorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,10, SCREENWIDTH, 50) collectionViewLayout:flowLayout];
        _colorCollectionView.delegate = self;
        _colorCollectionView.dataSource = self;
        _colorCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [_colorCollectionView registerClass:[NvCompoundColorCell class] forCellWithReuseIdentifier:@"NvCompoundColorCell"];
    }
    return _colorCollectionView;
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

//加载本地字体 Load local font
- (void)loadLocalFontFamily {
    //(ios系统内字体不一定能被底层框架识别，所以现在只添加一个默认选项)
    //(Fonts in ios are not necessarily recognized by the underlying framework, so just add a default option for now.)
    self.fontFamilyArr = [NSMutableArray array];
    NvCompoundCaptionModel *model = [[NvCompoundCaptionModel alloc] init];
    model.showName = @"默认";
    model.isSelected = NO;
    self.model = model;
    [self.fontFamilyArr addObject:model];
    //需要事先将字体对应的中英文存到一个字典里 The corresponding Chinese and English characters need to be stored in a dictionary in advance
    self.fontFamilyDic = [NSMutableDictionary dictionary];
    [self.fontFamilyDic setObject:@"杨任东竹石体" forKey:@"YRDZST-Semibold"];
    [self.fontFamilyDic setObject:@"方正书宋简体" forKey:@"FZSSJW--GB1-0"];
    [self.fontFamilyDic setObject:@"方正仿宋简体" forKey:@"FZFSJW--GB1-0"];
    [self.fontFamilyDic setObject:@"站酷文艺体" forKey:@"zcoolwenyiti"];
    [self.fontCollectionView reloadData];
}

//加载本地颜色数据 Load the local color data
- (void)loadLocalFontColor {
    self.fontColorArr = [NSMutableArray new];
    [[NvUtils captionColors] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NvCaptionColorItem *item = [NvCaptionColorItem new];
        item.isSelect = NO;
        item.colorString = obj;
        [self.fontColorArr addObject:item];
    }];
    [self.colorCollectionView reloadData];
    self.currentItem = self.fontColorArr.firstObject;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    if (_caption) {
        NSString *text = [_caption getText:selectedIndex];
        self.textView.text = text;
        
        //获取、设置字幕字体 Gets and sets the subtitle font
        NSString *fontFamily = [_caption getFontFamily:selectedIndex];
        for (NvCompoundCaptionModel *model in self.fontFamilyArr) {
            if ([model.fontName containsString:fontFamily]) {
                
                NvCompoundCaptionModel *defaultModel = self.fontFamilyArr[0];
                defaultModel.isSelected = NO;
                model.isSelected = YES;
                self.model = model;
            }
        }
        [self.fontCollectionView reloadData];
        
        //获取、设置字幕颜色 Gets and sets the subtitles color
        NvsColor color = [_caption getTextColor:selectedIndex];
        NvCaptionColorItem *item = [NvCaptionColorItem new];
        item.colorString = [NvUtils colorStringInARGBModeWithRGB:color];
        item.isSelect = YES;
        self.currentItem = item;

        [self.colorCollectionView reloadData];
        
    }
    _selectedIndex = selectedIndex;
}

#pragma mark - collectionViewDelegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.colorCollectionView) {
        return self.fontColorArr.count;
    }
    return self.fontFamilyArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.colorCollectionView) {
        NvCompoundColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCompoundColorCell" forIndexPath:indexPath];
        [cell renderCellWithItem:self.fontColorArr[indexPath.item]];
        return cell;
    }
    
    NvCompoundFontCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCompoundFontCell" forIndexPath:indexPath];
    NvCompoundCaptionModel *model = self.fontFamilyArr[indexPath.item];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.colorCollectionView) {
        for (NvCaptionColorItem *item in self.fontColorArr) {
            item.isSelect = NO;
        }
        NvCaptionColorItem *item = self.fontColorArr[indexPath.item];
        item.isSelect = YES;
        self.currentItem = item;
        [self.fontCollectionView reloadData];

    }else if (collectionView == self.fontCollectionView) {
        
        self.model.isSelected = NO;
        self.model = self.fontFamilyArr[indexPath.item];
        self.model.isSelected = YES;
        self.textView.font = [UIFont fontWithName:self.model.iosFontName size:14*SCREENSCALE];
        [self.fontCollectionView reloadData];
    }
    [self applyEffect];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    [self applyEffect];
}

@end
