//
//  NvARSceneMacro.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#ifndef NvARSceneMacro_h
#define NvARSceneMacro_h
/*
 编译effectsdkdemo的时候会根据，effectsdkdemo修改这个宏，自动编译库
 如果使用streamsdk，宏会改为USE_EFFECT_SDK_NO
 如果使用effectsdk，宏会改为USE_EFFECT_SDK
 
 如果是手动编译，只需要注释就行，不需要修改字符串
 So when you compile effectsdkdemo you will modify this macro according to effectsdkdemo, automatically compile the library
 If the streamsdk is used, the macro is changed to USE_EFFECT_SDK_NO
 If effectsdk is used, the macro is changed to USE_EFFECT_SDK

 If you compile by hand, you only need to comment, and you don't need to change the string
 */
#define USE_EFFECT_SDK_NO

#define ARSCENE_ST240 NO
#define ARSCENE_ST106 NO

#define ARSCENE_MS106 NO
#define ARSCENE_MS240 YES

// 界面常用
// Interface commonly used
#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define SCREENSCALE [UIScreen mainScreen].bounds.size.width / 414.0
#define SCREENSCALEHEIGHT [UIScreen mainScreen].bounds.size.height / 896.0
#define StatusBarHeight ((SCREEN_HEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"] ?44:20)
#define SafeAreaTopHeight ((SCREEN_HEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"] ? 88 : 64)
#define SafeAreaBottomHeight ((SCREEN_HEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"]  ? 30 : 0)

#endif /* NvARSceneMacro_h */
