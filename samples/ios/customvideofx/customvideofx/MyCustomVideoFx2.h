//
//  MyCustomVideoFx.h
//  customvideofx
//
//  Created by xuewen on 8/2/17.
//  Copyright © 2017 cdv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsStreamingContext.h"
// 这个例子是将buffer上传的例子，当然也可以自己上传仅供参考，要想在回调中有buffer数据，play、seek、compile必须要有NvsStreamingEngineSeekFlag_BuddyHostVideoFrame|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame flag。demo中默认使用纹理，不用加这个flag
// 这里仅做展示，把当前类中所有函数全部删掉了，如果改为这个类，请将控制器VC中调用此类函数的地方全部注释掉。
@interface MyCustomVideoFx2 : NSObject<NvsCustomVideoFxRenderer>

@end
