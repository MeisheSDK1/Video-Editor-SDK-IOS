//
//  EFContentView.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "NvLiveAppEnv.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EFContentBtTag) {
    EFContentBtTag_back,
    EFContentBtTag_device,
    EFContentBtTag_zoom,
    EFContentBtTag_exposure,
    EFContentBtTag_flash,
    EFContentBtTag_makeup,
    EFContentBtTag_beauty,
    EFContentBtTag_filter,
    EFContentBtTag_props,
    EFContentBtTag_record
};

@protocol EFContentViewDelegate <NSObject>

- (void)didSelectedBtTag:(EFContentBtTag)tag button:(UIButton *)button;

@optional
//切换拍照(0)、录制(1)方法
//Switch the method of photographing (0) and recording (1)
- (void)selectedCapture:(NSInteger)index;

@end

@interface EFContentView : UIView
@property(nonatomic, strong) UIButton *shootingBtn; //拍摄
@property(nonatomic, weak) id<EFContentViewDelegate> delegate;
- (void)stopRecord;
- (void)disabledFlash;
- (void)enabledFlash;
- (void)hiddenInterface:(BOOL)hidden;
- (void)setFlashSelected:(BOOL)selected;
@end

NS_ASSUME_NONNULL_END
