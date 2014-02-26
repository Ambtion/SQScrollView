//
//  SQScrollViewController.m
//  SQScrollView
//
//  Created by Lingjunhou on 14-2-26.
//  Copyright (c) 2014年 LinjunHou. All rights reserved.
//

#import "SQScrollViewController.h"
#import "AppDelegate.h"

#define SPACING 20

static  UIDeviceOrientation preOrientation = UIDeviceOrientationPortrait;

@interface SQScrollViewController()
{
    BOOL _needRefreshDataSoure;
    BOOL _isRotating;
    BOOL _isAnimating;
}
@property(nonatomic,strong)NSMutableArray * assetsArray;
@property(nonatomic,assign)NSInteger curPageNum;
@property(nonatomic,strong)UIScrollView * scrollView;
@property(nonatomic,strong)ScaleImageView * fontScaleImage;
@property(nonatomic,strong)ScaleImageView * curScaleImage;
@property(nonatomic,strong)ScaleImageView * rearScaleImage;
@property(nonatomic,assign)BOOL isLoading;
@end

@implementation SQScrollViewController
@synthesize assetsArray = _assetsArray;
@synthesize curPageNum = _curPageNum;
@synthesize scrollView = _scrollView,fontScaleImage = _fontScaleImage,curScaleImage = _curScaleImage,rearScaleImage = _rearScaleImage;
@synthesize isLoading;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initSubView
- (id)initWithAssetsArray:(NSArray *)array andCurAsset:(id)asset
{
    self = [super init];
    if (self) {
        self.wantsFullScreenLayout = YES;
        _curImageArray = [NSMutableArray arrayWithCapacity:0];
        self.assetsArray = [NSMutableArray arrayWithArray:array];
        self.curPageNum = [array indexOfObject:asset];
    }
    return self;
}
-(void)loadView
{
    [super loadView];
    [self setup];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.wantsFullScreenLayout = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self loadAllScrollView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}
- (void)setup
{
    _needRefreshDataSoure = YES;
    _isRotating = NO;
    _isAnimating = NO;
}

#pragma mark - NavgationBar
- (void)refreshNavBarButtonState
{
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"NewTitle"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    self.navigationItem.rightBarButtonItem = nil;
    [self upNavBarTitle];
}

- (void)upNavBarTitle
{
    self.title = [NSString stringWithFormat:@"%d/%d",_curPageNum + 1, _assetsArray.count];
}

#pragma mark - ReloadSubViews
- (void)loadAllScrollView
{
    [self initSubViews];
    [self refreshNavBarButtonState];
    [self refreshScrollView];
}

- (void)initSubViews
{
    
    NSArray * aray = [self.view subviews];
    [aray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    CGRect rect = self.view.bounds;
    rect.size.width += SPACING * 2;
    rect.origin.x -= SPACING;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3 , 0);
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    [self loadScrollViewSubViews];
}
- (void)loadScrollViewSubViews
{
    
    self.fontScaleImage = [[ScaleImageView alloc] initWithFrame:CGRectMake(SPACING,0, self.view.bounds.size.width, self.view.bounds.size.height) andDelegate:self];
    
    self.curScaleImage = [[ScaleImageView alloc]initWithFrame:CGRectMake(SPACING + _scrollView.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height) andDelegate:self];
    
    self.rearScaleImage = [[ScaleImageView alloc] initWithFrame:CGRectMake(SPACING + _scrollView.bounds.size.width * 2, 0, self.view.bounds.size.width, self.view.bounds.size.height) andDelegate:self];
    
    [_scrollView addSubview:_fontScaleImage];
    [_scrollView addSubview:_rearScaleImage];
    [_scrollView addSubview:_curScaleImage];
}

#pragma mark - Ratation
- (CGAffineTransform )getTransfrom
{
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsPortrait(orientation))
        return CGAffineTransformIdentity;
    if (orientation == UIInterfaceOrientationLandscapeLeft)
        return CGAffineTransformRotate(CGAffineTransformIdentity, - M_PI_2);
    if (orientation == UIInterfaceOrientationLandscapeRight)
        return CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
    return CGAffineTransformIdentity;
}

- (ScaleImageView *)getCurrentImageView
{
    ScaleImageView * view = nil;
    if (self.scrollView.contentOffset.x == 0)
        view = self.fontScaleImage;
    if (self.scrollView.contentOffset.x == self.scrollView.frame.size.width)
        view = self.curScaleImage;
    if (self.scrollView.contentOffset.x == self.scrollView.frame.size.width * 2)
        view = self.rearScaleImage;
    return view;
}
- (BOOL)isSupportOrientation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (preOrientation != orientation
        &&(UIDeviceOrientationIsPortrait(orientation)
           || UIDeviceOrientationIsLandscape(orientation))) {
            if (UIDeviceOrientationIsLandscape(preOrientation))
                return UIDeviceOrientationIsPortrait(orientation);
            if (UIDeviceOrientationIsPortrait(preOrientation))
                return UIDeviceOrientationIsLandscape(orientation);
        }
    return NO;
}

- (void)listOrientationChanged:(NSNotification *)notification
{
    if (![self isSupportOrientation]) return;
    preOrientation = [[UIDevice currentDevice] orientation];
    [self.view setUserInteractionEnabled:NO];
    
    _isAnimating = YES;
    CGFloat scale = 1.0;
    CGAffineTransform transform = CGAffineTransformIdentity;
    //    [self getCurrentImageView].tapEnabled = NO;
    
    if (CGAffineTransformEqualToTransform([self getTransfrom], CGAffineTransformIdentity)) {
        transform = CGAffineTransformInvert(self.view.transform);
        CGSize identifySzie = [self getIdentifyImageSizeWithImageView:[self getCurrentImageView]isPortraitorientation:YES];
        scale = MIN( identifySzie.width / [self getCurrentImageView].imageView.frame.size.width, identifySzie.height / [self getCurrentImageView].frame.size.height);
    }else{
        CGSize identifySzie = [self getIdentifyImageSizeWithImageView:[self getCurrentImageView] isPortraitorientation:NO];
        scale = MIN( identifySzie.width / [self getCurrentImageView].imageView.frame.size.width, identifySzie.height / [self getCurrentImageView].imageView.frame.size.height);
        transform = [self getTransfrom];
    }
    
    transform  = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(scale, scale));
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut    animations:^{
        [self getCurrentImageView].imageView.transform = transform;
    } completion:^(BOOL finished) {
        self.view.transform = [self getTransfrom];
        if (CGAffineTransformEqualToTransform(self.view.transform, CGAffineTransformIdentity))
            self.view.frame = [UIScreen mainScreen].bounds;
        [self loadAllScrollView];
        _isAnimating = NO;
        _isRotating = YES;
        [self.view setUserInteractionEnabled:YES];
        
    }];
}


#pragma mark - Refresh ScrollView
- (void)refreshScrollView
{
    if (!self.assetsArray.count) return;
    _needRefreshDataSoure = YES;
    
    self.curPageNum = [self validPageValue:self.curPageNum];
    
    //prevent than  when seting offset it can  scrollViewDidScroll
    _scrollView.delegate = nil;
    [self upNavBarTitle];
    if (self.assetsArray.count <= 3) {
        [self refreshScrollViewWhenPhotonumLessThree];
    }else if (_curPageNum == 0) {
        [self refreshScrollViewOnMinBounds];
    }else if (_curPageNum == self.assetsArray.count - 1) {
        [self refreshScrollViewOnMaxBounds];
    }else{
        [self refreshScrollViewNormal];
    }
    _scrollView.delegate = self;
    [self scrollViewDidEndDecelerating:_scrollView];
    
}
- (void)refreshScrollViewOnMinBounds
{
    [self setImageViewAsset:_fontScaleImage withAsset:[_assetsArray objectAtIndex:0]];
    [self setImageViewAsset:_curScaleImage withAsset:[_assetsArray objectAtIndex:1]];
    [self setImageViewAsset:_rearScaleImage withAsset:[_assetsArray objectAtIndex:2]];
    [self resetAllImagesFrame];
    [_scrollView setContentOffset:CGPointZero];
    _imagestate = AtLess;
}
- (void)refreshScrollViewOnMaxBounds
{
    [self setImageViewAsset:_fontScaleImage withAsset:[_assetsArray objectAtIndex:_assetsArray.count - 3]];
    [self setImageViewAsset:_curScaleImage  withAsset:[_assetsArray objectAtIndex:_assetsArray.count - 2]];
    [self setImageViewAsset:_rearScaleImage withAsset:[_assetsArray objectAtIndex:_assetsArray.count - 1]];
    [self resetAllImagesFrame];
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 2,0)];
    _imagestate = AtMore;
}

- (void)refreshScrollViewWhenPhotonumLessThree
{
    [self setImageViewAsset:_fontScaleImage withAsset:[_assetsArray objectAtIndex:0]];
    if (_assetsArray.count == 2) {
        
        [self setImageViewAsset:_curScaleImage withAsset:[_assetsArray objectAtIndex:1]];
        
    }else if(_assetsArray.count == 3){
        [self setImageViewAsset:_curScaleImage withAsset:[_assetsArray objectAtIndex:1]];
        [self setImageViewAsset:_rearScaleImage withAsset:[_assetsArray objectAtIndex:2]];
    }else{
        _curScaleImage.imageView.image = nil;
        _rearScaleImage.imageView.image = nil;
    }
    [self resetAllImagesFrame];
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width *_assetsArray.count , 0)];
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * _curPageNum, 0)];
    
}

- (void)refreshScrollViewNormal
{
    if ([self getDisplayImagesWithCurpage:_curPageNum])
    {
        //read images into curImages
        [self setImageViewAsset:_fontScaleImage withAsset:[_curImageArray objectAtIndex:0]];
        [self setImageViewAsset:_curScaleImage withAsset:[_curImageArray objectAtIndex:1]];
        [self setImageViewAsset:_rearScaleImage withAsset:[_curImageArray objectAtIndex:2]];
        [self resetAllImagesFrame];
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
    _imagestate = AtNomal;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if (_isAnimating || !_assetsArray.count)  return;
    if (_assetsArray.count <= 3) {
        _curPageNum = _scrollView.contentOffset.x / _scrollView.frame.size.width;
        _curPageNum = [self validPageValue:_curPageNum];
        [self upNavBarTitle];
        return;
    }
    
    //默认图片数量最小的值大于3
    if (self.curPageNum == _assetsArray.count - 2)
        [self getMoreAssetsWhenScrollLast];
    if (self.curPageNum == 1)
        [self getMoreAssetsWhenScrollFirst];
    
    int  x = aScrollView.contentOffset.x;
    if (x == aScrollView.frame.size.width) {
        if (_imagestate != AtNomal) {
            if (_imagestate == AtLess) _curPageNum = [self validPageValue:_curPageNum + 1];
            if (_imagestate == AtMore) _curPageNum = [self validPageValue:_curPageNum - 1];
            _imagestate = AtNomal;
            [self refreshScrollView];
        }
        return;
    }
    
    //right
    if(x >= (aScrollView.frame.size.width * 2) && _curPageNum <= _assetsArray.count - 2) {
        _curPageNum = [self validPageValue:_curPageNum + 1];
        [self refreshScrollView];
        return;
    }
    if(x == (aScrollView.frame.size.width * 2) && _curPageNum == _assetsArray.count - 2) {
        _curPageNum = [self validPageValue:_curPageNum + 1];
        [self refreshScrollView];
        return;
    }
    //left
    if(x <= 0 && _curPageNum >= 1) {
        _curPageNum = [self validPageValue:_curPageNum - 1];
        [self refreshScrollView];
        return;
    }
    if(x == 0  && _curPageNum == 1) {
        _curPageNum = [self validPageValue:_curPageNum - 1];
        [self refreshScrollView];
        return;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self fixScrollViewOffset:scrollView];
    if (_needRefreshDataSoure){
        [self reloadScrollViewData];
        _needRefreshDataSoure =  NO;
    }
}

- (void)fixScrollViewOffset:(UIScrollView *)scrollView
{
    if (_assetsArray.count <= 3) return;
    CGPoint point = CGPointZero;
    point.y = 0;
    if (_curPageNum > 0 && _curPageNum < self.assetsArray.count - 1) {
        point.x = scrollView.frame.size.width;
    }else if(_curPageNum == 0){
        point.x = 0;
    }else {
        point.x = scrollView.frame.size.width * 2;
    }
    [scrollView setContentOffset:point animated:NO];
}

#pragma mark - Get_ImageFromAsset
- (void)reloadScrollViewData
{
    if (_assetsArray.count <= 3) {
        switch (_assetsArray.count) {
            case 1:
                [self setImageViewFullImage:_fontScaleImage withAsset:[_assetsArray objectAtIndex:0] byOrientation:0];
                
                break;
            case 2:
                [self setImageViewFullImage:_fontScaleImage withAsset:[_assetsArray objectAtIndex:0] byOrientation:0];
                [self setImageViewFullImage:_curScaleImage withAsset:[_assetsArray objectAtIndex:1] byOrientation:0];
                
                break;
            case 3:
                [self setImageViewFullImage:_fontScaleImage withAsset:[_assetsArray objectAtIndex:0] byOrientation:0];
                [self setImageViewFullImage:_curScaleImage withAsset:[_assetsArray objectAtIndex:1] byOrientation:0];
                [self setImageViewFullImage:_rearScaleImage withAsset:[_assetsArray objectAtIndex:2] byOrientation:0];
                
                break;
            default:
                break;
        }
        return ;
    }
    if (_imagestate == AtLess) {
        [self setImageViewFullImage:_fontScaleImage withAsset:[_assetsArray objectAtIndex:0] byOrientation:0];
    }else if (_imagestate == AtMore) {
        [self setImageViewFullImage:_rearScaleImage withAsset:[_assetsArray lastObject] byOrientation:0];
    }else{
        [self setImageViewFullImage:_curScaleImage withAsset:[_assetsArray objectAtIndex:_curPageNum] byOrientation:0];
    }
}
- (void)setImageViewAsset:(ScaleImageView *)scaleView withAsset:(id)asset
{
    scaleView.asset = asset;
    [self setImageViewthumbImage:scaleView withAsset:asset];
}
#pragma mark - Overload function
- (void)imageViewScale:(ScaleImageView *)imageScale clickCurPageImage:(UIImageView *)imageview
{
    [NSException raise:NSInternalInconsistencyException format:@"you must override %@ in a subclass",NSStringFromSelector(_cmd)];
}
- (void)setImageViewthumbImage:(ScaleImageView *)scaleView withAsset:(id)asset
{
    [NSException raise:NSInternalInconsistencyException format:@"you must override %@ in a subclass",NSStringFromSelector(_cmd)];
}
- (void)setImageViewFullImage:(ScaleImageView *)scaleView withAsset:(id)asset byOrientation:(UIImageOrientation)orientation
{
   [NSException raise:NSInternalInconsistencyException format:@"you must override %@ in a subclass",NSStringFromSelector(_cmd)];
}

- (CGSize)getIdentifyImageSizeWithImageView:(ScaleImageView *)scaleView isPortraitorientation:(BOOL)isPortrait
{
    [NSException raise:NSInternalInconsistencyException format:@"you must override %@ in a subclass",NSStringFromSelector(_cmd)];
    return CGSizeZero;
}
- (void)getMoreAssetsWhenScrollLast
{
    [NSException raise:NSInternalInconsistencyException format:@"you must override %@ in a subclass",NSStringFromSelector(_cmd)];
}
- (void)getMoreAssetsWhenScrollFirst
{
    [NSException raise:NSInternalInconsistencyException format:@"you must override %@ in a subclass",NSStringFromSelector(_cmd)];
}
#pragma mark - BarDelegate

#pragma mark - Function
- (void)resetImageRect:(ScaleImageView *)scaleImage
{
    UIImageView * imageView = scaleImage.imageView;
    CGSize size = [self getIdentifyImageSizeWithImageView:scaleImage isPortraitorientation:CGAffineTransformEqualToTransform(CGAffineTransformIdentity, [self getTransfrom])];
    CGSize ratationSize = [self.view bounds].size;
    if (imageView.image) {
        imageView.frame = (CGRect){0,0,size};
    }else{
        imageView.frame = CGRectMake(0, 0, size.width,size.height);
    }
    imageView.center = CGPointMake(ratationSize.width / 2.f, ratationSize.height /2.f);
}

- (void)resetAllImagesFrame
{
    //设置图片的大小
    _fontScaleImage.zoomScale = 1.f;
    _curScaleImage.zoomScale = 1.f;
    _rearScaleImage.zoomScale = 1.f;
    [self resetImageRect:_curScaleImage];
    [self resetImageRect:_fontScaleImage];
    [self resetImageRect:_rearScaleImage];
}
- (NSArray *)getDisplayImagesWithCurpage:(int)page
{
    int pre = [self validPageValue:_curPageNum -1];
    int last = [self validPageValue:_curPageNum+1];
    if([_curImageArray count] != 0) [_curImageArray removeAllObjects];
    [_curImageArray addObject:[_assetsArray objectAtIndex:pre]];
    [_curImageArray addObject:[_assetsArray objectAtIndex:_curPageNum]];
    [_curImageArray addObject:[_assetsArray objectAtIndex:last]];
    return _curImageArray;
}
- (int)validPageValue:(NSInteger)value
{
    if(value <= 0) value = 0;                   // value＝1为第一张，value = 0为前面一张
    if(value >= _assetsArray.count){
        value = _assetsArray.count - 1;
    }
    return value;
}

- (void)imageViewScale:(ScaleImageView *)imageScale clickCurImage:(UIImageView *)imageview
{
    [self imageViewScale:imageScale clickCurPageImage:imageview];
}
@end
