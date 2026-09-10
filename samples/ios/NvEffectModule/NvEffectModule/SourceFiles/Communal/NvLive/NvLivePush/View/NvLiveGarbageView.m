//
//  NvLiveGarbageView.m
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/26.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import "NvLiveGarbageView.h"
#import "NvLiveAppEnv.h"
#import "Masonry.h"
#import "NvLiveARSceneUtils.h"

@interface NvLiveGarbageView()

@end

@implementation NvLiveGarbageView

-(void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addMainView];
    }
    return self;
}

- (void)addMainView{
    UIImageView *imageView_bg = [[UIImageView alloc]init];
    imageView_bg.contentMode = UIViewContentModeScaleAspectFit;
    imageView_bg.image = [NvLiveARSceneUtils imageNamed:@"MSGarbage_bg"];
    [self addSubview:imageView_bg];
    [imageView_bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [NvLiveARSceneUtils imageNamed:@"MSGarbage"];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28 * NvScreen(kScale));
        make.centerX.equalTo(self);
        make.width.height.offset(30 * NvScreen(kScale));
    }];
    
    UILabel *titlelabel = [[UILabel alloc]init];
    titlelabel.textColor = UIColor.whiteColor;
    titlelabel.font = [UIFont systemFontOfSize:19];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.text = NvLocalString(@"Drag here to delete", @"拖到这里删除");
    [self addSubview:titlelabel];
    [titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-10 * NvScreen(kScale));
        make.centerX.equalTo(self);
    }];
}

@end
