//
//  NvARSceneFilterView.h
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/24.
//

#import <UIKit/UIKit.h>
#import "NvARSeceneCaptureFilterCell.h"

@class NvARSceneFilterView;
@class NvCaptureFilterModel;

@protocol NvARSceneFilterViewDelegate <NSObject>
@optional

/**
选择或调节一个滤镜回调
 Select or adjust a filter callback
@param beautyView 当前NvBeautyView对象，self
@param model 当前滤镜model
 A value of true indicates that a filter was clicked, and a value of false indicates that the slider is being dragged
@param state 为true表示点击某个滤镜，为false表示滑杆拖动中
*/
- (void)nvARSceneFilterView:(NvARSceneFilterView *)filterView withFilter:(NvCaptureFilterModel *)model withState:(BOOL)state;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NvARSceneFilterView : UIView

@property (nonatomic, weak) id<NvARSceneFilterViewDelegate> delegate;

/// 配置滤镜数据
/// Configure the filter data
/// @param array 滤镜数组
- (void)configFilterArray:(NSMutableArray *)array;

/// 关闭滤镜
/// Close the filter
- (void)closeFilter;

@end

NS_ASSUME_NONNULL_END
