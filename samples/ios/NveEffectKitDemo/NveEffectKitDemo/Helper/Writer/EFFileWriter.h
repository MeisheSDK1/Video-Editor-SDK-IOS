//
//  EFFileWriter.h
//  GPUImageEffectDemo
//
//  Created by 美摄 on 2021/3/8.
//

#import <Foundation/Foundation.h>
#include <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EFFileWriter : NSObject

@property(readonly) BOOL isRecording;

- (instancetype)initWithGlContext:(EAGLContext *)glContext;

- (void)setupFormatDescription:(CMSampleBufferRef)sampleBuffer;

- (BOOL)startRecordWithFilePath:(NSString *)filePath;

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer timelinePos:(int64_t)timelinePos;

- (void)appendTexture:(GLuint)texture videoSize:(CGSize)videoSize timelinePos:(int64_t)timelinePos;

- (void)stopRecordWithCompletionHandler:(void (^)(NSString *))handler;

- (void)cleanUp;

@end

NS_ASSUME_NONNULL_END
