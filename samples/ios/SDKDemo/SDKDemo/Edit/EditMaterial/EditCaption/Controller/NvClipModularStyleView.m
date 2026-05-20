//
//  NvClipModularStyleView.m
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvClipModularStyleView.h"
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

@interface NvClipModularStyleView ()<NvClipModularStyleVMUIDelegate,NvClipModularStyleVMAnimationDurationDelegate>

@property (nonatomic, strong) NvCaptionRendererView *rendererListView;
@property (nonatomic, strong) NvCaptionContextView *contextListView;
@property (nonatomic, strong) NvColorListview *colorListView;
@property (nonatomic, strong) NvStrokeListView *strokeListView;
@property (nonatomic, strong) NvBgColorListview *bgColorListView;
@property (nonatomic, strong) NvFontListView *fontListView;
@property (nonatomic, strong) NvCaptionSpaceView *spaceView;
@property (nonatomic, strong) NvAnimationView *animationView;
@property (nonatomic, strong) NvViewPager *viewPager;
@property (nonatomic, strong) NvDoubleSliderView *doubleSlider;
@property (nonatomic, strong) NvPositionListView *positionListView;
@property (nonatomic, strong) UISlider *comSlider;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UILabel *comLabel;
@property (nonatomic, weak) NvClipModularStyleVM* vm;

@end

@implementation NvClipModularStyleView

-(void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyleVM:(NvClipModularStyleVM*)vm {
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
    self.rendererListView.containFinishButton = YES;
    self.rendererListView.applyButton.hidden = YES;
    self.rendererListView.styleApplyLabel.hidden = YES;
    self.rendererListView.delegate = self.vm;
    self.animationView = [[NvAnimationView alloc] init];
    self.animationView.containFinishButton = YES;
    self.animationView.delegate = self.vm;
    self.contextListView = [[NvCaptionContextView alloc] init];
    self.contextListView.containFinishButton = YES;
    self.contextListView.applyButton.hidden = YES;
    self.contextListView.styleApplyLabel.hidden = YES;
    self.contextListView.delegate = self.vm;
    self.colorListView = [[NvColorListview alloc] init];
    self.colorListView.containFinishButton = YES;
    self.colorListView.delegate = self.vm;
    self.strokeListView = [[NvStrokeListView alloc] init];
    self.strokeListView.containFinishButton = YES;
    self.strokeListView.delegate = self.vm;
    self.bgColorListView = [NvBgColorListview new];
    self.bgColorListView.containFinishButton = YES;
    self.bgColorListView.delegate = self.vm;
    self.fontListView = [[NvFontListView alloc] init];
    self.fontListView.containFinishButton = YES;
    self.fontListView.selectColor = [UIColor nv_colorWithHexString:@"#EA4359" alpha:0.5];
    self.fontListView.delegate = self.vm;
    self.spaceView = [[NvCaptionSpaceView alloc] init];
    self.spaceView.containFinishButton = YES;
    self.spaceView.delegate = self.vm;
    self.positionListView = [[NvPositionListView alloc] init];
    self.positionListView.containFinishButton = YES;
    self.positionListView.delegate = self.vm;
    NSArray *titles = @[NvLocalString(@"Renderer", @"花字"),
                        NvLocalString(@"Animation", @"动画"),
                        NvLocalString(@"Context", @"气泡"),
                        NvLocalString(@"Filling", @"填充"),
                        NvLocalString(@"Stroke", @"描边"),
                        NvLocalString(@"Background", @"背景"),
                        NvLocalString(@"Font", @"字体"),
                        NvLocalString(@"Space", @"间距"),
                        NvLocalString(@"Position", @"位置")];
    
    NSArray *views = @[self.rendererListView,
                       self.animationView,
                       self.contextListView,
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
    self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.viewPager.top - 45*SCREENSCALE, SCREENWIDTH, 45*SCREENSCALE)];
    self.sliderView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.sliderView];
    self.doubleSlider = [[NvDoubleSliderView alloc] initWithFrame:CGRectMake(60*SCREENSCALE, 0, SCREENWIDTH-120*SCREENSCALE, 45*SCREENSCALE)];
    self.doubleSlider.minInterval = 0;
    [self.sliderView addSubview:self.doubleSlider];
    self.doubleSlider.duration = (self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000000.0;
    self.doubleSlider.hidden = true;
    __weak typeof(self) weakSelf = self;
    self.doubleSlider.sliderBtnLocationChangeBlock = ^(BOOL isLeft, BOOL finish){
        [weakSelf sliderValueChangeActionIsLeft:isLeft finish:finish];
    };
    
    self.comSlider = [[UISlider alloc] initWithFrame:CGRectMake(60*SCREENSCALE, 0, SCREENWIDTH-120*SCREENSCALE, 40*SCREENSCALE)];
    [self.sliderView addSubview:self.comSlider];
    int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000);
    self.comSlider.minimumValue = 0.1;
    ///最大值单位秒
    ///Maximum unit second
    self.comSlider.maximumValue = d/1000.0;
    self.comSlider.minimumTrackTintColor = [UIColor nv_colorWithHexString:@"#D8D8D8" alpha:1];
    self.comSlider.maximumTrackTintColor = [UIColor nv_colorWithHexString:@"#D8D8D8" alpha:1];
    [self.comSlider setThumbImage:NvImageNamed(@"NvsliderWhite") forState:UIControlStateNormal];
    [self.comSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.comSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    self.comSlider.hidden = true;
    self.comLabel = [[UILabel alloc] init];
    if (@available(iOS 8.2, *)) {
        self.comLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    } else {
        self.comLabel.font = [UIFont systemFontOfSize:10];
    }
    self.comLabel.textColor = [UIColor whiteColor];
    self.comLabel.alpha = 0.8;
    self.comLabel.text = @"0.0s";
    self.comLabel.textAlignment = NSTextAlignmentCenter;
    [self.comLabel sizeToFit];
    [self.comSlider addSubview:self.comLabel];
    self.comLabel.centerY = 0;
    self.comLabel.width = 30;
    
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
        self.doubleSlider.hidden = YES;
        [self hiddenComSliderOrNot];
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.comSlider.value = 0;
            self.comLabel.hidden = YES;
        }else {
            self.comLabel.hidden = NO;
        }
    }else {
        [self hiddenDoubleSliderOrNot];
        self.comSlider.hidden = YES;
    }
}

- (void)selectAnimation:(NvCaptionAnimationItem *)item type:(NvAnimationType)type inValue:(CGFloat)inVal outValue:(CGFloat)outVal {
    if (type == NvInAnimationType) {
        [self hiddenDoubleSliderOrNot];
        self.doubleSlider.hiddenLeftIcon = false;
        self.comSlider.hidden = true;
        self.doubleSlider.curMinValue = inVal;
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.doubleSlider.curMinValue = 0;
            self.doubleSlider.hiddenLeftIcon = true;
        }
        if (self.vm.currentCaption.modularCaptionOutAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionOutAnimationPackageId isEqualToString:@""]) {
            self.doubleSlider.curMaxValue = 1;
            self.doubleSlider.hiddenRightIcon = true;
        } else {
            self.doubleSlider.curMaxValue = outVal;
            self.doubleSlider.hiddenRightIcon = false;
        }
    } else if (type == NvOutAnimationType) {
        [self hiddenDoubleSliderOrNot];
        self.comSlider.hidden = true;
        self.doubleSlider.hiddenRightIcon = false;
        self.doubleSlider.curMaxValue = outVal;
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.doubleSlider.curMaxValue = 1;
            self.doubleSlider.hiddenRightIcon = true;
        }
        if (self.vm.currentCaption.modularCaptionInAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionInAnimationPackageId isEqualToString:@""]) {
            self.doubleSlider.curMinValue = 0;
            self.doubleSlider.hiddenLeftIcon = true;
        } else {
            self.doubleSlider.curMinValue = inVal;
            self.doubleSlider.hiddenLeftIcon = false;
        }
    } else if (type == NvComAnimationType) {
        self.doubleSlider.curMinValue = 0;
        self.doubleSlider.curMaxValue = 1;
        self.doubleSlider.hidden = true;

        [self hiddenComSliderOrNot];
        int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000);
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.comLabel.hidden = YES;
            self.comSlider.value = 0;
        }else {
            self.comLabel.hidden = NO;
            self.comSlider.value = outVal*(d/1000.0);
        }
        self.comLabel.text = [NSString stringWithFormat:@"%.1fs",outVal*(d/1000.0)];
        self.comLabel.centerX = outVal * (self.comSlider.width - self.comSlider.currentThumbImage.size.width) + self.comSlider.currentThumbImage.size.width/2;
    }
    [self.doubleSlider changeLocationFromValue];
}

- (void)didSelectIndex:(NSNotification *)noti {
    NSNumber *num = noti.object;
    NSInteger index = [num integerValue];
    if (index != 1) {
        self.sliderView.hidden = true;
    } else {
        self.sliderView.hidden = false;
        if ([self.animationView getCurrenntType] == NvComAnimationType) {
            if (self.comSlider.hidden) {
                [self hiddenComSliderOrNot];
                self.doubleSlider.hidden = true;
               
                self.comSlider.value = self.vm.currentCaption.getModularCaptionAnimationPeroid/1000.0;
            }
        } else {
            if (self.doubleSlider.hidden) {
                self.comSlider.hidden = true;
                [self hiddenDoubleSliderOrNot];
                
                int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000);
                if (self.vm.currentCaption.modularCaptionOutAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionOutAnimationPackageId isEqualToString:@""]) {
                    self.doubleSlider.curMaxValue = 1;
                    self.doubleSlider.hiddenRightIcon = true;
                } else {
                    self.doubleSlider.curMaxValue = (d-1.0*self.vm.currentCaption.getModularCaptionOutAnimationDuration)/d;
                    self.doubleSlider.hiddenRightIcon = false;
                }
                if (self.vm.currentCaption.modularCaptionInAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionInAnimationPackageId isEqualToString:@""]) {
                    self.doubleSlider.curMinValue = 0;
                    self.doubleSlider.hiddenLeftIcon = true;
                } else {
                    self.doubleSlider.curMinValue = (1.0*self.vm.currentCaption.getModularCaptionInAnimationDuration)/d;
                    self.doubleSlider.hiddenLeftIcon = false;
                }
                [self.doubleSlider changeLocationFromValue];
            }
        }
    }
}

///是否隐藏doubleSlider
///Whether to hide doubleSlider
- (void)hiddenDoubleSliderOrNot {
    self.doubleSlider.hidden = NO;
    if ((self.vm.currentCaption.modularCaptionInAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionInAnimationPackageId isEqualToString:@""]) && (self.vm.currentCaption.modularCaptionOutAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionOutAnimationPackageId isEqualToString:@""])) {
        self.doubleSlider.hidden = YES;
    }
}

- (void)hiddenComSliderOrNot {
    self.comSlider.hidden = NO;
    if (self.vm.currentCaption.modularCaptionAnimationPackageId == nil || [self.vm.currentCaption.modularCaptionAnimationPackageId isEqualToString:@""]) {
        self.comSlider.hidden = YES;
    }
}

- (void)sliderValueChangeActionIsLeft: (BOOL)isLeft finish: (BOOL)finish {
    int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000);
    CGFloat minValue = self.doubleSlider.curMinValue;
    CGFloat maxValue = self.doubleSlider.curMaxValue;
    if (isLeft) {
        self.doubleSlider.curMinValue = minValue;
        [self.vm setModularCaptionInAnimationDuration:(int)(d*minValue)];
    } else {
        self.doubleSlider.curMaxValue = maxValue;
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
    self.comSlider.value = value*d;
    [self setComSliderLabel];
}

- (void)inAnimationValue:(float)value {
    self.doubleSlider.curMinValue = value;
    [self.doubleSlider changeLocationFromValue];
}

- (void)outAnimationValue:(float)value {
    self.doubleSlider.curMaxValue = value;
    [self.doubleSlider changeLocationFromValue];
}

- (void)setComSliderLabel {
    int d = (int)((self.vm.currentCaption.outPoint - self.vm.currentCaption.inPoint)/1000000);
    self.comLabel.text = [NSString stringWithFormat:@"%.1fs",self.comSlider.value];
    self.comLabel.centerX = self.comSlider.value/d * (self.comSlider.width - self.comSlider.currentThumbImage.size.width) + self.comSlider.currentThumbImage.size.width/2;
}

@end
