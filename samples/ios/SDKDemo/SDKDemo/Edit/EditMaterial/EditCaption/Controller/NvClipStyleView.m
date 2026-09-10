//
//  NvClipStyleView.m
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvClipStyleView.h"
#import "NVHeader.h"
#import "NvViewPager.h"
#import "NvPositionListView.h"
#import "NvCaptionStyleItem.h"

@interface NvClipStyleView()<NvClipModularStyleVMUIDelegate>

@property (nonatomic, strong) NvViewPager *viewPager;
@property (nonatomic, weak) NvClipModularStyleVM* vm;

@end

@implementation NvClipStyleView

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithStyleVM:(NvClipModularStyleVM*)vm {
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
    ///添加子Views
    ///Add child Views
    self.styleListView = [NvStyleListView new];
    self.styleListView.containFinishButton = YES;
    self.styleListView.delegate = self.vm;
    self.colorListView = [NvColorListview new];
    self.colorListView.containFinishButton = YES;
    self.colorListView.delegate = self.vm;
    self.strokeListView = [NvStrokeListView new];
    self.strokeListView.containFinishButton = YES;
    self.strokeListView.delegate = self.vm;
    self.bgColorListView = [NvBgColorListview new];
    self.bgColorListView.containFinishButton = YES;
    self.bgColorListView.delegate = self.vm;
    self.fontListView = [NvFontListView new];
    self.fontListView.containFinishButton = YES;
    self.fontListView.delegate = self.vm;
    self.spaceView = [NvCaptionSpaceView new];
    self.spaceView.containFinishButton = YES;
    self.spaceView.delegate = self.vm;
    self.positionListView = [NvPositionListView new];
    self.positionListView.containFinishButton = YES;
    self.positionListView.delegate = self.vm;

    NSArray *titles = @[NvLocalString(@"Style", @"样式"),
                        NvLocalString(@"Filling", @"填充"),
                        NvLocalString(@"Stroke", @"描边"),
                        NvLocalString(@"Background", @"背景"),
                        NvLocalString(@"Font", @"字体"),
                        NvLocalString(@"Space", @"间距"),
                        NvLocalString(@"Position", @"位置")];

    NSArray *views = @[self.styleListView,
                       self.colorListView,
                       self.strokeListView,
                       self.bgColorListView,
                       self.fontListView,
                       self.spaceView,
                       self.positionListView];
    self.viewPager = [[NvViewPager alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 250*SCREENSCALE + INDICATOR) subViews:views subTitles:titles];
    self.viewPager.categoryView.originalIndex = 0;
    self.viewPager.categoryView.collectionView.backgroundColor = [UIColor nv_colorWithHexString:@"#242728"];
    self.viewPager.categoryView.titleNomalFont = [NvUtils fontWithSize:12];
    self.viewPager.categoryView.titleNormalColor = [UIColor nv_colorWithHexRGBA:@"#FFFFFF85"];
    self.viewPager.categoryView.titleSelectedFont = [NvUtils fontWithSize:12];
    self.viewPager.categoryView.titleSelectedColor = [UIColor nv_colorWithHexString:@"#EA4359"];
    [self addSubview:self.viewPager];
}

@end
