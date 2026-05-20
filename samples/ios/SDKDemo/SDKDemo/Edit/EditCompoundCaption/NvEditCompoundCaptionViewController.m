//
//  NvEditCompoundCaptionViewController.m
//  SDKDemo
//  复合字幕界面 Composite captioning interface
//  Created by MS on 2019/5/14.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvEditCompoundCaptionViewController.h"
#import "NvAddCompoundCaptionView.h"
#import "NvRectView.h"
#import "NvsTimelineCompoundCaption.h"
#import "NvTimelineData.h"
#import "NvTimelineUtils.h"
#import "NvCompoundTimeSpanInfoModel.h"
#import "NvCompoundCaptionStyleView.h"
#import "NvCaptionDialog.h"
#import "NvCaptionStyleItem.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvAsset.h>
#import "NvMoreFilterViewController.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvCaptionDialogViewController.h"
#import "NvModifyCompoundCaptionViewController.h"
#import "NvCompoundCaptionAdjustmentView.h"
#import <math.h>

@interface NvEditCompoundCaptionViewController ()<NvAddCompoundCaptionViewDelegate, NvRectViewDelegate,NvLiveWindowPanelViewDelegate,NvsStreamingContextDelegate,NvAssetManagerDelegate,NvCompoundCaptionStyleViewDelegate,NvCompoundCaptionAdjustmentViewDelegate>

@property (nonatomic, strong) NvAddCompoundCaptionView *addCaptionView;
@property (nonatomic, strong) NvRectView *rectView;
@property (nonatomic, strong) NvsTimelineCompoundCaption *currentCaption;

@property (nonatomic, strong) NvCompoundCaptionAdjustmentView *adjustmentView;
@property (nonatomic, strong) NSMutableArray <NvCompoundTimeSpanInfoModel *>*timeSpanArray;
///字幕数据 Subtitle data
@property (nonatomic, strong) NSMutableArray <NvCompoundCaptionInfoModel *>*captionInfoArray;
@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NSMutableArray *styleDataSource;
///是否是样式模式
///Style or not pattern
@property (nonatomic, assign) BOOL isStyleModel;
///当前字幕是否是被选中(用于区分是否需要弹框)
///Whether the current subtitle is selected (to distinguish whether a box is needed)
@property (nonatomic, assign) BOOL isSelect;
///是否有info里误写有但实际上却没有的情况
///Is there a case where it is incorrectly listed in info but is not actually there
@property (nonatomic, assign) BOOL isStyleNone;
///字体列表
///Font list
@property (nonatomic, strong) NSMutableArray *fontDataSource;
///是否有在线资源列表
///Whether there is an online resource list
@property (nonatomic, assign) BOOL isHaveList;
///点击修改的子字幕index
///Click on the modified subtitle index
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation NvEditCompoundCaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedIndex = -1;
    self.title = NvLocalString(@"CompoundCaption", @"组合字幕");
    self.timeSpanArray = [NSMutableArray array];
    self.styleDataSource = [NSMutableArray array];
    self.fontDataSource = [NSMutableArray array];
    [self initTimeline];
    [self initSubViews];
    [self.liveWindowPanel setForceHiddenControlPanel:YES];
    self.liveWindowPanel.delegate = self;
    [self addObserver:self forKeyPath:@"currentCaption" options:NSKeyValueObservingOptionNew context:nil];
    [self preCheckoutAssetInfo];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    [self searchFonts];
}

///设置默认数据
///Set default data
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.assetManager.delegate = self;
    [self getStyleDefaultData];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.adjustmentView.compoundStyleView renderListWithItems:weakSelf.styleDataSource];
    });
}

///预先查询复合字幕样式、字体信息
///Query compound title style and font information in advance
- (void)preCheckoutAssetInfo {
    ///初始化assetManager
    ///Initialize the assetManager
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    ///查询用户在指定目录下添加的素材或下载的素材
    ///Initializes assetManager to query materials added or downloaded by the user in a specified directory
    [self.assetManager searchLocalAssets:ASSET_COMPOUND_CAPTION];
    ///查询代码中内置素材
    ///Query code in the built-in material
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"compoundCaptionPackage" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_COMPOUND_CAPTION bundlePath:itemPath];
    
    ///查询字体信息
    ///Querying Font Information
    [self.assetManager searchLocalAssets:ASSET_FONT];
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"fontPackage" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FONT bundlePath:fontPath];
}

///获取字幕样式、字体默认数据
///Gets subtitles style and font default data
- (void)getStyleDefaultData {
    
    AspectRatio ratio;
    switch (self.editMode) {
        case NvEditMode16v9:
            ratio = AspectRatio_16v9;
            break;
        case NvEditMode1v1:
            ratio = AspectRatio_1v1;
            break;
        case NvEditMode9v16:
            ratio = AspectRatio_9v16;
            break;
        case NvEditMode3v4:
            ratio = AspectRatio_3v4;
            break;
        case NvEditMode4v3:
            ratio = AspectRatio_4v3;
            break;
        default:
            ratio = AspectRatio_All;
            break;
    }
    
    ///获取复合字幕
    ///Get composite subtitles
    NSArray *innerArray = [self.assetManager getUsableAssets:ASSET_COMPOUND_CAPTION aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    [self.styleDataSource removeAllObjects];
    
    NSString *compoundPlist =[[[NSBundle mainBundle] pathForResource:@"compoundCaptionPackage" ofType:@"bundle"] stringByAppendingPathComponent:@"NvCompoundCaption.plist"];
    NSDictionary *defaultCmpCaption = [[NSDictionary alloc] initWithContentsOfFile:compoundPlist];
    for (NvAsset *asset in innerArray) {
        if ([self isCompoundCaptionExist:asset.uuid]) {
            continue;
        }
        if ([asset isReserved]) {
            NvCaptionStyleItem *item = [NvCaptionStyleItem new];
            item.imageUrl = asset.coverUrl;
            item.name = NvLocalString(defaultCmpCaption[asset.uuid], nil) ;
            item.packageId = asset.uuid;
            item.isAdjusted = asset.isAdjusted;
            [self.styleDataSource addObject:item];
        }else{
            NvCaptionStyleItem *item = [NvCaptionStyleItem new];
            item.imageUrl = asset.coverUrl;
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                item.name = asset.displayNamezhCN;
            }else{
                item.name = asset.displayName;
            }
            item.isAdjusted = asset.isAdjusted;
            item.packageId = asset.uuid;
            [self.styleDataSource insertObject:item atIndex:0];
        }
    }

}
- (void)searchFonts {
    self.fontDataSource = [NSMutableArray array];
    [self.assetManager searchLocalAssets:ASSET_FONT];
    
    [self.assetManager downloadRemoteAssetsInfo:ASSET_FONT categoryId:1 page:1 pageSize:20 kind:1 modular:NvAssetModularAll ratioFlag:0 ratio:AspectRatio_All sdkVerskon:[NvSDKUtils getSdkVersion]];
}

- (BOOL)isCompoundCaptionExist:(NSString *)uuid {
    for (NvCaptionStyleItem *item in _styleDataSource) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}

///重新创建timeline和数据结构
///Re-create the timeline and data structure
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
    NvTimelineData *data = [NvTimelineData sharedInstance];
    self.captionInfoArray = [[NSMutableArray alloc] initWithArray:[data compoundCaptionDataArray] copyItems:YES];
    [NvTimelineUtils resetCompoundCaption:self.timeline captionDataArray:self.captionInfoArray];
    
}

#pragma mark - initSubviews
- (void)initSubViews {
    [self.liveWindowPanel.liveWindow addSubview:self.rectView];
    [self.rectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.rectView.hidden = YES;
    [self.view addSubview:self.addCaptionView];
    [self.addCaptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(SCREENWIDTH));
        make.left.right.bottom.equalTo(@0);
        make.height.equalTo(@(250*SCREENSCALE + INDICATOR));
    }];
    ///显示时间
    ///Display time
    [self.addCaptionView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    
    ///恢复数据
    ///Recover data
    NvsTimelineCompoundCaption *nextCaption = [self.timeline getFirstCompoundCaption];
    self.currentCaption = nextCaption;
    do {
        NvsCTimelineTimeSpan *timeSpan = [self.addCaptionView.timelineEditor addTimeSpan:nextCaption.inPoint outPoint:nextCaption.outPoint];
        [self.addCaptionView.timelineEditor selectTimeSpan:timeSpan];
        
        ///存储一个infoModel对象用于使timelineEditor高亮
        ///Stores an infoModel object for highlighting the timelineEditor
        NvCompoundTimeSpanInfoModel *infoModel = [NvCompoundTimeSpanInfoModel new];
        infoModel.currentCaption = nextCaption;
        infoModel.infoModel =  [self getCaptionInfoModel:nextCaption];
        infoModel.timeSpan = timeSpan;
        if (nextCaption) {
            [self.timeSpanArray addObject:infoModel];
        }
        nextCaption = [self.timeline getNextCompoundCaption:nextCaption];
    } while (nextCaption);
    self.currentCaption = [[self.timeline getCompoundCaptionsByTimelinePosition:0] firstObject];
    if (self.currentCaption) {
        self.isSelect = YES;
        NvCompoundTimeSpanInfoModel  *infoModel = [self getCurrentTimeSpan:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:infoModel.timeSpan];
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.rectView.hidden = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf updateCaptionView:weakSelf.currentCaption];
            });
            weakSelf.addCaptionView.styleButton.hidden = NO;
        });

    } else {
        self.rectView.hidden = YES;
        self.addCaptionView.styleButton.hidden = YES;
        [self.addCaptionView.timelineEditor selectTimeSpan:nil];
    }
    
    self.adjustmentView = [NvCompoundCaptionAdjustmentView new];
    self.adjustmentView.compoundStyleView.delegate = self;
    self.adjustmentView.selectedIndex = -1;
    self.adjustmentView.delegate = self;
    self.adjustmentView.timeline = self.timeline;
    [self.view addSubview:self.adjustmentView];
    [self.adjustmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.addCaptionView);
    }];
    self.adjustmentView.hidden = YES;
}

///给试图设置默认数据
///Set default data for the attempt
- (void)setViewDefaultData:(NvsTimelineCompoundCaption *)currentCaption {
        [self getStyleDefaultData];
}

/**
 获取当前字幕的NvCompoundTimeSpanInfoModel
 Gets the current NvCompoundTimeSpanInfoModel subtitles
 
 @param currentCaption 当前字幕信息 Current subtitle information
 @return 当前字幕的NvCompoundTimeSpanInfoModel The current NvCompoundTimeSpanInfoModel subtitles
 */
- (NvCompoundTimeSpanInfoModel *)getCurrentTimeSpan:(NvsTimelineCompoundCaption *)currentCaption {
    NvCompoundTimeSpanInfoModel *infoModel = nil;
    for (int i = 0; i < self.timeSpanArray.count; i++) {
        infoModel = self.timeSpanArray[i];
        if (infoModel.currentCaption == self.currentCaption) {
            return infoModel;
        }
    }
    return infoModel;
}

///获取字幕对应的infoModel对象
///Obtain the infoModel object corresponding to the subtitle
- (NvCompoundCaptionInfoModel *)getCaptionInfoModel:(NvsTimelineCompoundCaption *) nextCaption {
    return (NvCompoundCaptionInfoModel *)[nextCaption getAttachment:@"compoundInfoModel"];
}

#pragma mark - 重现显示字幕及选中框 Show the subtitles and check box again
- (void)showCaption {
    if (self.currentCaption == nil) {
        self.rectView.hidden = YES;
        return;
    }
    self.rectView.hidden = NO;
    [self updateCaptionView:self.currentCaption];
}

///更新字幕框的位置
///Update the location of the subtitle box
- (void)updateCaptionView: (NvsTimelineCompoundCaption*) caption {
    NSArray *array = [caption getCompoundBoundingVertices:NvsBoundingType_Text];
 
    NSArray *captionArr = [self changeModifiableInternalCaptionsWithCaption:caption];
    [self.rectView changeModifiableInternalCaptionsWithPoints:captionArr];

    ///将外围边框变大
    ///Make the perimeter border larger
    [self enlargeVerticesWithArray:array];
    [self seekTimeline];
    
}

///将字幕框外围边框变大
///Make the surrounding border of the subtitle box larger
- (void)enlargeVerticesWithArray:(NSArray *)array {
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightBottomValue = array[2];
    NSValue *rightTopValue = array[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];
    
    topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
    rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
    bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
    rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];

    CGPoint centerPointer = CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
    CGFloat newAngle = atan2f(topLeftCorner.y - centerPointer.y, topLeftCorner.x - centerPointer.x);
    CGFloat leftTopDistance = [self distanceWithFirst:topLeftCorner second:centerPointer];
    leftTopDistance = leftTopDistance*1.1;
    topLeftCorner.y = sinf(newAngle)*leftTopDistance + centerPointer.y;
    topLeftCorner.x = cosf(newAngle)*leftTopDistance + centerPointer.x;

    newAngle = atan2f(bottomLeftCorner.y - centerPointer.y, bottomLeftCorner.x - centerPointer.x);
    bottomLeftCorner.y = sinf(newAngle)*leftTopDistance + centerPointer.y;
    bottomLeftCorner.x = cosf(newAngle)*leftTopDistance + centerPointer.x;

    newAngle = atan2f(rightBottomCorner.y - centerPointer.y, rightBottomCorner.x - centerPointer.x);
    rightBottomCorner.y = sinf(newAngle)*leftTopDistance + centerPointer.y;
    rightBottomCorner.x = cosf(newAngle)*leftTopDistance + centerPointer.x;

    newAngle = atan2f(rightTopCorner.y - centerPointer.y, rightTopCorner.x - centerPointer.x);
    rightTopCorner.y = sinf(newAngle)*leftTopDistance + centerPointer.y;
    rightTopCorner.x = cosf(newAngle)*leftTopDistance + centerPointer.x;
    
    [self.rectView setPoints:@[[NSValue valueWithCGPoint:topLeftCorner],[NSValue valueWithCGPoint:bottomLeftCorner],[NSValue valueWithCGPoint:rightBottomCorner],[NSValue valueWithCGPoint:rightTopCorner]]];
}

///获取两点之间距离
///Get the distance between two points
- (CGFloat)distanceWithFirst:(CGPoint)first second:(CGPoint)second {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
};


- (void)updateCaptionViewNOSeek:(NvsTimelineCompoundCaption*) caption {
    NSArray *array = [caption getCompoundBoundingVertices:NvsBoundingType_Text];
    NSArray *captionArr = [self changeModifiableInternalCaptionsWithCaption:caption];
    [self.rectView changeModifiableInternalCaptionsWithPoints:captionArr];
    ///将外围边框变大
    ///Make the perimeter border larger
    [self enlargeVerticesWithArray:array];
}

///根据字幕四周顶点计算出其中心点位置（视频坐标系中）
///Calculate the position of the center point according to the vertices around the subtitles (in the video coordinate system)
- (CGPoint)getCenterWithArray:(NSArray*)array {
    NSValue *leftTopValue = array[0];
    NSValue *rightBottomValue = array[2];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    return CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
}

///可修改字幕重新绘制边框--获取全部子字幕的顶点数组
///Modifiable subtitle redraw border -- Gets an array of vertices for all subtitles
- (NSArray *)changeModifiableInternalCaptionsWithCaption:(NvsTimelineCompoundCaption *)caption {

    NSMutableArray *captionArr = [NSMutableArray array];
    NSInteger count = caption.captionCount;
    for (int i=0; i<count; i++) {
        NSArray *pointArr = [caption getCaptionBoundingVertices:i boundingType:NvsBoundingType_Text];
        NSArray *subArr = [self changeModifiableSingleCaptionWithPoints:pointArr];
        if (subArr.count == 4) {
            [captionArr addObject:subArr];
        }
    }
    return [captionArr copy];
}

///单个子字幕重新绘制边框--获取单个字幕在rectview中的四个顶点
///Single subtitle redraws border - Gets the four vertices of a single subtitle in rectview
- (NSArray *)changeModifiableSingleCaptionWithPoints:(NSArray *)points {
    NSMutableArray *pointArr = [NSMutableArray array];
    for (int i=0; i<points.count; i++) {
        NSValue *value = points[i];
        CGPoint point = [value CGPointValue];
        point = [self.liveWindowPanel.liveWindow mapCanonicalToView:point];
        CGPoint finalPoint = [self.liveWindowPanel.liveWindow convertPoint:point toView:self.rectView];
        [pointArr addObject:[NSValue valueWithCGPoint:finalPoint]];
    }
    if (pointArr.count == 4) {
        return [pointArr copy];
    }
    return nil;
}

///获取点击点是否在一个范围内--其中两者在一个坐标系下，不用转换坐标系
///Gets whether the click point is in a range where the two are in the same frame without converting the frame
- (bool)pointIsInFrame:(CGPoint)point vertices:(NSArray *)vertices {
    NSValue *leftTopValue = vertices[0];
    NSValue *leftBottomValue = vertices[1];
    NSValue *rightBottomValue = vertices[2];
    NSValue *rightTopValue = vertices[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];
    CGMutablePathRef pathRef=CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
    CGPathCloseSubpath(pathRef);
    bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
    return isIn;
}

///删除当前caption
///Delete current caption
- (void)deleteCurrentCaption {
    ///获取数据删除timelineEditor框
    ///Get data to delete the timelineEditor box
    NvCompoundTimeSpanInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
    NvCompoundCaptionInfoModel *currentModel = [self getCaptionInfoModel:self.currentCaption];
    [self.addCaptionView.timelineEditor selectTimeSpan:modelInfo.timeSpan];
    [self.addCaptionView.timelineEditor deleteSelectedTimeSpan];
    ///删除字幕
    ///Delete subtitles
    [self.timeline removeCompoundCaption:self.currentCaption];
    ///删除数据
    ///Delete data
    [self.captionInfoArray removeObject:currentModel];
    [self.timeSpanArray removeObject:modelInfo];
}

#pragma mark - NvAddCaptionViewDelegate
- (void)nvAddCaptionViewdidAddCaptionClick {
    ///距离末尾小于1秒时不加字幕
    ///No subtitles are added when the distance is less than 1 second from the end
    if (self.timeline.duration-[self.streamingContext getTimelineCurrentPosition:self.timeline] < 1000000) {
        [NvToast showInfoWithMessage:NvLocalString(@"Add caption restrictions", @"距离末尾小于1秒时不加字幕")];
        return;
    }
    
    ///这里是点击添加按钮进入选择组合字幕界面
    ///Here, click the Add button to enter the interface of selecting combined subtitles
    [self.streamingContext stop];
    self.isStyleModel = NO;
    [self.streamingContext stop];
    self.adjustmentView.hidden = NO;
    
    [self setViewDefaultData:self.currentCaption];
}

///点击修改按钮
///Click the Modify button
- (void)nvAddCaptionViewdidAddStyleClick {
    [self.streamingContext stop];
    self.selectedIndex = -1;
    self.adjustmentView.hidden = NO;
    self.adjustmentView.currentCaption = self.currentCaption;
    self.adjustmentView.captionInfo = [self getCaptionInfoModel:self.currentCaption];
    self.adjustmentView.selectedIndex =  -1;
    [self refreshAdjustmentView];
    self.isStyleModel = YES;
    self.isSelect = YES;
}

///返回按钮事件,完成按钮
///Return button event, complete button
- (void)nvAddCaptionViewdidAddOkClick {
    [self.streamingContext removeTimeline:self.timeline];
    NvTimelineData *data = [NvTimelineData sharedInstance];
    data.compoundCaptionDataArray = self.captionInfoArray;
    NSMutableArray *order = [[NvTimelineData sharedInstance] dataOrder];
    [order removeObject:@"CompoundCaption"];
    [order addObject:@"CompoundCaption"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshAdjustmentView {
    self.adjustmentView.fontDataSource = [NSMutableArray arrayWithArray:self.fontDataSource];
    [self.adjustmentView refreshAdjustView];
}

///放大timelineEditor
///Enlarge the timelineEditor
- (void)captionTimelineEditorZoomIn {
    [self.addCaptionView.timelineEditor zoomIn];
    [self.addCaptionView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
}

///缩小timelineEditor
///Zoom out the timelineEditor
- (void)captionTimelineEditorZoomOut {
    [self.addCaptionView.timelineEditor zoomOut];
    [self.addCaptionView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
}

///拖拽timelineEditor回调
///Drag and drop the timelineEditor callback
- (void)dragTimelineEditor:(int64_t)timestamp {
    self.liveWindowPanel.progressSlider.value = 1.0*timestamp/self.timeline.duration;
    self.liveWindowPanel.currentTime = timestamp;
    self.rectView.hidden = YES;
    ///拖动过程中显示时间
    ///Show the time while dragging
    [self.addCaptionView setcurrentTime:timestamp];
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [self.addCaptionView.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    [self seekTimeline:timestamp];
    
}

///拖拽timelineEditor结束回调
///Drag and drop timelineEditor to end the callback
- (void)dragScrollTimelineEnded:(int64_t)timestamp {
    NvCompoundTimeSpanInfoModel *model = [self getCurrentTimeSpan:self.currentCaption];
    [self.addCaptionView.timelineEditor selectTimeSpan:model.timeSpan];
    self.currentCaption = [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
    self.rectView.hidden = self.currentCaption?NO:YES;
    
    if (self.currentCaption) {
        [self updateCaptionViewNOSeek:self.currentCaption];
        NvCompoundTimeSpanInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:modelInfo.timeSpan];
    } else {
        [self.addCaptionView.timelineEditor selectTimeSpan:nil];
    }
    self.isChange = NO;
    [self seekTimelineWithoutFlag];
}

///timespan滑块拖拽过程中
///timespan slider during drag
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
    ///更改出入点
    ///Change access point
     NvCompoundTimeSpanInfoModel *model = [self getCurrentTimeSpan:self.currentCaption];
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [self.addCaptionView.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    if (isInPoint) {
        model.infoModel.inPoint = timestamp;
        [self seekTimelineWithoutFlag:timestamp];
        ///播放过程中显示时间
        ///The time is displayed during playback
        [self.addCaptionView setcurrentTime:timestamp];
    } else {
        model.infoModel.outPoint = timestamp;
        [self seekTimelineWithoutFlag:timestamp-10000];
        ///播放过程中显示时间
        ///The time is displayed during playback
        [self.addCaptionView setcurrentTime:timestamp-10000];
    }
    
}


///timespan滑块拖拽结束
///The timespan slider drag is over
- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint {
    self.isChange = NO;
    [self.addCaptionView.timelineEditor setTimelinePosition:timestamp];
    NvCompoundTimeSpanInfoModel *modelnext = [self getCurrentTimeSpan:self.currentCaption];
    if (self.currentCaption) {
        [self updateCaptionViewNOSeek:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:modelnext.timeSpan];
    }
    
    if (isInPoint) {
        [self.currentCaption changeInPoint:timestamp];
        [self seekTimelineWithoutFlag:timestamp];
    } else {
        [self.currentCaption changeOutPoint:timestamp];
        [self seekTimelineWithoutFlag:timestamp-10000];
    }
}

#pragma mark - NvCompoundCaptionStyleViewDelegate
///播放视频(用于选中、切换复合字幕样式即预览时播放视频)
///Play video (Used to select and toggle composite title styles to play video during preview)
- (void)stylePlay {
    self.addCaptionView.playButton.selected = YES;
    
    if (![NvTimelineUtils playbackTimeline:self.timeline startTime:self.currentCaption.inPoint endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
        NSLog(@"播放时间线失败！Failed to play timeline!");
    }else{
        NSLog(@"播放时间线成功！success to play timeline!");
    }
   
}

///添加复合字幕(预览)
///Add composite subtitles (Preview)
- (void)selectStyle:(NvCaptionStyleItem *)item isApplyToAllCaption:(BOOL)isApplyToAllCaption {
    self.selectedIndex = -1;
    self.adjustmentView.selectedIndex = -1;
    int64_t inPoint = [[NvsStreamingContext sharedInstance] getTimelineCurrentPosition:self.timeline];
    
    int64_t duration = 5000000;
    if (inPoint + duration > self.timeline.duration) {
        duration = self.timeline.duration - inPoint;
    }
   
    ///防止复合字幕样式info文件中在没有相应比例文件时误写成有相应比例文件
    ///这样会导致之前的时间入点不正确
    ///Prevents the compound subtitle style info file from being incorrectly written with a proportional file when there is no proportional file
    ///This will cause the previous entry point to be incorrect
    
    if(self.isStyleNone){
        inPoint = self.currentCaption.inPoint;
        duration = 5000000;
    }
    
    
    if (self.isStyleModel && self.currentCaption) {
        inPoint = self.currentCaption.inPoint;
        duration = self.currentCaption.outPoint - self.currentCaption.inPoint;
        [self deleteCurrentCaption];
    }
    [self.streamingContext stop];
    NvsTimelineCompoundCaption *caption = [self.timeline addCompoundCaption:inPoint duration:duration compoundCaptionPackageId:item.packageId];

    if (!caption) {
        self.isStyleNone = YES;
        self.isStyleModel = NO;
        self.isSelect = NO;
        return;
    }
    self.currentCaption = caption;
    ///添加复合字幕信息
    ///Add compound subtitle information
    NvCompoundCaptionInfoModel *captionModel = [NvCompoundCaptionInfoModel new];
    captionModel.captionCount = caption.captionCount;
    captionModel.clipAffinityEnabled = caption.clipAffinityEnabled;
    captionModel.inPoint = caption.inPoint;
    captionModel.outPoint = caption.outPoint;
    captionModel.translationOffset = [caption getCaptionTranslation];
    captionModel.rotation = [caption getRotationZ];
    captionModel.scale = [caption getScaleX];
    captionModel.packageId = item.packageId;
    captionModel.captionArr = [NSMutableArray array];
    for (int i=0; i<caption.captionCount; i++) {
        NvInnerCompoundCaptionModel *innerModel = [NvInnerCompoundCaptionModel new];
        innerModel.text = [caption getText:i];
        innerModel.index = i;
        [captionModel.captionArr addObject:innerModel];
    }
    [caption setAttachment:captionModel forKey:@"compoundInfoModel"];
    [self.captionInfoArray addObject:captionModel];
    
    NvsCTimelineTimeSpan *timeSpan = [self.addCaptionView.timelineEditor addTimeSpan:inPoint outPoint:inPoint + duration];
    [self updateCaptionViewNOSeek:self.currentCaption];
    [self seekTimeline:self.currentCaption.inPoint];
    
    ///存储一个infoModel对象用于使timelineEditor高亮
    ///Stores an infoModel object for highlighting the timelineEditor
    NvCompoundTimeSpanInfoModel *infoModel = [NvCompoundTimeSpanInfoModel new];
    infoModel.currentCaption = self.currentCaption;
    infoModel.infoModel = captionModel;
    infoModel.timeSpan = timeSpan;
    if (self.currentCaption) {
        [self.timeSpanArray addObject:infoModel];
    }
    self.isStyleModel = YES;
    self.isStyleNone = NO;
    self.adjustmentView.currentCaption = self.currentCaption;
    self.adjustmentView.captionInfo = [self getCaptionInfoModel:self.currentCaption];

    [self stylePlay];
}

///点击添加复合字幕确认按钮（字幕样式表界面下方确认按钮）
///Click the Add Composite Subtitle Confirmation button (Confirm button at the bottom of the subtitle style sheet interface)
- (void)styleOkButtonClick {
    [self.streamingContext stop];
    self.adjustmentView.hidden = YES;
    [self.addCaptionView.timelineEditor setTimelinePosition:self.currentCaption.inPoint];
    self.isStyleModel = NO;
    self.isSelect = NO;
    [self.streamingContext stop];
    self.currentCaption = [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
    self.rectView.hidden = self.currentCaption?NO:YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        NvCompoundTimeSpanInfoModel *modelnext = [self getCurrentTimeSpan:self.currentCaption];
        if (self.currentCaption) {
            [self updateCaptionView:self.currentCaption];
            [self.addCaptionView.timelineEditor selectTimeSpan:modelnext.timeSpan];
        }
    });
}

///获取更多复合字幕样式
///Get more composite title styles
- (void)moreStyleClick {
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = ASSET_COMPOUND_CAPTION;
    vc.isCapture = NO;
    vc.categoryId = NV_CATEGORY_ID_ALL;
    vc.kind = NV_KIND_ID_ALL;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NvCompoundCaptionStyleViewDelegate
- (void)moreFontClick {
    [NvToast showInfoWithMessage:NvLocalString(@"No more fonts", @"目前没有更多字体")];
}

- (void)CompoundCaptionAdjustmentViewDelegateNvseekTimeline {
    [self seekTimeline];
}
- (void)CompoundCaptionAdjustmentViewDelegatePlayTimeline:(int64_t)start end:(int64_t)end {
    ///这个地方多播放200000微妙是为了让动画播的更完整，可以看清播动画放后是什么样子
    ///This place plays 200000 more subtle in order to make the animation broadcast more complete, you can see what the animation is like after playing
    [NvTimelineUtils playbackTimeline:self.timeline startTime:start endTime:end + 200000 flags:NvsStreamingEnginePlaybackFlag_LowPipelineSize|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

///样式播放
///Style play
- (void)stylePlayFromTime:(int64_t)time {
    [self.liveWindowPanel playBackStart:time end:self.currentCaption.outPoint];
}
- (NvRectView *)getRectView {
    return self.rectView;
}

#pragma mark - NvRectViewDelegate(NvRectView回调)
///关闭字幕框
///Close subtitle box
- (void)rectView:(NvRectView*)rectView close:(UIButton*)close {
    if (self.isStyleModel) {
        self.adjustmentView.hidden = YES;
        self.isStyleModel = NO;
    }
    ///获取数据删除timelineEditor框
    ///Get data to delete the timelineEditor box
    NvCompoundTimeSpanInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
    NvCompoundCaptionInfoModel *currentModel = [self getCaptionInfoModel:self.currentCaption];
    [self.addCaptionView.timelineEditor selectTimeSpan:modelInfo.timeSpan];
    [self.addCaptionView.timelineEditor deleteSelectedTimeSpan];
    ///删除字幕
    ///Delete subtitles
    [self.timeline removeCompoundCaption:self.currentCaption];
    ///删除数据
    ///Delete data
    [self.captionInfoArray removeObject:currentModel];
    [self.timeSpanArray removeObject:modelInfo];

    self.currentCaption = [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
    if (self.currentCaption) {
        NvCompoundTimeSpanInfoModel *modelInfonext = [self getCurrentTimeSpan:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:modelInfonext.timeSpan];
        [self showCaption];
    } else {
        self.rectView.hidden = YES;
    }
    ///timeline的duration，左闭区间，右开区间，不包含最后一个时间点，所以这里要如果是末尾，时间点药前移一点
    ///The duration of the timeline, with a left closed interval and right open interval, does not include the last point in time, so if it is the end, move the time forward a little
    int64_t curentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    if (curentTime-100000 < 0) {
        curentTime = 0;
    } else {
        curentTime = curentTime-100000;
    }
    [self seekTimeline:curentTime];
    self.adjustmentView.compoundStyleView.currentItem.isSelect =NO;
    [self.adjustmentView.compoundStyleView reloadData];
}

///旋转、放大缩小字幕框
///Rotate, zoom in and out of the subtitle box
- (void)rectView:(NvRectView*)rectView rotate:(float)rotate scale:(float)scale {
    NSArray *vertices = [self.currentCaption getCompoundBoundingVertices:NvsBoundingType_Text];
    CGPoint center = [self getCenterWithArray:vertices];
    ///字幕缩放大于5倍则不允许再放大
    ///Subtitle zooming greater than 5x is not allowed
    if (scale > 1 && [self.currentCaption getScaleX] > 5) {
        return;
    }
    
    [self.currentCaption scaleCaption:scale anchor:center];
    [self.currentCaption rotateCaption:rotate anchor:center];
    [self updateCaptionView:self.currentCaption];
    
    CGFloat rotationValue = [self.currentCaption getRotationZ];
    CGFloat scaleValue = [self.currentCaption getScaleX];
    CGPoint anchorValue = [self.currentCaption getAnchorPoint];
    NvCompoundCaptionInfoModel *model = [self getCaptionInfoModel:self.currentCaption];
    model.scale = scaleValue;
    model.rotation = rotationValue;
    model.anchorPoint = anchorValue;
    
    NvCompoundTimeSpanInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
    modelInfo.infoModel.rotation = [self.currentCaption getRotationZ];
    modelInfo.infoModel.scale = [self.currentCaption getScaleX];
}

///平移字幕框
///Panning box
- (void)rectView:(NvRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {
    CGPoint p1 = [self.liveWindowPanel.liveWindow mapViewToCanonical:currentPoint];
    CGPoint p2 = [self.liveWindowPanel.liveWindow mapViewToCanonical:previousPoint];
    CGPoint newPoint = CGPointMake(p1.x-p2.x, p1.y-p2.y);
    [self.currentCaption translateCaption:newPoint];
    
    [self updateCaptionView:self.currentCaption];
    NvCompoundTimeSpanInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
    modelInfo.infoModel.translationOffset = [self.currentCaption getCaptionTranslation];
    NvCompoundCaptionInfoModel *model = [self getCaptionInfoModel:self.currentCaption];
    model.translationOffset = [self.currentCaption getCaptionTranslation];
    
}

///点击字幕框
///Click the subtitle box
- (void)rectView:(NvRectView *)rectView touchUpInside:(CGPoint)point {
        if (self.currentCaption) {
            NSArray *array = [self.currentCaption getCompoundBoundingVertices:NvsBoundingType_Text];
            NSValue *leftTopValue = array[0];
            NSValue *leftBottomValue = array[1];
            NSValue *rightBottomValue = array[2];
            NSValue *rightTopValue = array[3];
            CGPoint topLeftCorner = [leftTopValue CGPointValue];
            CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
            CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
            CGPoint rightTopCorner = [rightTopValue CGPointValue];

            topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
            rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
            bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
            rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];

            CGMutablePathRef pathRef=CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
            CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
            CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
            CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
            CGPathCloseSubpath(pathRef);
            bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
            CGPathRelease(pathRef);
            if(isIn){
                if (self.isSelect) {
                    CGPoint pointInRectView = [self.liveWindowPanel.liveWindow convertPoint:point toView:self.rectView];
                    NSArray *captionArr = [self changeModifiableInternalCaptionsWithCaption:self.currentCaption];
                    ///处理两个字幕重合部分，选中index靠后的子字幕进行处理
                    ///To deal with the overlapped parts of two subtitles, select the subtitle next to index for processing
                    int toPushIndex = 0;
                    bool isInCompoundCaption = false;
                    for (int i=0; i<captionArr.count; i++) {
                        NSArray *compoundArr = captionArr[i];
                        bool inCompoundCaption = [self pointIsInFrame:pointInRectView vertices:compoundArr];
                        if (inCompoundCaption) {
                            toPushIndex = i;
                            isInCompoundCaption = true;
                        }
            
                    }

                    if (isInCompoundCaption) {
                        if (self.selectedIndex != -1 && self.selectedIndex == toPushIndex) {
                            NvCaptionDialogViewController *dialogVC = [NvCaptionDialogViewController new];
                            NSString *currentCaptionText =  [self.currentCaption getText:self.selectedIndex];
                            [dialogVC setCaptionText:currentCaptionText];
                            dialogVC.delegate = self;
                            [dialogVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                            ///必要配置
                            ///Necessary configuration
                            self.modalPresentationStyle = UIModalPresentationCurrentContext;
                            self.providesPresentationContextTransitionStyle = YES;
                            self.definesPresentationContext = YES;
                            [self presentViewController:dialogVC animated:YES completion:NULL];
                        }else{
                            [self.rectView setSubCaptionLineColorWithIndex:toPushIndex color:[UIColor redColor]];
                            self.adjustmentView.hidden = NO;
                            self.selectedIndex = toPushIndex;
                            self.adjustmentView.selectedIndex = toPushIndex;
                            self.adjustmentView.currentCaption = self.currentCaption;
                            self.adjustmentView.captionInfo = [self getCaptionInfoModel:self.currentCaption];
                            [self refreshAdjustmentView];
                            self.isStyleModel = YES;
                            self.isSelect = YES;
                        }
                        
                    }
                }else{
                   self.isSelect = YES;
                }
                
     
            } else {
                ///如果点击的位置不在字幕上
                ///If the location of the click is not on the subtitles
                if ([NvsStreamingContext sharedInstance].getStreamingEngineState != NvsStreamingEngineState_Playback) {
                    if (![NvTimelineUtils playbackTimeline:self.timeline startTime:self.liveWindowPanel.currentTime endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                        NSLog(@"播放时间线失败！success to play timeline!");
                        return;
                    }
                } else {
                    [[NvsStreamingContext sharedInstance] stop];
                }
            }
        }
}


- (void)captionDialog:(NvCaptionDialogViewController *)captionDialog clickButtonIndex:(NSInteger)index {
    NSString* textTemp = [captionDialog getCaptionText];
    textTemp = [textTemp stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (!textTemp || textTemp.length == 0) {
        [NvToast showInfoWithMessage:NvLocalString(@"Subtitle is empty", @"您输入的字幕为空，请重新输入")];
        return;
    }
    if (index == 0) {
        NSString* text = [captionDialog getCaptionText];
        [self.currentCaption setText:self.selectedIndex text:text];
        
        NvCompoundCaptionInfoModel *model = [self getCaptionInfoModel:self.currentCaption];
        NvInnerCompoundCaptionModel *innerModel = model.captionArr[self.selectedIndex];
        [innerModel setText:text];
        [self showCaption];
    }
    
    [captionDialog dismissViewControllerAnimated:NO completion:NULL];
}

///根据字幕框是否隐藏添加/移除手势方法
///Add/remove gesture methods based on whether the subtitle box is hidden
- (void)rectView:(NvRectView *)rectView isHidden:(BOOL)isHidden {
    if (isHidden) {
        [self.liveWindowPanel addTapScreenPause];
    } else {
        [self.liveWindowPanel removeTapScreenPause];
    }
}

///刚触碰字幕框
///Just touched the subtitle box
- (void)rectView:(NvRectView*)rectView touchBeganPoint:(CGPoint)point{
    if (self.isStyleModel) {
        ///不是编辑模式不能切换
        ///Not edit mode can not be switched
        return;
    }
    NSArray *captionArray = [self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    for (int i = 0; i < captionArray.count; i++) {
        NvsTimelineCompoundCaption *cap = captionArray[i];
        NSArray *array = [cap getCompoundBoundingVertices:NvsBoundingType_Text];
        NSValue *leftTopValue = array[0];
        NSValue *leftBottomValue = array[1];
        NSValue *rightBottomValue = array[2];
        NSValue *rightTopValue = array[3];
        CGPoint topLeftCorner = [leftTopValue CGPointValue];
        CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
        CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
        CGPoint rightTopCorner = [rightTopValue CGPointValue];

        topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
        rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
        bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
        rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];

        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
        CGPathCloseSubpath(pathRef);
        bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
        CGPathRelease(pathRef);
        if(isIn){
            if (self.currentCaption == cap) {
                self.isSelect = YES;
            } else {
                self.isSelect = NO;
            }

            ///将外围边框变大
            ///Make the perimeter border larger
            [self enlargeVerticesWithArray:array];
            ///设为当前字幕
            ///Set to the current subtitles
            self.currentCaption = cap;
            NSArray *captionArr = [self changeModifiableInternalCaptionsWithCaption:cap];
            [self.rectView changeModifiableInternalCaptionsWithPoints:captionArr];
            NvCompoundTimeSpanInfoModel *info = [self getCurrentTimeSpan:cap];
            ///选中timeSpan
            ///Select timeSpan
            [self.addCaptionView.timelineEditor selectTimeSpan:info.timeSpan];
        }
    }
}

#pragma mark - 播放过程中的回调 Callbacks during playback
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    [self.addCaptionView.timelineEditor selectTimeSpan:nil];
    self.addCaptionView.playButton.selected = YES;
    NvsTimelineCompoundCaption *captemp = [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
    self.addCaptionView.styleButton.hidden = !captemp;
    if (self.isStyleModel) {
        self.rectView.hidden = YES;
        __weak typeof(self)weakSelf = self;
        if (position > self.currentCaption.outPoint) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf seekTimeline:weakSelf.currentCaption.inPoint];
                NvCompoundTimeSpanInfoModel *modelnext = [self getCurrentTimeSpan:self.currentCaption];
                if (self.currentCaption) {
                    [self.addCaptionView.timelineEditor selectTimeSpan:modelnext.timeSpan];
                    self.rectView.hidden = self.currentCaption?NO:YES;
                    [self updateCaptionView:self.currentCaption];
                }
            });
            [self.addCaptionView.timelineEditor setTimelinePosition:self.currentCaption.inPoint];
        }
    } else {
        [self.addCaptionView.timelineEditor setTimelinePosition:position];
        self.rectView.hidden = YES;
        
        ///播放过程中显示时间
        ///The time is displayed during playback
        [self.addCaptionView setcurrentTime:position];
    }
}

///播放停止的回调
///A callback that stops playing
- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    [self.addCaptionView.timelineEditor setTimelinePosition:[self.streamingContext getTimelineCurrentPosition:timeline]];
    self.addCaptionView.playButton.selected = NO;
    if (self.isStyleModel) {
        NvsTimelineCompoundCaption *captemp= [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
        self.addCaptionView.styleButton.hidden = !captemp;
        int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
        if (currentTime > self.currentCaption.outPoint || currentTime < self.currentCaption.inPoint) {
            self.rectView.hidden = YES;
        } else {
            self.rectView.hidden = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NvCompoundTimeSpanInfoModel *modelnext = [self getCurrentTimeSpan:captemp];
            if (captemp) {
                if (!self.rectView.hidden) {
                    [self updateCaptionView:captemp];
                }
                
                [self.addCaptionView.timelineEditor selectTimeSpan:modelnext.timeSpan];
            }
        });
    } else {
        self.currentCaption = [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
        self.rectView.hidden = self.currentCaption?NO:YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            NvCompoundTimeSpanInfoModel *modelnext = [self getCurrentTimeSpan:self.currentCaption];
            if (self.currentCaption) {
                [self updateCaptionView:self.currentCaption];
                [self.addCaptionView.timelineEditor selectTimeSpan:modelnext.timeSpan];
            }
        });
    }
}

///播放到末尾的回调
///Play to the end of the callback
- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    if (self.isStyleModel) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf seekTimeline:weakSelf.currentCaption.inPoint];
            self.currentCaption = [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
            NvCompoundTimeSpanInfoModel *modelnext = [self getCurrentTimeSpan:self.currentCaption];
            if (self.currentCaption) {
                [self.addCaptionView.timelineEditor selectTimeSpan:modelnext.timeSpan];
                self.rectView.hidden = self.currentCaption?NO:YES;
                [self updateCaptionView:self.currentCaption];
            }
        });
        [self.addCaptionView.timelineEditor setTimelinePosition:self.currentCaption.inPoint];
    } else {
        [self.addCaptionView.timelineEditor setTimelinePosition:0];
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf seekTimeline:0];
            self.currentCaption = [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
            NvCompoundTimeSpanInfoModel *modelnext = [self getCurrentTimeSpan:self.currentCaption];
            if (self.currentCaption) {
                [self.addCaptionView.timelineEditor selectTimeSpan:modelnext.timeSpan];
                self.rectView.hidden = self.currentCaption?NO:YES;
                [self updateCaptionView:self.currentCaption];
            }
        });
    }
}


#pragma mark - 资源下载Delegate Resource download Delegate
/**
 * 获取到在线素材列表后执行该回调。
 * Perform the callback after obtaining the online material list.
 */
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    ///查询字体信息
    ///Querying Font Information
    [self.assetManager searchLocalAssets:ASSET_FONT];
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"fontPackage" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FONT bundlePath:fontPath];
    
    NSArray *useArray = [self.assetManager getUsableAssets:ASSET_FONT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    NSArray *array = [self.assetManager getRemoteAssets:ASSET_FONT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    [self.fontDataSource removeAllObjects];
    NvCaptionFontItem *item = [NvCaptionFontItem new];
    item.selected = NO;
    item.showName = NO;
    item.coverName = @"NvsFilterNone";
    item.packagePath = nil;
    item.packageNetPath = nil;
    item.fontName = @"";
    item.displayName = NvLocalString(@"None", @"无");
    item.state = Finish;
    [self.fontDataSource addObject:item];
    for (NvAsset *asset in useArray) {
        NvCaptionFontItem *item = [NvCaptionFontItem new];
        item.selected = NO;
        item.showName = NO;
        item.coverDefault = @"Nvfont";
        item.coverName = asset.coverUrl;
        item.packageId = asset.uuid;
        item.fontName = asset.uuid;
        item.packagePath = asset.bundledLocalDirPath ? asset.bundledLocalDirPath : asset.localDirPath;
        NSString *fontFamily = [self.streamingContext registerFontByFilePath:item.packagePath];
        item.fontName = fontFamily;
        item.packageNetPath = asset.packageUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.displayName = asset.displayNamezhCN;
        }else{
            item.displayName = asset.displayName;
        }
        item.state = Finish;
        item.isAdjusted = asset.isAdjusted;
        [self.fontDataSource addObject:item];
    }
    
    for (NvAsset *asset in array) {
        NvCaptionFontItem *item = [NvCaptionFontItem new];
        item.selected = NO;
        item.showName = NO;
        item.coverDefault = @"Nvfont";
        item.coverName = asset.coverUrl;
        item.packageId = asset.uuid;
        item.packagePath = asset.bundledLocalDirPath;
        item.packageNetPath = asset.packageUrl;
        item.isAdjusted = asset.isAdjusted;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.displayName = asset.displayNamezhCN;
        }else{
            item.displayName = asset.displayName;
        }
        __block BOOL isHavaAssetInLocal = NO;
        [useArray enumerateObjectsUsingBlock:^(NvAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.uuid isEqualToString:asset.uuid]) {
                item.packagePath = asset.localDirPath;
                item.state = Finish;
                isHavaAssetInLocal = YES;
            }
        }];
        if (!isHavaAssetInLocal) {
            [self.fontDataSource addObject:item];
        }
    }
    ///设置字体
    ///Set the font
    NSString *fontName = [self.currentCaption getFontFamily:0];
    if (fontName && ![fontName isEqualToString:@""]) {
        for (NvCaptionFontItem *item1 in self.fontDataSource) {
            if ([fontName isEqualToString:item1.fontName]) {
                item1.selected = YES;
            } else {
                item1.selected = NO;
            }
        }
    } else {
        [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                obj.selected = YES;
            } else {
                obj.selected = NO;
            }
        }];
    }

    if ([self.adjustmentView.fontListView respondsToSelector:@selector(setDefauleDataSource:)]) {
        [self.adjustmentView.fontListView setDefauleDataSource:self.fontDataSource];
    }
    if (self.currentCaption) {
        NvsColor color = [self.currentCaption getTextColor:0];
        [self.adjustmentView.colorListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionColorItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSelect = NO;
            NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
            if (rgb.count == 4) {
                if (([rgb[0] floatValue] == color.r) && ([rgb[1] floatValue] == color.g) && ([rgb[2] floatValue] == color.b) ) {
                    obj.isSelect = YES;
                }
            }
        }];
        if ([self.adjustmentView.colorListView respondsToSelector:@selector(setDefaultDataSource:alpha:)]) {
            [self.adjustmentView.colorListView setDefaultDataSource:self.adjustmentView.colorListView.dataSource alpha:color.a];
        }
        
        NvsColor bgColor = [self.currentCaption getBackgroundColor:0];
        [self.adjustmentView.bgColorListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionColorItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSelect = NO;
            NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
            if (rgb.count == 4) {
                if (([rgb[0] floatValue] == bgColor.r) && ([rgb[1] floatValue] == bgColor.g) && ([rgb[2] floatValue] == bgColor.b) ) {
                    obj.isSelect = YES;
                }
            }
        }];
        if ([self.adjustmentView.bgColorListView respondsToSelector:@selector(setDefaultDataSource:alpha:)]) {
            [self.adjustmentView.bgColorListView setDefaultDataSource:self.adjustmentView.bgColorListView.dataSource alpha:bgColor.a];
        }
        
        NvsColor outlineColor = [self.currentCaption getOutlineColor:0];
        [self.adjustmentView.strokeListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionColorItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSelect = NO;
            NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
            if (rgb.count == 4) {
                if (([rgb[0] floatValue] == outlineColor.r) && ([rgb[1] floatValue] == outlineColor.g) && ([rgb[2] floatValue] == outlineColor.b) ) {
                    obj.isSelect = YES;
                }
            }
        }];
        float outLineWidth = [self.currentCaption getOutlineWidth:0];
        if ([self.adjustmentView.strokeListView respondsToSelector:@selector(setDefaultDataSource: width:alpha:)]) {
            [self.adjustmentView.strokeListView setDefaultDataSource:self.adjustmentView.strokeListView.dataSource width:outLineWidth/10. alpha:outlineColor.a];
        }
    }

}

/**
 * 获取到在线素材列表失败执行该回调。
 * Description Failed to obtain the online material list.
 */
- (void)onGetRemoteAssetsFailed {
    [NvToast showErrorWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
    self.isHaveList = NO;
}

/**
 * 下载在线素材进度执行该回调。
 * Download online materials progress Perform this callback.
 */
- (void)onDownloadAssetProgress:(NSString *)uuid
                       progress:(int)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adjustmentView.fontListView updateProgress:progress/100.0 uuid:uuid];
    });
}

/**
 * 下载在线素材失败执行该回调。
 * Description Failed to download online materials.
 */
- (void)onDonwloadAssetFailed:(NSString *)uuid {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NvToast showErrorWithMessage:NvLocalString(@"downloadFaild", @"下载失败！")];
        [self.adjustmentView.fontListView downloadFailduuid:uuid];
    });
}

/**
 * 下载在线素材完成执行该回调。
 * Download online materials. Complete the callback.
 */
- (void)onDonwloadAssetSuccess:(NSString *)uuid {
    [self getStyleDefaultData];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.adjustmentView.compoundStyleView renderListWithItems:weakSelf.styleDataSource];
    });
    
    
     [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if ([obj.packageId isEqualToString:uuid]) {
             obj.state = Finish;
             obj.packagePath = [NSString stringWithFormat:@"%@%@/%@",NSHomeDirectory(),NV_ASSET_DOWNLOAD_PATH_FONT,obj.packageNetPath.lastPathComponent];
         }
     }];
     [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if (obj.lastSelect && [obj.packageId isEqualToString:uuid]) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self applyDownloadFont:obj];
             });
         }
     }];
     [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if (obj.lastSelect) {
             obj.selected = YES;
         } else {
             obj.selected = NO;
         }
     }];
     [self.adjustmentView.fontListView renderListWithItems:self.fontDataSource];
     
}

/**
 * 如果素材为异步安装，安装完成后执行该回调。
 * If materials are installed asynchronously, perform this callback after installation.
 */
- (void)onFinishAssetPackageInstallation:(NSString *)uuid {
   
}

/**
 * 如果素材为异步安装，升级完成后执行该回调。
 * If materials are installed asynchronously, perform this callback after the upgrade is complete.
 */
- (void)onFinishAssetPackageUpgrading:(NSString *)uuid {
    
}
- (void)applyDownloadFont:(NvCaptionFontItem *)item {

}

- (void)downloadFont:(NvCaptionFontItem *)item {
    [self.assetManager downloadAsset:item.packageId];
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentCaption"]) {
        self.addCaptionView.styleButton.hidden = self.currentCaption?NO:YES;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - lazyload
- (NvRectView *)rectView {
    if (!_rectView) {
        _rectView = [[NvRectView alloc] init];
        _rectView.delegate = self;
        [_rectView hideVoiceButton:YES];
        [_rectView hidenAlignImage:YES];
        _rectView.layer.masksToBounds = YES;
    }
    return _rectView;
}

- (NvAddCompoundCaptionView *)addCaptionView {
    if (!_addCaptionView) {
        _addCaptionView = [NvAddCompoundCaptionView new];
        _addCaptionView.delegate = self;
        _addCaptionView.timeline = self.timeline;
        [_addCaptionView.styleButton setTitle:NvLocalString(@"Modify", @"修改") forState:UIControlStateNormal];
        [_addCaptionView.styleButton setTitle:NvLocalString(@"Modify", @"修改") forState:UIControlStateSelected];
        if (@available(iOS 9.0, *)) {
            [_addCaptionView.styleButton setTitle:NvLocalString(@"Modify", @"修改") forState:UIControlStateFocused];
        } else {
            // Fallback on earlier versions
        }
        [_addCaptionView.styleButton setTitle:NvLocalString(@"Modify", @"修改") forState:UIControlStateHighlighted];
        _addCaptionView.styleButton.hidden = YES;
    }
    return _addCaptionView;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"currentCaption"];
    NSLog(@"%s",__func__);
}

@end
