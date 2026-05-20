//
//  NvBeautyTemplateDataManger.m
//  SDKDemo
//
//  Created by ms20221114 on 2023/2/22.
//  Copyright © 2023 meishe. All rights reserved.
//

#import "NvBeautyTemplateDataManger.h"
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvUtils.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "MJRefresh.h"
#import "NvMakeupModel.h"
#import "SSZipArchive.h"
#import "NvMakeupToolModel.h"

@interface NvBeautyTemplateDataManger()

@property (nonatomic, assign) int page;

@property (nonatomic, strong) UICollectionView *view;

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation NvBeautyTemplateDataManger

- (instancetype)init {
    if (self = [super init]) {
        self.dataArray = [NSMutableArray array];
        
        NSString *basePath = [[NSBundle mainBundle] pathForResource:@"BeautyTemplate" ofType:@"bundle"];
        NvBeautyTemplateModel *customModel = [[NvBeautyTemplateModel alloc]init];
        customModel.packageUrl = [basePath stringByAppendingPathComponent:@"customTemplate.json"];
        customModel.coverImage = @"capture_beauty_custom";
        customModel.selectedCoverImg = @"capture_beauty_template_s";
        customModel.beautyTemplate = [self analyticalTemplatePath:customModel.packageUrl];
        customModel.state = Finish;
        customModel.name = @"Custom";
        customModel.typeTemplate = 2;
        [self.dataArray addObject:customModel];
        
        NvBeautyTemplateModel *model = [[NvBeautyTemplateModel alloc]init];
        model.name = @"None";
        model.coverImage = @"capture_beauty_none";
        model.selectedCoverImg = @"capture_beauty_none";
        model.beautyTemplate = [self analyticalTemplatePath:model.packageUrl];
        model.state = Finish;
        model.typeTemplate = 0;
        [self.dataArray addObject:model];
    }
    return self;
}

- (void)configureSandboxData{
    NSString *pathString = [VIDEO_PATH(@"LocalAssets") stringByAppendingPathComponent:@"BeautyTemplate"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:pathString error:nil];
    for (NSString *string in array) {
        NvBeautyTemplateModel *model = [[NvBeautyTemplateModel alloc]init];
        model.name = @"测试";
        model.nameEn = @"测试";
        model.coverImage = @"NvDefaultProps";
        model.selectedCoverImg = @"capture_beauty_template_s";
        model.packageUrl = [pathString stringByAppendingPathComponent:string];
        model.beautyTemplate = [self analyticalTemplatePath:model.packageUrl];
        model.state = Finish;
        [self.dataArray addObject:model];
    }
}

- (void)configureProducData{
    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"BeautyTemplate" ofType:@"bundle"];
    NSString *jsonPath = [basePath stringByAppendingPathComponent:@"beautyTemplate.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSArray *array = [NSArray yy_modelArrayWithClass:NvBeautyTypeModel.class json:data];
    
    for (NvBeautyTemplateModel *model in array) {
        if (model.packageUrl.length > 0){
            model.packageUrl = [basePath stringByAppendingPathComponent:model.packageUrl];
            model.coverImage = [basePath stringByAppendingPathComponent:model.coverImage];
            model.beautyTemplate = [self analyticalTemplatePath:model.packageUrl];
        }
        
        model.name = NvLocalString(model.nameEn, model.name);
        model.state = Finish;
    }
    
    [self.dataArray addObjectsFromArray:array];
}

- (NvMakeupToolModel *)analyticalTemplatePath:(NSString *)path{
    NSString *jsonPath = [path stringByAppendingPathComponent:@"info_new.json"];
    if ([path containsString:@"customTemplate.json"]){
        jsonPath = path;
    }
    
    NSData *varialbeData = [[NSData alloc] initWithContentsOfFile:jsonPath];
    
    if(varialbeData) {
        NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:varialbeData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingFragmentsAllowed|NSJSONReadingAllowFragments error:nil];
        NvMakeupToolModel *model = [NvMakeupToolModel yy_modelWithJSON:infoDic];
        model.packagePath = path;
        return model;
    }
    return nil;
}

#pragma mark - 请求美颜模版数据
/// Request beauty template data
- (void)refreshRequestData:(UICollectionView *)view withSuccess:(void(^)(id respondData))success withFailure:(void(^)(NSError *error))failure{
    self.view = view;
    if (self.view.mj_trailer != nil) {
        if (self.view.mj_trailer.state == MJRefreshStateRefreshing) {
            [self.view.mj_trailer endRefreshing];
        }
        [self.view.mj_trailer removeFromSuperview];
        self.view.mj_trailer = nil;
        UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.view.contentInset = inset;
        self.view.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);

    }
    int pageSize = 20;
    int type = 20;
    int kind = 0;
    int categoryId = 5;
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    
    __weak typeof(self) weakSelf = self;
    
    NSString *downloadPath = [NvSDKUtils getAssetDownloadPath:ASSET_BEAUTY_TEMPLATE];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    MJRefreshNormalTrailer *trailer = [MJRefreshNormalTrailer trailerWithRefreshingBlock:^{
        weakSelf.page++;
        [NvHttpRequest RequestBeautyTemplateListWithType:type category:categoryId kind:kind ratioFlag:1 ratio:AspectRatio_All sdkVersion:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision] page:weakSelf.page pageSize:pageSize completionBlock:^(id respondData) {
            
            [self.view.mj_trailer endRefreshing];
            
            NSDictionary *dict = (NSDictionary *)respondData;
            NSDictionary *dataDic = dict[@"data"];
            NSArray *elements = dataDic[@"elements"];
            
            for (NSDictionary *item in elements) {
                NvBeautyTemplateModel *model = [self translateCellInfo:item];
                if (model) {
                    NSString *assetPath = [downloadPath stringByAppendingPathComponent:[self getPackageUUIDWithVersionNum:model.packageUrl]];
                    if ([fileManager fileExistsAtPath:assetPath]) {
                        model.state = Finish;
                        model.packageUrl = assetPath;
                    }
                    [self.dataArray addObject:model];
                }
            }
            
            if (elements.count > 0) {
                if (success) {
                    success(elements);
                }
            }else{
                if (failure) {
                    NSError *error;
                    failure(error);
                }
            }
        } failureBlock:^(NSError *error) {
            [self.view.mj_trailer endRefreshing];
            if (failure) {
                failure(error);
            }
        }];
    }];
    trailer.arrowView.hidden = YES;
    trailer.stateLabel.text = @"";
    [trailer setTitle:NvLocalString(@"RefreshTrailerIdleText", @"滑动查看") forState:MJRefreshStateIdle];
    [trailer setTitle:NvLocalString(@"RefreshTrailerPullingText", @"释放查看") forState:MJRefreshStatePulling];
    [trailer setTitle:NvLocalString(@"RefreshTrailerPullingText", @"释放查看") forState:MJRefreshStateRefreshing];
    
    self.view.mj_trailer = trailer;
}

- (NvBeautyTemplateModel *)translateCellInfo:(NSDictionary *)info{
    if (info){
        NvBeautyTemplateModel *effectModel = [[NvBeautyTemplateModel alloc]init];
        effectModel.name = info[@"displayName"];
        effectModel.packageUrl = info[@"zipUrl"];
        effectModel.coverImage = info[@"coverUrl"];
        effectModel.selectedCoverImg = @"capture_beauty_template_s";
        effectModel.uuid = info[@"id"];
        effectModel.state = NODownload;
        return effectModel;
    }
    
    return nil;
}

#pragma mark - 开始请求美颜模版数据
/// start Request beauty template data
- (void)startRequestData{
    self.page = 0;
    [self.view.mj_trailer beginRefreshing];
}

-(void)downloadData:(NvBeautyTemplateModel *)model WithProgress:(void (^)(CGFloat))progressBlock WithSuccess:(void (^)(id _Nonnull))success withFailure:(void (^)(NSError * _Nonnull))failure{
    
    NSString *downloadPath = [NvSDKUtils getAssetDownloadPath:ASSET_BEAUTY_TEMPLATE];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *assetPath = [downloadPath stringByAppendingPathComponent:[self getPackageUUIDWithVersionNum:model.packageUrl]];
    if (![fileManager fileExistsAtPath:assetPath]) {
        dispatch_async(self.queue, ^{
            NvHttpRequest *request = [NvHttpRequest sharedInstance];
            [request downloadAsset:model.packageUrl destFileDir:downloadPath downloadID:model.packageUrl.lastPathComponent progressBlock:^(int32_t progress) {
                if (progressBlock){
                    progressBlock((CGFloat)progress);
                }
            } completeBlock:^(NSString *downloadFilePath) {
                NSError *err = NSError.new;
                NSString *downloadPath = [downloadFilePath stringByReplacingOccurrencesOfString:@"file:" withString:@""];
                NSString *unzipPath = [downloadPath stringByDeletingPathExtension];
                BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:unzipPath isDirectory:nil];
                if (!exist) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:unzipPath withIntermediateDirectories:YES attributes:nil error:nil];
                }

                [SSZipArchive unzipFileAtPath:downloadPath
                                toDestination:unzipPath
                           preserveAttributes:NO
                                    overwrite:YES
                               nestedZipLevel:1
                                     password:nil
                                        error:&err
                                     delegate:nil
                              progressHandler:nil
                            completionHandler:nil];
                if (err.code == 0) {
                    [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
                    model.packageUrl = unzipPath;
                    model.state = Finish;
                    if (success) {
                        success(model);
                    }
                } else {
                }
            } failureBlock:^(NSError *error, NSString *downloadFilePath) {
                model.state = NODownload;
            }];
        });
    }else{
        model.packageUrl = assetPath;
        if (success) {
            success(model);
        }
    }
}

- (NSString *)getPackageUUIDWithVersionNum:(NSString *)path {
    return [path.lastPathComponent stringByDeletingPathExtension];
}

- (dispatch_queue_t)queue
{
    if (_queue == nil) {
        _queue = dispatch_queue_create("dispatch_queue_makeup", DISPATCH_QUEUE_CONCURRENT);
    }
    return _queue;
}

@end
