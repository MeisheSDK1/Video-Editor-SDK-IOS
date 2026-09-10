//
//  NvHomeCViewCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/15.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger,HomeModel){
    HomeModelShortVideoFx,
    HomeModelParticalFx,
    HomeModelVirtualKeyer,
    HomeModelTemplate,
    HomeModelPIP,
    HomeModelFlipSubtitles,
    HomeModelMusicLyric,
    HomeModelPushShot,
    HomeModelBoomrang,
    HomeModelPhotoAlbum,
    HomeModelFlashFx,
    HomeModelMimo,
    HomeModelThemeShooting,
    HomeModelCover,
    HomeModelAudioEqualizer,
    HomeModelPackagingTemplate
};

@interface NvHomeArrayModel : NSObject
///当前分组的collectionView
///collectionView for the current group
@property (nonatomic, strong) UICollectionView *collectionView;
///存放当前collectionView的数组NvHomeModel
///The array NvHomeModel that holds the current collectionView
@property (nonatomic, strong) NSMutableArray *array;

@end

@interface NvHomeModel : NSObject
///显示的文字
///Displayed text
@property (nonatomic, copy) NSString *name;
///封面
///cover
@property (nonatomic, strong) UIImage *coverImage;
///渐变颜色数组
///Gradient color array
@property (nonatomic, copy) NSArray *color;
///当前模块
///Current module
@property (nonatomic, assign) HomeModel category;
///模块名
///Module name
@property (nonatomic, copy) NSString *moduleName;

@end

@interface NvHomeCViewCell : UICollectionViewCell

- (void)renderCellWithItem:(NvHomeModel *)item;

@end

NS_ASSUME_NONNULL_END
