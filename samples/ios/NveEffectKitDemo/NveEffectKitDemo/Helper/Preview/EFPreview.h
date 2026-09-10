//
//  EFPreview.h
//  GPUImageEffectDemo
//
//  Created by 美摄 on 2021/3/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    EFPreviewFillModeStretch,                   // Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
    EFPreviewFillModePreserveAspectRatio,       // Maintains the aspect ratio of the source image, adding bars of the specified background color
    EFPreviewFillModePreserveAspectRatioAndFill // Maintains the aspect ratio of the source image, zooming in on its center to fill the view
} EFPreviewFillModeType;

@interface EFPreview : UIView

@property(assign, nonatomic) EFPreviewFillModeType fillMode;

/** This calculates the current display size, in pixels, taking into account Retina scaling factors
 */
@property(readonly, nonatomic) CGSize sizeInPixels;

- (instancetype)initWithFrame:(CGRect)frame glContext:(EAGLContext *)glContext;

/** Handling fill mode
 
 @param redComponent Red component for background color
 @param greenComponent Green component for background color
 @param blueComponent Blue component for background color
 @param alphaComponent Alpha component for background color
 */
- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;

- (void)newFrameReadyTexture:(GLuint)texture size:(CGSize)size;

- (void)cleanUp;

@end

NS_ASSUME_NONNULL_END
