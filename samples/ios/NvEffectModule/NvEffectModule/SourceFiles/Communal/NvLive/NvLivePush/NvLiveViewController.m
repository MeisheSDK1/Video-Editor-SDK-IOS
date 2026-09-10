//
//  NvLiveViewController.m
//  MeicamLive
//
//  Created by meishe on 2023/7/12.
//  Copyright © 2023 ms20180425. All rights reserved.
//

#import "NvLiveViewController.h"
#import "NvLiveAppEnv.h"
#import "Masonry.h"

@interface NvLiveViewController ()
<
NvLivePopViewDelegate
>
@property (nonatomic, strong, readwrite) NvLiveModel* liveModel;

@property (nonatomic, strong) NvLiveARSceneFilterView *filterView;

@property (nonatomic, strong) NvLiveARSceneFilterView *propView;

@property (nonatomic, strong) NvLiveARSceneMakeupView *makeupView;

@property (nonatomic, strong) NvLiveBeautyView *beautyView;

@end

@implementation NvLiveViewController

-(void)dealloc{
    NSLog(@"%s",__func__);
}

-(instancetype)initLiveModel:(NvLiveModel*)model{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.liveModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
 
    self.preview = [[UIView alloc]initWithFrame:self.view.bounds];
    self.preview.center = self.view.center;
    [self.view addSubview:self.preview];
    
    [self addMainView];
}

#pragma mark 加载/设置美颜数据 load/set beauty data
- (void)loadBeautyData{
    // Effect
    self.beautyViewModel = [[NvLiveBeautyViewModel alloc] init];
    
#if __has_include(<NveEffectKit/NveEffectKit.h>)
    
    NveBeauty *beauty = [self.beautyViewModel defaultBeauty];

    NveShape *shape = [self.beautyViewModel defaultShap];
    
    NveMicroShape *microShape = [self.beautyViewModel defaultMicroShap];
    
    NveEffectKit* effectKit = [NveEffectKit shareInstance];
    effectKit.beauty = beauty;
    effectKit.shape = shape;
    effectKit.microShape = microShape;
#else
    for (NvLiveBeautyTypeModel *model in self.beautyViewModel.beautyEffectArray) {
        [self.beautyViewModel.captureModularVM applyBeautyEffectModel:model withOpen:YES];
    }
    
    for (NvLiveBeautyTypeModel *model in self.beautyViewModel.beautyShapeArray) {
        [self.beautyViewModel.captureModularVM applyBeautyShapeModel:model withOpen:YES];
    }
    
    for (NvLiveBeautyTypeModel *model in self.beautyViewModel.beautyMicroArray) {
        [self.beautyViewModel.captureModularVM applyBeautyMicroshapingModel:model withOpen:YES];
    }
    
#endif

    self.filterViewModel = [[NvLiveFilterViewModel alloc] init];
    self.propViewModel = [[NvLivePropViewModel alloc] init];
    self.makeupViewModel = [[NvLiveMakeupViewModel alloc] init];

}



#pragma mark 添加主视图
- (void)addMainView{
    CGRect viewFrame = CGRectMake(15 * NvScreen(kScale),
                                  NvScreen(kStatusBarHeight) + 20 * NvScreen(kScale),
                                  NvScreen(kWidth) - 30 * NvScreen(kScale),
                                  NvScreen(kHeight) - NvScreen(kSafeAreaBottomHeight)
                                  - NvScreen(kSafeAreaTopHeight) - 50 * NvScreen(kScale));
    self.configView = [[NvLivePushConfigView alloc] initWithFrame:viewFrame];
    self.configView.backgroundColor = UIColor.clearColor;
    self.configView.delegate = self;
    [self.view addSubview:self.configView];
    
    [self addFunctionView];
    [self addGarbageView];
    
    self.operatingView.hidden = YES;
}

#pragma mark 添加功能视图
- (void)addFunctionView{
    //未选中封面图
    NSArray *tempArray = @[@"MSBeauty_off",@"MSProps_off",@"MSFilter_off",@"MSMakeup_off",@"capture_background_matting_image"];
    //选中封面图
    NSArray *tempArray_1 = @[@"MSBeauty_on",@"MSProps_on",@"MSFilter_on",@"MSMakeup_on",@"capture_background_matting_image"];
    NSArray *tempArray_2 = @[@(FunctionBeauty),@(FunctionArscene),@(FunctionFilter),@(FunctionMakeup),@(FunctionMatting)];
    NSArray *tempArray_3 = @[@"beauty",@"beauty_prop",@"beauty_filter",@"beauty_markup",@"Matting"];
    NSMutableArray *tempMutableArray = [NSMutableArray array];
    for (int i = 0; i < tempArray.count; i++) {
        NvLiveFunctionModel *model = [[NvLiveFunctionModel alloc]init];
        model.cover_unselected = tempArray[i];
        model.cover_selected = tempArray_1[i];
        model.functionType = [tempArray_2[i] intValue];
        model.name = NvLocalString(tempArray_3[i], tempArray_3[i]);
        [tempMutableArray addObject:model];
    }
    
    self.operatingView = [[NvLivePushOperatingView alloc]initWithFrame:CGRectMake(NvScreen(kWidth) - 60 * NvScreen(kScale) - 10 * NvScreen(kScale), NvScreen(kSafeAreaBottomHeight), 60 * NvScreen(kScale), tempMutableArray.count * (60 * NvScreen(kScale) + 10 * NvScreen(kScale)))];
    self.operatingView.backgroundColor = UIColor.clearColor;
    self.operatingView.delegate = self;
    [self.view addSubview:self.operatingView];
    
    [self.operatingView configData:tempMutableArray];
}

#pragma mark 添加垃圾箱视图,用于删除贴纸和字幕
- (void)addGarbageView{
    self.garbageView = [[NvLiveGarbageView alloc]initWithFrame:CGRectMake((NvScreen(kWidth) - 240 * NvScreen(kScale))/2.0, NvScreen(kHeight) - 120 * NvScreen(kScale), 240 * NvScreen(kScale), 120 * NvScreen(kScale))];
    self.garbageView.hidden = YES;
    [self.view addSubview:self.garbageView];
}

//MARK: -- NvLivePopViewDelegate
- (void)popViewDismissWithContentView:(UIView *)contentView {
    self.operatingView.hidden = NO;
}

#pragma mark NvLivePushConfigViewDelegate
- (void)start{
    self.operatingView.hidden = NO;
}

- (void)exit{
#if __has_include(<NveEffectKit/NveEffectKit.h>)
    

#else
    NvsStreamingContext * context = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit];
    [context removeAllCaptureVideoFx];
    [context setExposureBias:0.0];
    [context stop];
    [context clearCachedResources:NO];
    [NvsStreamingContext closeHumanDetection];
    [NvsStreamingContext destroyInstance];
#endif
}

- (void)switchCamera{
}

- (void)beauty{
  
}

#pragma mark NvLivePushOperatingViewDelegate
- (void)pushOperatingView:(NvLivePushOperatingView *)pushOperatingView withFunction:(NvLiveFunctionModel *)model{
    self.operatingView.hidden = YES;
    switch (model.functionType) {
        case FunctionArscene:
        {
            if (!self.filterView){
                self.filterView = [self.propViewModel createFilterView];
            }
            [NvLivePopView showView:self.filterView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
        }
            break;
        case FunctionFilter:
        {
            if (!self.propView){
                self.propView = [self.filterViewModel createFilterView];
            }
            [NvLivePopView showView:self.propView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
        }
            break;
        case FunctionBeauty:
        {
            if (!self.beautyView){
                CGRect viewFrame = CGRectMake(0, 0, NvScreen(kWidth), 285 * NvScreen(kScale) + NvScreen(kSafeAreaBottomHeight));
                self.beautyView = [[NvLiveBeautyView alloc] initWithFrame:viewFrame];
                self.beautyView.viewModel = self.beautyViewModel;
                [self.beautyViewModel configBeautyView:self.beautyView];
            }
            
            if (self.beautyView.viewModel.activeRefresh){
                [self.beautyView refreshUI];
                self.beautyView.viewModel.activeRefresh = NO;
            }
            
            [NvLivePopView showView:self.beautyView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
        }
            break;
        case FunctionMakeup:
        {
            if (!self.makeupView){
                self.makeupView = [self.makeupViewModel createMakeupView];
            }
            [NvLivePopView showView:self.makeupView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
        }
            break;
        case FunctionMatting:
        {
            [self applySegmentation];
            self.operatingView.hidden = NO;
        }
            break;
        case FunctionQuit:
            [self exit];
            break;
        default:
            self.operatingView.hidden = NO;
            break;
    }
}

- (void)applySegmentation{
#if __has_include(<NveEffectKit/NveEffectKit.h>)
    NSString *imagePath = [[[[NSBundle bundleForClass:[NvLiveEffectModule class]] bundlePath] stringByAppendingPathComponent:@"other.bundle"] stringByAppendingPathComponent:@"imageBg.jpg"];
    
    NveEffectKit* effectKit = [NveEffectKit shareInstance];
    
    NveFilter *fxSegmentation = nil;
    for (int i = 0; i < effectKit.rawFilterContainer.filters.count; i++) {
        NveFilter *fx = effectKit.rawFilterContainer.filters[i];
        if ([fx.effectId isEqualToString:@"Segmentation Background Fill"]){
            fxSegmentation = fx;
            break;
        }
    }
    
    if (fxSegmentation){
        [effectKit.rawFilterContainer remove:fxSegmentation];
    }else{
        fxSegmentation = [NveFilter filterWithEffectId:@"Segmentation Background Fill"];
        [fxSegmentation setEffectParam:@"Segment Type" type:NveParamType_MenuVal value:@"Half Body"];
        [fxSegmentation setEffectParam:@"Stretch Mode" type:NveParamType_int value:@(1)];
        [fxSegmentation setEffectParam:@"Tex File Path" type:NveParamType_string value:imagePath];
        [effectKit.rawFilterContainer append:fxSegmentation];
    }
    
#else
    NSString *imagePath = [[[[NSBundle bundleForClass:[NvLiveStreamingModule class]] bundlePath] stringByAppendingPathComponent:@"other.bundle"] stringByAppendingPathComponent:@"imageBg.jpg"];
    NvsStreamingContext *context = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit];
    NvsCaptureVideoFx *fxSegmentation = nil;
    for (int i = 0; i < context.getCaptureVideoFxCount; i++) {
        NvsCaptureVideoFx *fx = [context getCaptureVideoFxByIndex:i];
        if ([fx.bultinCaptureVideoFxName isEqualToString:@"Segmentation Background Fill"]){
            fxSegmentation = fx;
            break;
        }
    }
    
    if (fxSegmentation){
        [context removeCaptureVideoFx:fxSegmentation.index];
    }else{
        fxSegmentation =  [context insertBuiltinCaptureVideoFx:@"Segmentation Background Fill" withInsertPosition:0];
        [fxSegmentation setMenuVal:@"Segment Type" val:@"Half Body"];
        [fxSegmentation setIntVal:@"Stretch Mode" val:1];
        [fxSegmentation setStringVal:@"Tex File Path" val:imagePath];
    }
#endif
}

@end
