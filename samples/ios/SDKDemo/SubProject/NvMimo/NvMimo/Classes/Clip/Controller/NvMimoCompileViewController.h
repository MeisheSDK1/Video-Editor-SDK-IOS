//
//  NvCompileViewController.h
//  SDKDemo
//
//  Created by meishe01 on 2018/6/5.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"

@protocol NvMimoCompileViewControllerDelegate <NSObject>

@optional
- (void)compileFinished:(BOOL)needDelete;

@end

@interface NvMimoCompileViewController : UIViewController

@property (nonatomic, weak) id <NvMimoCompileViewControllerDelegate> delegate;

- (void)compileTimeline:(NvsTimeline *)timeline outputPath:(NSString *)ouputPath;

@end
