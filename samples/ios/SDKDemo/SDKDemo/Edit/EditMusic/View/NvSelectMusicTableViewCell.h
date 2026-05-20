//
//  NvSelectMusicTableViewCell.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvEditSelectMusicItem.h"
@class NvSelectMusicTableViewCell;

@protocol NvSelectMusicTableViewCellDelegate <NSObject>
@optional
- (void)nvSelectMusicTableViewCell:(NvSelectMusicTableViewCell *)cell playItem:(NvEditSelectMusicItem *)item;

@end

@interface NvSelectMusicTableViewCell : UITableViewCell

@property (nonatomic, weak) id delegate;

- (void)renderCellWithItem:(NvEditSelectMusicItem *)item;

@end
