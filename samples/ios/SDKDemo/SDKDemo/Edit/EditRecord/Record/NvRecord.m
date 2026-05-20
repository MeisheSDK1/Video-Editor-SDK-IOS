//
//  NvRecord.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvRecord.h"
#import "NVHeader.h"

@interface NvRecord()

@property(nonatomic, strong) AVAudioSession *session;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) NSURL *recordFileUrl;
@property (nonatomic, strong) NSString *audioCategory;

@end

@implementation NvRecord

- (instancetype)init {
    if (self = [super init]) {
        self.isRecording = NO;
    }
    return self;
}

- (NSString *)startRecord {
    NSLog(@"开始录音 Start recording");
    self.isRecording = YES;
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    self.audioCategory = session.category;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (session == nil) {
        
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [session setActive:YES error:nil];
        
    }
    
    self.session = session;
    
    
    NSString *path = VIDEO_PATH(@"Recordmp3");
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [path stringByAppendingFormat:@"/%@.m4a", [NvUtils currentDateAndTime]];
    
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];
    
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   ///采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   ///Sampling rate of 22050/44100/96000/8000/11025 (affect the quality of the audio)
                                   [NSNumber numberWithFloat: 44100],AVSampleRateKey,
                                   ///音频格式
                                   ///Audio format
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                                   ///采样位数  8、16、24、32 默认为16
                                   ///Sampling bits 8, 16, 24, 32 The default value is 16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   ///音频通道数 1 或 2
                                   ///Number of audio channels 1 or 2
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                   ///录音质量
                                   ///Recording quality
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    
    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:&error];
    
    if (_recorder) {
        
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        BOOL isSucces = [_recorder record];
        if (!isSucces) {
            filePath = @"";
        }
    }else{
        NSLog(@"%@",error.localizedDescription);
        filePath = @"";
    }
    return filePath;
}

- (void)stopRecord {
    self.isRecording = NO;
    NSLog(@"停止录音 Stop recording");
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setCategory:self.audioCategory error:nil];
}

@end
