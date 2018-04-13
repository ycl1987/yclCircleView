//
//  CircleScrollView.m
//  artplus
//
//  Created by ycl on 15/9/1.
//  Copyright (c) 2015年 artron. All rights reserved.
//

#import "CircleScrollView.h"
#import "UIImageView+WebCache.h"

@interface CircleScrollView()

@property (nonatomic ,strong)NSTimer *timer; //定时器

@end

@implementation CircleScrollView

@synthesize photoPageControl;
@synthesize nowIndex;

- (void)dealloc{
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame andType:(CircleType)type withSuperView:(UIView *)view{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _scrollType = type;
        _superView = view;
        oldFrame = frame;
        [self createTheSubViews];
        self.scrollEnabled = NO;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(scrollViewActivity) userInfo:nil repeats:YES];
        [self.timer fire];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseTimer) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeTimer) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

- (void)scrollViewActivity{
    
    if (_dataArray.count == 1) return;
    [self setContentOffset:CGPointMake(SCREEN_WIDTH*2, 0) animated:YES];
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:self afterDelay:0.3];
}

- (void)setDataArray:(NSArray *)dataArray{
    
    if (_dataArray != dataArray) {
        
        _dataArray = dataArray;
    }
    
    if (_dataArray.count > 1) {
        self.scrollEnabled = YES;
    }
    [self loadDataOfTopScrollView];
}

- (void)setPageFrame:(CGRect)pageFrame{
    
    if (!CGRectEqualToRect(_pageFrame, pageFrame)) {
       
        _pageFrame = pageFrame;
        
    }
    if (!photoPageControl) {
        photoPageControl = [[UIPageControl alloc]initWithFrame:_pageFrame];
        [_superView addSubview:photoPageControl];
        photoPageControl.currentPageIndicatorTintColor = SYStemColorYellow;
        photoPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    }
    photoPageControl.numberOfPages = _dataArray.count;
    photoPageControl.currentPage = 0;
}

- (void)createTheSubViews{
    
    self.pagingEnabled = YES;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    self.contentSize = CGSizeMake(self.width * 3, self.height);
    for(NSInteger a = 0 ;a < 3; a ++){
        
        UIScrollView *photoBackScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(self.width * a, 0, self.width, self.height)];
        photoBackScroll.backgroundColor = [UIColor blackColor];
        photoBackScroll.delegate = self;
        photoBackScroll.tag = 1122 + a;
        photoBackScroll.maximumZoomScale = 2;
        photoBackScroll.minimumZoomScale = 1;
        photoBackScroll.showsHorizontalScrollIndicator = NO;
        photoBackScroll.showsVerticalScrollIndicator = NO;
        photoBackScroll.scrollsToTop = NO;

        
        UIImageView *photoImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        photoImg.tag = 200 + a;
        photoImg.userInteractionEnabled = YES;
        
        [photoBackScroll addSubview:photoImg];
        [self addSubview:photoBackScroll];
        
        if(_scrollType == TouchType){
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToSubViewAction:)];
            [photoBackScroll addGestureRecognizer:tap];
            
        }
    }
    
    if (_scrollType == TapType) {
        //单击事件
        singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageAction:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
    }
}

#pragma mark - UIScrollView 代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    
    if(scrollView == self){
        
        if (_dataArray.count == 0) {
            return;
        }
        
        if (scrollView.contentOffset.x > SCREEN_WIDTH) {
            nowIndex = (nowIndex + 1) % _dataArray.count;
        }else if(scrollView.contentOffset.x == 0){
            nowIndex = (nowIndex - 1 + _dataArray.count) % _dataArray.count;
        }else{
            return;
        }
        
        photoPageControl.currentPage = nowIndex;
        UIScrollView *mideScroll = (UIScrollView *)[scrollView viewWithTag:1123];
        mideScroll.zoomScale = 1;
        [self loadDataOfTopScrollView];
    }
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (scrollView.tag < 1122 || scrollView.tag > 1124 || self.height != SCREEN_HEIGHT) {
        return nil;
    }
    UIView *subView = [scrollView viewWithTag:scrollView.tag - 1122 + 200];
    return subView;
    
}

//让图片居中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIImageView *image = (UIImageView *)[scrollView viewWithTag:scrollView.tag - 1122 + 200];
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    image.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                               scrollView.contentSize.height * 0.5 + offsetY);
    
}

/**
 *  加载轮播视图的界面
 */
- (void)loadDataOfTopScrollView{
    
    if(_dataArray.count == 1) self.scrollEnabled = NO;
    if(_dataArray.count == 0 || !_dataArray || [_dataArray isKindOfClass:[NSNull class]]) return;
    self.contentOffset = CGPointMake(self.width, 0);
    NSInteger middle = nowIndex;
    NSInteger left = (nowIndex - 1 + _dataArray.count) % _dataArray.count;
    NSInteger right = (nowIndex + 1) % _dataArray.count;
    UIImageView *middleImage = (UIImageView *)[self viewWithTag:201];
    UIImageView *leftImage = (UIImageView *)[self viewWithTag:200];
    UIImageView *rightImage = (UIImageView *)[self viewWithTag:202];
    [middleImage setMyImageWithUrlstring:_dataArray[middle]];
    [leftImage setMyImageWithUrlstring:_dataArray[left]];
    [rightImage setMyImageWithUrlstring:_dataArray[right]];
}

/**
 *  单击时间
 *
 *  @param tap
 */
- (void)tapImageAction:(UITapGestureRecognizer *)tap{
    
    if (isFullScreen) {
        [self resetTheTopImageScrollView];
    }else{
        [self reloadTheTopImageScrollView];
    }
    isFullScreen = !isFullScreen;
}
/**
 *  图像双击放大事件
 *
 *  @param tap
 */
- (void)doubleTapAction:(UITapGestureRecognizer *)tap{
    
    UIScrollView *photoScrollView = (UIScrollView *)[self viewWithTag:1123];
    if (photoScrollView.zoomScale == 1) {
        
        CGPoint touchPoint = [tap locationInView:tap.view];
        [photoScrollView zoomToRect:CGRectMake(touchPoint.x - 25, touchPoint.y - 25, 50, 50) animated:YES];
        [photoScrollView setZoomScale:2 animated:YES];
    }else{
        [photoScrollView setZoomScale:1 animated:YES];
    }
    
    
}
/**
 *  对轮播图进行重新布局
 */
- (void)reloadTheTopImageScrollView{
    
    [[self viewController].view addSubview:self];
    self.backgroundColor = [UIColor blackColor];
    self.frame = [self viewController].view.frame;
    
    for (NSInteger a = 0; a < 3; a ++) {
        
        UIScrollView *scroll = (UIScrollView *)[self viewWithTag:1122 + a];
        CGRect frame = scroll.frame;
        scroll.zoomScale = scroll.minimumZoomScale = 1;
        scroll.maximumZoomScale = 2;
        frame.size.height = SCREEN_HEIGHT;
        scroll.frame = frame;
        UIImageView *imageView = (UIImageView *)[scroll viewWithTag:200 + a];
        
        if (a == 1) {
            BOOL isDoubleTap = NO;
            NSArray *tapArray = [imageView gestureRecognizers];
            for (UITapGestureRecognizer *tap in tapArray) {
                if ([tap isKindOfClass:[UITapGestureRecognizer class]]) {
                    if (tap.numberOfTapsRequired == 2) {
                        isDoubleTap = YES;
                    }
                }
            }
            if (!isDoubleTap) {
                UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
                doubleTap.numberOfTapsRequired = 2;
                [imageView addGestureRecognizer:doubleTap];
                [singleTap requireGestureRecognizerToFail:doubleTap];
            }
            
        }
        imageView.frame = CGRectMake(0, (SCREEN_HEIGHT - oldFrame.size.height)/2, oldFrame.size.width, oldFrame.size.height);
        
    }
    
    photoPageControl.frame = CGRectMake((SCREEN_WIDTH - 50)/2, SCREEN_HEIGHT - 50, 50, 10);
    photoPageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    photoPageControl.pageIndicatorTintColor = [UIColor grayColor];
    [[self viewController].view addSubview:photoPageControl];
    
}

/**
 *  对轮播图进行还原
 */
- (void)resetTheTopImageScrollView{
    
    [_superView insertSubview:self belowSubview:[self viewController].naviBar];
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, oldFrame.size.width, oldFrame.size.height);
    
    for (NSInteger a = 0; a < 3; a ++) {
        
        UIScrollView *scroll = (UIScrollView *)[self viewWithTag:1122 + a];
        CGRect frame = scroll.frame;
        frame.size.height = oldFrame.size.height;
        scroll.frame = frame;
        scroll.zoomScale = 1;
        scroll.contentSize = CGSizeMake(oldFrame.size.width, oldFrame.size.height);
        UIImageView *imageView = (UIImageView *)[scroll viewWithTag:200 + a];
        imageView.frame = CGRectMake(0, 0, oldFrame.size.width, oldFrame.size.height);
        
        if (a == 1) {
            
            NSArray *tapArray = [imageView gestureRecognizers];
            for (UITapGestureRecognizer *tap in tapArray) {
                if ([tap isKindOfClass:[UITapGestureRecognizer class]]) {
                    if (tap.numberOfTapsRequired == 2) {
                        [imageView removeGestureRecognizer:tap];
                    }
                }
            }
            
        }
        
    }
    
    photoPageControl.frame = _pageFrame;
    photoPageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    photoPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [_superView addSubview:photoPageControl];
    
}
- (void)tapToSubViewAction:(UITapGestureRecognizer *)tap{
    
    if (self.topImgedelegate) {
        if ([self.topImgedelegate respondsToSelector:@selector(imageClickAction:)]) {
            [self.topImgedelegate imageClickAction:@(nowIndex)];
        }
    }
}

- (BaseViewController *)viewController{
    //下一个响应者
    UIResponder *next=[self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (BaseViewController *)next;
        }
        next=[next nextResponder];
    } while (next!=nil);
    return nil;
}

- (void)pauseTimer{
    
    if (![self.timer isValid]) {
        return ;
    }
    [self.timer setFireDate:[NSDate distantFuture]]; //如果给我一个期限，我希望是4001-01-01 00:00:00 +0000
}

- (void)resumeTimer{
    
    if (![self.timer isValid]) {
        return ;
    }
    [self.timer setFireDate:[NSDate date]];
}

@end
