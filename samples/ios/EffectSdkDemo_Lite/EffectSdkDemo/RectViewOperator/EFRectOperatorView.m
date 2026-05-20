//
//  EFRectOperatorView.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2021/3/12.
//  Copyright © 2021 美摄. All rights reserved.
//

#import "EFRectOperatorView.h"

@interface EFRectOperatorView ()

@property(nonatomic,strong) UIView* displayView;
@property(nonatomic,assign) CGSize bufferSize;

@end

@implementation EFRectOperatorView

- (instancetype)initWithFrame:(CGRect)frame type:(NvType)type{
    self = [super initWithFrame:frame type:type];
    if (self) {
        self.delegate = self;
    }
    return self;
}

-(void)dealloc{
    NSLog(@"RectView: %s",__FUNCTION__);
}

-(void)setRectDisplayView:(UIView * _Nonnull)displayView{
    self.displayView = displayView;
}

-(void)resetBufferSize:(CGSize)bufferSize{
    if (!CGSizeEqualToSize(self.bufferSize, bufferSize)) {
        self.bufferSize = bufferSize;
        [self updateEffectShow:self.currentEffect];
    }
}

#pragma mark - 显示道具框 Display item box
- (void)updateEffectShow:(NvsEffect *)effect{
    self.currentEffect = effect;
    if (!effect) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    NvsEffectVideoResolution videoRes;
    videoRes.imageWidth = self.bufferSize.width;
    videoRes.imageHeight = self.bufferSize.height;
    NvsEffectRational imagePAR = {1,1};
    videoRes.imagePAR = imagePAR;
    if ([effect isKindOfClass:[NvsVideoEffectAnimatedSticker class]]) {
        [self clearCaptionLayers];
        NvsVideoEffectAnimatedSticker *fx = (NvsVideoEffectAnimatedSticker *)effect;
        
        [fx setVideoResolution:&videoRes];
        NSArray *array = [fx getBoundingRectangleVertices];
        NSArray *points = [self changeModifiableSingleCaptionWithPoints:array];
        [self setPoints:points];
        
    }else if ([effect isKindOfClass:[NvsVideoEffectCompoundCaption class]]){
        [self clearCaptionLayers];
        NvsVideoEffectCompoundCaption *caption = (NvsVideoEffectCompoundCaption *)effect;
        [caption setVideoResolution:&videoRes];
        
        NSArray *array = [caption getCompoundBoundingVertices:NvsEffectBoundingType_Typographic_Text];
        NSArray *points = [self changeModifiableSingleCaptionWithPoints:array];
        [self setPoints:points];
        NSArray *captionArr = [self changeModifiableInternalCaptionsWithCaption:caption];
        [self changeModifiableInternalCaptionsWithPoints:captionArr];
        
    }else if ([effect isKindOfClass:[NvsVideoEffectCaption class]]){
        [self clearCaptionLayers];
        NvsVideoEffectCaption *caption = (NvsVideoEffectCaption *)effect;
        [caption setVideoResolution:videoRes];
        
        NSArray *array = [caption getCaptionBoundingVertices:NvsVideoEffectBoundingType_Typographic_Text];
        NSArray *points = [self changeModifiableSingleCaptionWithPoints:array];
        [self setPoints:points];
    }
}

// can change captions and redraw borders - get a vertex array of all subcaptions
//可修改字幕重新绘制边框--获取全部子字幕的顶点数组
- (NSArray *)changeModifiableInternalCaptionsWithCaption:(NvsVideoEffectCompoundCaption *)caption {

    NSMutableArray *captionArr = [NSMutableArray array];
    NSInteger count = caption.captionCount;
    for (int i=0; i<count; i++) {
        NSArray *pointArr = [caption getCaptionBoundingVertices:i boundingType:NvsEffectBoundingType_Typographic_Text];
        NSArray *subArr = [self changeModifiableSingleCaptionWithPoints:pointArr];
        if (subArr.count == 4) {
            [captionArr addObject:subArr];
        }
    }
    return [captionArr copy];
}

// single subtitle redraw border - Get the four vertices of a single subtitle in rectview
//单个子字幕重新绘制边框--获取单个字幕在rectview中的四个顶点
- (NSArray *)changeModifiableSingleCaptionWithPoints:(NSArray *)points {
    NSMutableArray *pointArr = [NSMutableArray array];
    for (int i=0; i<points.count; i++) {
        NSValue *value = points[i];
        CGPoint point = [value CGPointValue];
        point = [self mapCanonicalToView:point];
        CGPoint finalPoint = [self.displayView convertPoint:point toView:self];
        [pointArr addObject:[NSValue valueWithCGPoint:finalPoint]];
    }
    if (pointArr.count == 4) {
        return [pointArr copy];
    }
    return nil;
}

//Time line coordinate system to interface coordinate system
//时间线坐标系转界面坐标系
- (CGPoint)mapCanonicalToView:(CGPoint)point {
    CGSize size = self.displayView.frame.size;
    double ratio = self.bufferSize.width/self.bufferSize.height;
    double originY = (size.height - size.width/ratio)/2.0;
    CGFloat x = (point.x/self.bufferSize.width*2.0 + 1.0)/2.0*size.width;
    CGFloat y = (-1.0*point.y/self.bufferSize.height*2.0 + 1.0)/2.0*size.width/ratio + originY;
    CGPoint result = CGPointMake(x, y);
    return result;
}
//Interface coordinate system to time line coordinate system
//界面坐标系转时间线坐标系
- (CGPoint)mapViewToCanonical:(CGPoint)point {
    CGSize size = self.displayView.frame.size;
    double ratio = self.bufferSize.width/self.bufferSize.height;
    double originY = (size.height - size.width/ratio)/2.0;
    CGFloat x = (point.x*2.0/size.width - 1.0)/2.0*self.bufferSize.height;
    CGFloat y = -1.0*((point.y - originY)*ratio/size.width*2.0 - 1.0)/2.0*self.bufferSize.height;
    CGPoint result = CGPointMake(x, y);
    return result;
}
//Calculate the center position of the caption according to the vertices around it (in the video coordinate system)
//根据字幕四周顶点计算出其中心点位置（视频坐标系中）
- (CGPoint)getCenterWithArray:(NSArray*)array {
    NSValue *leftTopValue = array[0];
    NSValue *rightBottomValue = array[2];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    return CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
}



#pragma mark - NvRectViewDelegate(NvRectView回调)
- (void)rectView:(NvRectView*)rectView close:(UIButton*)close {
    if (self.editDelegate && [self.editDelegate respondsToSelector:@selector(deleteEffectOperatorView:)]) {
        [self.editDelegate deleteEffectOperatorView:self];
    }
    [self updateEffectShow:nil];
}

//Rotate, zoom in and out of the box
//旋转、放大缩小字幕框
- (void)rectView:(NvRectView*)rectView rotate:(float)rotate scale:(float)scale {
    if ([self.currentEffect isKindOfClass:[NvsVideoEffectCompoundCaption class]]) {
        NvsVideoEffectCompoundCaption *currentCaption = (NvsVideoEffectCompoundCaption *)self.currentEffect;
        //Caption scaled more than 5 times are not allowed to be enlarged
        //字幕缩放大于5倍则不允许再放大
        if (scale > 1 && [currentCaption getScaleX] > 5) {
            return;
        }
        NSArray *vertices = [currentCaption getCompoundBoundingVertices:NvsEffectBoundingType_Typographic_Text];
        CGPoint center = [self getCenterWithArray:vertices];
        
        [currentCaption scaleCaption:scale anchor:center];
        
        [currentCaption rotateCaption:rotate anchor:center];
        [self updateEffectShow:currentCaption];
    }else if ([self.currentEffect isKindOfClass:[NvsVideoEffectAnimatedSticker class]]){
        NvsVideoEffectAnimatedSticker *currentSticker = (NvsVideoEffectAnimatedSticker *)self.currentEffect;
        //Caption scaled more than 5 times are not allowed to be enlarged
        //字幕缩放大于5倍则不允许再放大
        if (scale > 1 && [currentSticker getScale] > 5) {
            return;
        }
        NSArray *vertices = [currentSticker getBoundingRectangleVertices];
        CGPoint center = [self getCenterWithArray:vertices];
        [currentSticker scaleAnimatedSticker:scale anchor:center];
        [currentSticker rotateAnimatedSticker:rotate anchor:center];
        [self updateEffectShow:currentSticker];
    }else if ([self.currentEffect isKindOfClass:[NvsVideoEffectCaption class]]){
        NvsVideoEffectCaption *currentCaption = (NvsVideoEffectCaption *)self.currentEffect;
        //Caption scaled more than 5 times are not allowed to be enlarged
        //字幕缩放大于5倍则不允许再放大
        if (scale > 1 && [currentCaption getScaleX] > 5) {
            return;
        }
        NSArray *vertices = [currentCaption getCaptionBoundingVertices:NvsVideoEffectBoundingType_Typographic_Text];
        CGPoint center = [self getCenterWithArray:vertices];
        [currentCaption scaleCaption:scale anchor:center];
        [currentCaption rotateCaption:rotate anchor:center];
        [self updateEffectShow:currentCaption];
    }
}

// Translate the caption box
//平移字幕框
- (void)rectView:(NvRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {
    CGPoint p1 = [self mapViewToCanonical:currentPoint];
    CGPoint p2 = [self mapViewToCanonical:previousPoint];
    CGPoint newPoint = CGPointMake(p1.x-p2.x, p1.y-p2.y);
    if ([self.currentEffect isKindOfClass:[NvsVideoEffectCompoundCaption class]]) {
        NvsVideoEffectCompoundCaption *currentCaption = (NvsVideoEffectCompoundCaption *)self.currentEffect;
        [currentCaption translateCaption:newPoint];
        [self updateEffectShow:currentCaption];
    }else if ([self.currentEffect isKindOfClass:[NvsVideoEffectAnimatedSticker class]]){
        NvsVideoEffectAnimatedSticker *currentSticker = (NvsVideoEffectAnimatedSticker *)self.currentEffect;
        [currentSticker translateAnimatedSticker:newPoint];
        [self updateEffectShow:currentSticker];
    }else if ([self.currentEffect isKindOfClass:[NvsVideoEffectCaption class]]){
        NvsVideoEffectCaption *currentCaption = (NvsVideoEffectCaption *)self.currentEffect;
        [currentCaption translateCaption:newPoint];
        [self updateEffectShow:currentCaption];
    }
    
}

- (void)rectView:(NvRectView *)rectView touchUpInside:(CGPoint)point{
    if (self.editDelegate && [self.editDelegate respondsToSelector:@selector(rectOperatorView:touchUpInside:point:)]) {
        if ([self.currentEffect isKindOfClass:[NvsVideoEffectCompoundCaption class]]) {
            // Looking for the click is the index of captions
            // 找点击的是第几个字幕
            NvsVideoEffectCompoundCaption* comCaption = (NvsVideoEffectCompoundCaption*)self.currentEffect;
            for (NSInteger i=0; i<comCaption.captionCount; i++) {
                NSArray *array = [comCaption getCaptionBoundingVertices:i boundingType:NvsEffectBoundingType_Typographic_Text];
                NSArray *points = [self changeModifiableSingleCaptionWithPoints:array];
                if ([self pointArray:points contentOfPoint:point]) {
                    [self.editDelegate rectOperatorView:self touchUpInside:i point:point];
                    return;
                }
            }
        }else{
            [self.editDelegate rectOperatorView:self touchUpInside:0 point:point];
        }
    }
}

-(BOOL)pointArray:(NSArray*)points contentOfPoint:(CGPoint)point{
    CGMutablePathRef pathRef=CGPathCreateMutable();
    CGPoint arrayPoint = [points[0] CGPointValue];
    CGPathMoveToPoint(pathRef, NULL, arrayPoint.x, arrayPoint.y);
    arrayPoint = [points[1] CGPointValue];
    CGPathAddLineToPoint(pathRef, NULL, arrayPoint.x, arrayPoint.y);
    arrayPoint = [points[2] CGPointValue];
    CGPathAddLineToPoint(pathRef, NULL, arrayPoint.x, arrayPoint.y);
    arrayPoint = [points[3] CGPointValue];
    CGPathAddLineToPoint(pathRef, NULL, arrayPoint.x, arrayPoint.y);
    CGPathCloseSubpath(pathRef);
    BOOL isIn = CGPathContainsPoint(pathRef, nil, point, false);
    CGPathRelease(pathRef);
    return isIn;
}

@end
