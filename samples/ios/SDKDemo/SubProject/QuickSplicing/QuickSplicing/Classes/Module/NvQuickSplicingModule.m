//
//  NvQuickSplicingModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvQuickSplicingModule.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvAlbum/NvAlbumViewController.h>
#import <NvAlbum/NvAlbumSizeViewController.h>
#import "NvQuickSplicingController.h"
#import "NvStreamingSdkCore.h"
@interface NvQuickSplicingModule ()
@property (nonatomic, assign) NvsSize size;
///编码方式
///Encoding mode
@property (nonatomic, assign) NvsVideoCodecType type;
///画质等级
///Picture quality grade
@property (nonatomic, assign) int codecProfile;
///编码等级
///Coding level
@property (nonatomic, assign) int codecLevel;
///旋转角度
///Angle of rotation
@property (nonatomic, assign) NvsVideoRotation rotation;
///颜色变换曲线
///Color transformation curve
@property (nonatomic, assign) NvsVideoColorTransfer colorTransfer;
///音频数量
///Audio quantity
@property (nonatomic, assign) int audioCount;
@end

@implementation NvQuickSplicingModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 16;
}

- (NSString *)moduleTitle {
    return NvLocalStringFromTable([self class], @"Quick splicing", @"快速拼接");
}

- (UIImage *)moduleCover {
    return NvImageNamed(@"quick_splicing");
}

- (void)startModule:(NSDictionary *)param {
    NvAlbumViewController *albumVC = [NvAlbumViewController new];
    albumVC.delegate = self;
    albumVC.mutableSelect = YES;
    albumVC.isOnlyVideo = YES;
    albumVC.isQuickSplicing = YES;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController 
            selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    if (assets.count == 0) {
        return;
    }
    NvAlbumSizeViewController *sizeVC = [NvAlbumSizeViewController new];
    sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:sizeVC animated:NO completion:NULL];
    __weak typeof(self)weakSelf = self;
    [sizeVC selectSizeTypeBlock:^(int type) {
        NvQuickSplicingController *vc = [[NvQuickSplicingController alloc] initWithAssets:assets editMode:(NvEditMode)type];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (BOOL)nvAlbumViewSamemMaterialController:(NvAlbumViewController *)albumViewController asset:(NvAlbumAsset *)asset index: (NSUInteger)index isSelect:(BOOL)select{

    if (!select) {
        return YES;
    }
    
    if (index == 0) {
        NvsAVFileInfo *fileInfo = [[NvsStreamingContext sharedInstance] getAVFileInfoExtra:asset.asset.localIdentifier extraFlag:NvsAVFileinfoExtra_AVPixelFormat];
        self.size = [fileInfo getVideoStreamDimension:0];
        self.type = [fileInfo getVideoStreamCodecType:0];
        self.codecProfile = [fileInfo getVideoCodecProfile:0];
        self.codecLevel = [fileInfo getVideoCodecLevel:0];
        self.rotation = [fileInfo getVideoStreamRotation:0];
        self.colorTransfer = [fileInfo getVideoStreamColorTranfer:0];
        self.audioCount = [fileInfo getAudioStreamChannelCount:0];
        return YES;
    }else{
        NvsAVFileInfo *fileInfo = [[NvsStreamingContext sharedInstance] getAVFileInfoExtra:asset.asset.localIdentifier extraFlag:NvsAVFileinfoExtra_AVPixelFormat];
        NvsSize size = [fileInfo getVideoStreamDimension:0];
        NvsVideoCodecType type = [fileInfo getVideoStreamCodecType:0];
        int codecProfile = [fileInfo getVideoCodecProfile:0];
        int codecLevel = [fileInfo getVideoCodecLevel:0];
        NvsVideoRotation rotation = [fileInfo getVideoStreamRotation:0];
        NvsVideoColorTransfer colorTransfer = [fileInfo getVideoStreamColorTranfer:0];
        int audio = [fileInfo getAudioStreamChannelCount:0];
        
        /*Note:
         * if you set the NvsStreamingEngineCompileFlag_OnlyVideo when you called
         "- (BOOL)compilePassthroughTimeline: outputFilePath: compileConfigurations: flags:" api, you should make sure the audiochannel of first track equal to the first asset you selected.
         eg:[fileInfo getAudioStreamChannelCount:0]
         */
        if (self.size.width == size.width && self.size.height == size.height
            && self.type == type && self.codecProfile == codecProfile && self.codecLevel == codecLevel && self.rotation == rotation && self.colorTransfer == colorTransfer && self.audioCount == audio) {
            return YES;
        }else{
            return NO;
        }
    }
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsOverMaxCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets {
    
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController didSelectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    
}

- (UIView *)nvAlbumViewControllerCustomBottomButton {
    return nil;
}


@end
