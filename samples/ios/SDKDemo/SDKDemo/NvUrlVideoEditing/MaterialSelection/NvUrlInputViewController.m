//
//  NvUrlInputViewController.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/3.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvUrlInputViewController.h"
#import "NvUrlInputTVCell.h"
//键盘类
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "NvAudioPlayerView.h"
#import "NvAudioPlayer.h"
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvUrlInputViewController () <UITableViewDelegate, UITableViewDataSource, NvUrlInputTVCellDelegate, NvAudioPlayerViewDelegate, NvAudioPlayerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *editView;

@property (nonatomic, strong) NvUrlInputMaterialModel *currentModel;

@property (nonatomic, strong) UIButton *delateButton;

@property (nonatomic, strong) NvAudioPlayerView *audioPlayerView;
@property (nonatomic, strong) NvAudioPlayer *audioPlayer;
@property (nonatomic, strong) NvEditSelectMusicItem *musicItem;

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@end

@implementation NvUrlInputViewController

-(void)dealloc {
    if (self.isMusicEdit) {
        [self.audioPlayerView removeObserver:self forKeyPath:@"hidden"];
        [self.audioPlayer pause];
        self.audioPlayer = nil;
    }
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#181818"];
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = NvLocalString(@"urlEditing_home_input_close", nil);
    [self addSubViews];
    [self configData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.view endEditing:YES];
    if (self.isMusicEdit) {
        self.audioPlayerView.hidden = true;
    }
}

- (void)addSubViews{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[NvUrlInputTVCell class] forCellReuseIdentifier:@"NvUrlInputTVCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0 * SCREENSCALE);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, INDICATOR+50*SCREENSCALE, 0);
    
    if (self.isMusicEdit){
        [self.view addSubview:self.audioPlayerView];
        self.audioPlayerView.delegate = self;
        
        self.audioPlayerView.hidden = YES;
        self.audioPlayer = [[NvAudioPlayer alloc] init];
        self.audioPlayer.delegate = self;
        [self.audioPlayerView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)configData {
    self.dataArray = [NSMutableArray array];
    NvUrlInputMaterialModel *model = [[NvUrlInputMaterialModel alloc] init];
    model.index = 0;
    [self.dataArray addObject:model];
}

- (void)removeSelect {
    for (NvUrlInputMaterialModel *info in self.dataArray) {
        info.urlString = @"";
        info.image = nil;
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NvUrlInputMaterialModel *model = self.dataArray[indexPath.row];
    if (model.image) {
        return 66 * SCREENSCALE + 16 * SCREENSCALE;
    }
    return 30 * SCREENSCALE + 16 * SCREENSCALE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NvUrlInputTVCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NvUrlInputTVCell" forIndexPath:indexPath];
    cell.delegate = self;
    if (self.isMusicEdit) {
        [cell renderMusicCellWithItem:self.dataArray[indexPath.row]];
    } else {
        [cell renderCellWithItem:self.dataArray[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma makr - NvUrlVideoMaterialTVCellDelegate
- (void)editClick:(NvUrlInputMaterialModel *)item {
    if (self.isMusicEdit) {
        [self selectMusicEdit:item];
    } else {
        if (!self.editView) {
            self.editView = [[UIView alloc] init];
            self.editView.backgroundColor = UIColor.blackColor;
            self.editView.hidden = YES;
            [self.view addSubview:self.editView];
            [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.view);
                make.height.offset(100 * SCREENSCALE + INDICATOR);
            }];
            
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
            addButton.titleLabel.font = [NvUtils regularFontWithSize:13];
            addButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15* SCREENSCALE, 0, 0);
            [addButton setTitle:NvLocalString(@"urlEditing_home_addUrl", nil) forState:UIControlStateNormal];
            [addButton setImage:NvImageNamed(@"NvUrlEdit_addUrl") forState:UIControlStateNormal];
            [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [self.editView addSubview:addButton];
            [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.editView).offset(20 * SCREENSCALE);
                make.left.equalTo(self.editView).offset(20 * SCREENSCALE);
                make.width.offset(100 * SCREENSCALE);
                make.height.offset(25 * SCREENSCALE);
            }];
            
            self.delateButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.delateButton.titleLabel.font = [NvUtils regularFontWithSize:13];
            self.delateButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15* SCREENSCALE, 0, 0);
            [self.delateButton setTitle:NvLocalString(@"urlEditing_home_delateUrl", nil) forState:UIControlStateNormal];
            [self.delateButton setImage:NvImageNamed(@"NvUrlEdit_deleteUrl") forState:UIControlStateNormal];
            [self.delateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.delateButton addTarget:self action:@selector(delateButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [self.editView addSubview:self.delateButton];
            [self.delateButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(addButton.mas_bottom).offset(20 * SCREENSCALE);
                make.left.equalTo(self.editView).offset(8 * SCREENSCALE);
                make.width.offset(100 * SCREENSCALE);
                make.height.offset(25 * SCREENSCALE);
            }];
        }
        
        self.delateButton.userInteractionEnabled = item.index == 0 ? NO : YES;
        self.delateButton.alpha = item.index == 0 ? 0.5 : 1;
        self.currentModel = item;
        self.editView.hidden = !self.editView.hidden;
        if (self.delegate && [self.delegate respondsToSelector:@selector(hideEdit)]) {
            [self.delegate hideEdit];
        }
    }
    
    [self.view endEditing:YES];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"hidden"]) {
        BOOL hidden = [change[NSKeyValueChangeNewKey] boolValue];
        if (hidden) {
            [self.audioPlayer pause];
        } else {
            [self.audioPlayer play];
            [self.audioPlayerView renderViewWithItem:self.musicItem];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)selectMusicEdit:(NvUrlInputMaterialModel *)info{
    __weak typeof(self)weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (info && info.urlString.length > 0) {
            [NvToast showLoading];
        }
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableString *error = [NSMutableString string];
            BOOL continueState = false;
            if (info && info.urlString.length > 0 && weakSelf.audioPlayerView.hidden) {
                NvsAVFileInfo *fileinfo = [weakSelf.streamingContext getAVFileInfo:info.urlString extraFlag:0 withError:error];
                if (fileinfo && error.length == 0) {
                    continueState = true;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (info && info.urlString.length > 0) {
                    [NvToast dismiss];
                    if (!continueState && error.length > 0) {
                        [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_urlError", nil)];
                    }
                    if (weakSelf.audioPlayerView.hidden && continueState) {
                        weakSelf.musicItem = [[NvEditSelectMusicItem alloc] init];
                        weakSelf.musicItem.musicPath = info.urlString;
                        weakSelf.musicItem.isPlay = true;
                        weakSelf.musicItem.coverUrl = @"";
                        
                        
                        [weakSelf.audioPlayer setUrlString:weakSelf.musicItem.musicPath];
                        [weakSelf.audioPlayerView setLeftValue:0 rightValue:100];
                        
                        weakSelf.musicItem.duration = weakSelf.audioPlayer.duration;
                        weakSelf.audioPlayerView.hidden = NO;
                        weakSelf.trimIn = 0;
                        weakSelf.trimOut = self.audioPlayer.duration;
                        
                    } else {
                        weakSelf.audioPlayerView.hidden = YES;
                        weakSelf.trimIn = 0;
                        weakSelf.trimOut = 0;
                    }
                }else {
                    weakSelf.musicItem = nil;
                    weakSelf.audioPlayerView.hidden = YES;
                }
            });
        });
    });
}

- (BOOL)hideControl {
    if (self.editView) {
        return !self.editView.hidden;
    }
    return NO;
}

- (void)addButtonClick {
    NvUrlInputMaterialModel *model = [[NvUrlInputMaterialModel alloc] init];
    model.index = 1;
    [self.dataArray addObject:model];
    [self.tableView reloadData];
    self.editView.hidden = YES;
}

- (void)delateButtonClick{
    if (self.currentModel) {
        self.editView.hidden = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(hideEdit)]) {
            [self.delegate hideEdit];
        }
        [self.dataArray removeObject:self.currentModel];
        self.currentModel = nil;
        [self inputEndEditing:self.currentModel];
    }
}

- (void)inputBeginEditing:(NvUrlInputMaterialModel *)model {
    if (self.isMusicEdit) {
        self.audioPlayerView.hidden = YES;
        self.trimIn = 0;
        self.trimOut = 0;
    } else {
        self.editView.hidden = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(hideEdit)]) {
            [self.delegate hideEdit];
        }
    }
}

- (void)inputEndEditing:(NvUrlInputMaterialModel *)model {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isMusicEdit) {
            if (model.urlString.length > 0) {
                NSURL *url = [NSURL URLWithString:model.urlString];
                if (url && ([url.absoluteString hasPrefix:@"http"] || [url.absoluteString hasPrefix:@"https"])) {
                    model.image = [self getImage:model.urlString];
                } else {
                    model.image = nil;
                    [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_urlError", nil)];
                }
            } else {
                model.image = nil;
            }
            
            [self.tableView reloadData];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeInputData)]) {
            [self.delegate changeInputData];
        }
    });
}

#pragma mark - NvAudioPlayerDelegate
///当前播放的位置
///The current playing position
- (void)nvAudioPlayer:(NvAudioPlayer *)player currentTime:(double)currentTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audioPlayerView.currentValue = currentTime;
        if (currentTime>self.trimOut) {
            [self.audioPlayer seekToTime:self.trimIn];
        }
    });
}
///播放到末尾
///Play to the end
- (void)nvAudioPlayerPlayEOF:(NvAudioPlayer *)player {
    [self.audioPlayer seekToTime:self.trimIn];
    [self.audioPlayer play];
}

#pragma mark - NvAudioPlayerViewDelegate
///裁剪时拖动左滑块
///Drag the left slider while cropping
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView leftValueChanged:(float)value {
    [self.audioPlayer seekToTime:value];
    if (self.trimOut == 0) {
        self.trimOut = self.musicItem.duration;
    }
    self.trimIn = value;
    [self.audioPlayer play];
}
///裁剪时拖动右滑块
///Drag the right slider while cropping
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView rightValueChanged:(float)value {
    self.trimOut = value;
    NSLog(@"%f",value);
}

- (void)audioPlayerViewPlayClick:(NvAudioPlayerView *)audioPlayerView withPlay:(BOOL)state{
    if (state) {
        [self.audioPlayer play];
    } else {
        [self.audioPlayer pause];
    }
}

- (void)audioPlayerViewImport{
    self.audioPlayerView.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicInputImport)]) {
        [self.delegate musicInputImport];
    }
}


#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear{
    
}

-(UIImage *)getImage:(NSString *)videoURL{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(6.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

-(NvAudioPlayerView *)audioPlayerView {
    if (!_audioPlayerView) {
        _audioPlayerView = [[NvAudioPlayerView alloc] initUrlViewWithFrame:CGRectMake(0, self.view.frame.size.height - (200 * SCREENSCALE + INDICATOR), self.view.frame.size.width, 200 * SCREENSCALE + INDICATOR)];
        _audioPlayerView.backgroundColor = UIColor.blackColor;
    }
    return _audioPlayerView;
}

@end
