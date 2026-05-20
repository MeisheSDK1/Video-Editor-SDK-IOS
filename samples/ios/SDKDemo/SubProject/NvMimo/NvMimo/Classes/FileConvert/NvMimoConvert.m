//
//  NvMimoConvert.m
//  NvMimoDemo
//
//  Created by MS on 2019/12/17.
//  Copyright © 2019 MS. All rights reserved.
//

#import "NvMimoConvert.h"
#import "NVHeader.h"
#import "NvsMediaFileConvertor.h"
#import <Photos/Photos.h>

@interface NvMimoConvert() <NvsMediaFileConvertorDelegate> {
    NvsMediaFileConvertor *mConvertor;
    dispatch_semaphore_t sem;
    NSFileManager *fm;
    NSString *tmpfilePath;
    int64_t taskId;
}

@property (nonatomic) void(^finishBlock)(BOOL, NSString*);
@property (nonatomic) BOOL isAllFinish;
@end

@implementation NvMimoConvert

- (instancetype)init {
    if (self = [super init]) {
        fm = [NSFileManager defaultManager];
        self.isAllFinish = YES;
        mConvertor = [[NvsMediaFileConvertor alloc] init];
        mConvertor.delegate = self;
    }
    return self;
}

- (void)startConvertWithOriginFilePath:(NSString *)originPath trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut {
    if (![fm fileExistsAtPath:CONVERTPATH]) {
           [fm createDirectoryAtPath:CONVERTPATH withIntermediateDirectories:YES attributes:nil error:nil];
       }
       NSString *last;
       if (originPath.length > 0) {
           last = [NSString stringWithFormat:@"%@.mp4",[originPath stringByReplacingOccurrencesOfString:@"/" withString:@"*"]];
       }
    tmpfilePath = [CONVERTPATH stringByAppendingPathComponent:last];
       NSFileManager *fm = [NSFileManager defaultManager];
       if ([fm fileExistsAtPath:tmpfilePath]) {
           [fm removeItemAtPath:tmpfilePath error:nil];
       }
    __block int64_t ret = 0;
    if (originPath.length > 0) {
        
        ret = [self->mConvertor convertMeidaFile:originPath outputFile:self->tmpfilePath isReverseConvert:YES fromPosition:trimIn toPosition:trimOut options:nil];
        self->taskId = ret;
        
    }
    
}

- (void)finishBlock:(void(^)(BOOL isFinish, NSString *outputPath))finishBlock {
    self.finishBlock = finishBlock;
}

- (void)cancel {
    DLog(@"convert cancel");
    [mConvertor cancelTask:taskId];
    mConvertor.delegate = nil;
    mConvertor = nil;
}

- (void)stop {
    mConvertor.delegate = nil;
    mConvertor = nil;
}

- (void)didConvertorFinish:(int64_t)taskId sourceFile:(NSString *)src outputFile:(NSString *)dst errorCode:(NvsMediaConvertorErrorType)error{
    if (error == keNvsMediaConvertorErrorType_NoError) {
        self.finishBlock(self.isAllFinish,dst);

    }else if (error == keNvsMediaConvertorErrorType_Cancled){
        
    }else{
        NSLog(@"转码失败 Transcoding failure,%d",error);
        self.isAllFinish = NO;
        self.finishBlock(self.isAllFinish,nil);
    }
}

- (void)didConvertorProgress:(int64_t)taskId progress:(float)progress{
    NSLog(@"%lf",progress);
}

- (void)didAudioMuteRage:(int64_t)taskId muteStart:(int64_t)start muteEnd:(int64_t)end{
    
}
@end
