//
//  NvARScenePreview.m
//  NvTest
//
//  Created by ms20180425 on 2022/8/23.
//

#import "NvARScenePreview.h"
#import "UIColor+NvColor.h"
#import "NvARSceneMacro.h"
#import "NvCaptureFilterModel.h"
#import "YYModel.h"
#import "NvARSceneFilterView.h"
#import "NvBeautyView.h"
#import "NvARSceneMakeupView.h"
#import "NvARLocalString.h"

@interface NvARScenePreview ()<NvBeautyViewDelegate,NvARSceneFilterViewDelegate,NvARSceneMakeupViewDelegate>

@property (nonatomic, assign) NvsEffectRational rational;

@property (nonatomic, strong) NvBeautyView *beautyView;

@property (nonatomic, strong) NvARSceneFilterView *filterView;

@property (nonatomic, strong) NvARSceneMakeupView *makeupView;

@end

@implementation NvARScenePreview

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.extraHeight = 0;
        self.rational = (NvsEffectRational){9,16};
    }
    return self;
}
- (NSMutableDictionary *)getMakeUpInfo{
    return self.makeupView.makeUpInfo;
}
#pragma mark 添加美颜视图
- (void)addBeautyView{
    self.beautyView = [[NvBeautyView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SafeAreaBottomHeight - 285 * SCREENSCALE - self.extraHeight, SCREEN_WIDTH, 285 * SCREENSCALE + SafeAreaBottomHeight + self.extraHeight)];
    [self addSubview:self.beautyView];
    
    self.beautyView.delegate = self;
    [self.beautyView.beautyBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyView.beautyTypeBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyView.beautyTypeMicroBtn addTarget:self action:@selector(beautyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyView.beautySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyView.beautyTypeSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.beautyView.beautyTypeMicroSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self configArray];
}

- (void)configArray{
    NvBeautyTypeModel *model = self.ARSceneFxOperator.beautyEffectArray[1];
    model.selected = YES;
    
    NvBeautyTypeModel *model1 = self.ARSceneFxOperator.beautyShapeArray.firstObject;
    model1.selected = YES;
    
    NvBeautyTypeModel *model2 = self.ARSceneFxOperator.beautyMicroArray.firstObject;
    model2.selected = YES;
    
    
    [self.beautyView configBeautyArray:self.ARSceneFxOperator.beautyEffectArray];
    [self.beautyView configBeautyByteArray:self.ARSceneFxOperator.beautyShapeArray];
    [self.beautyView configBeautyTypeMicroArray:self.ARSceneFxOperator.beautyMicroArray];
    
    self.beautyView.beautySwitch.selected = NO;
    self.beautyView.beautyTypeSwitch.selected = NO;
    self.beautyView.beautyTypeMicroSwitch.selected = NO;
      
    [self switchAction:self.beautyView.beautySwitch];
    [self switchAction:self.beautyView.beautyTypeSwitch];
    [self switchAction:self.beautyView.beautyTypeMicroSwitch];
    
    for (NvBeautyTypeModel *model in self.ARSceneFxOperator.beautyEffectArray) {
        if ([self.ARSceneFxOperator applicationDefaultBeautyEffect:model]) {
            [self.ARSceneFxOperator applicationBeautyEffect:model];
        }
        if ([model.name isEqualToString:@"校色"] || [model.name isEqualToString:@"color correction"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(correctionFilterDictionary:)]) {
                [self.delegate correctionFilterDictionary:[model yy_modelToJSONObject]];
            }
        }
    }
    
    for (NvBeautyTypeModel *model in self.ARSceneFxOperator.beautyShapeArray) {
        [self.ARSceneFxOperator applicationBeautyShapeAndMicro:model];
    }
    
    for (NvBeautyTypeModel *model in self.ARSceneFxOperator.beautyMicroArray) {
        [self.ARSceneFxOperator applicationBeautyShapeAndMicro:model];
    }
    
    self.beautyView.hiddenInteger = 0;
}

#pragma mark 添加滤镜视图
- (void)addFilterView{
    self.filterView = [[NvARSceneFilterView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SafeAreaBottomHeight - 285 * SCREENSCALE - self.extraHeight, SCREEN_WIDTH, 285 * SCREENSCALE + SafeAreaBottomHeight + self.extraHeight)];
    self.filterView.delegate = self;
    [self addSubview:self.filterView];
    
    [self configFilterArray];
}

- (void)configFilterArray{
    NSString *filterPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"filter"];
    NSString *jsonPath = [filterPath stringByAppendingPathComponent:@"filter.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSArray *array = [NSArray yy_modelArrayWithClass:NvCaptureFilterModel.class json:data];
    for (NvCaptureFilterModel *model in array) {
        model.coverName = [filterPath stringByAppendingPathComponent:model.coverName];
        if (model.packagePath && model.packagePath.length > 0) {
            model.packagePath = [filterPath stringByAppendingPathComponent:model.packagePath];
            model.packageId = [[NvARSceneAssetManager sharedInstance] installAssetPackage:model.packagePath licPath:nil assetType:NvsAssetPackageType_VideoFx];
        }
    }

    [self.filterView configFilterArray:[NSMutableArray arrayWithArray:array]];
}

#pragma mark - 添加美妆视图
- (void)addMakeupView{
    self.makeupView = [[NvARSceneMakeupView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SafeAreaBottomHeight - 160 * SCREENSCALE, SCREEN_WIDTH, 160 * SCREENSCALE + SafeAreaBottomHeight)];
    self.makeupView.delegate = self;
    [self addSubview:self.makeupView];
    
    [self configMakeupArray];
}

#pragma mark - 添加美妆视图
- (void)configMakeupArray{
    [self.makeupView configData:self.ARSceneFxOperator.beautyMakeupArray];
}

#pragma mark - 检测手机是否支持某个能力，不支持的就删除，然后更新数据
/// Check if the phone supports a capability, delete if it doesn't, and update the data
- (void)detectionCapability{
    [self.ARSceneFxOperator detectionCapability];
    
    BOOL isHave = NO;
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    for (NvBeautyTypeModel *model in self.beautyView.getBeautyArrayData) {
        for (NvBeautyTypeModel *model_1 in self.ARSceneFxOperator.beautyEffectArray) {
            if ([model.name isEqualToString:model_1.name]) {
                isHave = YES;
            }
        }
        if (isHave) {
            isHave = NO;
        }else{
            NSInteger index = [self.beautyView.getBeautyArrayData indexOfObject:model];
            [mutableArray addObject:@(index)];
        }
    }
    
    for (NSNumber *number in mutableArray) {
        [self.beautyView.getBeautyArrayData removeObjectAtIndex:number.integerValue];
    }
    
    [self.beautyView refreshUI];
}

#pragma mark 美颜视图，美颜按钮点击事件
/// Beauty view, beauty button click event
- (void)beautyClick:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"美颜"] || [sender.titleLabel.text isEqualToString:@"beauty"]) {
        self.beautyView.hiddenInteger = 0;
    }else if([sender.titleLabel.text isEqualToString:@"美型"] || [sender.titleLabel.text isEqualToString:@"beautyShape"]){
        self.beautyView.hiddenInteger = 1;
    }else{
        self.beautyView.hiddenInteger = 2;
    }
}

#pragma mark 美颜、美型、微整形开启、关闭换事件处理
/// Beauty, beauty, micro plastic open, close exchange event processing
- (void)switchAction:(NvSwitchView* )sender{
    if (sender.selected) {
        //关闭
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#A2A2A2"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = NO;
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(2, 2, sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
        [self.beautyView editBool:NO withType:sender.tag - 2000];
    }else {
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = YES;
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(sender.sliderView.frame.size.width, 2,sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
        [self.beautyView editBool:YES withType:sender.tag - 2000];
    }
}

- (void)showBeautyView:(BOOL)hidden{
    self.hidden = !hidden;
    self.beautyView.hidden = !hidden;
}

- (void)showFilterView:(BOOL)hidden{
    self.hidden = !hidden;
    self.filterView.hidden = !hidden;
}

- (void)showMakeupView:(BOOL)hidden{
    self.hidden = !hidden;
    self.makeupView.hidden = !hidden;
}

#pragma mark - 点击屏幕交互
///Tap screen interaction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    CGPoint point = CGPointZero;
    
    if (!self.beautyView.hidden && self.beautyView) {
        point = [self.beautyView.layer convertPoint:currentPoint fromLayer:self.layer];
        if (![self.beautyView.layer containsPoint:point]) {
            [self showBeautyView:NO];
            [super touchesBegan:touches withEvent:event];
        }
    }else if(!self.filterView.hidden && self.filterView){
        point = [self.filterView.layer convertPoint:currentPoint fromLayer:self.layer];
        if (![self.filterView.layer containsPoint:point]) {
            [self showFilterView:NO];
            [super touchesBegan:touches withEvent:event];
        }
    }else if(!self.makeupView.hidden && self.makeupView){
        point = [self.makeupView.layer convertPoint:currentPoint fromLayer:self.layer];
        if (![self.makeupView.layer containsPoint:point]) {
            [self showMakeupView:NO];
            [super touchesBegan:touches withEvent:event];
        }
    }
}

#pragma mark - NvBeautyViewDelegate
- (void)nvBeautyView:(NvBeautyView *)beautyView withModel:(NvBeautyTypeModel *)model withState:(BOOL)state{
    if (model.isBeauty) {
        [self.ARSceneFxOperator applicationBeautyEffect:model];
        if ([model.name isEqualToString:@"校色"] || [model.name isEqualToString:@"color correction"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(correctionFilterDictionary:)]) {
                [self.delegate correctionFilterDictionary:[model yy_modelToJSONObject]];
            }
        }
    }else{
        [self.ARSceneFxOperator applicationBeautyShapeAndMicro:model];
    }
}

- (void)nvBeautyView:(NvBeautyView *)beautyView withModelArray:(NSMutableArray *)array{
    if (beautyView.hiddenInteger == 0) {
        for (NvBeautyTypeModel *model in array) {
            if ([self.ARSceneFxOperator applicationDefaultBeautyEffect:model]) {
                [self.ARSceneFxOperator applicationBeautyEffect:model];
                if ([model.name isEqualToString:@"校色"] || [model.name isEqualToString:@"color correction"]) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(correctionFilterDictionary:)]) {
                        [self.delegate correctionFilterDictionary:[model yy_modelToJSONObject]];
                    }
                }
            }
        }
    }else{
        for (NvBeautyTypeModel *model in array) {
            [self.ARSceneFxOperator applicationBeautyShapeAndMicro:model];
        }
    }
}

- (void)nvBeautyView:(NvBeautyView *)beautyView withModelArray:(NSMutableArray *)array withOpen:(BOOL)open{
    if (beautyView.hiddenInteger == 0) {
        for (NvBeautyTypeModel *model in array) {
            if (open) {
                if ([self.ARSceneFxOperator applicationDefaultBeautyEffect:model]) {
                    [self.ARSceneFxOperator applicationBeautyEffect:model];
                }
            }else{
                [self.ARSceneFxOperator applicationBeautyEffect:model];
            }
            if ([model.name isEqualToString:@"校色"] || [model.name isEqualToString:@"color correction"]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(correctionFilterDictionary:)]) {
                    [self.delegate correctionFilterDictionary:[model yy_modelToJSONObject]];
                }
            }
        }
    }else{
        for (NvBeautyTypeModel *model in array) {
            [self.ARSceneFxOperator applicationBeautyShapeAndMicro:model];
        }
    }
}

#pragma mark - NvARSceneFilterViewDelegate
- (void)nvARSceneFilterView:(NvARSceneFilterView *)filterView withFilter:(NvCaptureFilterModel *)model withState:(BOOL)state{
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterDictionary:)]) {
        [self.delegate filterDictionary:[model yy_modelToJSONObject]];
    }
}

#pragma mark - NvARSceneMakeupViewDelegate
- (void)nvMakeupView:(NvARSceneMakeupView *)makeupView applyVariableMakeupEffect:(NvMakeupToolDataModel *)effectModel{
    [self.ARSceneFxOperator applicationMakeup:effectModel withSingleMakeup:NO];
    [self.beautyView refreshUI];
    
    for (NvBeautyTypeModel *model in self.ARSceneFxOperator.beautyEffectArray) {
        if ([model.name isEqualToString:@"校色"] || [model.name isEqualToString:@"color correction"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(correctionFilterDictionary:)]) {
                [self.delegate correctionFilterDictionary:[model yy_modelToJSONObject]];
            }
            break;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(makeupFilterArray:)]) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NvMakeupToolEffectModel *filterModel in effectModel.effectContent.filter) {
            NSDictionary *dict = [filterModel yy_modelToJSONObject];
            if (dict) {
                [mutableArray addObject:dict];
            }
        }
        
        [self.delegate makeupFilterArray:mutableArray];
    }
}

- (void)nvMakeupView:(NvARSceneMakeupView *)makeupView applySingleKindMakeupEffect:(NvMakeupToolDataModel *)effectModel {
    [self.ARSceneFxOperator applicationMakeup:effectModel withSingleMakeup:YES];
}

@end

