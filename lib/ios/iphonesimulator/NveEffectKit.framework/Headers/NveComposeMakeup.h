//
//  NveComposeMakeup.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NveComposeMakeup;
@class NveFilter;

@protocol NveComposeMakeupApplyDelegate <NSObject>
@optional
/// 在 NveComposeMakeup 即将被应用前回调，外部应进行必要的清理
/// @param makeup 即将应用的化妆组合对象
- (void)composeMakeupWillApply:(NveComposeMakeup *)makeup;

@end

@interface NveComposeMakeup : NSObject

@property(nonatomic, readonly) NSArray<NveFilter *> *composeMakeupInnerFilters;

//!< \if ENGLISH Intensity,Value range: 0-1 \else 妆容整体强度，取值范围：0-1 \endif
@property(nonatomic, assign) double intensity;

@property(nonatomic, weak) id<NveComposeMakeupApplyDelegate> _Nullable applyDelegate;

@property(nonatomic, readonly) NSString *packagePath; //!< \if ENGLISH The path of package \else
                                                      //!< 妆容包zip解压后的路径 \endif

/*! \if ENGLISH
 *  \brief create makeup theme object
 *  \param packagePath The path of package
 *  \return Makeup theme object
 *  \else
 *  \brief 新建妆容对象
 *  \param packagePath 妆容包zip解压后的路径
 *  \return 新建对象
 *  \endif
 */
+ (instancetype _Nullable)composeMakeupWithPackagePath:(NSString *)packagePath NS_SWIFT_NAME(composeMakeup(packagePath:));

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
