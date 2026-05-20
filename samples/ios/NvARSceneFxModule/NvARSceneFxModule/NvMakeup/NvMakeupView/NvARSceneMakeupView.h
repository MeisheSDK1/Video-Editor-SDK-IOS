//
//  NvARSceneMakeupView.h
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/26.
//

#import <UIKit/UIKit.h>
#import "NvARScenAsset.h"
#import "NvMakeupToolModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NvARSceneMakeupView;

@protocol NvARSceneMakeupViewDelegate <NSObject>
@optional
 
/**
 应用组合妆容
 Apply the variable makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvARSceneMakeupView *)makeupView applyVariableMakeupEffect:(NvMakeupToolDataModel *)effectModel;

/**
 应用单妆
 Apply the single makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvARSceneMakeupView *)makeupView applySingleKindMakeupEffect:(NvMakeupToolDataModel *)effectModel;

@end

@interface NvARSceneMakeupView : UIView

/// 代理 delegate
@property (nonatomic, weak) id<NvARSceneMakeupViewDelegate>delegate;
@property (nonatomic, strong) NSMutableDictionary *makeUpInfo;

- (void)configData:(NSMutableArray *)array;

@end

NS_ASSUME_NONNULL_END
