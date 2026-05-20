//
//  EFContentView.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EFContentViewDelegate <NSObject>

-(void)didSelectedBtTag:(NSInteger)tag;
//切换拍照(0)、录制(1)方法
// Switch between photo (0) and record (1) methods
-(void)selectedCapture:(NSInteger)index;

-(void)segmentSwitchValueChanged:(UISwitch*)segmentSwitch;

//audio engine
-(void)changeVolum:(CGFloat)value;
-(void)audioPlay;
-(void)audioPause;
-(void)changeAudioWithPath:(NSString *)path;
@end

@interface EFContentView : UIView

@property(nonatomic,strong) UIButton* recordingButton;

@property(nonatomic,weak) id<EFContentViewDelegate> delegate;
- (void)disabledFlash ;
- (void)enabledFlash ;
- (void)hiddenInterface:(BOOL)hidden;
@end

NS_ASSUME_NONNULL_END
