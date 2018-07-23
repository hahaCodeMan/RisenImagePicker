//
//  RisenPhotoViewController.h
//  RisenImageDemo
//
//  Created by Risen on 2018/7/18.
//  Copyright © 2018年 Risen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RisenPhotoViewController : UIViewController
@property (assign, nonatomic) NSInteger selectPhotoOfMax;/**< 选择照片的最多张数 */

/** 回调方法 */
@property (nonatomic, copy) void(^selectPhotosBack)(NSMutableArray *photosArr);
@end
