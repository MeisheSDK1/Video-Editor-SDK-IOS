//
//  NvStickerModel.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2020/4/27.
//  Copyright © 2020 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvStickerModelDelegate <NSObject>

-(UIImage *)coverImageObject;

@end

@interface NvStickerModel : NSObject<NvStickerModelDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) NSString *coverImage;
@property (nonatomic, strong) NSString *sceneId;
@property (nonatomic, strong) NSString *package;

@end

NS_ASSUME_NONNULL_END
