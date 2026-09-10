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

NSString* NvLocalString(NSString* translation_key,NSString *comment);
NSString* NvLocalStringFromTableInBundle(NSString* key,NSString *tbl,NSBundle *bundle,NSString *comment);

#endif /* NvLocalString_h */
