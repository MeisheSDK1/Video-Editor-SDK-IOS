//
//  TemplateModel.h
//  MemoryAlbum
//
//  Created by ms20180425 on 2019/12/25.
//  Copyright © 2019 ms20180425. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MusicClipModel;

@interface TemplateModel : NSObject

@property (nonatomic, strong) NSString *theme;
@property (nonatomic, strong) NSString *musicrhythm;
@property (nonatomic, strong) NSString *captionstyle1;
@property (nonatomic, strong) NSString *captionstyle2;
@property (nonatomic, strong) NSString *endingVideoFX;
@property (nonatomic, strong) NSArray *transition;

@property (nonatomic, strong) NSString *themePackage;
@property (nonatomic, strong) NSString *captionstyle1Package;
@property (nonatomic, strong) NSString *captionstyle2Package;
@property (nonatomic, strong) NSString *endingVideoFXPackage;

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) MusicClipModel *musicClip;


@end

NS_ASSUME_NONNULL_END
