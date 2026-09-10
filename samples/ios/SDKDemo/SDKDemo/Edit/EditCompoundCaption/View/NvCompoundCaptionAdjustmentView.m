//
//  NvCompoundCaptionAdjustmentView.m
//  SDKDemo
//
//  Created by ms on 2022/1/6.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvCompoundCaptionAdjustmentView.h"
#import "NVHeader.h"
#import "NvViewPager.h"

@interface NvCompoundCaptionAdjustmentView()
<NvCompoundCaptionStyleViewDelegate,
NvBgColorListviewDelegate,
NvFontListViewDelegate,
NvColorListviewDelegate,
NvPageViewDelegate>

@property (nonatomic, strong) NvViewPager *viewPager;


@property (nonatomic, assign) BOOL styleApplyAll;
@property (nonatomic, assign) BOOL strokeApplyAll;
@property (nonatomic, assign) BOOL colorBgApplyAll;

@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@property (nonatomic, strong) NvCaptionColorItem *colorItem;
@property (nonatomic, strong) NvCaptionStrokeItem *strokeItem;
@property (nonatomic, strong) NvCaptionFontItem *fontItem;
@end

@implementation NvCompoundCaptionAdjustmentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    ///添加子Views
    ///Add child Views
    self.compoundStyleView = [NvCompoundCaptionStyleView new];
    
    self.strokeListView = [NvStrokeListView new];
    self.strokeListView.delegate = self;
    self.strokeListView.applyButton.hidden = YES;
    self.strokeListView.styleApplyLabel.hidden = YES;
    
    self.fontListView = [NvFontListView new];
    self.fontListView.delegate = self;
    self.fontListView.italicButton.hidden = YES;

    self.fontListView.applyButton.hidden = YES;
    self.fontListView.underLineButton.hidden = YES;
    self.fontListView.styleApplyLabel.hidden = YES;

    self.colorListView = [[NvColorListview alloc] init];
    self.colorListView.delegate = self;
    self.colorListView.applyButton.hidden = YES;
    self.colorListView.styleApplyLabel.hidden = YES;
    
    self.bgColorListView = [NvBgColorListview new];
    self.bgColorListView.delegate = self;
    self.bgColorListView.isCompoundCaption = YES;
    self.bgColorListView.applyButton.hidden = YES;
    self.bgColorListView.styleApplyLabel.hidden= YES;
    self.bgColorListView.marginslider.hidden = YES;
    self.bgColorListView.marginLabel.hidden= YES;
    self.bgColorListView.marginNumLabel.hidden = YES;
    self.bgColorListView.radiusslider.hidden = YES;
    self.bgColorListView.radiusLabel.hidden = YES;
    self.bgColorListView.radiusNumLabel.hidden = YES;
    
    NSArray *titles = @[NvLocalString(@"Style", @"样式"),
                        NvLocalString(@"Stroke", @"描边"),
                        NvLocalString(@"Font", @"字体"),
                        NvLocalString(@"Filling", @"填充"),
                        NvLocalString(@"Background", @"背景")];

    NSArray *views = @[
                       self.compoundStyleView,
                       self.strokeListView,
                       self.fontListView,
                       self.colorListView,
                       self.bgColorListView,];
    self.viewPager = [[NvViewPager alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 250*SCREENSCALE + INDICATOR) subViews:views subTitles:titles];
    self.viewPager.categoryView.originalIndex = 0;
    self.viewPager.categoryView.collectionView.backgroundColor = [UIColor nv_colorWithHexString:@"#242728"];
    self.viewPager.categoryView.titleNomalFont = [NvUtils fontWithSize:12];
    self.viewPager.categoryView.titleNormalColor = [UIColor nv_colorWithHexRGBA:@"#FFFFFF85"];
    self.viewPager.categoryView.titleSelectedFont = [NvUtils fontWithSize:12];
    self.viewPager.categoryView.titleSelectedColor = [UIColor nv_colorWithHexString:@"#EA4359"];
    self.viewPager.isCompoundCaption = YES;
    [self.viewPager insertFixedItemAtLastIndex:@"" imageName:@"nv_style_finish"];
    self.viewPager.delegate = self;
    [self addSubview:self.viewPager];
    [self.fontListView.boldButton setTitle:NvLocalString(@"Italic", @"斜体") forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectIndex:) name:@"NvPagerViewSelected" object:nil];
}
- (void)setCaptionInfo:(NvCompoundCaptionInfoModel *)captionInfo{
    _captionInfo = captionInfo;
    self.viewPager.captionInfo = captionInfo;
}
- (void)didSelectIndex:(NSNotification *)noti {
    NSNumber *num = noti.object;
    NSInteger index = [num integerValue];
    if (index != 1) {
    } else {
    }
}

- (void)refreshAdjustView {
    if(self.selectedIndex == -1){
        return;
    }
    if (self.captionInfo.captionArr && self.captionInfo.captionArr.count > self.selectedIndex) {
        NvInnerCompoundCaptionModel *captionModel = self.captionInfo.captionArr[self.selectedIndex];
        
        ///描边界面
        ///Tracing boundary surface
        if(captionModel.isUserDrawOutline){
            [self.strokeListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionStrokeItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSelect = NO;
                NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
                if (rgb.count == 4) {
                    if (([rgb[0] floatValue] == captionModel.outlineColor.r) && ([rgb[1] floatValue] == captionModel.outlineColor.g) && ([rgb[2] floatValue] == captionModel.outlineColor.b) ) {
                        obj.isSelect = YES;
                    }
                }
            }];
            [self.strokeListView setDefaultDataSource:self.strokeListView.dataSource width:captionModel.outlineWidth/10. alpha:captionModel.outlineColor.a];
        }else{
            for(NvCaptionStrokeItem *obj in self.strokeListView.dataSource) {
                obj.isSelect = NO;
            }
            NvCaptionStrokeItem *obj = self.strokeListView.dataSource.firstObject;
            obj.isSelect = YES;
            obj.isNone = YES;
            [self.strokeListView setDefaultDataSource:self.strokeListView.dataSource width:captionModel.outlineWidth/10. alpha:captionModel.outlineColor.a];
        }
        
        
        ///背景颜色界面
        ///Background color interface
        if(captionModel.hasTextBgColor){
            NvsColor bgColor = captionModel.textBgColor;
            [self.bgColorListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionColorItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSelect = NO;
                NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
                if (rgb.count == 4) {
                    if (([rgb[0] floatValue] == bgColor.r) && ([rgb[1] floatValue] == bgColor.g) && ([rgb[2] floatValue] == bgColor.b) ) {
                        obj.isSelect = YES;
                    }
                }
            }];
            if ([self.bgColorListView respondsToSelector:@selector(setDefaultDataSource:alpha:)]) {
                [self.bgColorListView setDefaultDataSource:self.bgColorListView.dataSource alpha:bgColor.a];
            }
        }else{
            for (NvCaptionColorItem * obj in self.bgColorListView.dataSource) {
                obj.isSelect = NO;
            }
            NvCaptionColorItem * obj = self.bgColorListView.dataSource.firstObject;
            obj.isSelect = YES;
            if ([self.bgColorListView respondsToSelector:@selector(setDefaultDataSource:alpha:)]) {
                [self.bgColorListView setDefaultDataSource:self.bgColorListView.dataSource alpha:1.f];
            }
        }
        
        
        ///填充界面
        ///Filling interface
        if (captionModel.colorString.length > 0) {
            CGFloat r,g,b,a;
            [[UIColor nv_colorWithHexARGB:captionModel.colorString] getRed:&r green:&g blue:&b alpha:&a];
            NvsColor color = {r,g,b,a};
            [self.colorListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionColorItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSelect = NO;
                NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
                if (rgb.count == 4) {
                    if (([rgb[0] floatValue] == color.r) && ([rgb[1] floatValue] == color.g) && ([rgb[2] floatValue] == color.b) ) {
                        obj.isSelect = YES;
                    }
                }
            }];
            if ([self.colorListView respondsToSelector:@selector(setDefaultDataSource:alpha:)]) {
                [self.colorListView setDefaultDataSource:self.colorListView.dataSource alpha:color.a];
            }
        }else{
            if ([self.colorListView respondsToSelector:@selector(setDefaultDataSource:alpha:)]) {
                for (NvCaptionColorItem *obj in self.colorListView.dataSource) {
                    obj.isSelect = NO;
                }
                [self.colorListView setDefaultDataSource:self.colorListView.dataSource alpha:1.f];
            }
        }
        
        ///字体界面
        ///Font interface
        if (captionModel.fontFamily) {
            for (NvCaptionFontItem *item in self.fontDataSource) {
                if ([item.fontName isEqualToString:captionModel.fontFamily]) {
                    item.selected = YES;
                }else{
                    item.selected = NO;
                }
            }
            
        }else {
            for (NvCaptionFontItem *item in self.fontDataSource) {
                item.selected = NO;
            }
            NvCaptionFontItem *item = self.fontDataSource.firstObject;
            item.selected = YES;
        }
        [self.fontListView setDefauleDataSource:self.fontDataSource];
        ///组合字幕字体界面中斜体按钮其实用的是粗体按钮的button
        ///The italic button in the combined subtitle font interface is actually a button that uses the bold button
        [self.fontListView setDefaultFontBoldButton:captionModel.isItalic italic:NO shadow:NO underline:NO];
        
    }
}
#pragma mark - 点击确定
- (void)okClick {
    [self.streamingContext stop];
    if ([self.delegate respondsToSelector:@selector(styleOkButtonClick)]) {
        [self.delegate styleOkButtonClick];
    }
}

#pragma mark - 选择描边 Select stroke
//描边--颜色 Stroke -- Color
- (void)selectStroke:(NvCaptionStrokeItem *)item {
    self.strokeItem = item;
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self selectStroke:item with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self selectStroke:item with:innerModel];
    }
    [self playCaption:self.currentCaption];
}

- (void)selectStroke:(NvCaptionStrokeItem *)item with:(NvInnerCompoundCaptionModel *)innerModel{
    innerModel.isUserDrawOutline = YES;
    if (item.isNone) {
        innerModel.isDrawOutline = NO;
    } else {
        innerModel.isDrawOutline = YES;
        NvsColor color;
        NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            color.r = [rgb[0] floatValue];
            color.g = [rgb[1] floatValue];
            color.b = [rgb[2] floatValue];
            color.a = [rgb[3] floatValue];;
            innerModel.outlineColor = color;
        }
        innerModel.outlineWidth = item.width*10;
    }
    
    if (item.isNone) {
        [self.currentCaption setDrawOutline:NO captionIndex:(int)innerModel.index];
    } else {
        NvsColor color = [self.currentCaption getOutlineColor:(int)innerModel.index];
        NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            color.r = [rgb[0] floatValue];
            color.g = [rgb[1] floatValue];
            color.b = [rgb[2] floatValue];
            color.a = [rgb[3] floatValue];;
            innerModel.outlineColor = color;
            [self.currentCaption setDrawOutline:YES captionIndex:(int)innerModel.index];
            [self.currentCaption setOutlineColor:color captionIndex:(int)innerModel.index];
            [self.currentCaption setOutlineWidth:item.width*10 captionIndex:(int)innerModel.index];
        }
    }
}

//描边--宽度 Stroke -- width
- (void)selectStroke:(NvCaptionStrokeItem *)item withWidth:(CGFloat)width {
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self selectStroke:item withWidth:width with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self selectStroke:item withWidth:width with:innerModel];
    }
    [self nvseekTimeline];
}

- (void)selectStroke:(NvCaptionStrokeItem *)item withWidth:(CGFloat)width with:(NvInnerCompoundCaptionModel *)innerModel{
    innerModel.isUserDrawOutline = YES;
    innerModel.outlineWidth = width*10;
    [self.currentCaption setOutlineWidth:width*10 captionIndex:(int)innerModel.index];
}

// 描边--透明度 Stroke -- Transparency
- (void)selectStroke:(NvCaptionStrokeItem *)item withAlpha:(CGFloat)alpha {
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self selectStroke:item withAlpha:alpha with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self selectStroke:item withAlpha:alpha with:innerModel];
    }
    
    [self nvseekTimeline];
}

- (void)selectStroke:(NvCaptionStrokeItem *)item withAlpha:(CGFloat)alpha with:(NvInnerCompoundCaptionModel *)innerModel{
    innerModel.isUserDrawOutline = YES;
    NvsColor color1 = [self.currentCaption getOutlineColor:(int)innerModel.index];
    color1.a = alpha;
    
    innerModel.outlineColor = color1;
    [self.currentCaption setOutlineColor:color1 captionIndex:(int)innerModel.index];
}

#pragma mark - 选择背景颜色 Select background color
// 背景--颜色 Background - Color
- (void)selectBgColor:(NvCaptionColorItem *)item{
    self.colorItem = item;
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self selectBgColor:item with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self selectBgColor:item with:innerModel];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playCaption:self.currentCaption];
    });
}

- (void)selectBgColor:(NvCaptionColorItem *)item with:(NvInnerCompoundCaptionModel *)info{
    NvsColor color = [self.currentCaption getBackgroundColor:(int)info.index];
    NSArray *rgb = @[];
    if ([item.colorString isEqualToString:@"0"]) {
        rgb = @[@"0",@"0",@"0",@"0"];
    }else{
        rgb = [item.colorString componentsSeparatedByString:@","];
    }
    if (rgb.count == 4) {
        color.r = [rgb[0] floatValue];
        color.g = [rgb[1] floatValue];
        color.b = [rgb[2] floatValue];
        color.a = [rgb[3] floatValue];
        
        info.textBgColor = color;
        info.hasTextBgColor = YES;
        [self.currentCaption setBackgroundColor:color captionIndex:(int)info.index];
    }
}

// 背景--透明度 Background - Transparency
- (void)alphaBgChanged:(float)value{
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self alphaBgChanged:value with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self alphaBgChanged:value with:innerModel];
    }
    [self nvseekTimeline];
}

- (void)alphaBgChanged:(float)value with:(NvInnerCompoundCaptionModel *)info{
    NvsColor color = info.textBgColor;
    color.a = value;
    info.textBgColor = color;
    [self.currentCaption setBackgroundColor:color captionIndex:(int)info.index];
}

#pragma mark - 选择字体 Select font
- (void)selectFont:(NvCaptionFontItem *)item {
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self selectFont:item with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self selectFont:item with:innerModel];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playCaption:self.currentCaption];
    });
}

- (void)selectFont:(NvCaptionFontItem *)item with:(NvInnerCompoundCaptionModel *)info{
    info.fontFamily = item.fontName;
    
    if (item.fontName.length) {
        [self.currentCaption setFontFamily:info.index family:item.fontName];
    }else{
        [self.currentCaption setFontFamily:info.index family:@""];
    }
}

- (void)nvFontListView:(NvFontListView *)nvFontListView blodClick:(UIButton *)sender {
    ///使用bold 按钮，实现斜体效果
    ///Use the bold button to achieve the italic effect
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self nvFontListView:sender with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self nvFontListView:sender with:innerModel];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playCaption:self.currentCaption];
    });
}

- (void)nvFontListView:(UIButton *)sender with:(NvInnerCompoundCaptionModel *)innerModel{
    innerModel.isItalic = sender.selected;
    [self.currentCaption setItalic:innerModel.isItalic captionIndex:(int)innerModel.index];
}

#pragma mark - 填充 fill
- (void)selectColor:(NvCaptionColorItem *)item {
    self.colorItem = item;
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self selectColor:item with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self selectColor:item with:innerModel];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playCaption:self.currentCaption];
    });
}

- (void)selectColor:(NvCaptionColorItem *)item with:(NvInnerCompoundCaptionModel *)innerModel{
    NvsColor color ;
    NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
    if (rgb.count == 4) {
        color.r = [rgb[0] floatValue];
        color.g = [rgb[1] floatValue];
        color.b = [rgb[2] floatValue];
        color.a = [rgb[3] floatValue];

        innerModel.colorString = [NvUtils colorStringInARGBModeWithRGB:color];
        
        [self.currentCaption setTextColor:innerModel.index textColor:&color];
    }
}

- (void)alphaChanged:(float)value {
    if (self.selectedIndex == -1){
        for (NvInnerCompoundCaptionModel *innerModel in self.captionInfo.captionArr) {
            [self alphaChanged:value with:innerModel];
        }
    }else{
        NvInnerCompoundCaptionModel *innerModel = self.captionInfo.captionArr[self.selectedIndex];
        [self alphaChanged:value with:innerModel];
    }
    
    [self nvseekTimeline];
}

- (void)alphaChanged:(float)value with:(NvInnerCompoundCaptionModel *)innerModel{
    NvsColor color = [self.currentCaption getTextColor:innerModel.index];
    color.a = value;

    innerModel.colorString = [NvUtils colorStringInARGBModeWithRGB:color];
    [self.currentCaption setTextColor:innerModel.index textColor:&color];
}

- (void)playCaption:(NvsTimelineCompoundCaption *)currentCaption {
    if ([self.delegate respondsToSelector:@selector(CompoundCaptionAdjustmentViewDelegatePlayTimeline:end:)]) {
        [self.delegate CompoundCaptionAdjustmentViewDelegatePlayTimeline:currentCaption.inPoint end:currentCaption.outPoint];
    }
}

- (void)nvseekTimeline {
    if ([self.delegate respondsToSelector:@selector(CompoundCaptionAdjustmentViewDelegateNvseekTimeline)]) {
        [self.delegate CompoundCaptionAdjustmentViewDelegateNvseekTimeline];
    }
}

- (void)fixedItemClicked{
    if ([self.delegate respondsToSelector:@selector(styleOkButtonClick)]) {
        [self.delegate styleOkButtonClick];
    }
}
@end
