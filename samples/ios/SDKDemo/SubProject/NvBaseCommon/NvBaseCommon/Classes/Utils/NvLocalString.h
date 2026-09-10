//
//  NvLocalString.h
//  SDKDemo
//
//  Created by 刘东旭 on 2019/12/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#ifndef NvLocalString_h
#define NvLocalString_h

#import "Foundation/Foundation.h"

//从当主bundle中加载默认的Localizable.strings国际化文件
// Load the default Localizable.strings internationalization file from the main bundle
NSString* NvLocalString(NSString* translation_key,NSString *comment);

//从当前类中bundle中加载默认的Localizable.strings国际化文件
// Load the default Localizable.strings internationalization file from the bundle in the current class
NSString* NvLocalStringFromTable(Class cls,NSString* translation_key,NSString *comment);

//从指定bundle中加载默认的tbl国际化文件
// Load the default tbl internationalization file from the specified bundle
NSString* NvLocalStringFromTableInBundle(NSString* key,NSString *tbl,NSBundle *bundle,NSString *comment);
#endif /* NvLocalString_h */
