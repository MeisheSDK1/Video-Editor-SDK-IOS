//
//  NvPIPThemeView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvPIPThemeView;
@class NvPIPThemeItem;

@protocol NvPIPThemeViewDelegate

- (void)nvPIPThemeViewOkClick:(NvPIPThemeView *)pipThemeView;
- (void)nvPIPThemeView:(NvPIPThemeView *)pipThemeView applyTemplate:(NvPIPThemeItem *)item;

@end

@interface NvPIPThemeView : UIView

@property (weak, nonatomic) id delegate;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end
