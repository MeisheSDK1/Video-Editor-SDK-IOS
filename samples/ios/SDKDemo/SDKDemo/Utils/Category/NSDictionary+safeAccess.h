//
//  NSDictionary+safeAccess.h
//  SDKDemo
//
//  Created by meishe01 on 2024/3/20.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (safeAccess)

- (BOOL)ex_hasKey:(nonnull NSString *)key;

- (NSString* _Nullable)ex_stringForKey:(nonnull id)key;
///返回非nil字符串
- (NSString* _Nullable)ex_nonullStringForKey:(nonnull id)key;

- (NSNumber* _Nullable)ex_numberForKey:(nonnull id)key;
///返回非nil Number
- (NSNumber* _Nullable)ex_nonullNumberForKey:(nonnull id)key;

- (NSDecimalNumber * _Nullable)ex_decimalNumberForKey:(nonnull id)key;
///返回非nil NSDecimalNumber
- (NSDecimalNumber * _Nullable)ex_nonullDecimalNumberForKey:(nonnull id)key;

- (NSArray* _Nullable)ex_arrayForKey:(nonnull id)key;
///返回非nil NSArray
- (NSArray* _Nullable)ex_nonullArrayForKey:(nonnull id)key;

- (NSDictionary* _Nullable)ex_dictionaryForKey:(nonnull id)key;
///返回非nil NSDictionary
- (NSDictionary* _Nullable)ex_nonullDictionaryForKey:(nonnull id)key;

- (NSInteger)ex_integerForKey:(nonnull id)key;

- (NSUInteger)ex_unsignedIntegerForKey:(nonnull id)key;

- (BOOL)ex_boolForKey:(nonnull id)key;

- (int16_t)ex_int16ForKey:(nonnull id)key;

- (int32_t)ex_int32ForKey:(nonnull id)key;

- (int64_t)ex_int64ForKey:(nonnull id)key;

- (char)ex_charForKey:(nonnull id)key;

- (short)ex_shortForKey:(nonnull id)key;

- (float)ex_floatForKey:(nonnull id)key;

- (double)ex_doubleForKey:(nonnull id)key;

- (long long)ex_longLongForKey:(nonnull id)key;

- (unsigned long long)ex_unsignedLongLongForKey:(nonnull id)key;

- (NSDate * _Nullable)ex_dateForKey:(nonnull id)key dateFormat:(nonnull NSString *)dateFormat;

//CG
- (CGFloat)ex_CGFloatForKey:(nonnull id)key;

- (CGPoint)ex_pointForKey:(nonnull id)key;

- (CGSize)ex_sizeForKey:(nonnull id)key;

- (CGRect)ex_rectForKey:(nonnull id)key;

@end

#pragma --mark NSMutableDictionary setter

@interface NSMutableDictionary(safeAccess)

///防止key值为空崩溃处理
-(void)ex_setValue:(nullable id)i forKey:(nonnull NSString*)key;
    
-(void)ex_setObj:(nullable id)i forKey:(nonnull NSString*)key;

-(void)ex_setString:(nonnull NSString*)i forKey:(nonnull NSString*)key;

-(void)ex_setBool:(BOOL)i forKey:(nonnull NSString*)key;

-(void)ex_setInt:(int)i forKey:(nonnull NSString*)key;

-(void)ex_setInteger:(NSInteger)i forKey:(nonnull NSString*)key;

-(void)ex_setUnsignedInteger:(NSUInteger)i forKey:(nonnull NSString*)key;

-(void)ex_setCGFloat:(CGFloat)f forKey:(nonnull NSString*)key;

-(void)ex_setChar:(char)c forKey:(nonnull NSString*)key;

-(void)ex_setFloat:(float)i forKey:(nonnull NSString*)key;

-(void)ex_setDouble:(double)i forKey:(nonnull NSString*)key;

-(void)ex_setLongLong:(long long)i forKey:(nonnull NSString*)key;

-(void)ex_setPoint:(CGPoint)o forKey:(nonnull NSString*)key;

-(void)ex_setSize:(CGSize)o forKey:(nonnull NSString*)key;

-(void)ex_setRect:(CGRect)o forKey:(nonnull NSString*)key;
@end



NS_ASSUME_NONNULL_END
