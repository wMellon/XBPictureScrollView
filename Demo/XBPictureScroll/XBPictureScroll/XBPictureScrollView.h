//
//  XBPictureScrollView.h
//  XBPictureScroll
//
//  Created by xxb on 17/2/23.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XBPictureScrollDelegate <NSObject>

@required
-(NSInteger)numberOfPicture;
-(void)eachSceneThe:(UIImageView*)imageView index:(NSInteger)index;

@optional
-(void)imageClickForIndex:(NSInteger)index;//图片点击

@end

@interface XBPictureScrollView : UIView

@property (nonatomic, strong) UIColor *pageIndicatorTintColor;//pageControl的默认颜色
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;//pageControl选中时的颜色
@property (nonatomic, assign) NSTimeInterval autoScrollTimeInterval;//滚动间隔，默认2s
@property (nonatomic, assign) id<XBPictureScrollDelegate> delegate;

-(void)reloadData;

@end
