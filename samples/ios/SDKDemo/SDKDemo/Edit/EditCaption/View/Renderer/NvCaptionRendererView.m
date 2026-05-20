//
//  NvCaptionRendererView.m
//  SDKDemo
//
//  Created by ms on 2020/7/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCaptionRendererView.h"
#import "NvStyleCollectionViewCell.h"

@interface NvRendererCollectionViewCell : NvStyleCollectionViewCell

@end

@implementation NvRendererCollectionViewCell

- (void)renderCellWithItem:(NvCaptionStyleItem *)item {
    [super renderCellWithItem:item];
    if (item.isSelect) {
        self.coverView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
    } else {
        self.coverView.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    }
}

@end

@implementation NvCaptionRendererView

- (Class)registerCell {
    return [NvRendererCollectionViewCell class];
}

///刷新列表用于外界设置默认数据
///The refresh list is used to set default data for the outside world
- (void)renderListWithItems:(NSMutableArray <NvCaptionRendererItem *>*)dataSource {
    [super renderListWithItems:(NSMutableArray<NvCaptionStyleItem *> *)dataSource];
}

- (void)moreClick {
    if ([self.delegate respondsToSelector:@selector(moreCaptionRendererClick)]) {
        [self.delegate moreCaptionRendererClick];
    }
}

- (void)applyAllClick:(BOOL)applyToAll {
    if ([self.delegate respondsToSelector:@selector(applyCaptionRendererToAllCaption:)]) {
        [self.delegate applyCaptionRendererToAllCaption:self.applyButton.selected];
    }
}

- (void)selectCaptionItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(selectCaptionRenderer:)]) {
        [self.delegate selectCaptionRenderer:item];
    }
}

@end

