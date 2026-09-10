//
//  NvBottomLine.m
//  SDKDemo
//
//  Created by ms on 2020/8/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvBottomLine.h"
#import "NVHeader.h"
@interface NvBottomLine()

@property (nonatomic, strong) NSMutableArray *views;
@end

@implementation NvBottomLine

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.views = [NSMutableArray array];
        
    }
    return self;
}

-(void)setArr:(NSArray *)arr{
    _arr = arr;
    int64_t total = 0;
    CGRect lastFrame = CGRectMake(15.0f, 0, 0, 0) ;
    for (NvShotInfoModel *info in arr) {
        total = total + info.duration;
    }
    CGFloat totalWidth = SCREENWIDTH - 15.0 - 10.0 * (arr.count-1);
    for (NvShotInfoModel *info in arr) {
        UIView *view = [[UIView alloc] init];
        CGFloat ratio = info.duration * 1.0 / total;
        view.frame = CGRectMake(lastFrame.origin.x, lastFrame.origin.y, totalWidth *ratio, 3.0f);
        lastFrame = CGRectMake(CGRectGetMaxX(view.frame) + 10.0f, lastFrame.origin.y, 0, 0);
        [self addSubview:view];
        view.backgroundColor = [UIColor whiteColor];
        [self.views addObject:view];
    }
    
}

-(void)setCurrentIndex:(NSUInteger)currentIndex{
    _currentIndex = currentIndex;
    
    if (currentIndex < self.views.count) {
        UIView *view = self.views[currentIndex];
        view.backgroundColor = [UIColor nv_colorWithHexString:@"#4A90E2"];
    }
}

-(void)deleteLastPath{
    if (_currentIndex < self.views.count) {
        UIView *view = self.views[_currentIndex];
        view.backgroundColor = [UIColor nv_colorWithHexString:@"#ffffff"];
        _currentIndex --;
    }
}

@end
