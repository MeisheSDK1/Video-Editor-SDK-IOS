//
//  NvCaptionContextView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2020/7/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCaptionContextView.h"
#import "NvStyleCollectionViewCell.h"

@interface NvCaptionContextViewCell : NvStyleCollectionViewCell

@end

@implementation NvCaptionContextViewCell

- (void)renderCellWithItem:(NvCaptionContextItem *)item {
    [super renderCellWithItem:(NvCaptionStyleItem *)item];
    if (((NvCaptionStyleItem *)item).isSelect) {
        self.coverView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
    } else {
        self.coverView.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    }
}

@end

@implementation NvCaptionContextView

#pragma mark - Override
- (Class)registerCell {
    return [NvCaptionContextViewCell class];
}


///刷新列表用于外界设置默认数据
///The refresh list is used to set default data for the outside world
- (void)renderListWithItems:(NSMutableArray <NvCaptionContextItem *>*)dataSource {
    [super renderListWithItems:(NSMutableArray<NvCaptionStyleItem *>*)dataSource];
}

- (void)moreClick {
    if ([self.delegate respondsToSelector:@selector(moreCaptionContextClick)]) {
        [self.delegate moreCaptionContextClick];
    }
}

- (void)applyAllClick:(BOOL)applyToAll {
    if ([self.delegate respondsToSelector:@selector(applyCaptionContextToAllCaption:)]) {
        [self.delegate applyCaptionContextToAllCaption:self.applyButton.selected];
    }
}

- (void)selectCaptionItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(selectCaptionContext:)]) {
        [self.delegate selectCaptionContext:item];
    }
}

@end
