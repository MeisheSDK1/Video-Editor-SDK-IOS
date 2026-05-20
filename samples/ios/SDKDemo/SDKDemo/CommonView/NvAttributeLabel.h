//
//  NvAttributeLabel.h
//  SDKDemo
//
//  Created by chengww on 2020/7/29.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvAttributeLabel;
NS_ASSUME_NONNULL_BEGIN

@protocol NvAttributeLabelDelegate<NSObject>

- (void)attributeLabel:(NvAttributeLabel *)label didResponseLink:(NSString *)link;

@end

@interface NvAttributeLabel : UILabel

@property (nonatomic, weak) id<NvAttributeLabelDelegate> delegate;

@property (nonatomic, copy) NSMutableAttributedString *attriContent;

/// 可点击链接的Attributes
@property (nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *linkTextAttributes;

@property (nonatomic, strong) NSArray<NSString *> *links;

@property (nonatomic, assign) NSTextAlignment alignment;

@end

NS_ASSUME_NONNULL_END
