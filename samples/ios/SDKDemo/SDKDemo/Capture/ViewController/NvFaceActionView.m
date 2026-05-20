//
//  NvFaceActionView.m
//  SDKDemo
//
//  Created by kirk on 2022/6/23.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvFaceActionView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface NvFaceActionItemView : UIView
@property(nonatomic,strong)UILabel* titleLabel;
@property(nonatomic,strong)UILabel* valueLabel;
@end
@implementation NvFaceActionItemView

+(NvFaceActionItemView*)itemViewWithTitle:(NSString*)title frame:(CGRect)frame{
    NvFaceActionItemView* itemView = [[NvFaceActionItemView alloc] initWithFrame:frame];
    [itemView setupLabels];
    itemView.titleLabel.text = title;
    return itemView;
}

-(void)setupLabels{
    CGFloat textSize = 10;
    
    CGFloat titleRate = 0.7;
    CGSize size = self.frame.size;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width*titleRate, size.height)];
    self.titleLabel.font = [UIFont systemFontOfSize:textSize];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.titleLabel];
    
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width*titleRate, 0, size.width*(1-titleRate), size.height)];
    self.valueLabel.font = [UIFont systemFontOfSize:textSize];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    self.valueLabel.textColor = UIColor.redColor;
    [self addSubview:self.valueLabel];
    
}

@end

@interface NvFaceActionView ()

@property(nonatomic,strong)NSMutableArray<NvFaceActionItemView*>* itemArray;

@end

@implementation NvFaceActionView

+(NvFaceActionView*)createFaceActionView{
    CGRect frame = CGRectMake(30, 45, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 65);
    NvFaceActionView* actionView = [[NvFaceActionView alloc] initWithFrame:frame];
    actionView.userInteractionEnabled = NO;
    [actionView setupItems];
    return actionView;
}


- (void)notifyFaceFeatureInfos:(NSMutableArray<NvsFaceFeatureInfo *> *)faceFeatureInfos{
    dispatch_async(dispatch_get_main_queue(), ^{
    if (faceFeatureInfos.count > 0) {
        NvsFaceFeatureInfo* info = faceFeatureInfos[0];
        if (info.avatarExpressions.count > 0) {
            for (NSInteger i =0; i<info.avatarExpressions.count; i++) {
                NvFaceActionItemView* item = self.itemArray[i];
                CGFloat value = [info.avatarExpressions[i] floatValue];
                item.valueLabel.text = [NSString stringWithFormat:@"%.03f",value];
            }
        }
    }
    });
}

-(void)setupItems{
    
    NSArray<NSString*>* titleArray = @[@"右眼闭合",
                                       @"右眼下看",
                                       @"右眼向内看(向左看)",
                                       @"右眼向外看(向右看)",
                                       @"右眼向上看",
                                       @"右眼眯眼",
                                       @"右眼圆睁",
                                       @"左眼闭合",
                                       @"左眼下看",
                                       @"左眼向内看(向右看)",
                                       @"左眼向外看(向左看)",
                                       @"左眼上看",
                                       @"左眼眯眼",
                                       @"左眼圆睁",
                                       @"下颚前突(嘴闭合)",
                                       @"下颚右移(嘴闭合)",
                                       @"下颚左移(嘴闭合)",
                                       @"下颚向下张开(嘴自然张开)",
                                       @"下颚下降",
                                       @"嘴形自然闭合(下颚向下张开)",
                                       @"嘟嘴，嘴唇往前突",
                                       @"撅嘴，嘴唇往外翘",
                                       @"嘴巴鼓气",
                                       @"上下嘴唇右移",
                                       @"上下嘴唇左移",
                                       @"右嘴角向上扬",
                                       @"左嘴角向上扬",
                                       @"右嘴角向下撇",
                                       @"左嘴角向下撇",
                                       @"右嘴角向后撇",
                                       @"左嘴角向后撇",
                                       @"右嘴角水平向外移(右移)",
                                       @"左嘴角水平向外移(左移)",
                                       @"嘴角微微收拢",
                                       @"下嘴唇内卷",
                                       @"上嘴唇内卷",
                                       @"下嘴唇外翻",
                                       @"上嘴唇外翻",
                                       @"下嘴唇右上翘",
                                       @"下嘴唇左上翘",
                                       @"下嘴唇右下垂",
                                       @"下嘴唇左下垂",
                                       @"上嘴唇右上翘",
                                       @"上嘴唇左上翘",
                                       @"微张嘴",
                                       @"右眉毛外垂",
                                       @"左眉毛外垂",
                                       @"双眉向上内挑",
                                       @"双眉向下内垂",
                                       @"右眉外挑",
                                       @"左眉外挑",
                                       @"双面颊前突",
                                       @"右面颊上提",
                                       @"左面颊上提",
                                       @"右鼻子上提",
                                       @"左鼻子上提",
                                       @"双鼻张开",
                                       @"舌头伸出"];
    
    CGFloat itemHeight = 12;
    CGFloat itemWidth = self.frame.size.width*0.4;
    
//    CGFloat rectY = 0;
//    CGFloat rectX = 0;
    
    self.itemArray = [NSMutableArray array];
    NSInteger halfCount = titleArray.count/2;
    for (NSInteger i =0; i<titleArray.count; i++) {
        if (i<halfCount) {
            CGFloat rectY = itemHeight * i;
            CGRect itemFrame = CGRectMake(0, rectY, itemWidth, itemHeight);
            NvFaceActionItemView* item = [NvFaceActionItemView itemViewWithTitle:titleArray[i] frame:itemFrame];
            [self addSubview:item];
            [self.itemArray addObject:item];
        }else{
            CGFloat rectY = itemHeight * (i-halfCount);
            CGRect itemFrame = CGRectMake(itemWidth, rectY, itemWidth, itemHeight);
            NvFaceActionItemView* item = [NvFaceActionItemView itemViewWithTitle:titleArray[i] frame:itemFrame];
            [self addSubview:item];
            [self.itemArray addObject:item];
        }
        
    }
}

@end
