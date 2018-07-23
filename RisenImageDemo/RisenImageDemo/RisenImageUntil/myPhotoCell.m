//
//  myPhotoCell.m
//  RisenImageDemo
//
//  Created by Risen on 2018/7/18.
//  Copyright © 2018年 Risen. All rights reserved.
//

#import "myPhotoCell.h"
#import "WPMacros.h"

@implementation myPhotoCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _photoView = [[UIImageView alloc] initWithFrame:self.bounds];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.layer.masksToBounds = YES;
        _photoView.userInteractionEnabled = YES;
        [self addSubview:_photoView];
        
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(self.bounds.size.width/4, self.bounds.size.height/4*3, self.bounds.size.width/2, self.bounds.size.height/4)];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.progressTintColor = UIColorFromRGB(0x000000);
        _progressView.trackTintColor = UIColorFromRGB(0xffffff);
        [_photoView addSubview:_progressView];
        
//        _signImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-22-5, 5, 22, 22)];
//        _signImage.layer.cornerRadius = 22/2;
//        _signImage.image = WPhoto_btn_UnSelected;
//        _signImage.layer.masksToBounds = YES;
//        [_photoView addSubview:_signImage];
       
        _signImageButton =[[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-22-5, 5, 22, 22)];
        
        [_photoView addSubview:_signImageButton];
        
    }
    
    return self;
}

-(void)setProgressFloat:(CGFloat)progressFloat {
    _progressFloat = progressFloat;
    [_progressView setProgress:progressFloat animated:YES];
}
@end
