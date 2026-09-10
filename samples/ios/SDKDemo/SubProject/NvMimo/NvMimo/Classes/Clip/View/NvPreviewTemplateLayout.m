//
//  NvPreviewTemplateLayout.m
//  NvMimoDemo
//
//  Created by MS on 2019/9/11.
//  Copyright © 2019 MS. All rights reserved.
//

#import "NvPreviewTemplateLayout.h"
#import "NVHeader.h"

@implementation NvPreviewTemplateLayout
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * layoutAttributes_t = [super layoutAttributesForElementsInRect:rect];
    NSArray * layoutAttributes = [[NSArray alloc]initWithArray:layoutAttributes_t copyItems:YES];
    
    for (UICollectionViewLayoutAttributes * attributes in layoutAttributes) {
        CGRect nowFrame = attributes.frame;
        nowFrame.origin.y = 15.f*SCREANSCALE;
        attributes.frame = nowFrame;
    }
    return layoutAttributes;
}

@end
