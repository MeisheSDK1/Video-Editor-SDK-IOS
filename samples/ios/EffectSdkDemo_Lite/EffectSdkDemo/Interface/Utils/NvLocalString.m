//
//  NvLocalString.m
//  SDKDemo
//
//  Created by 刘东旭 on 2019/12/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#include "NvLocalString.h"

#define CURR_LANG  ([[NSLocale preferredLanguages] objectAtIndex:0])
NSString* NvLocalString(NSString* translation_key,NSString *comment) {
    NSString *s;
//    NSLog(@"%@",CURR_LANG);
    if ([CURR_LANG containsString:@"en"]||[CURR_LANG containsString:@"zh"]) {
        s = NSLocalizedString(translation_key, nil);
    } else {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }
    return s;
}

NSString* NvLocalStringFromTableInBundle(NSString* key,NSString *tbl,NSBundle *bundle,NSString *comment) {
    NSString *s;
//    NSLog(@"%@",CURR_LANG);
    if ([CURR_LANG containsString:@"en"]||[CURR_LANG containsString:@"zh"]) {
        s = NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment);
    } else {
        if (!bundle) {
            bundle = [NSBundle mainBundle];
        }
        NSString * path = [bundle pathForResource:@"en" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        s = [languageBundle localizedStringForKey:key value:@"" table:tbl];
    }
    return s;
}
