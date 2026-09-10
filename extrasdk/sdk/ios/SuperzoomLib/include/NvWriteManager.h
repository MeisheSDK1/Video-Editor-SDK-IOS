#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//录制状态，（这里把视频录制与写入合并成一个状态）
typedef NS_ENUM(NSInteger, NvRecordState) {
    NvRecordStateInit = 0,
    NvRecordStatePrepareRecording,
    NvRecordStateRecording,
    NvRecordStateFinish,
    NvRecordStateFail,
};


@protocol NvWriteManagerDelegate <NSObject>

- (void)finishWriting;

@end

@interface NvWriteManager : NSObject

@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;

@property (nonatomic, assign) NvRecordState writeState;
@property (nonatomic, weak) id <NvWriteManagerDelegate> delegate;
@property (nonatomic, assign) int duration;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;

- (instancetype)initWithURL:(NSURL *)URL;

- (void)startWrite;
- (void)stopWrite;

- (void)appendVideoBuffer:(CMTime)frameTime  pixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)appendAudioBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)destroyWrite;
@end
