//
//  NvPreviewViewController.h
//  NvMimoDemo
//
//  Created by MS on 2019/8/13.
//  Copyright © 2019 MS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvThemeModel.h"
#import "NVMimoDefineConfig.h"
#import "NvMimoAlbumSelectService.h"
#import <NvBaseCommon/NvBaseViewController.h>
NS_ASSUME_NONNULL_BEGIN

@interface NvPreviewViewController : NvBaseViewController

/// mimo模版路径
/// the template path
@property (nonatomic, copy) NSString *dirPath;

/// 修改的复合字幕文本内容
/// compound caption text
@property (nonatomic, copy) NSString *compoundCaptionText;

/// 时间线宽高比
/// the editmode to create timeline
@property (nonatomic, assign) NvMimoEditMode editMode;

@property (nonatomic, strong) NvMimoAlbumSelectService *selectService;

/// 初始化预览页面
/// intialize the preview of mimo
/// @param themeModel mimo模版数据
/// themeModel model of the template
/// @param shotArr 镜头数据（不包含空镜头）
/// shotArr shot datas (donot contain empty shot which with assigned content by template)
- (instancetype )initWithThemeModel:(NvThemeModel *)themeModel shotArr:(NSMutableArray <NvShotModel *> *)shotArr;
@end

NS_ASSUME_NONNULL_END
