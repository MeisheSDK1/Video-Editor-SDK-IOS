//
//  NvAlbumItem.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/28.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Photos;

@interface NvAlbumAsset : NSObject

////是否需要展示蒙层
//// Whether mask should be shown
//@property (nonatomic, assign) BOOL isShowLayer;
//是否需要展示蒙层
// Whether mask should be shown
@property (nonatomic, assign) CGRect maskRect;

//被选择的个数
// The number of selected
@property (nonatomic, assign) NSInteger number;

@property (nonatomic, strong) PHAsset *asset;
//显示cell的时候被赋值
// assigned when displaying the cell
@property (nonatomic, strong) NSIndexPath *indexPath;

//是否选中
// Checked or not
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL useOriginalFile;

@property (nonatomic, assign) BOOL isLivePhoto;

//从相册缓存到沙盒路径
// from album cache to sandbox path
@property (nonatomic, copy) NSString *albumVideoPath;

//直通功能中用到trimIn
// Use trimIn for passthrough
@property (nonatomic, assign) int64_t trimIn;

//直通功能中用到trimOut
// trimOut is used in the passthrough function
@property (nonatomic, assign) int64_t trimOut;
@end

@interface NvAlbumItem : NSObject

@property (nonatomic, strong) NSMutableArray<NvAlbumAsset *> *collectionList;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, assign) BOOL isSelectAll;

@end
