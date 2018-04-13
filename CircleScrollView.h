//
//  CircleScrollView.h
//  artplus
//
//  Created by ycl on 15/9/1.
//  Copyright (c) 2015年 artron. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CircleType){
    
    NormalType = 0,//常规模式
    TapType = 1,   //点击查看大图模式
    TouchType = 2  //点击跳到相应界面
};

@protocol TopImageTapDelegate <NSObject>
//图片点击查看大图
- (void)imageClickAction:(NSNumber *)indexInArray;

@end

@interface CircleScrollView : UIScrollView<UIScrollViewDelegate>{
    
    UITapGestureRecognizer *singleTap;
    CGRect oldFrame;
    BOOL isFullScreen;//是否全屏显示
}

@property(nonatomic ,assign)CircleType scrollType;
@property(nonatomic ,strong)UIView *superView;
@property(nonatomic ,assign)NSInteger nowIndex;//现在scrollview所在的位置
@property(nonatomic ,assign)CGRect pageFrame;
@property(nonatomic ,strong)NSArray *dataArray;//对应的图片网址数组
@property(nonatomic ,assign)id<TopImageTapDelegate>topImgedelegate;
@property(nonatomic ,strong)UIPageControl *photoPageControl;

- (instancetype)initWithFrame:(CGRect)frame andType:(CircleType)type withSuperView:(UIView *)view;
//定时器暂停
-(void)pauseTimer;
//定时器恢复
-(void)resumeTimer;

@end
