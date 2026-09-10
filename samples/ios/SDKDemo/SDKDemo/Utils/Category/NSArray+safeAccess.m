//
//  NSArray+safeAccess.m
//  SDKDemo
//
//  Created by meishe01 on 2024/3/20.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NSArray+safeAccess.h"

@implementation NSArray (safeAccess)

-(id)ex_objectWithIndex:(NSUInteger)index{
    if (index >= 0 && index < self.count) {
        return self[index];
    }else{
        return nil;
    }
}

- (NSString*)ex_stringWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    if (value == nil || value == [NSNull null] || [[value description] isEqualToString:@"<null>"]){
        return nil;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString*)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    return nil;
}

- (NSString*)ex_nonullStringWithIndex:(NSUInteger)index
{
    id value = [self ex_stringWithIndex:index];
    return value ? : @"";
}

- (NSNumber*)ex_numberWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber*)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f numberFromString:(NSString*)value];
    }
    return nil;
}

- (NSNumber*)ex_nonullNumberWithIndex:(NSUInteger)index
{
    id value = [self ex_numberWithIndex:index];
    return value ? : @(0);
}

- (NSDecimalNumber *)ex_decimalNumberWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber * number = (NSNumber*)value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString * str = (NSString*)value;
        return [str isEqualToString:@""] ? nil : [NSDecimalNumber decimalNumberWithString:str];
    }
    return nil;
}

- (NSDecimalNumber *)ex_nonullDecimalNumberWithIndex:(NSUInteger)index{
    
    id value = [self ex_decimalNumberWithIndex:index];
    return value ? : @(0);
}

- (NSArray*)ex_arrayWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    if (value == nil || value == [NSNull null]){
        return nil;
    }
    if ([value isKindOfClass:[NSArray class]]){
        return value;
    }
    return nil;
}

- (NSArray*)ex_nonullArrayWithIndex:(NSUInteger)index{
    
    id value = [self ex_arrayWithIndex:index];
    return value ? : @[];
}


- (NSDictionary*)ex_dictionaryWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    if ([value isKindOfClass:[NSDictionary class]])
    {
        return value;
    }
    return nil;
}

- (NSDictionary*)ex_nonullDictionaryWithIndex:(NSUInteger)index
{
    id value = [self ex_dictionaryWithIndex:index];
    return value ? : @{};
}

- (NSInteger)ex_integerWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
    {
        return [value integerValue];
    }
    return 0;
}

- (NSUInteger)ex_unsignedIntegerWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
    {
        return [value unsignedIntegerValue];
    }
    return 0;
}

- (BOOL)ex_boolWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return NO;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value boolValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value boolValue];
    }
    return NO;
}

- (int16_t)ex_int16WithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}

- (int32_t)ex_int32WithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}

- (int64_t)ex_int64WithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value longLongValue];
    }
    return 0;
}

- (char)ex_charWithIndex:(NSUInteger)index{
    
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value charValue];
    }
    return 0;
}

- (short)ex_shortWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}

- (float)ex_floatWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value floatValue];
    }
    return 0;
}

- (double)ex_doubleWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value doubleValue];
    }
    return 0;
}

- (NSDate *)ex_dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat {
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = dateFormat;
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    
    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] && !dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

//CG
- (CGFloat)ex_CGFloatWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value doubleValue];
    }
    
    return 0;
}

- (CGPoint)ex_pointWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return CGPointZero;
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return CGPointFromString(value);
    }
 
    return CGPointZero;
}

- (CGSize)ex_sizeWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return CGSizeZero;
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return CGSizeFromString(value);
    }
    
    return CGSizeZero;
}

- (CGRect)ex_rectWithIndex:(NSUInteger)index
{
    id value = [self ex_objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return CGRectZero;
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return CGRectFromString(value);
    }
    
    return CGRectZero;
}
@end


#pragma --mark NSMutableArray setter
@implementation NSMutableArray (safeAccess)
-(void)ex_addObj:(id)i{
    if (i != nil) {
        [self addObject:i];
    }
}

-(void)ex_removeObjWithIndex:(NSUInteger)index{
    
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    }
}

-(void)ex_addString:(NSString*)i
{
    if (i != nil) {
        [self addObject:i];
    }
}

-(void)ex_addBool:(BOOL)i
{
    [self addObject:@(i)];
}

-(void)ex_addInt:(int)i
{
    [self addObject:@(i)];
}

-(void)ex_addInteger:(NSInteger)i
{
    [self addObject:@(i)];
}

-(void)ex_addUnsignedInteger:(NSUInteger)i
{
    [self addObject:@(i)];
}

-(void)ex_addCGFloat:(CGFloat)f
{
    [self addObject:@(f)];
}

-(void)ex_addChar:(char)c
{
    [self addObject:@(c)];
}

-(void)ex_addFloat:(float)i
{
    [self addObject:@(i)];
}

-(void)ex_addPoint:(CGPoint)o
{
    [self addObject:NSStringFromCGPoint(o)];
}

-(void)ex_addSize:(CGSize)o
{
    [self addObject:NSStringFromCGSize(o)];
}

-(void)ex_addRect:(CGRect)o
{
    [self addObject:NSStringFromCGRect(o)];
}
@end
