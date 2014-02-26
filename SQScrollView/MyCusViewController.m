//
//  MyCusViewController.m
//  SQScrollView
//
//  Created by Lingjunhou on 14-2-26.
//  Copyright (c) 2014年 LinjunHou. All rights reserved.
//

#import "MyCusViewController.h"

@interface MyCusViewController ()

@end

@implementation MyCusViewController

- (void)imageViewScale:(ScaleImageView *)imageScale clickCurImage:(UIImageView *)imageview
{

}
- (void)setImageViewthumbImage:(ScaleImageView *)scaleView withAsset:(id)asset
{
    scaleView.imageView.image = [UIImage imageNamed:asset];
}
- (void)setImageViewFullImage:(ScaleImageView *)scaleView withAsset:(id)asset byOrientation:(UIImageOrientation)orientation
{
    scaleView.imageView.image = [UIImage imageNamed:asset];

}
- (CGSize)getIdentifyImageSizeWithImageView:(ScaleImageView *)scaleView isPortraitorientation:(BOOL)isPortrait
{
    CGFloat w = 320;
    CGFloat h = 628;
    CGRect frameRect = CGRectZero;
    CGRect  screenFrame = [[UIScreen mainScreen] bounds];
    if (!isPortrait) {
        frameRect = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
    }else{
        frameRect = screenFrame;
    }
    
    CGRect rect = CGRectZero;
    CGFloat scale = MIN(frameRect.size.width / w, frameRect.size.height / h);
    rect = CGRectMake(0, 0, w * scale, h * scale);
    return rect.size;

}
- (void)getMoreAssetsWhenScrollLast
{
    return;
}
- (void)getMoreAssetsWhenScrollFirst
{
    return;
}

@end
