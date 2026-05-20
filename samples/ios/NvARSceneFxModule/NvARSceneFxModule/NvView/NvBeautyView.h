//
//  NvBeautyView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvSwitchView.h"
#import "NvBeautyTypeCViewCell.h"
#import "NvARSeceneCaptureFilterCell.h"

@class NvBeautyView;
@class NvCaptureFilterModel;
@protocol NvBeautyViewDelegate <NSObject>
@optional

/**
 选择或调节一个美颜、美型特效回调
 Select or adjust a beauty or beauty effect callback
 @param beautyView 当前NvBeautyView对象，self
 @param model 当前美颜、美型数据model
 @param state 为true表示要记录数据，为false表示滑杆拖动中中，拖动结束再记录数据，如果只是一个开关，美颜滑杆，传true
 A value of true indicates that data should be recorded, and a value of false indicates that the slider is in the middle, and the data should be recorded after the drag is finished. If it is only a switch, the beautiful slider should be transmitted to true
 */
- (void)nvBeautyView:(NvBeautyView *)beautyView withModel:(NvBeautyTypeModel *)model withState:(BOOL)state;

/**
 重置按钮点击的回调
 Reset button click callback
 @param beautyView 当前NvBeautyView对象，self
 @param array 回调的美型数据，一个NvBeautyTypeModel的数组
 Callback beauty data, an array of NvBeautyTypeModel
 */
- (void)nvBeautyView:(NvBeautyView *)beautyView withModelArray:(NSMutableArray *)array;

/**
 美颜、美型、微整形开启关闭点击的回调
 Beauty, beauty, micro plastic open and close click callback
 @param beautyView 当前NvBeautyView对象，self
 @param array 回调的美型数据，一个NvBeautyTypeModel的数组
 Callback beauty data, an array of NvBeautyTypeModel
 */
- (void)nvBeautyView:(NvBeautyView *)beautyView withModelArray:(NSMutableArray *)array withOpen:(BOOL)open;

@end

@interface NvBeautyView : UIView

/// 美颜点击按钮——切换当前显示视图为美颜
/// Beauty click button -- toggle the current display view to beauty
@property (nonatomic, strong) UIButton *beautyBtn;
/// 美颜开关按钮（其点击方法为在controller中添加）
/// Beauty switch button (click method is to add in the controller)
@property (nonatomic, strong) NvSwitchView *beautySwitch;

/// 美型点击按钮——切换当前显示视图为美型
/// Beauty click button -- toggle the current display view to beauty
@property (nonatomic, strong) UIButton *beautyTypeBtn;
/// 美型开关按钮（其点击方法为在controller中添加）
/// Beauty switch button (click method is added in controller)
@property (nonatomic, strong) NvSwitchView *beautyTypeSwitch;

/// 微整形点击按钮——切换当前显示视图为滤镜
/// Micro Shaping click button - toggle current display view to filter
@property (nonatomic, strong) UIButton *beautyTypeMicroBtn;
/// 微整形开关按钮（其点击方法为在controller中添加）
/// Micro shaping switch button (click by adding in controller)
@property (nonatomic, strong) NvSwitchView *beautyTypeMicroSwitch;

@property (nonatomic, weak) id<NvBeautyViewDelegate> delegate;

/// 0==美颜视图，1==美型视图，2==滤镜视图
/// 0== Beauty view, 1== Beauty view, 2== Filter view
@property (nonatomic, assign) NSInteger hiddenInteger;

/// 用户的交互处理
/// User interaction processing
/// true indicates that the beauty, beauty and micro-plastic are open, and false indicates that the beauty, beauty and micro-plastic are closed
/// @param edit true标识该美颜、美型、微整形是打开，false标识该美颜、美型、微整形是关闭
/// 0 indicates that beauty is being operated, 1 indicates that beauty is being operated, and 2 indicates that micro plastic is being operated
/// @param type  0标识正在操作的是美颜，1标识正在操作的是美型，2标识正在操作的是微整形
- (void)editBool:(BOOL)edit withType:(NSInteger)type;

/// 配置美型数据
/// Configure beauty data
/// @param array 一个NvBeautyTypeModel的数组
- (void)configBeautyByteArray:(NSMutableArray*)array;

/// 配置美颜数据
/// Configure beauty data
/// @param array 一个NvBeautyTypeModel的数组
- (void)configBeautyArray:(NSMutableArray*)array;

/// 配置微整形数据
/// Configure Micro data
/// @param array 微整形数组
- (void)configBeautyTypeMicroArray:(NSMutableArray *)array;

/// 获取美颜数据
/// get beauty data
- (NSMutableArray *)getBeautyArrayData;

- (void)refreshUI;
@end
