//
//  NvMaskMenuBottonView.h
//  SDKDemo
//
//  Created by ms on 2021/3/5.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDKDemo-Swift.h"

typedef NS_ENUM(NSInteger, MaskItem) {
    MaskItemNone = 0,
    MaskItemLine,
    MaskItemMirror,
    MaskItemCircle,
    MaskItemRect,
    MaskItemheart,
    MaskItemStar,
    MaskItemCaption,
};
NS_ASSUME_NONNULL_BEGIN
@interface NvMaskMenuBottonView : UIView
@property (nonatomic, strong) NSMutableArray *dataArray;      

@property (nonatomic, copy) void(^okBtnClick)(void);

@property (nonatomic, copy) void(^flipBtnClick)(void);

@property (nonatomic, copy) void(^selectItemClick)(NvClipMaskType);
@end

NS_ASSUME_NONNULL_END
