//
//  NvStickerAnimationController.m
//  SDKDemo
//
//  Created by ms on 2021/4/20.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvStickerAnimationController.h"
#import "NvsStreamingContext.h"
#import "NvStickerAnimationView.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvAsset.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvDoubleSliderView.h"
#import "NvMoreFilterViewController.h"
#import "NvAnimationSlider.h"
@interface NvStickerAnimationController ()<NvLiveWindowPanelViewDelegate, NvsStreamingContextDelegate,NvAssetManagerDelegate,NvAnimationViewDelegate,NvAnimationSliderDelegate>
@property (nonatomic, strong) NvStickerAnimationView *stickerView;
@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NvDoubleSliderView *doubleSlider;
@property (nonatomic, strong) NvAnimationSlider *comSlider;
@property (nonatomic, strong) NSMutableArray *stickerAnimationDataSource;
@property (nonatomic, strong) NSMutableArray *stickerInAnimationDataSource;
@property (nonatomic, strong) NSMutableArray *stickerOutAnimationDataSource;
@property (nonatomic, assign) NvStickerAnimationType animationType;


@end

@implementation NvStickerAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NvLocalString(@"Animation", @"动画");
    self.stickerAnimationDataSource = [NSMutableArray array];
    self.stickerInAnimationDataSource = [NSMutableArray array];
    self.stickerOutAnimationDataSource = [NSMutableArray array];
    [self.liveWindowPanel setForceHiddenControlPanel:YES];
    self.liveWindowPanel.delegate = self;
    self.liveWindowPanel.editMode = self.editMode;
    [self.liveWindowPanel addTapScreenPause];
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    [self initSubViews];
}


-(void)initSubViews{
    self.stickerView = [[NvStickerAnimationView alloc] init];
    self.stickerView.frame = CGRectMake(0, CGRectGetMaxY(self.liveWindowPanel.frame) + 40, SCREENWIDTH, 120);
    [self.view addSubview:self.stickerView];
    self.stickerView.delegate = self;
    [self.stickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(260.0f);
    }];

    self.doubleSlider = [[NvDoubleSliderView alloc] initWithFrame:CGRectMake(60*SCREENSCALE, 0, SCREENWIDTH-120*SCREENSCALE, 45*SCREENSCALE)];
    self.doubleSlider.minInterval = 0;
    [self.view addSubview:self.doubleSlider];
    self.doubleSlider.duration = (self.currentSticker.outPoint - self.currentSticker.inPoint)/1000000.0;
    self.doubleSlider.hidden = true;
    __weak typeof(self) weakSelf = self;
    self.doubleSlider.sliderBtnLocationChangeBlock = ^(BOOL isLeft, BOOL finish){
        [weakSelf sliderValueChangeActionIsLeft:isLeft finish:finish];
    };
    [self.doubleSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(60*SCREENSCALE);
        make.right.mas_equalTo(self.view).offset(-60*SCREENSCALE);
        make.bottom.mas_equalTo(self.stickerView.mas_top).offset(-20.0f);
        make.height.mas_equalTo(45.0f);
    }];
    
    self.comSlider = [[NvAnimationSlider alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH - 100.0f, 2 )];
    self.comSlider.minValue = 0;
    self.comSlider.maxValue = (self.currentSticker.outPoint - self.currentSticker.inPoint)/1000000.0;
    self.comSlider.lineHeight = 2.0f;
    self.comSlider.maximumTrackTintColor = [UIColor whiteColor];
    self.comSlider.thumbImageView.image = NvImageNamed(@"slider_thumb");
    self.comSlider.delegate = self;
    self.comSlider.hidden = YES;
    [self.view addSubview:self.comSlider];
    [self.comSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(50.0f);
        make.right.mas_equalTo(self.view).offset(-50.0f);
        make.bottom.mas_equalTo(self.stickerView.mas_top).offset(-20.0f);
        make.height.mas_equalTo(45.0f);
    }];
}


-(void)itemSlider:(NvAnimationSlider*)slider valueChanged:(float)value{
    [self setModularStickerAnimationDuration:slider.value*1000];
}

-(void)itemSliderTouchEnd:(NvAnimationSlider*)slider {
    [NvTimelineUtils playbackTimeline:self.timeline startTime:self.currentSticker.inPoint endTime:self.currentSticker.outPoint + 200000 flags:NvsStreamingEnginePlaybackFlag_LowPipelineSize|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

/**
 改变动画类型回调
 Change animation type callback

 @param type 动画类型
 animation type
 @param item 动画模型
 animation model
 */
- (void)changeAnimationType:(NvStickerAnimationType)type data:(NvStickerAnimationModel *)item{
    if (type == NvComStickerAnimationType) {
        self.doubleSlider.hidden = YES;
        [self hiddenComSliderOrNot];
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.comSlider.value = 0;
        }
    }else {
        [self hiddenDoubleSliderOrNot];
        self.comSlider.hidden = YES;
    }
    
}

//是否隐藏doubleSlider
//hide doubleslide or not
- (void)hiddenDoubleSliderOrNot {
    self.doubleSlider.hidden = NO;
    if ((self.currentSticker.animatedStickerInAnimationPackageId == nil || [self.currentSticker.animatedStickerInAnimationPackageId isEqualToString:@""]) && (self.currentSticker.animatedStickerOutAnimationPackageId == nil || [self.currentSticker.animatedStickerOutAnimationPackageId isEqualToString:@""])) {
        self.doubleSlider.hidden = YES;
    }
}

- (void)hiddenComSliderOrNot {
    self.comSlider.hidden = NO;
    if (self.currentSticker.animatedStickerPeriodAnimationPackageId == nil || [self.currentSticker.animatedStickerPeriodAnimationPackageId isEqualToString:@""]) {
        self.comSlider.hidden = YES;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self connectLiveWindow];
    [self searchStickerComAnimation];
    [self searchStickerOutAnimation];
    [self searchStickerInAnimation];
}

- (void)sliderValueChangeActionIsLeft: (BOOL)isLeft finish: (BOOL)finish {
    int d = (int)((self.currentSticker.outPoint - self.currentSticker.inPoint)/1000);
    CGFloat minValue = self.doubleSlider.curMinValue;
    CGFloat maxValue = self.doubleSlider.curMaxValue;
    if (isLeft) {
        self.doubleSlider.curMinValue = minValue;
        [self.currentSticker setAnimatedStickerInAnimationDuration:(int)(d*minValue)];
    } else {
        self.doubleSlider.curMaxValue = maxValue;
        [self.currentSticker setAnimatedStickerOutAnimationDuration:(int)(d*(1-maxValue))];
    }
    if (finish) {
        ///这个地方多播放200000微妙是为了让动画播的更完整，可以看清播动画放后是什么样子
        ///This place plays 200000 more subtle in order to make the animation broadcast more complete, you can see what the animation is like after playing
        [NvTimelineUtils playbackTimeline:self.timeline startTime:self.currentSticker.inPoint endTime:self.currentSticker.outPoint + 200000 flags:NvsStreamingEnginePlaybackFlag_LowPipelineSize|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    }
}


- (void)connectLiveWindow {
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindowPanel.currentTime];
}

/**
 配置组合动画数据
 Configure input animation data
 */
- (void)searchStickerComAnimation {
    [self.assetManager searchLocalAssets:ASSET_STICKER_ANIMATION];
    ///普通字幕样式
    ///Normal title style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"stickerAnimation" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_STICKER_ANIMATION bundlePath:itemPath];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_STICKER_ANIMATION aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    [self.stickerAnimationDataSource removeAllObjects];
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvStickerAnimationModel *item = [NvStickerAnimationModel new];
        item.imageUrl = asset.coverUrl;
        item.name = asset.displayName;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.stickerAnimationDataSource addObject:item];
    }
    NvStickerAnimationModel *item = [NvStickerAnimationModel new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = @"";
    item.isSelect = YES;
    [self.stickerAnimationDataSource insertObject:item atIndex:0];
    ///设置组合动画
    ///Set composite animation
    float value = 0;
    NSString *packageId = self.currentSticker.animatedStickerPeriodAnimationPackageId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvStickerAnimationModel *item in self.stickerAnimationDataSource) {
            item.isSelect = NO;
        }
        NvStickerAnimationModel *item = [self.stickerAnimationDataSource firstObject];
        item.isSelect = YES;
    } else {
        for (int i = 0; i < self.stickerAnimationDataSource.count; i++) {
            NvStickerAnimationModel *item = [self.stickerAnimationDataSource objectAtIndex:i];
            if ([item.packageId isEqualToString:packageId]) {
                item.isSelect = YES;
            } else {
                item.isSelect = NO;
            }
        }
        value = 1.0*self.currentSticker.getAnimatedStickerAnimationPeriod/((self.currentSticker.outPoint - self.currentSticker.inPoint)/1000);
    }
    [self animationValue:value];
    [self.stickerView renderListWithOpenItems:self.stickerAnimationDataSource withType:NvComStickerAnimationType];
}

- (void)animationValue:(float)value {
    int d = (int)((self.currentSticker.outPoint - self.currentSticker.inPoint)/1000000);
    self.comSlider.value = value*d;
}
/**
 配置入动画数据
 Configure input animation data
 */
- (void)searchStickerInAnimation {
    [self.assetManager searchLocalAssets:ASSET_STICKER_INANIMATION];
    ///普通字幕样式
    ///Normal title style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"stickerInAnimation" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_STICKER_INANIMATION bundlePath:itemPath];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_STICKER_INANIMATION aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    [self.stickerInAnimationDataSource removeAllObjects];;
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvStickerAnimationModel *item = [NvStickerAnimationModel new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.stickerInAnimationDataSource addObject:item];
        
    }
    NvStickerAnimationModel *item = [NvStickerAnimationModel new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = nil;
    item.isSelect = YES;
    [self.stickerInAnimationDataSource insertObject:item atIndex:0];
    ///设置入动画
    ///Set into animation
    float value = 0;
    NvStickerAnimationModel *selectItem;
    NSString *packageId = self.currentSticker.animatedStickerInAnimationPackageId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvStickerAnimationModel *item in self.stickerInAnimationDataSource) {
            item.isSelect = NO;
        }
        selectItem = [self.stickerInAnimationDataSource firstObject];
        selectItem.isSelect = YES;
    } else {
        for (int i = 0; i < self.stickerInAnimationDataSource.count; i++) {
            selectItem = [self.stickerInAnimationDataSource objectAtIndex:i];
            if ([selectItem.packageId isEqualToString:packageId]) {
                selectItem.isSelect = YES;
            } else {
                selectItem.isSelect = NO;
            }
        }
        value = 1.0*self.currentSticker.getAnimatedStickerInAnimationDuration/((self.currentSticker.outPoint - self.currentSticker.inPoint)/1000);
    }
    
    [self inAnimationValue:value];
    
    [self.stickerView renderListWithOpenItems:self.stickerInAnimationDataSource withType:NvInStickerAnimationType];
    [self selectAnimation:selectItem withAnimationType:NvInStickerAnimationType];
}
/**
 配置出动画数据
 Configure output animation data
 */
- (void)searchStickerOutAnimation {
    [self.assetManager searchLocalAssets:ASSET_STICKER_OUTANIMATION];
    ///普通字幕样式
    ///Normal title style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"stickerOutAnimation" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_STICKER_OUTANIMATION bundlePath:itemPath];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_STICKER_OUTANIMATION aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    [self.stickerOutAnimationDataSource removeAllObjects];
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvStickerAnimationModel *item = [NvStickerAnimationModel new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.stickerOutAnimationDataSource addObject:item];
        
    }
    NvStickerAnimationModel *item = [NvStickerAnimationModel new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = @"";
    item.isSelect = YES;
    [self.stickerOutAnimationDataSource insertObject:item atIndex:0];
    ///设置出动画
    ///set outanimate
    float value = 1;
    NSString *packageId = self.currentSticker.animatedStickerOutAnimationPackageId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvStickerAnimationModel *item in self.stickerOutAnimationDataSource) {
            item.isSelect = NO;
        }
        NvStickerAnimationModel *item = [self.stickerOutAnimationDataSource firstObject];
        item.isSelect = YES;
    } else {
        for (int i = 0; i < self.stickerOutAnimationDataSource.count; i++) {
            NvStickerAnimationModel *item = [self.stickerOutAnimationDataSource objectAtIndex:i];
            if ([item.packageId isEqualToString:packageId]) {
                item.isSelect = YES;
            } else {
                item.isSelect = NO;
            }
        }
        value = 1-1.0*self.currentSticker.getAnimatedStickerOutAnimationDuration/((self.currentSticker.outPoint - self.currentSticker.inPoint)/1000);
        
    }
    [self inAnimationValue:value];
    [self.stickerView renderListWithOpenItems:self.stickerOutAnimationDataSource withType:NvOutStickerAnimationType];
}
- (void)inAnimationValue:(float)value {
    self.doubleSlider.curMinValue = value;
    [self.doubleSlider changeLocationFromValue];
}

- (void)outAnimationValue:(float)value {
    self.doubleSlider.curMaxValue = value;
    [self.doubleSlider changeLocationFromValue];
}
/**
 配置素材数据
 Configure material data
 */
- (void)initReservedAssetName:(NvAsset *)asset {
    if ([asset isReserved]) {
        if ([asset.uuid isEqualToString:@"20870C92-4466-4E6F-B5F9-CD8FA107ABA6"]) {
            asset.displayName = NvLocalString(@"twinkle", @"闪烁");
        }
        if ([asset.uuid isEqualToString:@"E06A5FF1-0C7A-4FA1-93E9-5B1824EC6435"]) {
            asset.displayName = NvLocalString(@"Wiper", @"雨刷");
        }
        if ([asset.uuid isEqualToString:@"CD0E020E-FE12-4536-8C88-C480AF92F4B7"]) {
            asset.displayName = NvLocalString(@"pendulum", @"钟摆");
        }
        if ([asset.uuid isEqualToString:@"8007D7BA-88E9-4FB0-98C4-260AD5714BAF"]) {
            asset.displayName = NvLocalString(@"Zoom Out", @"放大");
        }
        if ([asset.uuid isEqualToString:@"ECF06228-5D1F-4728-80FB-0B1943A60C23"]) {
            asset.displayName = NvLocalString(@"Zoom In", @"缩小");
        }
        if ([asset.uuid isEqualToString:@"CC2B7B7D-39D2-4432-898E-AC62C66188B8"]) {
            asset.displayName = NvLocalString(@"BounceIn", @"弹入");
        }
        if ([asset.uuid isEqualToString:@"3ADAD718-359B-44AF-B33B-6E27E514B2ED"]) {
            asset.displayName = NvLocalString(@"BounceOut", @"弹出");;
        }
        if ([asset.uuid isEqualToString:@"409CA83D-76A5-4D2B-9522-5939A55FEC79"]) {
            asset.displayName = NvLocalString(@"FadeOut", @"淡出");
        }
        if ([asset.uuid isEqualToString:@"6B243A23-A3FB-4709-A16A-CF0E0292616F"]) {
            asset.displayName = NvLocalString(@"SpinOut", @"旋出");
        }
        
    }
}

- (void)okClick{
    
    for (NvStickerInfoModel *model in [NvTimelineData sharedInstance].stickerDataArray) {
        if ([model.packageId isEqualToString:self.currentStickerInfoModel.packageId]) {
            model.stickerAnimationInfo = self.currentStickerInfoModel.stickerAnimationInfo;
            break;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreAnimationClickWithAnimationType:(NvStickerAnimationType)type{
    if (type == NvInStickerAnimationType) {
        [self moreInAnimationClick];
    } else if (type == NvOutStickerAnimationType) {
        [self moreOutAnimationClick];
    } else {
        [self moreAnimationClick];
    }
}

///更多字幕组合动画
///More captions combined animation
- (void)moreAnimationClick {
    [self popToMoreFilterController:3 type:ASSET_STICKER_ANIMATION];
}

///更多字幕入动画
///More subtitles into the animation
- (void)moreInAnimationClick {
    [self popToMoreFilterController:1 type:ASSET_STICKER_INANIMATION];
}

///更多字幕出动画
///More subtitles for animation
- (void)moreOutAnimationClick {
    [self popToMoreFilterController:2 type:ASSET_STICKER_OUTANIMATION];
}

- (void)popToMoreFilterController:(int)kindId type:(AssetType)assetType {
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = assetType;
    vc.categoryId = 3;
    vc.kind = kindId;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)selectAnimation:(NvStickerAnimationModel *)item withAnimationType:(NvStickerAnimationType)type{
    self.animationType = type;
    int duration = (int)((self.currentSticker.outPoint - self.currentSticker.inPoint) / 1000);
    int inDuration = 0;
    int outDuration = 0;
    if (type == NvInStickerAnimationType) {
        
        if (item.packageId.length > 0) {
            inDuration = self.currentSticker.getAnimatedStickerInAnimationDuration;
            outDuration = self.currentSticker.getAnimatedStickerOutAnimationDuration;
            if (inDuration == 0) { inDuration = 500; }
        }else {
            inDuration = 0;
        }
        [self applyModularStickerInAnimation:item.packageId];
        if (item.packageId) {
            if (duration - outDuration < inDuration) {
                outDuration = duration - inDuration;
                [self.currentSticker setAnimatedStickerOutAnimationDuration:outDuration];
            }
            [self.currentSticker setAnimatedStickerInAnimationDuration:inDuration];
            
        }
        outDuration = self.currentSticker.getAnimatedStickerOutAnimationDuration;
        self.currentStickerInfoModel.stickerAnimationInfo.inputDuration = self.currentSticker.getAnimatedStickerInAnimationDuration;
        self.currentStickerInfoModel.stickerAnimationInfo.outputDuration = outDuration;
        [self playSticker:self.currentSticker animationType:type animationDuration:self.currentStickerInfoModel.stickerAnimationInfo.inputDuration*1000];
        
        [self selectAnimation:item type:type inValue:1.0 * self.currentStickerInfoModel.stickerAnimationInfo.inputDuration / duration outValue:(1 - 1.0 * self.currentStickerInfoModel.stickerAnimationInfo.outputDuration / duration)];
        
    } else if (type ==  NvOutStickerAnimationType) {
        if (item.packageId.length > 0) {
            inDuration = self.currentSticker.getAnimatedStickerInAnimationDuration;
            outDuration = self.currentSticker.getAnimatedStickerOutAnimationDuration;
            if (outDuration == 0) { outDuration = 500; }
        }else {
            outDuration = 0;
        }
        [self applyModularStickerOutAnimation:item.packageId];
        if (duration - inDuration < outDuration) {
            inDuration = duration - outDuration;
            [self.currentSticker setAnimatedStickerInAnimationDuration:inDuration];
        }
        [self.currentSticker setAnimatedStickerOutAnimationDuration:outDuration];
        inDuration = self.currentSticker.getAnimatedStickerInAnimationDuration;
        self.currentStickerInfoModel.stickerAnimationInfo.outputDuration = self.currentSticker.getAnimatedStickerOutAnimationDuration;
        self.currentStickerInfoModel.stickerAnimationInfo.inputDuration = inDuration;
        [self playSticker:self.currentSticker animationType:type animationDuration:self.currentStickerInfoModel.stickerAnimationInfo.outputDuration*1000];
        [self selectAnimation:item type:type inValue:1.0 * self.currentStickerInfoModel.stickerAnimationInfo.inputDuration / duration outValue:(1 - 1.0 * self.currentStickerInfoModel.stickerAnimationInfo.outputDuration / duration)];
    } else {
        if (item.packageId.length > 0) {
            if (outDuration == 0) { outDuration = 600; }
        }else {
            outDuration = 0;
        }
        [self applyModularStickerAnimation:item.packageId];
        [self.currentSticker setAnimatedStickerAnimationPeriod:outDuration];
        self.currentStickerInfoModel.stickerAnimationInfo.stickerDuration = self.currentSticker.getAnimatedStickerAnimationPeriod;
        [self playSticker:self.currentSticker animationType:type animationDuration:self.currentStickerInfoModel.stickerAnimationInfo.stickerDuration*1000];
        [self selectAnimation:item type:type inValue:1.0 * self.currentStickerInfoModel.stickerAnimationInfo.stickerDuration / duration outValue:1.0 * self.currentStickerInfoModel.stickerAnimationInfo.stickerDuration / duration];
    }
}

- (void)selectAnimation:(NvStickerAnimationModel *)item type:(NvStickerAnimationType)type inValue:(CGFloat)inVal outValue:(CGFloat)outVal {
    if (type == NvInStickerAnimationType) {
        [self hiddenDoubleSliderOrNot];
        self.doubleSlider.hiddenLeftIcon = false;
        self.comSlider.hidden = true;
        self.doubleSlider.curMinValue = inVal;
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.doubleSlider.curMinValue = 0;
            self.doubleSlider.hiddenLeftIcon = true;
        }
        if (self.currentSticker.animatedStickerOutAnimationPackageId == nil || [self.currentSticker.animatedStickerOutAnimationPackageId isEqualToString:@""]) {
            self.doubleSlider.curMaxValue = 1;
            self.doubleSlider.hiddenRightIcon = true;
        } else {
            self.doubleSlider.curMaxValue = outVal;
            self.doubleSlider.hiddenRightIcon = false;
        }
    } else if (type == NvOutStickerAnimationType) {
        [self hiddenDoubleSliderOrNot];
        self.comSlider.hidden = true;
        self.doubleSlider.hiddenRightIcon = false;
        self.doubleSlider.curMaxValue = outVal;
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.doubleSlider.curMaxValue = 1;
            self.doubleSlider.hiddenRightIcon = true;
        }
        if (self.currentSticker.animatedStickerInAnimationPackageId == nil || [self.currentSticker.animatedStickerInAnimationPackageId isEqualToString:@""]) {
            self.doubleSlider.curMinValue = 0;
            self.doubleSlider.hiddenLeftIcon = true;
        } else {
            self.doubleSlider.curMinValue = inVal;
            self.doubleSlider.hiddenLeftIcon = false;
        }
    } else if (type == NvComStickerAnimationType) {
        self.doubleSlider.curMinValue = 0;
        self.doubleSlider.curMaxValue = 1;
        self.doubleSlider.hidden = true;
        
        [self hiddenComSliderOrNot];
        int d = (int)((self.currentSticker.outPoint - self.currentSticker.inPoint)/1000);
        if (item.packageId == nil || [item.packageId isEqualToString:@""]) {
            self.comSlider.value = 0;
        }else {
            self.comSlider.value = outVal*(d/1000.0);
        }
    }
    [self.doubleSlider changeLocationFromValue];
}



- (void)playSticker:(NvsTimelineAnimatedSticker *)currentSticker animationType:(NvStickerAnimationType)type animationDuration:(int64_t)duration {
    int64_t inPoint;
    if (type == NvInStickerAnimationType) {
        inPoint = currentSticker.inPoint;
    } else if (type == NvOutStickerAnimationType) {
        inPoint = currentSticker.outPoint - duration;
    } else {
        inPoint = currentSticker.inPoint;
        duration = currentSticker.outPoint - inPoint;
    }
    [self playTimeline:inPoint end:inPoint + duration];
    
}

- (void)playTimeline:(int64_t)start end:(int64_t)end {
    ///这个地方多播放200000微妙是为了让动画播的更完整，可以看清播动画放后是什么样子
    ///This place plays 200000 more subtle in order to make the animation broadcast more complete, you can see what the animation is like after playing
    [NvTimelineUtils playbackTimeline:self.timeline startTime:start endTime:end + 200000 flags:NvsStreamingEnginePlaybackFlag_LowPipelineSize|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}


#pragma mark - 选择入动画 Select in animation
- (void)applyModularStickerInAnimation:(NSString *)inAnimationId {
    if (inAnimationId && ![inAnimationId isEqualToString:@""]) {
        [self.currentSticker applyAnimatedStickerPeriodAnimation:nil];
    }
    [self.currentSticker applyAnimatedStickerInAnimation:inAnimationId];
    self.currentStickerInfoModel.stickerAnimationInfo.inputId = inAnimationId;
    self.currentStickerInfoModel.stickerAnimationInfo.stickerId = nil;
    self.currentStickerInfoModel.stickerAnimationInfo.type = StickerInOutput;
}
- (void)setModularStickerInAnimationDuration:(int)duration {
    [self.currentSticker setAnimatedStickerInAnimationDuration:duration];
    self.currentStickerInfoModel.stickerAnimationInfo.inputDuration = [self.currentSticker getAnimatedStickerInAnimationDuration];
}
#pragma mark - 出动画 out animation
- (void)applyModularStickerOutAnimation:(NSString *)outAnimationId {
    [self.currentSticker applyAnimatedStickerPeriodAnimation:nil];
    [self.currentSticker applyAnimatedStickerOutAnimation:outAnimationId];
    self.currentStickerInfoModel.stickerAnimationInfo.outputId = outAnimationId;
    self.currentStickerInfoModel.stickerAnimationInfo.stickerId = nil;
    self.currentStickerInfoModel.stickerAnimationInfo.type = StickerInOutput;
}
- (void)setModularStickerOutAnimationDuration:(int)duration {
    [self.currentSticker setAnimatedStickerOutAnimationDuration:duration];
    self.currentStickerInfoModel.stickerAnimationInfo.outputDuration = self.currentSticker.getAnimatedStickerOutAnimationDuration;
}
#pragma mark - 组合动画 Composite animation
- (void)applyModularStickerAnimation:(NSString *)captionAnimationId {
    [self.currentSticker applyAnimatedStickerInAnimation:nil];
    [self.currentSticker applyAnimatedStickerOutAnimation:nil];
    [self.currentSticker applyAnimatedStickerPeriodAnimation:captionAnimationId];
    self.currentStickerInfoModel.stickerAnimationInfo.stickerId = captionAnimationId;
    self.currentStickerInfoModel.stickerAnimationInfo.type = StickerCom;
    self.currentStickerInfoModel.stickerAnimationInfo.inputId = nil;
    self.currentStickerInfoModel.stickerAnimationInfo.outputId = nil;
}
- (void)setModularStickerAnimationDuration:(int)duration {
    [self.currentSticker setAnimatedStickerAnimationPeriod:duration];
    self.currentStickerInfoModel.stickerAnimationInfo.stickerDuration = self.currentSticker.getAnimatedStickerAnimationPeriod;
}


@end
