//
//  NvMenuTextView.m
//  SDKDemo
//
//  Created by 美摄 on 2022/6/28.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvMenuTextView.h"

@implementation NvMenuTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action ==@selector(copy:) ||
       action ==@selector(selectAll:)||
       action ==@selector(cut:)||
       action ==@selector(select:)||
       action ==@selector(paste:))
    {
        return [super canPerformAction:action withSender:sender];
    }

    return NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setEditable:YES];
    [self becomeFirstResponder];
}
@end
