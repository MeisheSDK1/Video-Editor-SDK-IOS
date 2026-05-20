//
//  NvFlipCaptionModel.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFlipCaptionModel.h"

@implementation NvFlipCaptionModel

- (id)copyWithZone:(NSZone *)zone {
    NvFlipCaptionModel *model = [NvFlipCaptionModel new];
    model.colorString = self.colorString;
    model.isSelect = self.isSelect;
    model.isEdit = self.isEdit;
    model.text = self.text;
    model.timeStr = self.timeStr;
    return model;
}

@end
