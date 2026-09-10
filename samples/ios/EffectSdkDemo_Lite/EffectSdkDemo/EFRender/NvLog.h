//
//  NvLog.h
//  NvXMLParse
//
//  Created by 美摄 on 2021/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 显示Parse调试日志
#define enableParseLog


#ifdef enableParseLog
//Debug
#define logDebug(fmt, ...) NSLog((@"[Debug] 💚:" fmt), ##__VA_ARGS__);
//Info
#define logInfo(fmt, ...) NSLog((@"[Info] 💙:" fmt), ##__VA_ARGS__);
//Warning
#define logWarning(fmt, ...) NSLog((@"[Warning] 💛:" fmt), ##__VA_ARGS__);
//Error
#define logError(fmt, ...) NSLog((@"[Error] ❤️:" fmt), ##__VA_ARGS__);

#else

//Debug
#define logDebug(fmt, ...);
//Info
#define logInfo(fmt, ...);
//Warning
#define logWarning(fmt, ...);
//Error
#define logError(fmt, ...);

#endif

NS_ASSUME_NONNULL_END
