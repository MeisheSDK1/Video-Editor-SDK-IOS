//
//  NSArray+safeAccess.h
//  SDKDemo
//
//  Created by meishe01 on 2024/3/20.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (safeAccess)
- (id)ex_objectWithIndex:(NSUInteger)index;

- (NSString*)ex_stringWithIndex:(NSUInteger)index;
///返回非nil字符串
- (NSString*)ex_nonullStringWithIndex:(NSUInteger)index;

- (NSNumber*)ex_numberWithIndex:(NSUInteger)index;
///返回非nil Number
- (NSNumber*)ex_nonullNumberWithIndex:(NSUInteger)index;

- (NSDecimalNumber *)ex_decimalNumberWithIndex:(NSUInteger)index;
///返回非nil DecimalNumber
- (NSDecimalNumber *)ex_nonullDecimalNumberWithIndex:(NSUInteger)index;

- (NSArray*)ex_arrayWithIndex:(NSUInteger)index;
///返回非nil Array
- (NSArray*)ex_nonullArrayWithIndex:(NSUInteger)index;

- (NSDictionary*)ex_dictionaryWithIndex:(NSUInteger)index;
///返回非nil Dictionary
- (NSDictionary*)ex_nonullDictionaryWithIndex:(NSUInteger)index;

- (NSInteger)ex_integerWithIndex:(NSUInteger)index;

- (NSUInteger)ex_unsignedIntegerWithIndex:(NSUInteger)index;

- (BOOL)ex_boolWithIndex:(NSUInteger)index;

- (int16_t)ex_int16WithIndex:(NSUInteger)index;

- (int32_t)ex_int32WithIndex:(NSUInteger)index;

- (int64_t)ex_int64WithIndex:(NSUInteger)index;

- (char)ex_charWithIndex:(NSUInteger)index;

- (short)ex_shortWithIndex:(NSUInteger)index;

- (float)ex_floatWithIndex:(NSUInteger)index;

- (double)ex_doubleWithIndex:(NSUInteger)index;

- (NSDate *)ex_dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat;

//CG
- (CGFloat)ex_CGFloatWithIndex:(NSUInteger)index;

- (CGPoint)ex_pointWithIndex:(NSUInteger)index;

- (CGSize)ex_sizeWithIndex:(NSUInteger)index;

- (CGRect)ex_rectWithIndex:(NSUInteger)index;
@end


#pragma --mark NSMutableArray setter

@interface NSMutableArray(safeAccess)

-(void)ex_addObj:(id)aObj;

-(void)ex_removeObjWithIndex:(NSUInteger)index;

-(void)ex_addString:(NSString*)aString;

-(void)ex_addBool:(BOOL)aBoolValue;

-(void)ex_addInt:(int)aIntValue;

-(void)ex_addInteger:(NSInteger)aIntegerValue;

-(void)ex_addUnsignedInteger:(NSUInteger)aUInterValue;

-(void)ex_addCGFloat:(CGFloat)aFloatValue;

-(void)ex_addChar:(char)aCharValue;

-(void)ex_addFloat:(float)aFloatValue;

-(void)ex_addPoint:(CGPoint)aPointValue;

-(void)ex_addSize:(CGSize)aSize;

-(void)ex_addRect:(CGRect)aRect;
@end

NS_ASSUME_NONNULL_END
