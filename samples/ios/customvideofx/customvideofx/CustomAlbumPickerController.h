//
//  PhotoPickerViewController.h
//  customvideofx
//
//  Created by Mac-Mini on 2025/6/4.
//  Copyright © 2025 cdv. All rights reserved.
//

// PhotoPickerViewController.h
// Objective-C
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoPickerViewController : UIViewController
@property (nonatomic, copy) void (^completionHandler)(NSArray<PHAsset *> *selectedAssets);
@end
