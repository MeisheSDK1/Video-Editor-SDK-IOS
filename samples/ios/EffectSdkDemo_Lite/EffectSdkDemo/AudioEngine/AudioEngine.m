//
//  AudioEngine.m
//  AudioEngineDemo
//
//  Created by LiYong on 2021/10/24.
//

#import "AudioEngine.h"

@interface AudioEngine ()
@property (nonatomic,strong)AVAudioEngine * engine;

@property (nonatomic,strong)AVAudioPlayerNode * player;
@property (nonatomic,strong)AVAudioFile * audioFile;
@property (nonatomic,strong)AVAudioInputNode * input;
@property (nonatomic,strong)AVAudioOutputNode * output;
@property (nonatomic,strong)AVAudioMixerNode * mixer;

@property (nonatomic,strong)AVAudioUnitDelay * delay;
@property (nonatomic,strong)AVAudioUnitEQ * eq;//均衡器 equalizer
@property (nonatomic,strong)AVAudioUnitReverb * reverb;//混响(大房间场景) Reverberation (large room scene)
@property (nonatomic,strong)AVAudioUnitDistortion * distortion;//失真(声音沙哑） Distortion (hoarse voice)

@property (nonatomic,strong)NSMutableArray * effects;

@end

@implementation AudioEngine

#pragma -mark add node
- (void)addUnitDelay{
    if (![self.effects containsObject:self.delay]) {
        [self.effects addObject:self.delay];
    }
}
- (void)addUnitEQ{
    if (![self.effects containsObject:self.eq]) {
        [self.effects addObject:self.eq];
    }
}
- (void)addUnitReverb{
    if (![self.effects containsObject:self.reverb]) {
        [self.effects addObject:self.reverb];
    }
}
- (void)addUnitDistortion{
    if (![self.effects containsObject:self.distortion]) {
        [self.effects addObject:self.distortion];
    }
}

#pragma -mark start
- (void)startAudioRecord{
    [self startAudioRecordWithAudioPath:nil];
}
- (void)startAudioRecordWithAudioPath:(NSString *)path{
    [self stopAudioRecord];
    self.state = AudioEngineState_playAndRecord;
    NSError * error;
    if (!path) {
        path = [[NSBundle mainBundle]pathForResource:@"semiconductor" ofType:@"mp3"];
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    path = url.absoluteString;
    self.input = self.engine.inputNode;
    self.output = self.engine.outputNode;
    self.mixer = self.engine.mainMixerNode;
    self.mixer.outputVolume = 0.2;
    
    [self.engine attachNode:self.player];
    
    [self.effects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.engine attachNode:obj];
    }];
    if (@available(iOS 13.0, *)) {
        [self.input setVoiceProcessingEnabled:YES error:&error];
    } else {
        // Fallback on earlier versions
    }
    
    self.audioFile = [[AVAudioFile alloc]initForReading:[NSURL URLWithString:path] error:&error];

    AVAudioPCMBuffer * buffer = [[AVAudioPCMBuffer alloc]initWithPCMFormat:self.audioFile.processingFormat frameCapacity:(AVAudioFrameCount)(self.audioFile.length)];
    [self.audioFile readIntoBuffer:buffer error:&error];
    
    __block AVAudioNode * node = self.input;
    [self.effects enumerateObjectsUsingBlock:^(AVAudioNode *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.engine connect:node to:obj format:[self.input inputFormatForBus:1]];
        node = obj;
    }];
    [self.engine connect:node to:self.mixer format:[self.input inputFormatForBus:1]];
    [self.engine connect:self.player to:self.mixer format:buffer.format];
    
    __weak typeof(self) weakSelf = self;
    [self.engine.mainMixerNode installTapOnBus:0 bufferSize:1024 format:[self.mixer outputFormatForBus:0] block:^(AVAudioPCMBuffer * buffer, AVAudioTime * _Nonnull when) {
        if (weakSelf.block && weakSelf.state == AudioEngineState_playAndRecord) {
            weakSelf.block(buffer,when.audioTimeStamp.mSampleTime);
        }
    }];
    [self.engine prepare];
    [self.engine startAndReturnError:nil];
    
    [self.player scheduleBuffer:buffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:^{
        NSLog(@"finished");
    }];
    [self.player play];
}
- (void)stopAudioRecord{
    self.state = AudioEngineState_normal;
    [self.engine stop];
    [self.player stop];
    [self.engine.mainMixerNode removeTapOnBus:0];
}
#pragma -mark method
- (void)audipPlay{
    if (!self.player.isPlaying) {
        [self.player play];
    }
}
- (void)audioPause{
    if (self.player.isPlaying) {
        [self.player pause];
    }
}
- (void)changeAudioWithPath:(NSString *)path{
    [self startAudioRecordWithAudioPath:path];
}
- (void)changePlayVolume:(CGFloat)volume{
    self.player.volume = volume;
}
- (void)dealloc{
    NSLog(@"%s",__func__);
}
#pragma -mark getter
- (AVAudioEngine *)engine{
    if (!_engine) {
        _engine = [[AVAudioEngine alloc]init];
    }
    return _engine;
}
- (AVAudioPlayerNode *)player{
    if (!_player) {
        _player = [[AVAudioPlayerNode alloc]init];
        _player.volume = 0.5;
    }
    return _player;
}
- (AVAudioUnitDelay *)delay{
    if (!_delay) {
        _delay = [[AVAudioUnitDelay alloc]init];
        _delay.wetDryMix = 30;
        _delay.feedback = 30;
        _delay.delayTime = 1;
        [self.engine attachNode:_delay];
    }
    return _delay;
}
- (AVAudioUnitReverb *)reverb{
    if (!_reverb) {
        _reverb = [[AVAudioUnitReverb alloc]init];
        _reverb.wetDryMix = 50;
        [_reverb loadFactoryPreset:AVAudioUnitReverbPresetLargeHall];
        [self.engine attachNode:_reverb];
    }
    return _reverb;
}
- (AVAudioUnitEQ *)eq{
    if (!_eq) {
        _eq = [[AVAudioUnitEQ alloc]initWithNumberOfBands:2];
        _eq.globalGain = 20;
        [self.engine attachNode:_eq];
    }
    return _eq;
}
- (AVAudioUnitDistortion *)distortion{
    if (!_distortion) {
        _distortion = [[AVAudioUnitDistortion alloc]init];
        [_distortion loadFactoryPreset:AVAudioUnitDistortionPresetSpeechRadioTower];//收音机的声音 The sound of the radio
        _distortion.preGain = 4;
        _distortion.wetDryMix = 80;
        [self.engine attachNode:_distortion];
    }
    return _distortion;
}
- (NSMutableArray *)effects{
    if (!_effects) {
        _effects = [NSMutableArray array];
    }
    return _effects;
}
@end
