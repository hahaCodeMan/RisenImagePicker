//
//  myPhotoCell.h
//  RisenImageDemo
//
//  Created by Risen on 2018/7/18.
//  Copyright © 2018年 Risen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myPhotoCell : UICollectionViewCell

@property(nonatomic, strong)UIImageView *photoView;

@property(nonatomic, assign)BOOL chooseStatus;

@property (nonatomic, copy) NSString *representedAssetIdentifier;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, assign) CGFloat progressFloat;

@property (nonatomic, strong) UIImageView *signImage;
@property (nonatomic, strong) UIButton *signImageButton;
@end
