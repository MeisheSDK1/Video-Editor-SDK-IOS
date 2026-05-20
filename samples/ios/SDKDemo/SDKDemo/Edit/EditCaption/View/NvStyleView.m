//
//  NvStyleView.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/5.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvStyleView.h"
#import "NVHeader.h"
#import "NvViewPager.h"
#import "NvPositionListView.h"
#import "NvCaptionStyleItem.h"

@interface NvStyleView()<NvModularStyleVMUIDelegate,NvPageViewDelegate>

@property (nonatomic, strong) NvViewPager *viewPager;
@property (nonatomic, weak) NvModularStyleVM* vm;

@end

@implementation NvStyleView

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithStyleVM:(NvModularStyleVM*)vm {
    if (self = [super init]) {
        self.vm = vm;
        self.vm.uiDelegate = self;
        [self initSubViews];
        [self loadData];
    }
    return self;
}

- (void)loadData {
    [self.vm searchFonts];
    [self.vm searchStyle];
}

- (void)initSubViews {
    self.styleListView = [NvStyleListView new];
    self.styleListView.delegate = self.vm;
    self.colorListView = [NvColorListview new];
    self.colorListView.delegate = self.vm;
    self.strokeListView = [NvStrokeListView new];
    self.strokeListView.delegate = self.vm;
    self.bgColorListView = [NvBgColorListview new];
    self.bgColorListView.delegate = self.vm;
    self.fontListView = [NvFontListView new];
    self.fontListView.delegate = self.vm;
    self.spaceView = [NvCaptionSpaceView new];
    self.spaceView.delegate = self.vm;
    self.positionListView = [NvPositionListView new];
    self.positionListView.delegate = self.vm;
    self.fontRatioView = [NvFontRatioView new];
    self.fontRatioView.delegate = self.vm;
    self.shadowListView = [NvShadowListView new];
    self.shadowListView.delegate = self.vm;
    UIView *inputView = [UIView new];
    NSArray *titles = @[NvLocalString(@"Input", @"输入"),
                        NvLocalString(@"Style", @"样式"),
                        NvLocalString(@"Filling", @"填充"),
                        NvLocalString(@"Stroke", @"描边"),
                        NvLocalString(@"shadow", @"阴影"),
                        NvLocalString(@"Background", @"背景"),
                        NvLocalString(@"Font", @"字体"),
                        NvLocalString(@"Space", @"间距"),
                        NvLocalString(@"Position", @"位置"),
                        NvLocalString(@"FontRatio", @"字号")];

    NSArray *views = @[inputView,
                       self.styleListView,
                       self.colorListView,
                       self.strokeListView,
                       self.shadowListView,
                       self.bgColorListView,
                       self.fontListView,
                       self.spaceView,
                       self.positionListView,
                       self.fontRatioView];

    self.viewPager = [[NvViewPager alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 250*SCREENSCALE + INDICATOR) subViews:views subTitles:titles];
    self.viewPager.categoryView.originalIndex = 0;
    self.viewPager.categoryView.collectionView.backgroundColor = [UIColor nv_colorWithHexString:@"#242728"];
    self.viewPager.categoryView.titleNomalFont = [NvUtils fontWithSize:12];
    self.viewPager.categoryView.titleNormalColor = [UIColor nv_colorWithHexRGBA:@"#FFFFFF85"];
    self.viewPager.categoryView.titleSelectedFont = [NvUtils fontWithSize:12];
    self.viewPager.categoryView.titleSelectedColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.viewPager.categoryView.underlineHeight = 1.f*SCREENSCALE;
    self.viewPager.categoryView.shortUnderline = YES;
    [self.viewPager insertFixedItemAtLastIndex:@"" imageName:@"nv_style_finish"];
    self.viewPager.delegate = self;
    [self addSubview:self.viewPager];
}

- (void)fixedItemClicked {
    if ([self.delegate respondsToSelector:@selector(fixedItemClicked)]) {
        [self.delegate fixedItemClicked];
    }
}

- (CGFloat)getTitleHeight {
    return self.viewPager.categoryView.frame.size.height;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self.viewPager.categoryView changeItemWithTargetIndex:self.selectedIndex];
}

@end
