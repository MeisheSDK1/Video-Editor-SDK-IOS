//
//  NvMimoAlbumItem.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/28.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface NvMimoAlbumAsset : NSObject

//是否需要展示蒙层
// Whether mask should be shown
@property (nonatomic, assign) BOOL isShowLayer;
//被选择的个数
// The number of selected
@property (nonatomic, assign) NSInteger number;

@property (nonatomic, strong) PHAsset *asset;
//显示cell的时候被赋值
// assigned when displaying the cell
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@interface NvMimoAlbumItem : NSObject

@property (nonatomic, strong) NSMutableArray<NvMimoAlbumAsset *> *collectionList;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, assign) BOOL isSelectAll;

@end
