//
//  ViewController.m
//  XBPictureScroll
//
//  Created by xxb on 17/2/23.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "ViewController.h"
#import "XBPictureScrollView.h"

@interface ViewController ()<XBPictureScrollDelegate>

@property (nonatomic, strong) XBPictureScrollView *scrollView;
@property (nonatomic, strong) NSArray *imageNames;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageNames = @[@"image01.jpg", @"image02.jpg", @"image03.jpg"];
    self.scrollView = [[XBPictureScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    self.scrollView.autoScrollTimeInterval = 2;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

-(NSInteger)numberOfPicture{
    return self.imageNames.count;
}
-(void)eachSceneThe:(UIImageView*)imageView index:(NSInteger)index{
    imageView.image = [UIImage imageNamed:self.imageNames[index]];
}

-(void)imageClickForIndex:(NSInteger)index{
    NSLog(@"图片%ld被点击", (long)index);
}

@end
