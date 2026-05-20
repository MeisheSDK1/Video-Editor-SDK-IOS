//
//  NSString+NvPath.m
//  NvSDKCommon
//
//  Created by meishe01 on 2024/3/29.
//

#import "NSString+NvPath.h"

@implementation NSString (NvPath)

+(NSString *)convertFilePathToNewPath:(NSString *)originalPath WithExtension:(NSString *)extension{
    
    if(originalPath &&
       originalPath.length > 0 &&
       originalPath.pathExtension.length > 0 &&
       ![originalPath.pathExtension isEqualToString:@"bundle"] &&
       ![originalPath.pathExtension isEqualToString:@"ttf"] &&
       ![originalPath.pathExtension isEqualToString:@"TTF"]){
        
        // 获取文件目录路径r
        NSString *directory = [originalPath stringByDeletingLastPathComponent];
        // 默认设置为原始路径的最后一部分
        NSString *baseFilename = [originalPath lastPathComponent];
        if (baseFilename && baseFilename.length > 0) {
            
            baseFilename = [baseFilename componentsSeparatedByString:@"."].firstObject;
        }
        NSString *licenseFilename = [NSString stringWithFormat:@"%@.%@", baseFilename, extension];
        //新文件路径
        NSString *licensePath = [directory stringByAppendingPathComponent:licenseFilename];
#ifdef DEBUG
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL packageFileExists = [fileManager fileExistsAtPath:originalPath];
        BOOL licenseFileExists = [fileManager fileExistsAtPath:licensePath];
        // 使用NSAssert来确保文件必须存在
        NSAssert(packageFileExists, @"packagePath: %@ don't exit", originalPath);
        if(![licensePath  containsString:@"font"]) {
            NSAssert(licenseFileExists, @"licensePath: %@ don't exit", licensePath);
        }
        
#endif
        return licensePath;
    }else{
        
        NSLog(@"文件路径不合规:%@",originalPath);
        return originalPath;
    }
}

@end
