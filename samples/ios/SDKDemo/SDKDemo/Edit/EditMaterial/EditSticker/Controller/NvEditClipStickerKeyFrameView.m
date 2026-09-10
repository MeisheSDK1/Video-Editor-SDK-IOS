//
//  NvEditClipStickerKeyFrameView.m
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditClipStickerKeyFrameView.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "NvKeyFrameButton.h"
#import "NVHeader.h"
#import "NvsTimelineAnimatedSticker.h"

@interface NvEditClipStickerKeyFrameView()
/// 上一帧按钮
/// Previous frame button
@property (nonatomic, strong) NvKeyFrameButton *preFrameBtn;
/// 下一帧按钮
/// Next frame button
@property (nonatomic, strong) NvKeyFrameButton *nextFrameBtn;
/// 控制关键帧按钮（添加、删除）
/// Control key frame button (add, delete)
@property (nonatomic, strong) NvKeyFrameButton *managerFrameBtn;
/// 完成
/// complete
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, assign) int64_t pos;

@end

@implementation NvEditClipStickerKeyFrameView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.backgroundColor = UIColorFromRGB(0x242728);
    self.indexPath = 0;
    //finish button
    self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishButton setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [self.finishButton addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.finishButton];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-10*SCREENSCALE-INDICATOR);
        make.centerX.equalTo(self.mas_centerX);
        make.width.offset(25 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
    
    UIView *sepLine = [[UIView alloc] init];
    sepLine.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.finishButton.mas_top).offset(-10);
        make.width.offset(SCREENWIDTH);
        make.height.offset(0.5);
    }];
    
    UIView *buttonBGView = [[UIView alloc] init];
    [self addSubview:buttonBGView];
    [buttonBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(45*SCREENSCALE);
        make.bottom.equalTo(sepLine.mas_top);
    }];
    
    CGFloat buttonWidth = 60*SCREENSCALE;
    CGFloat buttonSep = (SCREENWIDTH - 5*buttonWidth)/4;
    
    self.managerFrameBtn = [NvKeyFrameButton buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Add frame", @"添加帧") withImageNormal:@"nv_edit_addFrame" withImageSelected:@"nv_edit_deleteFrame"];
    
    self.managerFrameBtn.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    [self.managerFrameBtn addTarget:self action:@selector(managerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBGView addSubview:self.managerFrameBtn];
    [self.managerFrameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(buttonBGView.mas_top);
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(-3*SCREENSCALE);
    }];
    
    self.preFrameBtn = [NvKeyFrameButton buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Previous frame", @"上一帧") withImageNormal:@"nv_edit_preFrame" withImageSelected:nil];
    self.preFrameBtn.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    [self.preFrameBtn addTarget:self action:@selector(preFrameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBGView addSubview:self.preFrameBtn];
    [self.preFrameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.managerFrameBtn.mas_left).offset(-buttonSep);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(buttonBGView.mas_top);
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(-3*SCREENSCALE);
    }];
    
    self.nextFrameBtn = [NvKeyFrameButton buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Next frame", @"下一帧") withImageNormal:@"nv_edit_nextFrame" withImageSelected:nil];
    self.nextFrameBtn.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    [self.nextFrameBtn addTarget:self action:@selector(nextFrameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBGView addSubview:self.nextFrameBtn];
    [self.nextFrameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.managerFrameBtn.mas_right).offset(buttonSep);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(buttonBGView.mas_top);
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(-3*SCREENSCALE);
    }];
}

#pragma mark 根据传入的时间点，正确配置内部按钮的状态
///Correctly configure the state of the internal button based on the point in time passed in
- (void)configTime:(int64_t)time withEnd:(BOOL)end{
    self.pos = time;
    self.currentModel = nil;
    if (self.model.keyFramesArray && self.model.keyFramesArray.count != 0) {
        for (int i = 0; i < self.model.keyFramesArray.count; i++) {
            NvKeyFrameStickerModel *keyModel = self.model.keyFramesArray[i];
            if (llabs(keyModel.time - self.pos) < 300000) {
                self.currentModel = keyModel;
                self.pos = keyModel.time;
                self.indexPath = i;
            }
        }
    }
    
    if (self.currentModel) {
        self.managerFrameBtn.btnLabel.text = NvLocalString(@"Delete frame", @"删除帧");
        self.managerFrameBtn.selected = YES;
        if (end) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyFrameView:withState:withModel:)]) {
                [self.delegate keyFrameView:self withState:NvKeyFrameTypeSelected withModel:self.currentModel];
            }
        }
    }else{
        self.managerFrameBtn.btnLabel.text = NvLocalString(@"Add frame", @"添加帧");
        self.managerFrameBtn.selected = NO;
        if (end) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyFrameView:withState:withModel:)]) {
                [self.delegate keyFrameView:self withState:NvKeyFrameTypeNoSelected withModel:self.currentModel];
            }
        }
    }
    
    if (time >= self.model.inPoint && time <= self.model.outPoint) {
        self.managerFrameBtn.enabled = YES;
        self.preFrameBtn.enabled = YES;
        self.nextFrameBtn.enabled = YES;
        
        self.managerFrameBtn.alpha = 1;
        self.preFrameBtn.alpha = 1;
        self.nextFrameBtn.alpha = 1;
        
        BOOL befor = NO;
        BOOL after = NO;
        for (NSString *string in self.model.keyArray) {
            int64_t beforPos = [self.sticker findKeyframeTime:string time:self.pos-self.model.inPoint flags:NvsKeyFrameFindModeFlag_Before];
            if (beforPos != -1) {
                befor = YES;
                break;
            }
        }
        
        for (NSString *string in self.model.keyArray) {
            int64_t afterPos = [self.sticker findKeyframeTime:string time:self.pos-self.model.inPoint flags:NvsKeyFrameFindModeFlag_After];
            if (afterPos != -1) {
                after = YES;
                break;
            }
        }
        
        if (!befor) {
            self.preFrameBtn.enabled = NO;
            self.preFrameBtn.alpha = 0.5;
        }
        if (!after) {
            self.nextFrameBtn.enabled = NO;
            self.nextFrameBtn.alpha = 0.5;
        }
    }else{
        self.managerFrameBtn.enabled = NO;
        self.preFrameBtn.enabled = NO;
        self.nextFrameBtn.enabled = NO;
        self.managerFrameBtn.alpha = 0.5;
        self.preFrameBtn.alpha = 0.5;
        self.nextFrameBtn.alpha = 0.5;
    }
}

#pragma mark 禁止操作 Forbidden operation
- (void)prohibitOperation{
    self.managerFrameBtn.enabled = NO;
    self.preFrameBtn.enabled = NO;
    self.nextFrameBtn.enabled = NO;
    self.managerFrameBtn.alpha = 0.5;
    self.preFrameBtn.alpha = 0.5;
    self.nextFrameBtn.alpha = 0.5;
}

#pragma mark 添加关键帧 Add keyframe
- (void)addKey:(int64_t)pos{
    self.pos = pos;
    self.currentModel = nil;
    [self managerButtonClicked:self.managerFrameBtn];
}

#pragma mark finshClick——完成按钮点击
- (void)finshClick:(UIButton *)button {
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyFrameViewFinsh:)]) {
        [self.delegate keyFrameViewFinsh:self];
    }
}

#pragma mark - 点击关键帧按钮方法 Click the keyframe button method
- (void)managerButtonClicked:(UIButton *)sender {
    NvKeyFrameType type = NvKeyFrameTypeAdd;
    if (self.currentModel) {
        ///删除
        ///delete
        type = NvKeyFrameTypeDelete;
        if (self.model.keyFramesArray && self.model.keyFramesArray.count != 0 && self.currentModel) {
            self.deletePos = self.currentModel.pos;
            [self.model.keyFramesArray removeObject:self.currentModel];
            self.currentModel = nil;
        }
    }else{
        ///添加
        ///add
        if (!self.model.keyFramesArray) {
            self.model.keyFramesArray = [NSMutableArray array];
        }
        NvKeyFrameStickerModel *keyModel = [[NvKeyFrameStickerModel alloc]init];
        keyModel.time = self.pos;
        keyModel.pos = self.pos - self.model.inPoint;
        [self.model.keyFramesArray addObject:keyModel];
        self.currentModel = keyModel;
        self.indexPath = [self.model.keyFramesArray indexOfObject:keyModel];
        self.managerFrameBtn.btnLabel.text = NvLocalString(@"Delete frame", @"删除帧");
        self.managerFrameBtn.selected = YES;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyFrameView:withState:withModel:)]) {
        [self.delegate keyFrameView:self withState:type withModel:self.currentModel];
    }
}

#pragma mark - 下一帧 Next frame
- (void)nextFrameBtnClicked:(UIButton *)sender {
    BOOL after = NO;
    int64_t tempPos = self.pos - self.model.inPoint;
    int64_t tempPos_1 = 0;
    int64_t tempPos_2 = 0;
    for (NSString *string in self.model.keyArray) {
        tempPos_1 = [self.sticker findKeyframeTime:string time:tempPos flags:NvsKeyFrameFindModeFlag_After];
        if (tempPos_1 != -1) {
            after = YES;
            [self configTime:tempPos_1+self.model.inPoint withEnd:YES];
            break;
        }
    }
    
    if (after) {
        after = NO;
        for (NSString *string in self.model.keyArray) {
            tempPos_2 = [self.sticker findKeyframeTime:string time:tempPos_1 flags:NvsKeyFrameFindModeFlag_After];
            if (tempPos_2 != -1) {
                after = YES;
                break;
            }
        }
    }
    
    sender.enabled = after?YES:NO;
    sender.alpha = after?1:0.5;
    
    self.preFrameBtn.enabled = YES;
    self.preFrameBtn.alpha = 1;
}

#pragma mark - 上一帧 Previous frame
- (void)preFrameBtnClicked:(UIButton *)sender {
    BOOL before = NO;
    int64_t tempPos = self.pos - self.model.inPoint;
    int64_t tempPos_1 = 0;
    int64_t tempPos_2 = 0;
    
    for (NSString *string in self.model.keyArray) {
        tempPos_1 = [self.sticker findKeyframeTime:string time:tempPos flags:NvsKeyFrameFindModeFlag_Before];
        if (tempPos_1 != -1) {
            before = YES;
            [self configTime:tempPos_1+self.model.inPoint withEnd:YES];
            break;
        }
    }
    
    if (before) {
        before = NO;
        for (NSString *string in self.model.keyArray) {
            tempPos_2 = [self.sticker findKeyframeTime:string time:tempPos_1 flags:NvsKeyFrameFindModeFlag_Before];
            if (tempPos_2 != -1) {
                before = YES;
                break;
            }
        }
    }
    
    sender.enabled = before?YES:NO;
    sender.alpha = before?1:0.5;
    
    self.nextFrameBtn.enabled = YES;
    self.nextFrameBtn.alpha = 1;
}

@end
