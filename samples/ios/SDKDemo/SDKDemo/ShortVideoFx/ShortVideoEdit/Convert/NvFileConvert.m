//
//  NvFileConvert.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/6.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFileConvert.h"
#import "NVHeader.h"
#import "NvsMediaFileConvertor.h"

@interface NvFileConvert() <NvsMediaFileConvertorDelegate>{
    NvsMediaFileConvertor *mConvertor;
    dispatch_semaphore_t sem;
    NSFileManager *fm;
    NSString *tmpfilePath;
    int64_t taskId;
}

@property (nonatomic) void(^finishBlock)(BOOL);
@property (nonatomic) NSArray <NvRecordingInfo *>*files;
@property (nonatomic) NvRecordingInfo *nextFile;
@property (nonatomic) BOOL isAllFinish;
@end

@implementation NvFileConvert

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)init {
    if (self = [super init]) {
        fm = [NSFileManager defaultManager];
        self.isAllFinish = YES;
        mConvertor = [[NvsMediaFileConvertor alloc] init];
        mConvertor.delegate = self;
    }
    return self;
}

- (void)convertFiles:(NSArray <NvRecordingInfo *>*)files {
    self.files = [files copy];
    self.nextFile = self.files.firstObject;
}

- (void)startConvert {
    NvRecordingInfo *file = self.nextFile;
    
    if (![fm fileExistsAtPath:CONVERTPATH]) {
        [fm createDirectoryAtPath:CONVERTPATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *last;
    if (file.asset!=nil) {
        last = [NSString stringWithFormat:@"%@.mp4",[NvUtils currentDateAndTime]];
    } else {
        last = [file.recordingPath lastPathComponent];
    }
    
    tmpfilePath = [CONVERTPATH stringByAppendingPathComponent:last];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:tmpfilePath]) {
        [fm removeItemAtPath:tmpfilePath error:nil];
    }
    __block int64_t ret = 0;
    if (file.asset != nil) {
        ret = [self->mConvertor convertMeidaFile:file.asset.localIdentifier outputFile:self->tmpfilePath isReverseConvert:YES fromPosition:file.trimIn toPosition:file.trimOut options:nil];
        self->taskId = ret;
    } else {
        
        ret = [self->mConvertor convertMeidaFile:file.recordingPath outputFile:self->tmpfilePath isReverseConvert:YES fromPosition:file.trimIn toPosition:file.trimOut options:nil];
        self->taskId = ret;
    }
}

- (void)cancel {
    NSLog(@"convert cancel");
    [mConvertor cancelTask:taskId];
    mConvertor.delegate = nil;
    mConvertor = nil;
    self.files = nil;
}

- (void)finishBlock:(void(^)(BOOL isFinish))finishBlock {
    self.finishBlock = finishBlock;
}

- (void)didConvertorFinish:(int64_t)taskId sourceFile:(NSString *)src outputFile:(NSString *)dst errorCode:(NvsMediaConvertorErrorType)error{
    if (error == keNvsMediaConvertorErrorType_NoError) {
        NSLog(@"转码成功 Transcoding success");
        self.nextFile.convertPath = tmpfilePath;
        if (self.files.lastObject == self.nextFile) {
            self.finishBlock(self.isAllFinish);
        } else {
            self.nextFile = [self.files objectAtIndex:[self.files indexOfObject:self.nextFile]+1];
            NSLog(@"开始下一个 Start the next one");
            [self startConvert];
        }
    }else if (error == keNvsMediaConvertorErrorType_Cancled){
        NSLog(@"转码取消 Transcoding cancellation");
    }else{
        NSLog(@"转码失败 Transcoding failure,%d",error);
        self.isAllFinish = NO;
        if (self.files.lastObject == self.nextFile) {
            self.finishBlock(self.isAllFinish);
        } else {
            
            self.nextFile = [self.files objectAtIndex:[self.files indexOfObject:self.nextFile]+1];
        }
    }
}

- (void)didConvertorProgress:(int64_t)taskId progress:(float)progress{
    NSLog(@"%lf",progress);
}

- (void)didAudioMuteRage:(int64_t)taskId muteStart:(int64_t)start muteEnd:(int64_t)end{
    
}

@end
