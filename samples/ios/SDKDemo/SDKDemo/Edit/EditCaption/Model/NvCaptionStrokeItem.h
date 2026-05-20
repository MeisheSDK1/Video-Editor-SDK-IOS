//
//  NvCaptionStrokeItem.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef struct {
    float r, g, b, a;
} NvColor;


@interface NvCaptionStrokeItem : NSObject

@property (nonatomic, strong) NSString *colorString;
@property (nonatomic, assign) float alpha;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL isNone;

@end
