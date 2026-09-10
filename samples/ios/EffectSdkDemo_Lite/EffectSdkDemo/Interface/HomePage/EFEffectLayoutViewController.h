//
//  EFEffectLayoutViewController.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2021/3/11.
//  Copyright © 2021 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCapturePopupView.h"
#import "EFContentView.h"
#import "EFStickerView.h"
#import "EFRectOperatorView.h"
#import "NvCaptionDialogViewController.h"
#import "EFDataSource.h"
#import <NvARSceneFx/NvARScenePreview.h>

NS_ASSUME_NONNULL_BEGIN

@interface EFEffectLayoutViewController : UIViewController
<EFStickerViewDelegate>

@property(nonatomic,strong) EFContentView*          contentView;
@property (strong, nonatomic) EFStickerView *exposureBgView;
@property (nonatomic, strong) NvCapturePopupView *exposureView;
@property (strong, nonatomic) EFStickerView *zoomBgView;
@property (nonatomic, strong) NvCapturePopupView *zoomView;
@property (nonatomic, strong) UIImageView *focusView;
@property (strong, nonatomic) EFStickerView *propsView;

@property (strong, nonatomic) EFStickerView *compoundCaptionView;

@property (strong, nonatomic) EFStickerView *stickerView;

@property (strong, nonatomic) EFStickerView *transitionView;

@property (nonatomic, strong) EFRectOperatorView *rectView;

@property (nonatomic, strong) NvARScenePreview *scenePreview;
@property (nonatomic, strong) NvARSceneFxOperator *ARSceneFxOperator;
@property (nonatomic, assign) BOOL isHidden;

// 给手动对焦视图添加动画
// Animate the manual focus view
- (void)animateFocusView:(CGPoint)currentPoint;

-(void)didSelectedBtTag:(NSInteger)tag;

- (void)addScenePreview;

@end

NS_ASSUME_NONNULL_END
