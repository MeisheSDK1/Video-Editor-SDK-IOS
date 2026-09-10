//
//  NvEditMaterialLayout.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvEditMaterialLayout;
@protocol NvEditMaterialLayoutDelegate <NSObject>

- (void)nvEditMaterialLayout:(NvEditMaterialLayout *)nvEditMaterialLayout uiCollectionViewLayoutAttributes:(UICollectionViewLayoutAttributes*)layout;

@end

@interface NvEditMaterialLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<NvEditMaterialLayoutDelegate> delegate;

@end
