//
//  NvModularStyleView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2020/7/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvModularStyleView.h"
#import "NvViewPager.h"
#import "NVHeader.h"
#import "NvCaptionRendererView.h"
#import "NvAnimationView.h"
#import "NvColorListview.h"
#import "NvStrokeListView.h"
#import "NvFontListView.h"
#import "NvCaptionSpaceView.h"
#import "NvCaptionContextView.h"
#import "NvDoubleSliderView.h"

@interface NvModularStyleView ()<NvModularStyleVMUIDelegate ,NvModularStyleAnimationDurationDelegate,NvPageViewDelegate>

@property (nonatomic, strong) NvCaptionRendererView *rendererListView;
@property (nonatomic, strong) NvCaptionContextView *contextListView;
@property (nonatomic, strong) NvColorListview *colorListView;
@property (nonatomic, strong) NvStrokeListView *strokeListView;
@property (nonatomic, strong) NvBgColorListview *bgColorListView;
@property (nonatomic, strong) NvFontListView *fontListView;
@property (nonatomic, strong) NvCaptionSpaceView *spaceView;
@property (nonatomic, strong) NvAnimationView *animationView;
@property (nonatomic, strong) NvViewPager *viewPager;
@property (nonatomic, strong) NvPositionListView *positionListView;
@property (nonatomic, strong) NvFontRatioView *fontRatioView;
@property (nonatomic, strong) NvShadowListView *shadowListView;
@property (nonatomic, weak) NvModularStyleVM* vm;

@end

@implementation NvModularStyleView

-(void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyleVM:(NvModularStyleVM*)vm {
    if (self = [super init]) {
        self.vm = vm;
        self.vm.uiDelegate = self;
        self.vm.animationDelegate = self;
        [self initSubViews];
        [self loadData];
    }
    return self;
}

- (void)initSubViews {
    self.rendererListView = [[NvCaptionRendererView alloc] init];
    self.rendererListView.applyButton.hidden = YES;
    self.rendererListView.styleApplyLabel.hidden = YES;
    self.rendererListView.delegate = self.vm;
    self.animationView = [[NvAnimationView alloc] init];
    self.animationView.delegate = self.vm;
    self.contextListView = [[NvCaptionContextView alloc] init];
    self.contextListView.applyButton.hidden = YES;
    self.contextListView.styleApplyLabel.hidden = YES;
    self.contextListView.delegate = self.vm;
    self.colorListView = [[NvColorListview alloc] init];
    self.colorListView.delegate = self.vm;
    self.strokeListView = [[NvStrokeListView alloc] init];
    self.strokeListView.delegate = self.vm;
    self.bgColorListView = [NvBgColorListview new];
    self.bgColorListView.delegate = self.vm;
    self.fontListView = [[NvFontListView alloc] init];
    self.fontListView.delegate = self.vm;
    self.spaceView = [[NvCaptionSpaceView alloc] init];
    self.spaceView.delegate = self.vm;
    self.positionListView = [[NvPositionListView alloc] init];
    self.positionListView.delegate = self.vm;
    self.fontRatioView = [NvFontRatioView new];
    self.fontRatioView.delegate = self.vm;
    self.shadowListView = [NvShadowListView new];
    self.shadowListView.delegate = self.vm;
    UIView *inputView = [UIView new];
    NSArray *titles = @[NvLocalString(@"Input", @"输入"),
                        NvLocalString(@"Renderer", @"花字"),
                        NvLocalString(@"Animation", @"动画"),
                        NvLocalString(@"Context", @"气泡"),
                        NvLocalString(@"Filling", @"填充"),
                        NvLocalString(@"Stroke", @"描边"),
                        NvLocalString(@"shadow", @"阴影"),
                        NvLocalString(@"Background", @"背景"),
                        NvLocalString(@"Font", @"字体"),
                        NvLocalString(@"Space", @"间距"),
                        NvLocalString(@"Position", @"位置"),
                        NvLocalString(@"FontRatio", @"字号")];
    
    NSArray *views = @[inputView,
                       self.rendererListView,
                       self.animationView,
                       self.contextListView,
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
    self.viewPager.delegate = self;
    [self.viewPager insertFixedItemAtLastIndex:@"" imageName:@"nv_style_finish"];
    [self addSubview:self.viewPager];
    
    [self.animationView.comSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.animationView.comSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    __weak typeof(self) weakSelf = self;
    self.animationView.doubleSlider.sliderBtnLocationChangeBlock = ^(BOOL isLeft, BOOL finish){
        [weakSelf sliderValueChangeActionIsLeft:isLeft finish:finish];
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectIndex:) name:@"NvPagerViewSelected" object:nil];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
        if (hitTestView) {
            return hitTestView;
        }
    }
    return nil;
}

- (void)loadData {
    [self.vm searchFonts];
    [self.vm searchStyle];
    [self.vm searchCaptionRenderer];
    [self.vm searchCaptionContext];
    [self.vm searchCaptionAnimation];
    [self.vm searchCaptionInAnimation];
    [self.vm searchCaptionOutAnimation];
    [self.vm setDefaultTextBgRadius];
}
- (void)changeAnimation:(NvAnimationType)type data:(NvCaptionAnimationItem *)item {
    if (type == NvComAnimationType) {
        self.animationView.doubleSlider.hidden = YES;
        [self hiddenComSliderOrNot];
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.animationView.comSlider.value = 0;
            self.animationView.comLabel.hidden = YES;
        }else {
            self.animationView.comLabel.hidden = NO;
        }
    }else {
        [self hiddenDoubleSliderOrNot];
        self.animationView.comSlider.hidden = YES;
    }
}

- (void)changeSelectedItem:(NSInteger)index {
    [self.viewPager.categoryView changeItemWithTargetIndex:index];
}

- (void)selectAnimation:(NvCaptionAnimationItem *)item type:(NvAnimationType)type inValue:(CGFloat)inVal outValue:(CGFloat)outVal {
    if (type == NvInAnimationType) {
        [self hiddenDoubleSliderOrNot];
        self.animationView.doubleSlider.hiddenLeftIcon = false;
        self.animationView.comSlider.hidden = true;
        self.animationView.doubleSlider.curMinValue = inVal;
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.animationView.doubleSlider.curMinValue = 0;
            self.animationView.doubleSlider.hiddenLeftIcon = true;
        }
        if (self.vm.currentCaption.modularCaptionOutAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionOutAnimationPackageId isEqualToString:@""]) {
            self.animationView.doubleSlider.curMaxValue = 1;
            self.animationView.doubleSlider.hiddenRightIcon = true;
        } else {
            self.animationView.doubleSlider.curMaxValue = outVal;
            self.animationView.doubleSlider.hiddenRightIcon = false;
        }
    } else if (type == NvOutAnimationType) {
        [self hiddenDoubleSliderOrNot];
        self.animationView.comSlider.hidden = true;
        self.animationView.doubleSlider.hiddenRightIcon = false;
        self.animationView.doubleSlider.curMaxValue = outVal;
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.animationView.doubleSlider.curMaxValue = 1;
            self.animationView.doubleSlider.hiddenRightIcon = true;
        }
        if (self.vm.currentCaption.modularCaptionInAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionInAnimationPackageId isEqualToString:@""]) {
            self.animationView.doubleSlider.curMinValue = 0;
            self.animationView.doubleSlider.hiddenLeftIcon = true;
        } else {
            self.animationView.doubleSlider.curMinValue = inVal;
            self.animationView.doubleSlider.hiddenLeftIcon = false;
        }
    } else if (type == NvComAnimationType) {
        self.animationView.doubleSlider.curMinValue = 0;
        self.animationView.doubleSlider.curMaxValue = 1;
        self.animationView.doubleSlider.hidden = true;

        [self hiddenComSliderOrNot];
        int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000);
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.animationView.comLabel.hidden = YES;
            self.animationView.comSlider.value = 0;
        }else {
            self.animationView.comLabel.hidden = NO;
            self.animationView.comSlider.value = outVal*(d/1000.0);
        }
        self.animationView.comLabel.text = [NSString stringWithFormat:@"%.1fs",outVal*(d/1000.0)];
        self.animationView.comLabel.centerX = outVal * (self.animationView.comSlider.width - self.animationView.comSlider.currentThumbImage.size.width) + self.animationView.comSlider.currentThumbImage.size.width/2;
    }
    [self.animationView.doubleSlider changeLocationFromValue];
}

- (void)didSelectIndex:(NSNotification *)noti {
    NSNumber *num = noti.object;
    NSInteger index = [num integerValue];
    if (index != 2) {
        self.animationView.sliderView.hidden = true;
    } else {
        if (self.vm.currentCaption) {
            int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000);
            self.animationView.doubleSlider.duration = (self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000000.0;
            self.animationView.comSlider.maximumValue = d/1000.0;
        }
        self.animationView.sliderView.hidden = false;
        if ([self.animationView getCurrenntType] == NvComAnimationType) {
            if (self.animationView.comSlider.hidden) {
                [self hiddenComSliderOrNot];
                self.animationView.doubleSlider.hidden = true;
                
                self.animationView.comSlider.value = self.vm.currentCaption.getModularCaptionAnimationPeroid/1000.0;
            }
        } else {
            if (self.animationView.doubleSlider.hidden) {
                self.animationView.comSlider.hidden = true;
                [self hiddenDoubleSliderOrNot];
                
                int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000);
                if (self.vm.currentCaption.modularCaptionOutAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionOutAnimationPackageId isEqualToString:@""]) {
                    self.animationView.doubleSlider.curMaxValue = 1;
                    self.animationView.doubleSlider.hiddenRightIcon = true;
                } else {
                    self.animationView.doubleSlider.curMaxValue = (d-1.0*self.vm.currentCaption.getModularCaptionOutAnimationDuration)/d;
                    self.animationView.doubleSlider.hiddenRightIcon = false;
                }
                if (self.vm.currentCaption.modularCaptionInAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionInAnimationPackageId isEqualToString:@""]) {
                    self.animationView.doubleSlider.curMinValue = 0;
                    self.animationView.doubleSlider.hiddenLeftIcon = true;
                } else {
                    self.animationView.doubleSlider.curMinValue = (1.0*self.vm.currentCaption.getModularCaptionInAnimationDuration)/d;
                    self.animationView.doubleSlider.hiddenLeftIcon = false;
                }
                [self.animationView.doubleSlider changeLocationFromValue];
            }
        }
    }
}

- (void)hiddenDoubleSliderOrNot {
    self.animationView.doubleSlider.hidden = NO;
    if ((self.vm.currentCaption.modularCaptionInAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionInAnimationPackageId isEqualToString:@""]) && (self.vm.currentCaption.modularCaptionOutAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionOutAnimationPackageId isEqualToString:@""])) {
        self.animationView.doubleSlider.hidden = YES;
    }
}

- (void)hiddenComSliderOrNot {
    self.animationView.comSlider.hidden = NO;
    if (self.vm.currentCaption.modularCaptionAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionAnimationPackageId isEqualToString:@""]) {
        self.animationView.comSlider.hidden = YES;
    }
}

- (void)sliderValueChangeActionIsLeft: (BOOL)isLeft finish: (BOOL)finish {
    int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000);
    CGFloat minValue = self.animationView.doubleSlider.curMinValue;
    CGFloat maxValue = self.animationView.doubleSlider.curMaxValue;
    if (isLeft) {
        self.animationView.doubleSlider.curMinValue = minValue;
        [self.vm setModularCaptionInAnimationDuration:(int)(d*minValue)];
    } else {
        self.animationView.doubleSlider.curMaxValue = maxValue;
        [self.vm setModularCaptionOutAnimationDuration:(int)(d*(1-maxValue))];
    }
    if (finish) {
        [self.vm.delegate playTimeline:self.vm.currentCaption.inPoint end:self.vm.currentCaption.outPoint];
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    [self.vm setModularCaptionAnimationDuration:slider.value*1000];
    [self setComSliderLabel];
}

- (void)sliderValueEnd:(UISlider *)slider {
    [self.vm.delegate playTimeline:self.vm.currentCaption.inPoint end:self.vm.currentCaption.outPoint];
}

- (void)animationValue:(float)value {
    int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000000);
    self.animationView.comSlider.value = value*d;
    [self setComSliderLabel];
}

- (void)inAnimationValue:(float)value {
    self.animationView.doubleSlider.curMinValue = value;
    [self.animationView.doubleSlider changeLocationFromValue];
}

- (void)outAnimationValue:(float)value {
    self.animationView.doubleSlider.curMaxValue = value;
    [self.animationView.doubleSlider changeLocationFromValue];
}

- (void)setComSliderLabel {
    int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000000);
    self.animationView.comLabel.text = [NSString stringWithFormat:@"%.1fs",self.animationView.comSlider.value];
    if (d==0) {
        return;
    }
    self.animationView.comLabel.centerX = self.animationView.comSlider.value/d * (self.animationView.comSlider.width - self.animationView.comSlider.currentThumbImage.size.width) + self.animationView.comSlider.currentThumbImage.size.width/2;
}

- (CGFloat)getTitleHeight {
    return self.viewPager.categoryView.frame.size.height;
}

- (void)fixedItemClicked {
    if ([self.delegate respondsToSelector:@selector(fixedItemClicked)]) {
        [self.delegate fixedItemClicked];
    }
}
@end
