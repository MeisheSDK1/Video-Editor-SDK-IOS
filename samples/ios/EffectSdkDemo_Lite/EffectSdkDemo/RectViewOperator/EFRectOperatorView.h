//
//  EFRectOperatorView.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2021/3/12.
//  Copyright © 2021 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvRectView.h"
#import "NvsEffectSdkContext.h"

NS_ASSUME_NONNULL_BEGIN

@class EFRectOperatorView;

@protocol EFRectOperatorViewEditDelegate <NSObject>

-(void)rectOperatorView:(EFRectOperatorView*)rectOperatorView touchUpInside:(NSInteger)captionIndex point:(CGPoint)point;

-(void)deleteEffectOperatorView:(EFRectOperatorView*)rectOperatorView;

@end

@interface EFRectOperatorView : NvRectView

@property(nonatomic,weak) id<EFRectOperatorViewEditDelegate> editDelegate;

//Current compoundcaption or stickers
@property (nonatomic, strong) NvsEffect * __nullable currentEffect; //当前复合字幕或者动态贴纸

-(void)setRectDisplayView:(UIView * _Nonnull)displayView;

-(void)resetBufferSize:(CGSize)bufferSize;

- (void)updateEffectShow:(NvsEffect *)effect;

@end

NS_ASSUME_NONNULL_END
