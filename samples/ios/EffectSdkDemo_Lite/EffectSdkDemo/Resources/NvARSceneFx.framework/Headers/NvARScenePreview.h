//
//  NvARScenePreview.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/23.
//

#import <UIKit/UIKit.h>
#import "NvARSceneFxOperator.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NvARScenePreviewViewDelegate <NSObject>
@optional

/// 设置代理，并且实现代理方法，创建滤镜特效，由外部自己创建维护
/// Set up the proxy, implement the proxy method, create the filter effect, and maintain it externally
/// @param dict 滤镜模型
- (void)filterDictionary:(NSDictionary *)dict;

/// 设置代理，并且实现代理方法，创建校色滤镜特效，由外部自己创建维护
/// Set the proxy, and implement the proxy method, create the correction color filter effect, created by the external maintenance
/// @param dict 校色滤镜模型
- (void)correctionFilterDictionary:(NSDictionary *)dict;

/// 设置代理，并且实现代理方法，创建美妆中的滤镜特效，由外部自己创建维护
/// Set up the proxy, and implement the proxy method, create the filter effect in the makeup, created and maintained by the outside
/// @param array
- (void)makeupFilterArray:(NSMutableArray *)array;

@end

@interface NvARScenePreview : UIView

@property (nonatomic, weak) id<NvARScenePreviewViewDelegate> delegate;

/// effectdemo需要设置这个变量值，适配滤镜、美颜视图的整体高度
/// effectdemo needs to set this variable to match the overall height of the filter and beauty view
@property (nonatomic, assign) CGFloat extraHeight;

@property (nonatomic, strong) NvARSceneFxOperator *ARSceneFxOperator;
- (NSMutableDictionary *)getMakeUpInfo;

- (void)addBeautyView;

- (void)addFilterView;

- (void)addMakeupView;

- (void)showBeautyView:(BOOL)hidden;

- (void)showFilterView:(BOOL)hidden;

- (void)showMakeupView:(BOOL)hidden;

/// 检查手机是否有某种特效的能力，比如去油光，根据能力，再去重新更新数据，这个接口需要依赖外部NvsEffectRenderCore对象的initializeWithFlags方法，要在调用initializeWithFlags之后调用
/// The ability to check whether the phone has a specific effect, such as degreying, and then update the data based on that ability, relies on the initializeWithFlags method of the external NvsEffectRenderCore object, which is called after initializeWithFlags is called
- (void)detectionCapability;
@end

NS_ASSUME_NONNULL_END
