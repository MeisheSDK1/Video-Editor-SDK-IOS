//
//  NvLiveModel.h
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/16.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import "NvLiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveModel : NSObject

@property (nonatomic, strong) NSString *roomId;

@property (nonatomic, strong) NSString *pushUrl;

@property (nonatomic, strong) NSString *pullUrl;

@property (nonatomic, strong) NSString *coverUrl;

@property (nonatomic, assign) BOOL online;

@property (nonatomic, strong) NSString *onlineUsers;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NvLiveUserModel *userInfo;

@end

NS_ASSUME_NONNULL_END
