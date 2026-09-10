//
//  NveEffectKit.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/6.
//

#import "NveBeauty.h"
#import "NveFilter.h"
#import "NveFilterContainer.h"
#import "NveMakeup.h"
#import "NveComposeMakeup.h"
#import "NveMicroShape.h"
#import "NveRenderInput.h"
#import "NveRenderOutput.h"
#import "NveShape.h"
#import "NveFaceProp.h"
#import "NveMutableArray.h"

#if __has_include(<NvStreamingSdkCore/NvStreamingSdkCore.h>)
#import <NvStreamingSdkCore/NvStreamingSdkCore.h>
#else
#import <NvEffectSdkCore/NvEffectSdkCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/*! \if ENGLISH
 *  \brief Flag of human detection
 *  \else
 *  \brief 人体检测特征标志
 *  \endif
 */
typedef NS_ENUM(NSInteger, NveDetectionModelType) {
    NveDetectionModelType_face,       // 人脸 / Face
    NveDetectionModelType_hand,       // 手势 / Hand
    NveDetectionModelType_avatar,     // avatar
    NveDetectionModelType_fakeFace,   // 假脸，人脸道具使用 / Fake face, face prop use
    NveDetectionModelType_eyeball,    // 眼球, / Eyeball
    NveDetectionModelType_makeup2,    // 美妆 / Makeup deprecated, replaced by NvsHumanDetectionDataType_FaceCommon
    NveDetectionModelType_background, // 背景分割 部分人脸道具会用到分割效果 /
                                      // Backgroud，Some face props use the
                                      // segmentation effect

    NveDetectionModelType_faceCommon,    //人脸通用模型 Universal face model
    NveDetectionModelType_advancedBeauty //高级美颜模型 AdvancedBeauty model
};

@interface NveEffectKit : NSObject

/// 美颜后的滤镜
@property(nonatomic, strong) NveFilterContainer *filterContainer;

/// 美颜前的滤镜  如：背景分割、背景模糊 / Filters before beauty such as: background segmentation, background blur
@property(nonatomic, strong) NveFilterContainer *rawFilterContainer;

/// 美颜
@property(nonatomic, strong) NveBeauty *_Nullable beauty;

/// 美型
@property(nonatomic, strong) NveShape *_Nullable shape;

/// 微整形
@property(nonatomic, strong) NveMicroShape *_Nullable microShape;

/// 美妆
@property(nonatomic, strong) NveMakeup *_Nullable makeup;

/// 人脸道具
@property(nonatomic, strong) NveFaceProp *_Nullable prop;

/// Makeup Theme
@property(nonatomic, strong) NveComposeMakeup *_Nullable composeMakeup;

@property(nonatomic, readonly) int64_t renderTime;

/// 自定义特效数组，NveEffectKit销毁时，销毁数组中的特效
@property(nonatomic, strong) NveMutableArray<NvsEffect *> *customEffectArray;

@property(nonatomic, weak) id<NvsARSceneManipulateDelegate> manipulateDelegate;

- (instancetype)init NS_UNAVAILABLE;

/*! \if ENGLISH
 *  \brief Verifies the SDK license file. Note: The license file interface must
 * be called before the NveEffectKit is initialized.
 *  \param sdkLicenseFilePath
 * Path of SDK license file
 *  \return Returns the BOOL value. YES indicates that
 * the authorization verification is successful,
 *  \else
 *  \brief 验证SDK授权文件。注意：授权文件接口必须在NveEffectKit获取单例前之前调用。
 *  \param sdkLicenseFilePath SDK授权文件路径
 *  \return 返回BOOL值。YES表示授权验证成功，NO则验证失败。若验证失败，则渲染失败 \endif
 */
+ (BOOL)verifySdkLicenseFile:(NSString *)sdkLicenseFilePath;

/*! \if ENGLISH
 *  \brief Initializes the human body detection mechanism.
 *  \param type Type of model
 *  \param modelFilePath Path of the model file
 *  \param licenseFilePath license file path
 *  \else
 *  \brief 初始化人体检测机制,
 *  \param type 模型类型
 *  \param modelFilePath 模型文件路径
 *  \param licenseFilePath 授权文件路径
 *  \endif
 */
+ (BOOL)initHumanDetection:(NveDetectionModelType)type modelPath:(NSString *)modelFilePath licenseFilePath:(NSString *_Nullable)licenseFilePath;

/*! \if ENGLISH
 *  \brief Gets a unique instance of the effect kit.
 *  \return Returns an object instance of the effect kit.
 *  \else
 *  \brief 获取唯一实例
 *  \return 返回对象实例
 *  \endif
 *  \sa destroyInstance
 */
+ (instancetype)shareInstance;

/*! \if ENGLISH
 *  \brief Destroys the effect kit instance.
 *  \else
 *  \brief 销毁实例。
 *  \endif
 *  \sa sharedInstance
 */
+ (void)destroyInstance;

/*! \if ENGLISH
 *  \brief Installs asset package
 *  \param assetPackageFilePath Asset package file path
 *  \param licenseFilePath License file path
 *  \param type Asset package type
 *  \param assetPackageId output value. Output asset package ID
 *  \return Return error value of installation. NvsAssetPackageManagerError_NoError indicates that the installation succeeds (It can only be returned in synchronous installation), otherwise it fails.
 *  \else
 *  \brief 安装资源包
 *  \param assetPackageFilePath 待安装资源包的文件路径 \param licenseFilePath 待安装资源包的授权文件路径
 *  \param type 待安装资源包的类型
 *  \param 注意：如果type是模板类型，那么只能使用异步安装。
 *  \param assetPackageId 返回值，返回该资源包ID。
 *  \return 返回错误类型值。NvsAssetPackageManagerError_NoError:  表示安装成功（只有同步安装才可能返回这个)，任何其它返回值都表示安装错误。
 *  \endif
 */
- (NvsAssetPackageManagerError)installAssetPackage:(NSString *)assetPackageFilePath
                                           license:(NSString *)licenseFilePath
                                              type:(NvsAssetPackageType)type
                                    assetPackageId:(NSMutableString *)assetPackageId;

/*! \if ENGLISH
 *  \brief Get the AR scene operation pointer.
 *  \return Return the AR scene operation pointer.
 *  \else
 *  \brief 获得AR场景操作指针
 *  \return 返回指向AR场景操作指针
 *  \endif
*/
- (NvsARSceneManipulate *)getARSceneManipulate;

/*!
 *    \if ENGLISH
 *  \brief Get the prompt message of the ARScene asset package
 *  \param uuidString asset package uuid
 *  \return Returns a String object which represent the prompt message.
 *    \else
 *  \brief 获取ARScene资源包的提示信息
 *  \param uuidString 资源包uuid
 *  \return 返回提示信息的String对象
 *    \endif
 */
- (NSString *)getARSceneAssetPackagePrompt:(NSString *)uuidString;

/*! \if ENGLISH
 *  \brief Get the AR Scene Fx pointer.Please note that, whenever possible, you should avoid creating strong references to this object from external code; the destruction of this object is handled internally by EffectKit.
 *  \return Return the AR Scene Fx pointer.
 *  \else
 *  \brief 获得AR Scene特效指针，注意外部尽量不要强引用这个对象，这个对象的销毁是effectkit内部来处理的。
 *  \return 返回指向AR Scene特效指针
 *  \endif
 */
- (nullable NvsVideoEffect *)getARSceneObject;

@end

@interface NveEffectKit (Render)

/*! \if ENGLISH
 *  \brief Rendering interface
 *  \param input Input
 *  \return Render result
 *  \else
 *  \brief 渲染接口
 *  \param input 输入
 *  \return 渲染结果
 *  \endif
 */
- (NveRenderOutput *)renderEffect:(NveRenderInput *)input;

/*! \if ENGLISH
 *  \brief Recycle render output
 *  \param output Render output
 *  \else
 *  \brief 回收渲染输出
 *  \param output 渲染输出
 *  \endif
 */
- (void)recycleOutput:(NveRenderOutput *)output;

/*! \if ENGLISH
 *  \brief Uploading buffer to GPU texture
 *  \param frameBuffer buffer of the uploding frame (NV12 format).
 *  \param horizontalFlip hrozontal flip
 *  \param outputTexId ID of output texture
 *  \return "NvsEffectCoreError_NoError" means success, while any other value
 * means failure. Refer to the error code definition.
 *  \else
 *  \brief 上传buffer到GPU纹理
 *  \param frameBuffer 需要上传buffer(支持NV12)
 *  \param horizontalFlip 是否横向反转
 *  \param outputTexId 输出纹理
 *  \return 返回NvsEffectCoreError_NoError为成功,其他值都是错误,参考错误码定义
 *  \endif
 */
- (NvsEffectCoreError)uploadPixelBufferToTexture:(CVPixelBufferRef)frameBuffer
                                 displayRotation:(int)rotation
                                  horizontalFlip:(BOOL)flip
                                     outputTexId:(int)outputTexId;

/*! \if ENGLISH
 *  \brief Downloading buffer from GPU texture
 *  \param inputTexId ID of input texture
 *  \param inputVideoResolution Resolution of input texture
 *  \param outputFrameFormat returned buffer foramt(BGRA or YUV420 format)
 *  \param isBT601 The color is converted according to BT.601 standard. If the returned buffer format is YUV, this parameter is meaningful.
 *  \param frameBuffer returned buffer of the downloading frame (BGRA or YUV420 format).
 *  \return "NvsEffectCoreError_NoError" means success, while any other value
 * means failure. Refer to the error code definition.
 *  \else
 *  \brief  从GPU纹理下传到buffer
 *  \param inputTexId 输入纹理
 *  \param inputVideoResolution 输入纹理的视频解析度
 *  \param outputFrameFormat 返回下传的buffer格式(BGRA or YUV420 format)
 *  \param isBT601 是否按照BT.601的标准转化,如果返回下传的buffer格式为YUV,这个参数有意义
 *  \param frameBuffer 返回下传的buffer(BGRA or YUV420 format)
 *  \return 返回NvsEffectCoreError_NoError为成功,其他值都是错误,参考错误码定义
 *  \endif
 */
- (NvsEffectCoreError)downloadPixelBufferFromTexture:(int)inputTexId
                                inputVideoResolution:(NvsEffectVideoResolution *)inputVideoResolution
                                   outputFrameFormat:(NvsEffectVideoFramePixelFormat)format
                                             isBT601:(BOOL)is601
                                         outputFrame:(CVPixelBufferRef _Nullable *_Nonnull)frameBuffer;

@end

@interface NveEffectKit (Debug)

- (BOOL)outputParamToJsonFile:(NSString *)jsonFilePath;

@end

NS_ASSUME_NONNULL_END
