//
//  NvFilterSearchResultViewController.m
//  SDKDemo
//
//  Created by chengww on 2020/11/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvFilterSearchResultViewController.h"
#import "NvBaseModel.h"
#import "NvMoreFilterCollectionCell.h"

@interface NvFilterSearchResultViewController ()
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation NvFilterSearchResultViewController
- (void)setKeywords:(NSString *)keywords {
    _keywords = keywords;
    NSLog(@"%s:%@",__func__, keywords);
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

}

@end
