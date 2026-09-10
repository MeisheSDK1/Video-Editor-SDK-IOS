//
//  NSDictionary+safeAccess.m
//  SDKDemo
//
//  Created by meishe01 on 2024/3/20.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NSDictionary+safeAccess.h"


@implementation NSDictionary (safeAccess)

- (BOOL)ex_hasKey:(NSString *)key
{
    return [self objectForKey:key] != nil;
}

- (NSString*)ex_stringForKey:(id)key
{
    id value = [self objectForKey:key];
    if (value == nil || value == [NSNull null])
    {
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

- (NSString*)ex_nonullStringForKey:(id)key{
    
    id value = [self ex_stringForKey:key];
    return value ? : @"";
}

- (NSNumber*)ex_numberForKey:(id)key
{
    id value = [self objectForKey:key];
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

- (NSNumber*)ex_nonullNumberForKey:(id)key{
    
    id value = [self ex_numberForKey:key];
    return value ? : @(0);
}

- (NSDecimalNumber *)ex_decimalNumberForKey:(id)key {
    id value = [self objectForKey:key];
    
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

- (NSDecimalNumber *)ex_nonullDecimalNumberForKey:(id)key {
    
    id value = [self ex_decimalNumberForKey:key];
    return value ? : @(0);
}

- (NSArray*)ex_arrayForKey:(id)key
{
    id value = [self objectForKey:key];
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    if ([value isKindOfClass:[NSArray class]])
    {
        return value;
    }
    return nil;
}

- (NSArray*)ex_nonullArrayForKey:(id)key{
    
    id value = [self ex_arrayForKey:key];
    return value ? : @[];
}

- (NSDictionary*)ex_dictionaryForKey:(id)key
{
    id value = [self objectForKey:key];
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

- (NSDictionary*)ex_nonullDictionaryForKey:(id)key{
    
    id value = [self ex_dictionaryForKey:key];
    return value ? : @{};
}

- (NSInteger)ex_integerForKey:(id)key
{
    id value = [self objectForKey:key];
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

- (NSUInteger)ex_unsignedIntegerForKey:(id)key{
    id value = [self objectForKey:key];
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

- (BOOL)ex_boolForKey:(id)key
{
    id value = [self objectForKey:key];
    
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

- (int16_t)ex_int16ForKey:(id)key
{
    id value = [self objectForKey:key];
    
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

- (int32_t)ex_int32ForKey:(id)key
{
    id value = [self objectForKey:key];
    
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

- (int64_t)ex_int64ForKey:(id)key
{
    id value = [self objectForKey:key];
    
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

- (char)ex_charForKey:(id)key{
    id value = [self objectForKey:key];
    
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

- (short)ex_shortForKey:(id)key
{
    id value = [self objectForKey:key];
    
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

- (float)ex_floatForKey:(id)key
{
    id value = [self objectForKey:key];
    
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

- (double)ex_doubleForKey:(id)key
{
    id value = [self objectForKey:key];
    
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

- (long long)ex_longLongForKey:(id)key
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value longLongValue];
    }
    return 0;
}

- (unsigned long long)ex_unsignedLongLongForKey:(id)key
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedLongLongValue];
    }
    return 0;
}

- (NSDate *)ex_dateForKey:(id)key dateFormat:(NSString *)dateFormat{
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = dateFormat;
    id value = [self objectForKey:key];
    
    if (value == nil || value == [NSNull null]){
        return nil;
    }
    
    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] && !dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

//CG
- (CGFloat)ex_CGFloatForKey:(id)key
{
    CGFloat f = [self[key] doubleValue];
    return f;
}

- (CGPoint)ex_pointForKey:(id)key
{
    CGPoint point = CGPointFromString(self[key]);
    return point;
}
- (CGSize)ex_sizeForKey:(id)key
{
    CGSize size = CGSizeFromString(self[key]);
    return size;
}
- (CGRect)ex_rectForKey:(id)key
{
    CGRect rect = CGRectFromString(self[key]);
    return rect;
}
@end

#pragma --mark NSMutableDictionary setter

@implementation NSMutableDictionary (safeAccess)

-(void)ex_setValue:(id)i forKey:(nonnull NSString*)key{
    
    if (key != nil && i != nil) {
        
        [self setValue:i forKey:key];
    }
}

-(void)ex_setObj:(id)i forKey:(NSString*)key{
    if (i != nil) {
        self[key] = i;
    }
}

-(void)ex_setString:(NSString*)i forKey:(NSString*)key;
{
    if (i != nil) {
        [self setValue:i forKey:key];
    }
}

-(void)ex_setBool:(BOOL)i forKey:(NSString *)key
{
    self[key] = @(i);
}

-(void)ex_setInt:(int)i forKey:(NSString *)key
{
    self[key] = @(i);
}

-(void)ex_setInteger:(NSInteger)i forKey:(NSString *)key
{
    self[key] = @(i);
}

-(void)ex_setUnsignedInteger:(NSUInteger)i forKey:(NSString *)key
{
    self[key] = @(i);
}

-(void)ex_setCGFloat:(CGFloat)f forKey:(NSString *)key
{
    self[key] = @(f);
}

-(void)ex_setChar:(char)c forKey:(NSString *)key
{
    self[key] = @(c);
}

-(void)ex_setFloat:(float)i forKey:(NSString *)key
{
    self[key] = @(i);
}

-(void)ex_setDouble:(double)i forKey:(NSString*)key{
    self[key] = @(i);
}

-(void)ex_setLongLong:(long long)i forKey:(NSString*)key{
    self[key] = @(i);
}

-(void)ex_setPoint:(CGPoint)o forKey:(NSString *)key
{
    self[key] = NSStringFromCGPoint(o);
}

-(void)ex_setSize:(CGSize)o forKey:(NSString *)key
{
    self[key] = NSStringFromCGSize(o);
}

-(void)ex_setRect:(CGRect)o forKey:(NSString *)key
{
    self[key] = NSStringFromCGRect(o);
}
@end
