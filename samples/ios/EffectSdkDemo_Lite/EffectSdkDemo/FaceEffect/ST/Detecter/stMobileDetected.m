//
//  stMobileDetected.m
//  particle
//
//  Created by Meicam on 2017/11/21.
//  Copyright © 2017年 NewAuto video team. All rights reserved.
//

#import "stMobileDetected.h"
#import "st_mobile_license.h"
#import "st_mobile_human_action.h"
#import <AVKit/AVKit.h>
#import <CommonCrypto/CommonDigest.h>


@implementation stMobileDetected {
    st_handle_t _hDetector; // detector句柄
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hDetector = nil;
    }
    return self;
}

- (void)dealloc {
    if (_hDetector) {
        st_mobile_human_action_destroy(_hDetector);
        _hDetector = NULL;
    }
}

//验证license
- (BOOL)checkActiveCode {
    NSString *strLicensePath = [[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"];
    NSData *dataLicense = [NSData dataWithContentsOfFile:strLicensePath];
    
    NSString *strKeySHA1 = @"SENSEME";
    NSString *strKeyActiveCode = @"ACTIVE_CODE";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strStoredSHA1 = [userDefaults objectForKey:strKeySHA1];
    NSString *strLicenseSHA1 = [self getSHA1StringWithData:dataLicense];
    
    st_result_t iRet = ST_OK;
    
    
    if (strStoredSHA1.length > 0 && [strLicenseSHA1 isEqualToString:strStoredSHA1]) {
        
        // Get current active code
        // In this app active code was stored in NSUserDefaults
        // It also can be stored in other places
        NSData *activeCodeData = [userDefaults objectForKey:strKeyActiveCode];
        
        // Check if current active code is available

        // use buffer
        
        iRet = st_mobile_check_activecode_from_buffer(
                                                      [dataLicense bytes],
                                                      (int)[dataLicense length],
                                                      [activeCodeData bytes],
                                                      (int)[activeCodeData length]
                                                      );
      
        
        if (ST_OK == iRet) {
            
            // check success
            return YES;
        }
    }
    
    /*
     1. check fail
     2. new one
     3. update
     */
    
    char active_code[1024];
    int active_code_len = 1024;
    
    // generate one

    
    // use buffer
    
    iRet = st_mobile_generate_activecode_from_buffer(
                                                     [dataLicense bytes],
                                                     (int)[dataLicense length],
                                                     active_code,
                                                     &active_code_len
                                                     );

    if (ST_OK != iRet) {
        NSLog(@"st 使用 license 文件生成激活码时失败，可能是授权文件过期。");
        return NO;
    } else {
        
        // Store active code
        NSData *activeCodeData = [NSData dataWithBytes:active_code length:active_code_len];
        
        [userDefaults setObject:activeCodeData forKey:strKeyActiveCode];
        [userDefaults setObject:strLicenseSHA1 forKey:strKeySHA1];
        
        [userDefaults synchronize];
    }
    
    return YES;
}

- (NSString *)getSHA1StringWithData:(NSData *)data {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *strSHA1 = [NSMutableString string];
    
    for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; i ++) {
        
        [strSHA1 appendFormat:@"%02x" , digest[i]];
    }
    
    return strSHA1;
}


- (BOOL)setupHandle {
    
    st_result_t iRet = ST_OK;
    
    
    //初始化检测模块句柄
    NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"action5.0.0" ofType:@"model"];
    
    uint32_t config = 0;
    
    config = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO;
    

    iRet = st_mobile_human_action_create(strModelPath.UTF8String,
                                         config,
                                         &_hDetector);
    
    
    if (ST_OK != iRet || !_hDetector) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"算法SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return NO;
    }
    
    //设置张嘴动作的阈值,置信度为[0,1], 默认阈值为0.5
    st_mobile_set_mouthah_threshold(0.4f);
    return YES;
}

- (BOOL)initSTMobileDetected {
    if(![self checkActiveCode])
      return NO;
    if(![self setupHandle])
        return NO;
    return YES;
}

- (NvsFaceFeaturePoint *)stMobileDetected:(void *)imageBuffer width:(int)width height:(int)height {
    if (!imageBuffer)
        return nil;
    
    st_mobile_human_action_t detectResult;
    st_result_t iRet = st_mobile_human_action_detect(_hDetector,
                                                     imageBuffer,
                                                     ST_PIX_FMT_BGRA8888,
                                                     width,
                                                     height,
                                                     width * 4,
                                                     ST_CLOCKWISE_ROTATE_0,
                                                     ST_MOBILE_FACE_DETECT,
                                                     &detectResult);
    if (iRet == ST_OK) {
        if (detectResult.face_count > 0) {
            NvsFaceFeaturePoint *faceFeaturePoint = [[NvsFaceFeaturePoint alloc] initWithCapacity:detectResult.face_count];
            if (!faceFeaturePoint || faceFeaturePoint.faceCount != detectResult.face_count)
                return nil;
            for (int i = 0; i < faceFeaturePoint.faceCount; i++) {
                st_mobile_face_t face = detectResult.p_faces[i];
                NvsFaceInfo *faceInfo = faceFeaturePoint.faces[i];
                faceInfo.faceId = face.face106.ID;
                for (int j = 0; j < 106; j++) {
                    st_pointf_t pt = face.face106.points_array[j];
                    float visibility = face.face106.visibility_array[j];
                    NvsEffectPosition2D pt2D;
                    pt2D.x = pt.x;
                    pt2D.y = pt.y;
                    faceInfo.pointsArray[j] = [NSData dataWithBytes:&pt2D length:sizeof(NvsEffectPosition2D)];
                    faceInfo.visibilityArray[j] = [NSNumber numberWithFloat:visibility];
                }
            }
            return faceFeaturePoint;
        }
    }
    
    return nil;
}

@end
