
//
//  NvHttpRequest.m
//  NvCheez
//
//  Created by shizhouhu on 2018/6/5.
//  Copyright © 2018年 shizhouhu. All rights reserved.
//

#import "NvHttpRequest.h"
#import "AFNetworking.h"
#import "NvAsset.h"

@implementation NvHttpRequest

static NvHttpRequest *sharedInstance = nil;
static AFHTTPSessionManager *httpSessionManager;
static AFNetworkReachabilityManager *networkManager;

+ (NvHttpRequest *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvHttpRequest alloc] init];
        networkManager = [AFNetworkReachabilityManager sharedManager];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

+ (AFHTTPSessionManager *)sharedManager {
    if (httpSessionManager)
        return httpSessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpSessionManager = [AFHTTPSessionManager manager];
        httpSessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        ///设置15秒超时 - 取消请求
        ///Set 15-second timeout - Cancel request
        httpSessionManager.requestSerializer.timeoutInterval = 15.0;
        [httpSessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        httpSessionManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        httpSessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    });
    return httpSessionManager;
}
- (void)getAssetListForCaptureScene:(AssetType)assetType
                         categoryId:(int)categoryId
                              page:(int32_t)page
                          pageSize:(int32_t)pageSize
                       kind:(int)kind ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon withDelegate:(id<NvHttpRequestDelegate>)delegate
{
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    NSMutableDictionary *params = [self makeRequestParam:assetType categoryId:categoryId page:page pageSize:pageSize kind:kind modular:NvAssetModularAll ratioFlag:ratioFlag ratio:ratio sdkVerskon:sdkVerskon keyword:nil];
    [httpSessionManager GET:NV_ASSET_REQUEST_URL parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *err = nil;
        NSDictionary *dicResults = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&err];
        if(err) {
            if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:)]){
                [delegate onGetAssetListFailed:err assetType:assetType];
            }
        }else{
            NSInteger code = [[dicResults objectForKey:@"code"] integerValue];
            NSDictionary * dataDic = [dicResults objectForKey:@"data"];
            NSInteger total = [[dataDic objectForKey:@"total"] integerValue];
            NSInteger pageNum = [[dataDic objectForKey:@"pageNum"] integerValue];
            BOOL hasNext = pageNum < total;
            if (assetType == ASSET_CAPTURE_SCENE && code == 1){
                if(delegate && [delegate respondsToSelector:@selector(onGetAssetListSuccess:assetType:hasNext:)]){
                    
                    [delegate onGetAssetListSuccess:[dataDic objectForKey:@"elements"] assetType:assetType hasNext:hasNext];
                }
            } else {
                
                if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:)]){
                    [delegate onGetAssetListFailed:nil assetType:assetType];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:)]){
            [delegate onGetAssetListFailed:error assetType:assetType];
        }
    }];
}
- (void)getAssetList:(AssetType)assetType
          categoryId:(int)categoryId
               page:(int32_t)page
           pageSize:(int32_t)pageSize
        kind:(int)kind modular:(NvAssetModular)modular ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon withDelegate:(id<NvHttpRequestDelegate>)delegate
{
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    NSMutableDictionary *params = [self makeRequestParam:assetType categoryId:categoryId page:page pageSize:pageSize kind:kind modular:modular ratioFlag:ratioFlag ratio:ratio sdkVerskon:sdkVerskon keyword:nil];
    
    [httpSessionManager GET:NV_ASSET_REQUEST_URL parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *err = nil;
        NSDictionary *dicResults = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&err];
        if(err) {
            if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:)]){
                [delegate onGetAssetListFailed:err assetType:assetType];
            }
        }else{
            NSInteger code = [[dicResults objectForKey:@"code"] integerValue];
            NSDictionary * dataDic = [dicResults objectForKey:@"data"];
            NSInteger total = [[dataDic objectForKey:@"total"] integerValue];
            NSInteger pageNum = [[dataDic objectForKey:@"pageNum"] integerValue];
            BOOL hasNext = pageNum < total;
            if(code == 1){
                if(delegate && [delegate respondsToSelector:@selector(onGetAssetListSuccess:assetType:hasNext:)]){
                    
                    [delegate onGetAssetListSuccess:[dataDic  objectForKey:@"elements"] assetType:assetType hasNext:hasNext];
                }
            } else {
                if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:)]){
                    
                    [delegate onGetAssetListFailed:nil assetType:assetType];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:)]){
            
            [delegate onGetAssetListFailed:error assetType:assetType];
        }
    }];
}

- (void)getAssetList:(AssetType)assetType
          categoryId:(int)categoryId
             keyword:(NSString *)keyword
                page:(int32_t)page
            pageSize:(int32_t)pageSize
                kind:(int)kind
             modular:(NvAssetModular)modular
           ratioFlag:(int)ratioFlag
               ratio:(int)ratio
          sdkVerskon:(NSString *)sdkVerskon
        withDelegate:(id<NvHttpRequestDelegate>)delegate
{
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    NSMutableDictionary *params = [self makeRequestParam:assetType categoryId:categoryId page:page pageSize:pageSize kind:kind modular:modular ratioFlag:ratioFlag ratio:ratio sdkVerskon:sdkVerskon keyword:keyword];
    [httpSessionManager GET:NV_ASSET_REQUEST_URL parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *err = nil;
        NSDictionary *dicResults = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&err];
        if(err) {
            if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:keyword:)]){
                [delegate onGetAssetListFailed:err assetType:assetType keyword:keyword];
            }
        }else{
            NSInteger code = [[dicResults objectForKey:@"code"] integerValue];
            NSDictionary * dataDic = [dicResults objectForKey:@"data"];
            NSInteger total = [[dataDic objectForKey:@"total"] integerValue];
            NSInteger pageNum = [[dataDic objectForKey:@"pageNum"] integerValue];
            BOOL hasNext = pageNum < total;
            if(code == 1){
                if(delegate && [delegate respondsToSelector:@selector(onGetAssetListSuccess:assetType:keyword:hasNext:)]){
                    [delegate onGetAssetListSuccess:[dataDic  objectForKey:@"elements"] assetType:assetType keyword:keyword hasNext:hasNext];
                }
            } else {
                if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:keyword:)]){
                    [delegate onGetAssetListFailed:nil assetType:assetType keyword:keyword];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:keyword:)]){
            [delegate onGetAssetListFailed:error assetType:assetType keyword:keyword];
        }
    }];
}

- (NSMutableDictionary *)makeRequestParam:(AssetType)assetType
                               categoryId:(int)categoryId
                                     page:(int32_t)page
                                 pageSize:(int32_t)pageSize
                                     kind:(int)kind
                                  modular:(NvAssetModular)modular
                                    ratioFlag:(int)ratioFlag
                                        ratio:(int)ratio
                                   sdkVerskon:(NSString *)sdkVerskon
                                  keyword:(NSString *)keyword
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (modular == NvAssetModularCapture) {
        params[@"suitablePlatform"] = @(1);
    }else if (modular == NvAssetModularEdit) {
        params[@"suitablePlatform"] = @(2);
    }
    if (ratioFlag != 1) {
        params[@"ratio"] = @(ratio);
        params[@"ratioFlag"] = @(ratioFlag);
    }
    
    if (assetType == ASSET_FILTER || assetType == ASSET_ANIMATED_STICKER) {
        ///贴纸传这个category数组
        ///Stickers pass this category array
        params[@"categories"] = @"1,2";
    }else if(assetType == ASSET_CAPTURE_SCENE){
        params[@"category"] = @(0);
        params[@"command"] = @"listMaterial";
    }else{
        if (categoryId != 0) {
            params[@"category"] = @(categoryId);
        }
    }
    if (kind != 0) {
        params[@"kind"] = @(kind);
    }
    params[@"pageNum"] = @(page);
    params[@"pageSize"] = @(pageSize);
    params[@"sdkVersion"] = sdkVerskon;
    if (keyword && ![keyword isEqualToString:@""]) {
        params[@"keyword"] = keyword;
    }
    if (assetType == ASSET_THEME) {
        params[@"type"] = @1;
    } else if (assetType == ASSET_FILTER || assetType == ASSET_ANIMATION_IN || assetType == ASSET_ANIMATION_OUT || assetType == ASSET_ANIMATION_COMBINE) {
        params[@"type"] = @2;
    } else if (assetType == ASSET_CAPTION_STYLE || assetType == ASSET_CAPTION_RENDERER || assetType == ASSET_CAPTION_CONTEXT || assetType == ASSET_CAPTION_ANIMATION || assetType == ASSET_CAPTION_INANIMATION || assetType == ASSET_CAPTION_OUTANIMATION) {
        params[@"type"] = @3;
    } else if (assetType == ASSET_ANIMATED_STICKER || assetType == ASSET_STICKER_ANIMATION || assetType == ASSET_STICKER_INANIMATION || assetType == ASSET_STICKER_OUTANIMATION) {
        params[@"type"] = @4;
    } else if (assetType == ASSET_VIDEO_TRANSITION) {
        params[@"type"] = @5;
    } else if (assetType == ASSET_FONT) {
        params[@"type"] = @6;
    } else if (assetType == ASSET_CAPTURE_SCENE) {
        params[@"type"] = @8;
    } else if (assetType == ASSET_PARTICLE) {
        params[@"type"] = @9;
    } else if (assetType == ASSET_FACE_STICKER) {
        params[@"type"] = @10;
    } else if (assetType == ASSET_CUSTOM_ANIMATED_STICKER) {
        params[@"type"] = @4;
    } else if (assetType == ASSET_FACE1_STICKER) {
        params[@"type"] = @12;
    } else if (assetType == ASSET_SUPERZOOM) {
        params[@"type"] = @13;
    } else if (assetType == ASSET_ARSCENE) {
        params[@"type"] = @14;
    } else if (assetType == ASSET_COMPOUND_CAPTION) {
        params[@"type"] = @15;
    } else if (assetType == ASSET_MAKEUP) {
        params[@"type"] = @20;
    }
    params[@"lang"] = [NvHttpRequest getCurrentLang];
    [self.class concatenateParameters:params];
    
    return params;
}

#pragma mark - 获取在线素材
- (void)newGetAssetList:(AssetType)assetType categoryId:(int)categoryId categoryList:(NSString *)categorys keyword:(NSString *)keyword page:(int32_t)page pageSize:(int32_t)pageSize kind:(int)kind ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon withDelegate:(id<NvHttpRequestDelegate>)delegate{
    
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    NSMutableDictionary *params = [self newMakeRequestParam:assetType categoryId:categoryId categoryList:categorys page:page pageSize:pageSize kind:kind ratioFlag:ratioFlag ratio:ratio sdkVerskon:sdkVerskon keyword:keyword];
    NSLog(@"params====================%@",params);
    [httpSessionManager GET:NV_ASSET_REQUEST_URL parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *err = nil;
        NSDictionary *dicResults = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&err];
        if(err) {
            if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:keyword:)]){
                [delegate onGetAssetListFailed:err assetType:assetType keyword:keyword];
            }
        }else{
            NSInteger code = [[dicResults objectForKey:@"code"] integerValue];
            NSDictionary * dataDic = [dicResults objectForKey:@"data"];
            NSInteger total = [[dataDic objectForKey:@"total"] integerValue];
            NSInteger pageNum = [[dataDic objectForKey:@"pageNum"] integerValue];
            BOOL hasNext = pageNum < total;
            if(code == 1){
                if(delegate && [delegate respondsToSelector:@selector(onGetAssetListSuccess:assetType:keyword:hasNext:)]){
                    [delegate onGetAssetListSuccess:[dataDic  objectForKey:@"elements"] assetType:assetType keyword:keyword hasNext:hasNext];
                }
            } else {
                if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:keyword:)]){
                    [delegate onGetAssetListFailed:nil assetType:assetType keyword:keyword];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(delegate && [delegate respondsToSelector:@selector(onGetAssetListFailed:assetType:keyword:)]){
            [delegate onGetAssetListFailed:error assetType:assetType keyword:keyword];
        }
    }];
}

#pragma mark - 拼接在线素材获取参数
///Splice online materials to obtain parameters
- (NSMutableDictionary *)newMakeRequestParam:(AssetType)assetType
                                  categoryId:(int)categoryId
                                categoryList:(NSString *)categorys
                                        page:(int32_t)page
                                    pageSize:(int32_t)pageSize
                                        kind:(int)kind
                                   ratioFlag:(int)ratioFlag
                                       ratio:(int)ratio
                                  sdkVerskon:(NSString *)sdkVerskon
                                     keyword:(NSString *)keyword
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (ratioFlag != 1) {
        params[@"ratio"] = @(ratio);
        params[@"ratioFlag"] = @(ratioFlag);
    }
    
    if (categoryId == 0) {
        if (categorys && ![categorys isEqualToString:@""]) {
            params[@"categories"] = categorys;
        }
    }else{
        params[@"category"] = @(categoryId);
    }

    if (kind != 0) {
        params[@"kind"] = @(kind);
    }
    params[@"pageNum"] = @(page);
    params[@"pageSize"] = @(pageSize);
    params[@"sdkVersion"] = sdkVerskon;
    if (keyword && ![keyword isEqualToString:@""]) {
        params[@"keyword"] = keyword;
    }
    

    if (assetType == ASSET_THEME) {
        params[@"type"] = @1;
    } else if (assetType == ASSET_FILTER || assetType == ASSET_ANIMATION_IN || assetType == ASSET_ANIMATION_OUT || assetType == ASSET_ANIMATION_COMBINE) {
        params[@"type"] = @2;
    } else if (assetType == ASSET_CAPTION_STYLE || assetType == ASSET_CAPTION_RENDERER || assetType == ASSET_CAPTION_CONTEXT || assetType == ASSET_CAPTION_ANIMATION || assetType == ASSET_CAPTION_INANIMATION || assetType == ASSET_CAPTION_OUTANIMATION) {
        params[@"type"] = @3;
    } else if (assetType == ASSET_ANIMATED_STICKER || assetType == ASSET_STICKER_ANIMATION || assetType == ASSET_STICKER_INANIMATION || assetType == ASSET_STICKER_OUTANIMATION) {
        params[@"type"] = @4;
    } else if (assetType == ASSET_VIDEO_TRANSITION) {
        params[@"type"] = @5;
    } else if (assetType == ASSET_FONT) {
        params[@"type"] = @6;
    } else if (assetType == ASSET_CAPTURE_SCENE) {
        params[@"type"] = @8;
    } else if (assetType == ASSET_PARTICLE) {
        params[@"type"] = @9;
    } else if (assetType == ASSET_FACE_STICKER) {
        params[@"type"] = @10;
    } else if (assetType == ASSET_CUSTOM_ANIMATED_STICKER) {
        params[@"type"] = @4;
    } else if (assetType == ASSET_FACE1_STICKER) {
        params[@"type"] = @12;
    } else if (assetType == ASSET_SUPERZOOM) {
        params[@"type"] = @13;
    } else if (assetType == ASSET_ARSCENE) {
        params[@"type"] = @14;
    } else if (assetType == ASSET_COMPOUND_CAPTION) {
        params[@"type"] = @15;
    } else if (assetType == ASSET_MAKEUP) {
        params[@"type"] = @20;
    }
    params[@"lang"] = [NvHttpRequest getCurrentLang];
    [self.class concatenateParameters:params];
    return params;
}

- (NSURLSessionDownloadTask *) downloadAsset:(NSString*)srcFileUrl
                                 destFileDir:(NSString*)destFileDir
                                withDelegate:(id<NvHttpRequestDelegate>)delegate
                                  downloadID:(NSString*)downloadID
{
    AFURLSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    NSURL *url = [NSURL URLWithString:srcFileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *currentTask = [httpSessionManager downloadTaskWithRequest:request
                                                                               progress:^(NSProgress * _Nonnull downloadProgress) {
        int32_t progress = (int32_t)(downloadProgress.completedUnitCount * 100 / downloadProgress.totalUnitCount);
        if(delegate && [delegate respondsToSelector:@selector(onDonwloadAssetProgress:downloadID:)])
            [delegate onDonwloadAssetProgress:progress downloadID:downloadID];
    }
                                                                            destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *filePath = [destFileDir stringByAppendingPathComponent:url.lastPathComponent];
        return [NSURL fileURLWithPath:filePath];
        
    }
                                                                      completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(delegate){
            if(error){
                if([delegate respondsToSelector:@selector(onDonwloadAssetFailed:downloadFilePath:downloadID:)])
                    [delegate onDonwloadAssetFailed:error downloadFilePath:[filePath absoluteString] downloadID:downloadID];
            } else{
                if([delegate respondsToSelector:@selector(onDonwloadAssetSuccess: downloadFilePath: downloadID:)])
                    [delegate onDonwloadAssetSuccess:TRUE downloadFilePath:[filePath absoluteString] downloadID:downloadID];
            }
        }
    }];

    [currentTask resume];
    return currentTask;
}

- (NSURLSessionDownloadTask *) downloadAsset:(NSString*)srcFileUrl
                                 destFileDir:(NSString*)destFileDir
                                  downloadID:(NSString*)downloadID
                               progressBlock:(void(^)(int32_t progress))progressBlock
                               completeBlock:(void(^)(NSString *downloadFilePath))completeBlock
                                failureBlock:(void(^)(NSError *error,NSString *downloadFilePath))failureBlock
{
    AFURLSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    NSURL *url = [NSURL URLWithString:srcFileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *currentTask = [httpSessionManager downloadTaskWithRequest:request
                                                                               progress:^(NSProgress * _Nonnull downloadProgress) {
        int32_t progress = (int32_t)(downloadProgress.completedUnitCount * 100 / downloadProgress.totalUnitCount);
        if (progressBlock) {
            progressBlock(progress);
        }
    }
                                                                            destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *filePath = [destFileDir stringByAppendingPathComponent:url.lastPathComponent];
        return [NSURL fileURLWithPath:filePath];
        
    }
                                                                      completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(error && failureBlock){
            failureBlock(error,[filePath absoluteString]);
        } else{
            if (completeBlock) {
                completeBlock([filePath absoluteString]);
            }
        }
    }];

    [currentTask resume];
    return currentTask;
}

- (void)checkNetwork:(id<NvHttpRequestDelegate>)delegate
{
    [networkManager startMonitoring];
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        BOOL isNetAvailable = YES;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: {
                isNetAvailable = NO;
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:{
                isNetAvailable = NO;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                isNetAvailable = YES;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                isNetAvailable = YES;
            }
        }
        
        if(delegate && [delegate respondsToSelector:@selector(onCheckNetworkState:)]){
            [delegate onCheckNetworkState:isNetAvailable];
        }
    }];
}

+ (NSString *)getCurrentLang{
    
    NSString * currentLang =  [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString * lang = @"en";
    NSArray *languageCodes = @[@"en", @"zh", @"es", @"ar", @"de", @"el", @"fi", @"fr", @"hi", @"id", @"it", @"ja", @"ko", @"nl", @"pl", @"pt", @"ru", @"tr", @"he", @"sv"];
    for (NSString *code in languageCodes) {
    
        if ([currentLang hasPrefix:code]) {
            
            if([code isEqualToString:@"zh"]){
                lang = @"zh-cn";
            }else{
                lang = code;
            }
            break;
        }
    }
    return lang;
}

- (void)feedBackWithContent:(NSString *)content withContact:(NSString *)contact withSdkVersion:(NSString *)sdkVersion withDeviceModel:(NSString *)deviceModel withDelegate:(id<NvHttpRequestDelegate>)delegate{
    NSDictionary *body = @{@"content":content,@"contact":contact,@"sdkVersion":sdkVersion,@"deviceModel":deviceModel};
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [httpSessionManager POST:[NV_API_HOST stringByAppendingString:NV_API_FEEDBACK] parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        [delegate feedBackWithDictionary:dict];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

+ (void)RequestPhotoAlbumMaterialListWithPage:(NSInteger)page
                                     pageSize:(NSInteger)pageSize
                              completionBlock:(void(^)(id respondData))completion
                                 failureBlock:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *urlStr = NV_ASSET_REQUEST_URL;
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{@"type":@16,
                                                                                @"pageNum":[NSNumber numberWithInteger:page],
                                                                                @"pageSize":[NSNumber numberWithInteger:pageSize],
                                                                                @"lang":[NvHttpRequest getCurrentLang]}];
    [self concatenateParameters:body];
    [httpSessionManager GET:urlStr parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        int code = [dict[@"code"] intValue];
        if (code == 1) {
            completion(dict);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@",error);
    }];
}

+ (void)RequestListCategoryWithType:(NSInteger)type
                             category:(NSString *)category
                           sdkVersion:(NSString *)sdkVersion
                                 page:(NSInteger)page
                             pageSize:(NSInteger)pageSize
                      completionBlock:(void(^)(id respondData))completion
                         failureBlock:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSString *urlStr = NV_MAKEUP_SINGLE_URL;
    NSDictionary *body = @{@"types":@(type),@"categories":category,@"sdkVersion":sdkVersion};
    if (category.length == 0) {
        body = @{@"types":@(type),@"sdkVersion":sdkVersion};
    }
    [httpSessionManager GET:urlStr parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        int errNo = [dict[@"errNo"] intValue];
        if (errNo == 0) {
            NSArray *arr = dict[@"data"];
            NSDictionary *dicInfo = arr[0];
            NSArray *arr1 = dicInfo[@"categories"];
            for (int i = 0; i < arr1.count; i++) {
                NSDictionary *categories = arr1[i];
                NSArray *arr2 = categories[@"kinds"];
                if (type == 2) {
                    [mutableArray addObjectsFromArray:arr2];
                }else{
                    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:categories];
                    [mutableDictionary setValue:categories[@"id"] forKey:@"category"];
                    [mutableDictionary setValue:@(0) forKey:@"id"];
                    [mutableArray addObject:mutableDictionary];
                }
            }
            
            completion(mutableArray);
            
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@",error);
    }];
}

+ (void)RequestMakeupKindListWithType:(NSInteger)type
                             category:(NSInteger)category
                           sdkVersion:(NSString *)sdkVersion
                                 page:(NSInteger)page
                             pageSize:(NSInteger)pageSize
                      completionBlock:(void(^)(id respondData))completion
                         failureBlock:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];

    
    NSString *urlStr = NV_MAKEUP_SINGLE_URL;
    NSDictionary *body = @{@"types":@(type),@"categories":@(category),@"sdkVersion":sdkVersion};
    [httpSessionManager GET:urlStr parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        int errNo = [dict[@"errNo"] intValue];
        if (errNo == 0) {
            NSArray *arr = dict[@"data"];
            NSDictionary *dicInfo = arr[0];
            NSArray *arr1 = dicInfo[@"categories"];
            NSDictionary *categories = arr1[0];
            NSArray *arr2 = categories[@"kinds"];
            completion(arr2);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@",error);
    }];
}

+ (void)RequestVariableMakeupListWithType:(NSInteger)type
                                 category:(NSInteger)category
                                     kind:(NSInteger)kind
                                ratioFlag:(NSInteger)ratioFlag
                                    ratio:(NSInteger)ratio
                               sdkVersion:(NSString *)sdkVersion
                                     page:(NSInteger)page
                                 pageSize:(NSInteger)pageSize
                          completionBlock:(void(^)(id respondData))completion
                             failureBlock:(void(^)(NSError *error))failure {
    NSString *urlStr = NV_ASSET_REQUEST_URL;
    ///sorted字段，0是按照星级排序，不传或者1是按照创建时间排序
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{@"type":@(type),
                                                                                @"sdkVersion":sdkVersion,
                                                                                @"pageNum":@(page),
                                                                                @"pageSize":@(pageSize),
                                                                                @"lang":[NvHttpRequest getCurrentLang],
                                                                                @"sorted":@0}] ;

    if (kind && kind != -1) {
        [body setValue:@(kind)forKey:@"kind"];
    }
    if (category && category != -1) {
        [body setValue:@(category)forKey:@"category"];
    }
    
    if (ratioFlag != 1) {
        body[@"ratio"] = @(ratio);
        body[@"ratioFlag"] = @(ratioFlag);
    }
    
    [self concatenateParameters:body];
    
    [httpSessionManager GET:urlStr parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        int errNo = [dict[@"errNo"] intValue];
        if (errNo == 0) {
            completion(dict);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(nil);
        }
        NSLog(@"%@",error);
    }];
}

+ (void)RequestBeautyTemplateListWithType:(NSInteger)type category:(NSInteger)category kind:(NSInteger)kind ratioFlag:(NSInteger)ratioFlag ratio:(NSInteger)ratio sdkVersion:(NSString *)sdkVersion page:(NSInteger)page pageSize:(NSInteger)pageSize completionBlock:(void (^)(id))completion failureBlock:(void (^)(NSError *))failure{
    NSString *urlStr = NV_ASSET_REQUEST_URL;
    ///sorted字段，0是按照星级排序，不传或者1是按照创建时间排序
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{@"type":@(type),
                                                                                @"sdkVersion":sdkVersion,
                                                                                @"pageNum":@(page),
                                                                                @"pageSize":@(pageSize),
                                                                                @"lang":[NvHttpRequest getCurrentLang],
                                                                                @"sorted":@0}] ;

    if (kind && kind != -1) {
        [body setValue:@(kind)forKey:@"kind"];
    }
    if (category && category != -1) {
        [body setValue:@(category)forKey:@"category"];
    }
    
    if (ratioFlag != 1) {
        body[@"ratio"] = @(ratio);
        body[@"ratioFlag"] = @(ratioFlag);
    }
    
    [self concatenateParameters:body];
    
    [httpSessionManager GET:urlStr parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        int errNo = [dict[@"errNo"] intValue];
        if (errNo == 0) {
            completion(dict);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

+ (void)RequestListMediaInfoListWithType:(NSInteger)type
                                     page:(NSInteger)page
                                 pageSize:(NSInteger)pageSize
                          completionBlock:(void(^)(id respondData))completion
                            failureBlock:(void(^)(NSError *error))failure{
    AFHTTPSessionManager *httpSessionManager = [NvHttpRequest sharedManager];
    httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    httpSessionManager.requestSerializer.timeoutInterval = 15.0;
    NSString *urlStr = NV_LISTMEDIAINFO_URL;
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{@"type":@(type),@"pageNum":@(page),
                                                                                @"pageSize":@(pageSize), @"lang":[NvHttpRequest getCurrentLang]}] ;
    
    [self concatenateParameters:body];
    
    [httpSessionManager GET:urlStr parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        int errNo = [dict[@"errNo"] intValue];
        if (errNo == 0) {
            completion(dict);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@",error);
    }];
}

+ (BOOL)getTestMaterial{
    if ([NV_TEST_MATERIAL isEqualToString:@"1"]){
        return true;
    }
    return false;
}

+(void)concatenateParameters:(NSMutableDictionary *)dict{
    if ([self getTestMaterial]){
        NSNumber * testNumMaterialNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"NvTestNumMaterial"];
        if (testNumMaterialNum && testNumMaterialNum.boolValue){
            [dict setValue:@(0) forKey:@"isTestMaterial"];
        }
    }
}

@end
