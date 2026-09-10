//
//  NvBoomerangPreviewView.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/19.
//  Copyright © 2018 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NvStreamingSdkCore/NvsLiveWindow.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NvBoomerangPreviewViewDelegate <NSObject>

- (void)backBtnClick;
- (void)exportBtnClick;

@end

typedef enum {
    NV_NOT_BEGIN,
    NV_GENERATING,
    NV_GENERATED
}NvGenerateStatus;

@interface NvBoomerangPreviewView : UIView

@property (nonatomic, weak) id<NvBoomerangPreviewViewDelegate> delegate;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, assign) NvGenerateStatus status;

@end

NS_ASSUME_NONNULL_END
