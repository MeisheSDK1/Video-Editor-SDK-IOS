//
//  NvAudioEqualizerRectView.m
//  SDKDemo
//
//  Created by MS on 2021/6/23.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvAudioEqualizerRectView.h"
#import "YWISOSlider.h"
#import <NvBaseCommon/NVDefineConfig.h>
@interface NvAudioEqualizerRectView ()<YWISOSliderDelegate>
@property (nonatomic, strong) NSString *leftTopTitle;
@property (nonatomic, strong) NSString *leftBottomTitle;

@property (nonatomic, assign) double maxVoice;
@property (nonatomic, assign) double minVoice;
@property (nonatomic, assign) double middelVoice;

@property (nonatomic, strong) NSMutableArray *frequencyRangeArr;
@property (nonatomic, strong) NSMutableArray *voiceValueArr;
@property (nonatomic, strong) NSMutableArray *sliderArr;

@property (nonatomic, strong) NSMutableArray *voiceValueLayerArr;
@end

@implementation NvAudioEqualizerRectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.sliderArr = [NSMutableArray array];
    }
    return self;
}

- (void)configData:(NSString *)leftTopTitle leftBottomTitle:(NSString *)leftBottomTitle maxVoice:(double)maxVoice minVoice:(double)minVoice middelVoice:(double)middelVoice frequencyRangeArr:(NSArray*)frequencyRangeArr voiceValueArr:(NSArray*)voiceValueArr {
    self.leftTopTitle = leftTopTitle;
    self.leftBottomTitle = leftBottomTitle;
    self.maxVoice = maxVoice;
    self.minVoice = minVoice;
    self.middelVoice = middelVoice;
    self.frequencyRangeArr = [NSMutableArray arrayWithArray:frequencyRangeArr];
    self.voiceValueArr = [NSMutableArray arrayWithArray:voiceValueArr];
    self.voiceValueLayerArr = [NSMutableArray array];
    [self addTextLayers];
}

-(void)configValueData:(NSArray *)voiceValueArr{
    for (int i = 0; i < _sliderArr.count; i ++) {
        YWISOSlider *slider = self.sliderArr[i];
        slider.value = [voiceValueArr[i] floatValue];
        NSNumber * num = [NSNumber numberWithInt:slider.value];
        [self refreshVoiceLayerValue:num index:slider.tag];
    }
}

- (void)addTextLayers {
    ///The leftmost column of text layers
    UIColor *textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    CGFloat xBorderSpace = 32.5*SCREENSCALE;
    CATextLayer *leftTopLayer = [self createTextLayerWithFontSize:10*SCREENSCALE color:textColor];
    leftTopLayer.frame = CGRectMake(xBorderSpace, 0, 20*SCREENSCALE, 14*SCREENSCALE);
    leftTopLayer.string = self.leftTopTitle;
    [self.layer addSublayer:leftTopLayer];
    
    CGFloat leftBottomY = CGRectGetMaxY(self.bounds) - 45.5*SCREENSCALE - 14*SCREENSCALE;
    CATextLayer *leftBottomLayer = [self createTextLayerWithFontSize:10*SCREENSCALE color:textColor];
    leftBottomLayer.frame = CGRectMake(xBorderSpace, leftBottomY, 20*SCREENSCALE, 14*SCREENSCALE);
    leftBottomLayer.string = self.leftBottomTitle;
    [self.layer addSublayer:leftBottomLayer];
    
    CGFloat startY = CGRectGetMaxY(leftTopLayer.frame);
    CGFloat bottomTextY = CGRectGetMinY(leftBottomLayer.frame);
    CGFloat topAndBottomSep = 14*SCREENSCALE;
    CGFloat layerH = 11*SCREENSCALE;
    CGFloat middleSep =  (bottomTextY - startY - 2*topAndBottomSep - 3*layerH)/2;
    CATextLayer *maxVoiceLayer = [self createTextLayerWithFontSize:8*SCREENSCALE color:textColor];
    maxVoiceLayer.frame = CGRectMake(xBorderSpace, topAndBottomSep + startY, 20*SCREENSCALE, layerH);
    maxVoiceLayer.string = [NSString stringWithFormat:@"%.f",self.maxVoice];
    [self.layer addSublayer:maxVoiceLayer];
    
    CGFloat maxVoiceYMaxYV = CGRectGetMaxY(maxVoiceLayer.frame);
    CGFloat middleVoiceY = CGRectGetMaxY(maxVoiceLayer.frame) + middleSep;
    CATextLayer *middleVoiceLayer = [self createTextLayerWithFontSize:8*SCREENSCALE color:textColor];
    middleVoiceLayer.frame = CGRectMake(xBorderSpace, middleVoiceY, 20*SCREENSCALE, 11*SCREENSCALE);
    middleVoiceLayer.string = [NSString stringWithFormat:@"%.f",self.middelVoice];
    [self.layer addSublayer:middleVoiceLayer];
    
    CGFloat minVoiceY = CGRectGetMaxY(middleVoiceLayer.frame) + middleSep;
    CATextLayer *minVoiceLayer = [self createTextLayerWithFontSize:8*SCREENSCALE color:textColor];
    minVoiceLayer.frame = CGRectMake(xBorderSpace, minVoiceY, 20*SCREENSCALE, 11*SCREENSCALE);
    minVoiceLayer.string = [NSString stringWithFormat:@"%.f",self.minVoice];
    [self.layer addSublayer:minVoiceLayer];
    
    
    ///the frequency text layers(the bottom line of text layers)
    CGFloat sliderWidth = 20*SCREENSCALE;
    CGFloat sliderHeight = CGRectGetMinY(leftBottomLayer.frame) - CGRectGetMaxY(leftTopLayer.frame) - 24*SCREENSCALE;
    CGFloat startX = CGRectGetMaxX(leftTopLayer.frame);
    CGFloat sliderSep = (SCREENWIDTH - startX - xBorderSpace)/self.frequencyRangeArr.count;
    CGFloat sliderX = startX - sliderWidth/2;
    CGFloat layerX = startX - sliderSep/2;

    CGFloat topTextY = CGRectGetMinY(leftTopLayer.frame);
    CGFloat topTextH = CGRectGetHeight(leftTopLayer.frame);
    CGFloat bottomTextH = CGRectGetHeight(leftBottomLayer.frame);
    for (int i=0; i<self.frequencyRangeArr.count; i++) {
        sliderX += sliderSep;
        layerX += sliderSep;
        
        CGRect valueLayerFrame = CGRectMake(layerX, topTextY+2*SCREENSCALE, sliderSep, topTextH);
        CATextLayer *valueLayer = [self createTextLayerWithFontSize:8*SCREENSCALE color:textColor];
        valueLayer.frame = valueLayerFrame;
        NSString *valueStr = [NSString stringWithFormat:@"%@",self.voiceValueArr[i]];
        valueLayer.string = valueStr;
        [self.layer addSublayer:valueLayer];
        [self.voiceValueLayerArr addObject:valueLayer];
        
        CGRect frequencyLayerFrame = CGRectMake(layerX, bottomTextY+2*SCREENSCALE, sliderSep, bottomTextH);
        CATextLayer *frequencyLayer = [self createTextLayerWithFontSize:8*SCREENSCALE color:textColor];
        frequencyLayer.frame = frequencyLayerFrame;
        frequencyLayer.string = [NSString stringWithFormat:@"%@",self.frequencyRangeArr[i]];
        [self.layer addSublayer:frequencyLayer];

        ///sliders
        YWISOSlider *slider = [[YWISOSlider alloc] initWithFrame:CGRectMake(sliderX, topTextY+topTextH+12*SCREENSCALE, sliderWidth, sliderHeight)];
        slider.delegate = self;
        slider.tag = i;
        slider.maximumTrackTintColor = [UIColor grayColor];
        slider.minimumTrackTintColor = [UIColor whiteColor];
        slider.thumbImage = NvImageNamed(@"audioEqualThumb");
        slider.maximumValue = self.maxVoice;
        slider.minimumValue = self.minVoice;
        [self.sliderArr addObject:slider];
        [self addSubview:slider];
    }
}

- (CATextLayer *)createTextLayerWithFontSize:(CGFloat)fontSize color:(UIColor *)color {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.foregroundColor = color.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.wrapped = YES;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    return textLayer;
}

- (void)refreshVoiceLayerValue:(NSNumber *)value index:(NSInteger)index {
    CATextLayer *layer = self.voiceValueLayerArr[index];
    layer.string = [NSString stringWithFormat:@"%@",value];
}

#pragma mark - YWISOSliderDelegate
- (void)YWISOSliderValueChanged:(YWISOSlider *)slider {
    NSNumber *num = self.voiceValueArr[slider.tag];
    num = [NSNumber numberWithInt:slider.value];
    [self refreshVoiceLayerValue:num index:slider.tag];
    if ([self.delegate respondsToSelector:@selector(audioEqualizerRect:index:changeValue:)]) {
        [self.delegate audioEqualizerRect:self index:slider.tag changeValue:slider.value];
    }
}

- (void)YWISOSliderValueEnded:(YWISOSlider *)slider {
    NSNumber *num = self.voiceValueArr[slider.tag];
    num = [NSNumber numberWithInt:slider.value];
    [self refreshVoiceLayerValue:num index:slider.tag];
    if ([self.delegate respondsToSelector:@selector(audioEqualizerRect:index:endValue:)]) {
        [self.delegate audioEqualizerRect:self index:slider.tag endValue:slider.value];
    }
}
@end
