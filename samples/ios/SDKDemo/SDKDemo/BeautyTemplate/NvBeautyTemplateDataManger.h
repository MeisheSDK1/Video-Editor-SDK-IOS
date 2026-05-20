//
//  NvBeautyTemplateDataManger.h
//  SDKDemo
//
//  Created by ms20221114 on 2023/2/22.
//  Copyright © 2023 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NvBeautyTemplateModel;
@class NvMakeupToolModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvBeautyTemplateDataManger : NSObject

@property (nonatomic, strong) NSMutableArray *dataArray;

/// 读取模版数据
/// Read the template data
/// - Parameter path: 文件路径
/// File path
- (NvMakeupToolModel *)analyticalTemplatePath:(NSString *)path;

/// 配置工程内置数据
/// configure Produc Data
- (void)configureProducData;

/// 配置沙盒数据
/// configure Sandbox Data
- (void)configureSandboxData;

/// 创建网络数据请求
/// - Parameters:
///   - view: UICollectionView
///   - success: 完成回调 success block
///   - failure: 失败回调 failure block
- (void)refreshRequestData:(UICollectionView *)view withSuccess:(void(^)(id respondData))success withFailure:(void(^)(NSError *error))failure;

/// 开始请求数据
/// start Request Data
- (void)startRequestData;

/// 下载
/// - Parameters:
///   - model: 模型 model
///   - progressBlock: 进度回调
///   - success: 完成回调 success block
///   - failure: 失败回调 failure block
- (void)downloadData:(NvBeautyTemplateModel *)model WithProgress:(void(^)(CGFloat progress))progressBlock WithSuccess:(void(^)(id respondData))success withFailure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
