//
//  NvAlbumSizeView.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvAlbumSizeView;

@protocol NvAlbumSizeViewDelegate

@optional

/* selectType
 typedef enum {
     NvEditMode16v9 = 0,
     NvEditMode1v1,
     NvEditMode9v16,
     NvEditMode3v4,
     NvEditMode4v3,
     NvEditMode21v9,
     NvEditMode9v21,
     NvEditMode18v9,
     NvEditMode9v18,
     NvEditMode2d39v1,
     NvEditMode2d55v1,
 } NvEditMode;
 */
- (void)nvSizeView:(NvAlbumSizeView *)nvSizeView selectType:(int)type;

@end

@interface NvAlbumSizeView : UIView

@property (nonatomic, weak)id delegate;

@end
