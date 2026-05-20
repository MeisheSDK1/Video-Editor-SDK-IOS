//
//  NvEditBeautyView.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/15.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvEditBeautyView;
@class NvBeautyTypeModel;

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM (NSUInteger, NvEditBeautyCategory) {
    NvEditBeautyCategoryBeauty,        //美颜
    NvEditBeautyCategoryShape,         //美型
    NvEditBeautyCategoryMicroShape,    //微整形
};

@protocol NvEditBeautyViewDelegate <NSObject>
@optional
- (void)nvEditBeautyViewFinishedButtonClicked:(NvEditBeautyView *)beautyView;

- (void)nvEditBeautyView:(NvEditBeautyView *)beautyView category:(NvEditBeautyCategory)category applyModel:(NvBeautyTypeModel *)model;

- (void)nvEditBeautyViewRemoveAllEffect:(NvEditBeautyView *)beautyView category:(NvEditBeautyCategory)category;

- (void)nvEditBeautyView:(NvEditBeautyView *)beautyView forbiddenReplaceCategory:(NvEditBeautyCategory)category model:( NvBeautyTypeModel * _Nullable )model;

@end

@interface NvEditBeautyView : UIView
@property (nonatomic, assign) id <NvEditBeautyViewDelegate>delegate;
@property (nonatomic, assign) NvEditBeautyCategory viewCategory;
@property (nonatomic, assign) BOOL containAI;
@property (nonatomic, assign) BOOL beautySwitchOpen;
@property (nonatomic, assign) BOOL shapeSwitchOpen;
@property (nonatomic, assign) BOOL microShapeSwitchOpen;

- (instancetype)initWithContainAI:(BOOL)containAI;

- (void)configData:(NSMutableArray *)datas category:(NvEditBeautyCategory)category showTemporaryData:(BOOL)temporary;

- (void)changeSwitchState:(NvEditBeautyCategory)category isOpen:(BOOL)open;

- (void)applyEffects:(NSMutableArray *)datas category:(NvEditBeautyCategory)category;
@end

NS_ASSUME_NONNULL_END
