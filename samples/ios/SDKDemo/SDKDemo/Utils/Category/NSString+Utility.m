//
//  NSString+Utility.m
//  SDKDemo
//
//  Created by meishe01 on 2024/4/19.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NSString+Utility.h"

@implementation NSString (Utility)

- (BOOL)nv_isEmpty {
    if (self == nil || [self length] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)nv_isNotEmpty {
    return ![self nv_isEmpty];
}

- (BOOL)nv_isValidURL {
    NSURL *url = [NSURL URLWithString:self];
    return url && url.scheme && url.host;
}

- (NSString *)nv_trimWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)nv_removeAllWhitespaces {
    NSArray *components = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [components componentsJoinedByString:@""];
}

- (BOOL)nv_fileExists{
    
    if([self nv_isEmpty]) return NO;
    NSFileManager * fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:self];
}

@end
