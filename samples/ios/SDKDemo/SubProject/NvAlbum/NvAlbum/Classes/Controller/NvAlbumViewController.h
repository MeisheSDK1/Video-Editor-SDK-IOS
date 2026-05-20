//
//  NvAlbumViewController.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvAlbumItem.h"
@class NvAlbumViewController;

typedef enum : NSUInteger {
    NvSelectAssetAll,
    NvSelectAssetVideo,
    NvSelectAssetImage,
} NvSelectAssetType;

@protocol NvAlbumViewControllerDelegate

@optional
//点击底部按钮触发的回调将所有被选择的assets传出去，自定义按钮的话不会触发此回调
// Click the bottom button triggers a callback that emits all selected assets. Custom buttons don't trigger this callback
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets;

//每次点击cell或者点击全选取消反选都会掉用，将所有被选择的assets传出去
// It will be disabled every time you click cell or deselect all, outgoing all selected assets
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController didSelectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets;

//点击相册超过最大限制数量，将所有被选择的assets传出去
// Click album over Max limit to send out all selected assets
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsOverMaxCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets;

//点击相册低过最小限制数量，自定义按钮的话不会触发此回调，将所有被选择的assets传出去
// Clicking an album below the minimum, custom button will not trigger this callback, outgoing all selected assets
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsUnderMinCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets;

//测试webm 数据回调方法
// Test webm data callback methods
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectWebmAlbumAssets:(NSMutableArray <NSString *>*)assets;

//返回按钮触发的回调
// Return the callback triggered by the button
- (void)nvAlbumViewControllerCancelClick:(NvAlbumViewController *)albumViewController;

//自定义底部按钮的回调
// Customize the bottom button callback
- (UIView *)nvAlbumViewControllerCustomBottomButton;

//自定义底部view 的可用高度（不包括iPhone 底部安全区域高度）
//the height of the custom bottom view , not include the safe bottom area on iphone
- (CGFloat)nvAlbumViewControllerUsefulCustomBottomHeight;

//点击底部按钮取消 取消背景抠像
// Click the bottom button to cancel background matting
- (void)nvAlbumViewCancelMattController:(NvAlbumViewController *)albumViewController;

//快速拼接时是否是同一类素材
// Is it the same type of asset for quick stitching
- (BOOL)nvAlbumViewSamemMaterialController:(NvAlbumViewController *)albumViewController asset:(NvAlbumAsset *)asset index: (NSUInteger)index isSelect:(BOOL)select;

//是否在界面初始化的时候根据自定义view 给出的高度调整
//wheter adjust the album collectionViews height as the given custom view height when they are initialized
- (BOOL)nvAlbumViewControllerAdjustAlbumCollectionFrameAsCustomBottomViewHeightAtInitialization:(NvAlbumViewController *)albumViewController;

@end

@protocol NvAlbumViewControllerSelectStrategy <NSObject>
@optional
//是否开启相册选中策略
//whether the select strategy has been enabled or not
- (BOOL)enableNvAlbumViewControllerSelectStrategy:(NvAlbumViewController *)albumViewController;

//点击某个相册资源
//click and select one asset in album
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAssetOnSelectStrategy:(PHAsset *)asset;



@end

@interface NvAlbumViewController : UIViewController

@property (nonatomic, weak) id delegate;

@property (nonatomic, weak) id <NvAlbumViewControllerSelectStrategy>selectStrategy;

@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *>*outputSelectAssetSource;

// Is it a quick stitching module
@property (nonatomic, assign) BOOL isQuickSplicing; //是否是快速拼接模块
/**
 isOnlyImage和isOnlyVideo互斥，不要同时设置
 isOnlyImage and isOnlyVideo are mutually exclusive and should not be set at the same time
 */
@property (nonatomic, assign) BOOL isOnlyImage; //是否仅现实图片
@property (nonatomic, assign) BOOL isOnlyVideo; //是否仅为视频

// Multi-select, default YES, no number mark for radio
@property (nonatomic, assign) BOOL mutableSelect; //是否多选，默认YES,单选不会有数字标记
// Max number of selections
@property (nonatomic, assign) NSInteger maxSelectCount; //最多选择的个数
// minimum number of selections
@property (nonatomic, assign) NSInteger minSelectCount; //最少选择的个数

// Whether to hide the all-select button
@property (nonatomic, assign) BOOL hiddenSelectAll; //是否隐藏全选按钮
//获取默认底部按钮
// Get the default bottom button
@property (nonatomic, strong, readonly) UIButton *customButton;
//自定义下一步按钮的文字
// Customize the next button text
- (void)customSelectAssetButtonText:(NSString *)text;
//一直显示底部自定义试图 默认NO
// Always show bottom Custom attempts default NO
@property (nonatomic, assign) BOOL alwaysShowCustomBottom;
// "Photo gallery", default "no"
@property (nonatomic, assign) BOOL isPhotoAlbumMode;      //是否是“照片影集”,默认“否”
// Only works under "Photo gallery"
@property (nonatomic, copy) NSString *rightItemStr; //只在“照片影集”下起作用

@property (nonatomic, assign) BOOL showMattingView;
@end
