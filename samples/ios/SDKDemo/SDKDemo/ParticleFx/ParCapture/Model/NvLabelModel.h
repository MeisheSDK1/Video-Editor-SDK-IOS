//
//  NvLabelModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/19.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NvLabelModel : NSObject

@property (nonatomic, strong) NSString *labelName;
@property (nonatomic, strong) NSString *labelImage;
@property (nonatomic, strong) NSString *labelImage_no;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL first;
@property (nonatomic, assign) NSInteger categoryId;
@end
