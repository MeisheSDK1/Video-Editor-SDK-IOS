//
//  NvLiveMakeupItemModel.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveMakeupItemModel : NSObject

@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, strong) NSString *coverImage; //封面图片 Cover image
@property(nonatomic, strong) NSMutableArray<NvLiveMakeupItemModel *> *contents;
@property(nonatomic, strong) NSString *infoPath;
@property(nonatomic, strong) NSString *packagePath;
@property(nonatomic, strong) NSString *licPath;
@property(nonatomic, assign) NSInteger effectType;

@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) NSString *displayNameZhCn;
@property(nonatomic, assign) BOOL selected; //是否选中 Whether selected

//@property(nonatomic, strong) NSArray<NvMakeupItemTranslationModel *> *translation;
@property(nonatomic, strong) NSString *textColorStr;
@property(nonatomic, strong) NSString *labelColorStr;
@property(nonatomic, assign) BOOL hasBgColor;
@property(nonatomic, strong) NSString *bgColorStr;
@property(nonatomic, assign) NSInteger conLevel; //数据处于第几层级（整妆0，分类1，单妆2） What level is the data at (makeup 0, classification 1, single makeup 2)

@property (nonatomic, strong) NSString *packageName;
@property (nonatomic, strong) NSString *colorName;
@property (nonatomic, strong) NSString *intensityName;
@property (nonatomic, assign) CGFloat value;
@end

NS_ASSUME_NONNULL_END
