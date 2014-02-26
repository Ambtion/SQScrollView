//
//  ImageView_Scale.h
//  ScaleImageView
//
//  Created by sohu on 13-3-26.
//  Copyright (c) 2013年 Qu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoImageView : UIImageView <UIWebViewDelegate>
{
    UIActivityIndicatorView * actV;
    UIImageView * logo;
}
- (void)startLoading;
- (void)stopLoading;
@end

@class ScaleImageView;
@protocol ScaleImageViewDelegate <NSObject>
- (void)imageViewScale:(ScaleImageView *)imageScale clickCurImage:(UIImageView *)imageview;
@end

@interface ScaleImageView : UIScrollView<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    InfoImageView * _imageView;
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id<ScaleImageViewDelegate>)delegate;

@property(nonatomic,weak)id<ScaleImageViewDelegate> Adelegate;
@property(nonatomic,strong)InfoImageView * imageView;
@property(nonatomic,strong)id asset;
@property(nonatomic,assign)BOOL tapEnabled;
@end
