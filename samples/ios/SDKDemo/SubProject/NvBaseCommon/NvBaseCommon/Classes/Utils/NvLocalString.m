//
//  NvLocalString.m
//  SDKDemo
//
//  Created by 刘东旭 on 2019/12/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#include "NvLocalString.h"

@interface NvNoUse : NSObject

@end

@implementation NvNoUse


@end

#define CURR_LANG  ([[NSLocale preferredLanguages] objectAtIndex:0])
NSString* NvLocalString(NSString* translation_key,NSString *comment) {
    
    NSString *s;
    if ([CURR_LANG containsString:@"en"]||
        [CURR_LANG containsString:@"zh"]) {
        
        s = NSLocalizedString(translation_key, nil);
    } else {
        
        NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }
    return s;
}

NSString* NvLocalStringFromTable(Class cls,NSString* translation_key,NSString *comment) {
    return NvLocalStringFromTableInBundle(translation_key,@"Localizable",[NSBundle bundleForClass:cls],comment);
}

NSString* NvLocalStringFromTableInBundle(NSString* key,NSString *tbl,NSBundle *bundle,NSString *comment) {
    
    if ([CURR_LANG containsString:@"en"]||
        [CURR_LANG containsString:@"zh"]) {
        
        return NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment);
    } else {
        
        NSString *resourcePath = bundle.bundlePath;
        resourcePath = [resourcePath stringByAppendingPathComponent:@"en.lproj"];
        NSBundle *resourceBundle = [NSBundle bundleWithPath:resourcePath];
        NSString *ret = [resourceBundle localizedStringForKey:key value:@"" table:tbl];
        return ret;
    }
}

