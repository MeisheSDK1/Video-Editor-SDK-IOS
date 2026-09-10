//
//  NveItem.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*! \if ENGLISH
 *  \brief Parameter type of Effect
 *  \else
 *  \brief 特效参数类型
 *  \endif
 */
typedef NS_ENUM(NSInteger, NveParamType) {
    NveParamType_bool,
    NveParamType_int,
    NveParamType_float,
    NveParamType_string,
    NveParamType_expr,
    NveParamType_color,
    NveParamType_MenuVal
};

@interface NveItem : NSObject

@property(nonatomic, strong) NSString *name;

@property(nonatomic, assign) BOOL enable;

/*! \if ENGLISH
 *  \brief List of builtin effects:
 * https://www.meishesdk.com/ios/doc_ch/html/content/FxNameList_8md.html \else
 *  \brief
 * 特效参数列表：https://www.meishesdk.com/ios/doc_ch/html/content/FxNameList_8md.html
 *  \endif
 */
- (void)setEffectParam:(NSString *)key type:(NveParamType)type value:(id)value;
- (id)getEffectParam:(NSString *)key type:(NveParamType)type;

- (void)changeInPoint:(int64_t)inPoint;

@end

NS_ASSUME_NONNULL_END
