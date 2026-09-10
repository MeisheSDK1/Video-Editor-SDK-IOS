//
//  AudioEngine.h
//  AudioEngineDemo
//
//  Created by LiYong on 2021/10/24.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AudioEngineBlock) (AVAudioPCMBuffer * buffer,int64_t mSampleTime);

typedef NS_ENUM(NSInteger,AudioEngineState) {
    AudioEngineState_normal,
    AudioEngineState_playAndRecord,
};

@interface AudioEngine : NSObject
@property (nonatomic, copy)AudioEngineBlock block;
@property (nonatomic, assign)AudioEngineState state;

- (void)audipPlay;
- (void)audioPause;
- (void)changeAudioWithPath:(NSString *)path;
- (void)changePlayVolume:(CGFloat)volume;

//effects
- (void)addUnitDelay;
- (void)addUnitEQ;
- (void)addUnitReverb;
- (void)addUnitDistortion;

- (void)startAudioRecordWithAudioPath:(NSString *)path;
- (void)startAudioRecord;
- (void)stopAudioRecord;
@end

NS_ASSUME_NONNULL_END
