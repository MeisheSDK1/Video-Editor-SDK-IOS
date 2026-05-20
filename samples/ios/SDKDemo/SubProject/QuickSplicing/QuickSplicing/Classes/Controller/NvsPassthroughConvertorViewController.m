//
//  NvsPassthroughCompileViewController.m
//  QuickSplicing
//
//  Created by 美摄 on 2022/4/8.
//

#import "NvsPassthroughConvertorViewController.h"
#import "NvSDKUtils.h"
#import "NvsPassthroughConvertor.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvBaseCommon/NvToast.h>
#import "NvUtils.h"
#import <NvSDKCommon/NvHDRManager.h>

static CGFloat const BgCircleWidth = 90;

@interface NvsPassthroughConvertorViewController ()<NvsPassthroughConvertorDelegate>
@property (nonatomic, strong) UIView *compileView;
@property (nonatomic, strong) UIView *compileProgress;

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *tranLayer;
@property (nonatomic, strong) UILabel *percentageLabel;
@property (nonatomic, strong) NvsPassthroughConvertor *convertor;
@property (nonatomic, copy) NSString *outputPath;
@property (nonatomic, strong) NvsPassthroughFileInfo *taskFileInfo;
@end

@implementation NvsPassthroughConvertorViewController

- (void)dealloc {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addSubviews];
    self.convertor = [[NvsPassthroughConvertor alloc] init];
    self.convertor.delegate = self;
}

- (UIBezierPath *)_path
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.compileProgress.width / 2.0, self.compileProgress.width / 2.0) radius:BgCircleWidth / 2.0 startAngle:-M_PI_2 endAngle:1.5*M_PI clockwise:YES];
    return path;
}


- (void)addSubviews {
    self.view.backgroundColor = [UIColor clearColor];
    
    self.compileView = [[UIView alloc] initWithFrame:self.view.frame];
    self.compileView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self.view addSubview:self.compileView];
    self.compileProgress = [UIView new];
    self.compileProgress.backgroundColor = [UIColor clearColor];
    [self.compileView addSubview:self.compileProgress];
    self.compileProgress.frame = CGRectMake(0, 0, BgCircleWidth, BgCircleWidth);
    self.compileProgress.centerX = self.compileView.centerX;
    self.compileProgress.centerY = self.compileView.centerY;
    
    [self.compileProgress.layer addSublayer:self.circleLayer];
    [self.compileProgress.layer addSublayer:self.tranLayer];
    [self.compileProgress addSubview:self.percentageLabel];
    [self.percentageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.compileProgress);
        make.width.mas_equalTo(80.0f);
        make.height.mas_equalTo(30.0f);
    }];
}

-(UILabel *)percentageLabel{
    if (!_percentageLabel) {
        _percentageLabel = [UILabel new];
        _percentageLabel.font = [UIFont systemFontOfSize:12.0f];
        _percentageLabel.textAlignment = NSTextAlignmentCenter;
        _percentageLabel.textColor =  [UIColor whiteColor];
    }
    return _percentageLabel;
}

-(CAShapeLayer *)circleLayer{
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.bounds = self.compileProgress.bounds;
        _circleLayer.position = CGPointMake(self.compileProgress.width / 2.0, self.compileProgress.width / 2.0);
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = [UIColor nv_colorWithHexString:@"484848"].CGColor;
        _circleLayer.path = [self _path].CGPath;
        _circleLayer.lineWidth = 5;
        _circleLayer.lineCap = kCALineCapRound;
        _circleLayer.strokeStart = 0;
        _circleLayer.strokeEnd = 1;
    }
    return _circleLayer;
}

-(CAShapeLayer *)tranLayer{
    if (!_tranLayer) {
        _tranLayer = [CAShapeLayer layer];
        _tranLayer.bounds = self.compileProgress.bounds;
        _tranLayer.position = CGPointMake(self.compileProgress.width / 2.0, self.compileProgress.width / 2.0);
        _tranLayer.fillColor = [UIColor clearColor].CGColor;
        _tranLayer.strokeColor = [UIColor nv_colorWithHexString:@"#63abff"].CGColor;
        _tranLayer.path = [self _path].CGPath;
        _tranLayer.lineWidth = 5;
        _tranLayer.lineCap = kCALineCapRound;
        _tranLayer.strokeStart = 0;
        _tranLayer.strokeEnd = 0;
    }
    return _tranLayer;
}

CFAbsoluteTime begin = 0;

- (int64_t)convertMediaFile:(NSString *)srcFilePath
              outputFile:(NSString *)outputFilePath
                  trimIn:(int64_t)trimIn
                 trimOut:(int64_t)trimOut
                    options:(NSMutableDictionary *)options {
    self.outputPath = outputFilePath;
    
    NvsPassthroughFileInfo *info = [[NvsPassthroughFileInfo alloc]init];
    info.mediaFilePath = srcFilePath;
    info.trimIn = trimIn;
    info.trimOut = trimOut;
    self.taskFileInfo = info;
    int64_t index = [self.convertor convertMediaFile:@[info] outputFile:outputFilePath options:nil passthroughType:0];
    return index;
}

- (void)cancelTask:(int64_t)taskId {
    [self.convertor cancelTask:taskId];
}

- (void)convertFinish:(int64_t)taskId sourceFile:(NSString*)src outputFile:(NSString*)dst trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut errorCode:(NvsPassthroughConvertorErrorType)error {
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"%f",end - begin);
    
    if ([self.delegate respondsToSelector:@selector(didConvertorFinish:sourceFile:outputFile:trimIn:trimOut:errorCode:)]) {
        [self.delegate didConvertorFinish:taskId sourceFile:src outputFile:dst trimIn:trimIn trimOut:trimOut errorCode:error];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

#pragma mark - NvsPassthroughConvertorDelegate
- (void)didConvertorProgress:(int64_t)taskId progress:(float)progress {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.tranLayer.strokeEnd = progress;
        weakSelf.percentageLabel.text = [NSString stringWithFormat:@"%.f%%", progress*100];
    });
    
    if ([self.delegate respondsToSelector:@selector(didConvertorProgress:progress:)]) {
        [self.delegate didConvertorProgress:taskId progress:progress];
    }
}

- (void)didConvertorFinish:(int64_t)taskId errorCode:(NvsPassthroughConvertorErrorType)error errorString:(NSString*)errorString {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NvToast dismiss];
        if (error == NvsPassthroughConvertorErrorType_NoError) {
            
            [weakSelf.compileProgress removeFromSuperview];
            weakSelf.compileProgress = nil;
             
            UILabel *tipLabel = [[UILabel alloc] init];
            tipLabel.textAlignment = NSTextAlignmentCenter;
            tipLabel.text = NvLocalStringFromTable([self class], @"Generated complete", @"已完成\n请在相册中查看");
            tipLabel.textColor = UIColor.whiteColor;
            tipLabel.numberOfLines = 0;
            tipLabel.alpha = 0.8;
            [weakSelf.compileView addSubview:tipLabel];
            [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.compileView.mas_centerX);
                make.centerY.equalTo(self.compileView.mas_centerY);
            }];
            [weakSelf convertFinish:taskId sourceFile:weakSelf.taskFileInfo.mediaFilePath outputFile:weakSelf.outputPath trimIn:weakSelf.taskFileInfo.trimIn trimOut:weakSelf.taskFileInfo.trimOut errorCode:error];
        }else{
            NSString *errorMessage = @"";
            NSString *tempString = @"";
            switch (error) {
                case NvsPassthroughConvertorErrorType_Cancled:
                    tempString = @"中途取消";
                    break;
                case NvsPassthroughConvertorErrorType_ProcessVideo:
                    tempString = @"输出视频帧失败";
                    break;
                case NvsPassthroughConvertorErrorType_ProcessAudio:
                    tempString = @"输出音频帧失败";
                    break;
                case NvsPassthroughConvertorErrorType_InvalidData:
                    tempString = @"无效参数";
                    break;
                case NvsPassthroughConvertorErrorType_IO:
                    tempString = @"IO错误";
                    break;
                default:
                    tempString = @"未知错误";
                    break;
            }
            
            errorMessage = [NSString stringWithFormat:@"错误类型:%@",tempString];
            DebugLog(@"%@",errorMessage);
            weakSelf.compileView.hidden = YES;
            __weak typeof(self)weakSelf = self;
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalStringFromTable([self class], @"Generated failed", @"生成失败") message:NvLocalStringFromTable([self class], @"storage", @"请检查手机存储空间") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalStringFromTable([self class], @"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf convertFinish:taskId sourceFile:weakSelf.taskFileInfo.mediaFilePath outputFile:weakSelf.outputPath trimIn:weakSelf.taskFileInfo.trimIn trimOut:weakSelf.taskFileInfo.trimOut errorCode:error];
            }];
            [alertVC addAction:skipAction];
            
            [weakSelf presentViewController:alertVC animated:YES completion:nil];
        }
    });

}

@end
