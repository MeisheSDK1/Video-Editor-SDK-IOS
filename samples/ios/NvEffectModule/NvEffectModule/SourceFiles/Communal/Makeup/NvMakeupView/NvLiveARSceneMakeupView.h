//
//  NvLiveARSceneMakeupView.h
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/26.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@class NvLiveMakeupItemModel;
@class NvLiveARSceneMakeupView;

@protocol NvLiveARSceneMakeupViewDelegate <NSObject>
@optional

/**
 应用组合妆容
 Apply the variable makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView applyVariableMakeupEffect:(NvLiveMakeupItemModel *)effectModel;

/**
 应用单妆
 Apply the single makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView applySingleKindMakeupEffect:(NvLiveMakeupItemModel *)effectModel;

//
- (void)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView refetchModel:(NvLiveMakeupItemModel *)effectModel;

- (double)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView intensity:(NvLiveMakeupItemModel *)effectModel;
- (void)nvMakeupView:(NvLiveARSceneMakeupView *)makeupView update:(NvLiveMakeupItemModel *)effectModel intensity:(double)intensity;

@end

@interface NvLiveARSceneMakeupView : UIView

/// 代理 delegate
@property(nonatomic, weak) id<NvLiveARSceneMakeupViewDelegate> delegate;
@property(nonatomic, strong) NSMutableDictionary *makeUpInfo;

- (void)configData:(NSMutableArray *)array;

@end

NS_ASSUME_NONNULL_END
