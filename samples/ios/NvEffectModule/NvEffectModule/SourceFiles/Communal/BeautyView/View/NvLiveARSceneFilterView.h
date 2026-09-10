//
//  NvLiveARSceneFilterView.h
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/24.
//

#import <UIKit/UIKit.h>

#import "NvLiveARSeceneCaptureFilterCell.h"

@class NvLiveARSceneFilterView;
@class NvLiveCaptureFilterModel;

NS_ASSUME_NONNULL_BEGIN

@protocol NvLiveARSceneFilterViewDelegate <NSObject>

@optional
/**
选择或调节一个滤镜回调
 Select or adjust a filter callback
@param filterView 当前NvLiveARSceneFilterView对象，self
@param model 当前滤镜model
 A value of true indicates that a filter was clicked, and a value of false indicates that the slider is being dragged
@param state 为true表示点击某个滤镜，为false表示滑杆拖动中
*/
- (void)nvARSceneFilterView:(NvLiveARSceneFilterView *)filterView withFilter:(NvLiveCaptureFilterModel *)model withState:(BOOL)state;

@end

@interface NvLiveARSceneFilterView : UIView

@property(nonatomic, weak) id<NvLiveARSceneFilterViewDelegate> delegate;

/// type==0：滤镜，type==0：filter
/// type==1：道具，type==0：prop
@property (nonatomic, assign) int type;

/// 配置滤镜数据
/// Configure the filter data
/// @param array 滤镜数组
- (void)configFilterArray:(NSMutableArray *)array needSlider:(BOOL)needSlider;

/// 关闭滤镜
/// Close the filter
- (void)closeFilter;

@end

NS_ASSUME_NONNULL_END
