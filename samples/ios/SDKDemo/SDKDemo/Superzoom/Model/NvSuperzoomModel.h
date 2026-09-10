#import <Foundation/Foundation.h>
#import "NvAVAssetWriteManager.h"
#import <UIKit/UIKit.h>


//闪光灯状态
typedef NS_ENUM(NSInteger, NvFlashState) {
    NvFlashClose = 0,
    NvFlashOpen,
    NvFlashAuto,
};

@protocol NvSuperzoomModelDelegate <NSObject>

- (void)updateFlashState:(NvFlashState)state;
- (void)updateRecordingProgress:(CGFloat)progress;
- (void)updateRecordState:(NvRecordState)recordState;
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


@interface NvSuperzoomModel : NSObject

@property (nonatomic, weak  ) id<NvSuperzoomModelDelegate>delegate;
@property (nonatomic, assign) NvRecordState recordState;
@property (nonatomic, strong, readonly) NSURL *videoUrl;
@property (nonatomic, strong)NvAVAssetWriteManager *writeManager;
@property (nonatomic, assign) BOOL isFrontCamera;

- (instancetype)initWithNvVideoViewType:(NvVideoViewType )type superView:(UIView *)superView;

- (void)turnCameraAction;
- (void)switchflash;
- (void)startRecord;
- (void)stopRecord;
- (void)reset;


@end
