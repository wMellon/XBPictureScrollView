//
//  XBPictureScrollView.m
//  XBPictureScroll
//
//  Created by xxb on 17/2/23.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "XBPictureScrollView.h"

#define PageControlHeight 20

@interface XBPictureScrollView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger numbersOfPic;//代理设置的总个数
@property (nonatomic, assign) NSInteger initIndex;//初始索引
@property (nonatomic, assign) NSInteger currentIndex;//当前索引
@property (nonatomic, assign) BOOL autoScroll;//定时器自动滚动

@end

@implementation XBPictureScrollView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.autoScrollTimeInterval = 2;//默认2s
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.autoScroll = NO;
    [self invalidateTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.autoScroll = YES;
    [self setupTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //所以只剩下手动拖拽了
    if(!self.autoScroll){
        NSInteger temp = scrollView.contentOffset.x / scrollView.frame.size.width;
        self.currentIndex = temp;
        if(self.currentIndex >= _numbersOfPic + 1){
            self.currentIndex = self.initIndex;
            [self.scrollView scrollRectToVisible:CGRectMake(self.initIndex * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height) animated:NO];
        }
        //手动拖动后，会调用四次该方法，所以下面用这种方式判断
        if(scrollView.contentOffset.x == 0){
            self.currentIndex = self.numbersOfPic;
            [self.scrollView scrollRectToVisible:CGRectMake(self.currentIndex * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height) animated:NO];
        }
        //设置pageControl
        self.pageControl.currentPage = self.currentIndex - 1;
    }
}

#pragma mark - action

- (void)setupTimer{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer{
    [_timer invalidate];
    _timer = nil;
}

-(void)automaticScroll{
    self.currentIndex ++;//索引+1
    [UIView animateWithDuration:0.5 animations:^{
        [self.scrollView setContentOffset:CGPointMake(self.currentIndex * self.frame.size.width, 0)];
        //会先调用scrollViewDidScroll方法，然后才结束
    } completion:^(BOOL finished) {
        if(self.currentIndex >= _numbersOfPic + 1){
            [self.scrollView scrollRectToVisible:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:NO];
            self.currentIndex = self.initIndex;
        }
        //设置pageControl
        self.pageControl.currentPage = self.currentIndex - 1;
    }];
}

-(void)reloadData{
    if(![self.delegate respondsToSelector:@selector(numberOfPicture)] ||
       ![self.delegate respondsToSelector:@selector(eachSceneThe:index:)]){
        //没有实现这两个方法都不做处理
        return;
    }
    self.numbersOfPic = [self.delegate numberOfPicture];
    if(self.numbersOfPic <= 0){
        return;
    }
    NSInteger realCount = self.numbersOfPic;
    self.initIndex = 0;
    self.currentIndex = 0;
    if(self.numbersOfPic > 1){
        realCount += 2; //第一张图片再添加一次到最后一个位置；最后一张图片再添加一次到第一个位置
        self.initIndex = 1;
        self.currentIndex = 1;
    }
    //设置scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * realCount, self.frame.size.height);
    //为每个页面设置图片
    UIImageView *imageView;
    UITapGestureRecognizer *tapGesture;
    NSInteger realIndex = 0;
    for(int i = 0; i < self.numbersOfPic; i++){
        if(realCount > 1 && i == 0){
            //留下第一个位置出来
            realIndex ++;
            //添加第一张图片到最后一个位置
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.numbersOfPic + 1) * self.scrollView.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
            imageView.backgroundColor = [UIColor redColor];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
            [imageView addGestureRecognizer:tapGesture];
            [self.scrollView addSubview:imageView];
            [self.delegate eachSceneThe:imageView index:0];
        }
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(realIndex * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [imageView addGestureRecognizer:tapGesture];
        [self.scrollView addSubview:imageView];
        [self.delegate eachSceneThe:imageView index:i];
        if(realCount > 1 && i == self.numbersOfPic - 1){
            //最后一张图片再添加一次到第一个位置
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
            [imageView addGestureRecognizer:tapGesture];
            [self.scrollView addSubview:imageView];
            [self.delegate eachSceneThe:imageView index:i];
        }
        realIndex ++;
    }
    
    //scrollview设置
    if(self.numbersOfPic > 1){
        [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
    }
    //pageControl设置
    _pageControl.numberOfPages = self.numbersOfPic;
    _pageControl.currentPage = 0;
    
    //对定时器做设置
    if(self.numbersOfPic > 1){
        [self setupTimer];
        self.autoScroll = YES;
    }else{
        [self invalidateTimer];
        self.autoScroll = NO;
    }
}

-(void)imageClick:(id)sender{
    UIImageView *imageView = (UIImageView*)((UITapGestureRecognizer*)sender).view;
    if([self.delegate respondsToSelector:@selector(imageClickForIndex:)]){
        [self.delegate imageClickForIndex:imageView.tag];
    }
}

-(void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor{
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

-(void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor{
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

#pragma mark - properties

-(UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

-(UIPageControl *)pageControl{
    if(!_pageControl){
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - PageControlHeight, self.frame.size.width, PageControlHeight)];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

-(void)setDelegate:(id<XBPictureScrollDelegate>)delegate{
    _delegate = delegate;
    [self reloadData];
}

@end
