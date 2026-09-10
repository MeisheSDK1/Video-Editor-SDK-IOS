//
//  NvMusicTableView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvEditSelectMusicItem.h"

@protocol NvSelectMusicTableViewDelegate <NSObject>
@optional
- (void)playItem:(NvEditSelectMusicItem *)item;

@end

@interface NvMusicTableView : UIView

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSMutableArray <NvEditSelectMusicItem *>*dataSource;

@end
