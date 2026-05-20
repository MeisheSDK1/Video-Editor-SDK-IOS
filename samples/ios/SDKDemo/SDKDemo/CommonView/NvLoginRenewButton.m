//
//  NvLoginRenewButton.m
//  SDKDemo
//
//  Created by meishe01 on 2024/3/22.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvLoginRenewButton.h"
#import "NvSubscriproController.h"
#import "AppDelegate+Qonversion.h"

@implementation NvLoginRenewButton

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if([[NvUserInfoManager sharedInstance] nv_loginAndRenewProActive]){
        
        [super sendAction:action to:target forEvent:event];
    }else{
        
        UIViewController *rootViewController = (UIViewController *)[UIApplication.sharedApplication.windows firstObject].rootViewController;
        if ([NvUserInfoManager sharedInstance].nv_hasLogin){
            
            NvSubscriproController *SubscriproVC = [[NvSubscriproController alloc]init];
            SubscriproVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [rootViewController presentViewController:SubscriproVC animated:YES completion:nil];
        }else{
            //调取登录，登录完成进行存储数据
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.appleLoginResult = ^(BOOL success) {
                
                if(success){
                    [AppDelegate checkQonEntitlements:^(BOOL isActive) {
                        if(!isActive){
                            NvSubscriproController *SubscriproVC = [[NvSubscriproController alloc]init];
                            SubscriproVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                            [rootViewController presentViewController:SubscriproVC animated:YES completion:nil];
                        }
                    }];
                }
            };
            [appDelegate loginInWithApple];
        }
    }
}
//重写防止长按下去背景变为normal状态
- (void)setHighlighted:(BOOL)highlighted
{

}

@end
