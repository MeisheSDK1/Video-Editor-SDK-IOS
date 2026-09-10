//
//  EFDataSource.m
//  EffectSdkDemo
//
//  素材不安装
//
//  Created by 美摄 on 2021/3/11.
//  Copyright © 2021 美摄. All rights reserved.
//

#import "EFDataSource.h"
#import "YYModel.h"

@interface EFDataSource()
//Reserve an array of design material paths
//预留设计素材路径数组
@property (nonatomic, strong) NSMutableArray *dirArr;


@end

@implementation EFDataSource

//-(instancetype)init{
//    self = [super init];
//    if (self) {
//        [self initializeData];
//    }
//    return self;
//}

-(NSArray<NvStickerModel*>*)stickerArray{
    NSMutableArray* _stickerArray = [NSMutableArray array];
    
    NvStickerModel *model = [NvStickerModel new];
    model.sceneId = nil;
    model.coverImage = @"nonerecord";
    model.name = @"";
    model.selected = NO;
    model.package = @"";
    [_stickerArray addObject:model];
    
    NSArray *stickerPathArray = @[@"7242B80E-A804-4CB5-B7DD-DFACC1B6BF6F.5.arscene",
                                  @"6F8624EC-6B19-4AFA-8C57-7F32DCFD9E41.arscene",
                                  @"049ED95F-C80F-483D-B739-C76FD706485A.arscene",
                                  @"BED6B75B-3DAE-4F6B-A859-9318288F4706.arscene",
                                  @"25C78DC6-823C-4103-9E8A-D84350362F16.arscene",
                                  @"D3F9A1A9-CFD8-46B6-8E9C-DC3E87A9A687.2.arscene",
                                  @"D18BD048-4176-4E14-B705-7E2A4DF08274.arscene",
                                  @"9C917EE3-A1B0-4B5D-B50F-9624A6824A6B.arscene",
                                  @"827EB8A5-1804-45CE-B054-4BA640E566A9.arscene",
                                  @"AA219FDE-AF03-4CD7-87A9-28D7CF930DB0.arscene",
                                  @"EA962143-6CCA-42E4-B7FC-9615B9EEA231.arscene",
                                  @"E8E908B6-215B-4EF7-B1CD-C2832FFB9CF3.arscene"];
    NSArray *stickerImageArray = @[@"huli",@"gaoda", @"goutou", @"jiangshimaozi", @"pickyou", @"maoxin", @"gangtiexia", @"xiaolu", @"yanjing", @"mianju", @"kuloumojing", @"2019"];
    
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"StickerResource" ofType:@"bundle"];
    NSString *arscenePath = [resourceBundlePath stringByAppendingPathComponent:@"arscene"];
    for (int i = 0; i < stickerPathArray.count; i++) {
        NSString *fileName = stickerPathArray[i];
        NSString *filePath = [arscenePath stringByAppendingPathComponent:fileName];
        NSString* sceneId = nil;//[self createStickerItem:filePath];
//        if(sceneId.length > 0) {
            NvStickerModel *model = [NvStickerModel new];
            model.sceneId = sceneId;
            model.coverImage = stickerImageArray[i];
            model.name = @"";
            model.selected = NO;
            model.package = filePath;
            [_stickerArray addObject:model];
//        }
    }
    return _stickerArray;
}

#pragma mark - 读取滤镜数据
//Read the filter data
-(NSMutableArray*)loadFxArray{
    NSString *json = [[NSBundle mainBundle] pathForResource:@"videofx" ofType:@"json"];
    NSData* jsonData = [NSData dataWithContentsOfFile:json];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:[NvFilterItem class] json:[dic objectForKey:@"infoList"]]];
    
    //安装滤镜
    //Installing filters
    for (NvFilterItem* fxItem in mutableArray) {
        NSString* path = [[NSBundle mainBundle] bundlePath];
        path = [path stringByAppendingPathComponent:fxItem.package];
//        [self installEffectAssetPackage:path license:nil type:(NvsAssetPackageType_VideoFx)];
        fxItem.package = path;
    }
    
    if (self.dirArr.count > 3) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *basePath = self.dirArr[0];
        NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:basePath];

        NSMutableArray *assetArr = [NSMutableArray array];
        for (NSString *path in myDirectoryEnumerator.allObjects) {
            if ([path.pathExtension isEqualToString:@"videofx"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", basePath, path];
                NvFilterItem *item = [NvFilterItem new];
                if ([[path componentsSeparatedByString:@"."] count] > 0) {
                    item.packageId = [[path componentsSeparatedByString:@"."] firstObject];
                    item.package = filePath;
                    [assetArr addObject:item];
                    [mutableArray addObject:item];
                }
            }
        }

//        for (NvFilterItem* fxItem in assetArr) {
//            [self installEffectAssetPackage:fxItem.package license:nil type:(NvsAssetPackageType_VideoFx)];
//        }
    }
    return mutableArray;
}

#pragma mark - 读取复合字幕数据
//Read the compound caption data
-(NSMutableArray*)loadCompoundCaptionArray{
    NSString *json = [[NSBundle mainBundle] pathForResource:@"compoundCaption" ofType:@"json"];
    NSData* jsonData = [NSData dataWithContentsOfFile:json];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:[NvFilterItem class] json:[dic objectForKey:@"infoList"]]];
    
    //安装滤镜
    //install filter
    for (NvFilterItem* fxItem in mutableArray) {
        NSString* path = [[NSBundle mainBundle] bundlePath];
        path = [path stringByAppendingPathComponent:fxItem.package];
//        [self installEffectAssetPackage:path license:nil type:(NvsAssetPackageType_CompoundCaption)];
        fxItem.package = path;
    }
    
    if (self.dirArr.count > 3) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *basePath = self.dirArr[2];
        NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:basePath];

        NSMutableArray *assetArr = [NSMutableArray array];
        for (NSString *path in myDirectoryEnumerator.allObjects) {
            if ([path.pathExtension isEqualToString:@"compoundcaption"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", basePath, path];
                NvFilterItem *item = [NvFilterItem new];
                if ([[path componentsSeparatedByString:@"."] count] > 0) {
                    item.packageId = [[path componentsSeparatedByString:@"."] firstObject];
                    item.package = filePath;
                    [assetArr addObject:item];
                    [mutableArray addObject:item];
                }
            }
        }
        
//        for (NvFilterItem* fxItem in assetArr) {
//            [self installEffectAssetPackage:fxItem.package license:nil type:(NvsAssetPackageType_CompoundCaption)];
//        }
    }

    return mutableArray;
}

#pragma mark - 读取贴纸数据
//read sticker data
-(NSMutableArray*)loadAnimatedStickerArray{
    NSString *json = [[NSBundle mainBundle] pathForResource:@"sticker" ofType:@"json"];
    NSData* jsonData = [NSData dataWithContentsOfFile:json];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:[NvFilterItem class] json:[dic objectForKey:@"infoList"]]];
    
    for (NvFilterItem* fxItem in mutableArray) {
        NSString* path = [[NSBundle mainBundle] bundlePath];
        path = [path stringByAppendingPathComponent:fxItem.package];
//        [self installEffectAssetPackage:path license:nil type:(NvsAssetPackageType_AnimatedSticker)];
        fxItem.package = path;
    }
    
    if (self.dirArr.count > 3) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *basePath = self.dirArr[1];
        NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:basePath];

        NSMutableArray *assetArr = [NSMutableArray array];
        for (NSString *path in myDirectoryEnumerator.allObjects) {
            if ([path.pathExtension isEqualToString:@"animatedsticker"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", basePath, path];
                NvFilterItem *item = [NvFilterItem new];
                if ([[path componentsSeparatedByString:@"."] count] > 0) {
                    item.packageId = [[path componentsSeparatedByString:@"."] firstObject];
                    item.package = filePath;
                    [assetArr addObject:item];
                    [mutableArray addObject:item];
                }
            }
        }
        
//        for (NvFilterItem* fxItem in assetArr) {
//            [self installEffectAssetPackage:fxItem.package license:nil type:(NvsAssetPackageType_AnimatedSticker)];
//        }
    }

    return mutableArray;
}


#pragma mark - 读取转场数据
//read video transition data
-(NSMutableArray*)loadTransitionArray{
    NSString *json = [[NSBundle mainBundle] pathForResource:@"transition" ofType:@"json"];
    NSData* jsonData = [NSData dataWithContentsOfFile:json];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:[NvFilterItem class] json:[dic objectForKey:@"infoList"]]];
    
    for (NvFilterItem* fxItem in mutableArray) {
        NSString* path = [[NSBundle mainBundle] bundlePath];
        path = [path stringByAppendingPathComponent:fxItem.package];
//        [self installEffectAssetPackage:path license:nil type:(NvsAssetPackageType_VideoTransition)];
        fxItem.package = path;
    }
    if (self.dirArr.count > 3) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *basePath = self.dirArr[3];
        NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:basePath];

        NSMutableArray *assetArr = [NSMutableArray array];
        for (NSString *path in myDirectoryEnumerator.allObjects) {
            if ([path.pathExtension isEqualToString:@"videotransition"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", basePath, path];
                NvFilterItem *item = [NvFilterItem new];
                if ([[path componentsSeparatedByString:@"."] count] > 0) {
                    item.packageId = [[path componentsSeparatedByString:@"."] firstObject];
                    item.package = filePath;
                    [assetArr addObject:item];
                    [mutableArray addObject:item];
                }
            }
        }
        
//        for (NvFilterItem* fxItem in assetArr) {
//            [self installEffectAssetPackage:fxItem.package license:nil type:(NvsAssetPackageType_VideoTransition)];
//        }
    }

    return mutableArray;
}

@end
