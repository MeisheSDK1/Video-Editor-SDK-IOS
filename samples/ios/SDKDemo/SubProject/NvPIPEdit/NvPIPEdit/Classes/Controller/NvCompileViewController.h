//
//  NvCompileViewController.h
//  SDKDemo
//
//  Created by meishe01 on 2018/6/5.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"

@protocol NvCompileViewControllerDelegate <NSObject>

@optional
- (void)compileFinished:(BOOL)needDelete;

@end

@interface NvCompileViewController : UIViewController

@property (nonatomic, weak) id <NvCompileViewControllerDelegate> delegate;

- (void)compileTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath;

@end
