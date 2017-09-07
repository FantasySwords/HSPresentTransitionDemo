//
//  SecondViewController.m
//  HSPresentTransitionDemo
//
//  Created by hejianyuan on 2017/5/6.
//  Copyright © 2017年 hejianyuan. All rights reserved.
//

#import "SecondViewController.h"
#import "HSLeftPresentAnimation.h"
#import "ThirdViewController.h"

@interface SecondViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition* interactiveTransition;

@end

@implementation SecondViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.transitioningDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 40;

    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, 100, width-40, height);
    [btn1 setTitle:@"关闭" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(btn1Action) forControlEvents:UIControlEventTouchUpInside];
    
    //添加手势
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(panGestureRecognizerAction:)];
    [self.view addGestureRecognizer:pan];
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan{
    
    //产生百分比
    CGFloat process = [pan translationInView:self.view].x / ([UIScreen mainScreen].bounds.size.width);
    
    process = MIN(1.0,(MAX(0.0, process)));
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
        //触发dismiss转场动画
        [self dismissViewControllerAnimated:YES completion:nil];

    }else if (pan.state == UIGestureRecognizerStateChanged){
        [self.interactiveTransition updateInteractiveTransition:process];
    }else if (pan.state == UIGestureRecognizerStateEnded
              || pan.state == UIGestureRecognizerStateCancelled){
        if (process > 0.5) {
            [ self.interactiveTransition finishInteractiveTransition];
        }else{
            [ self.interactiveTransition cancelInteractiveTransition];
        }
        self.interactiveTransition = nil;
    }
}

- (void)btn1Action{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    HSLeftPresentAnimation* leftPresentAnimation = [[HSLeftPresentAnimation alloc] init];
    leftPresentAnimation.isPresent = NO;
    return leftPresentAnimation;

}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return self.interactiveTransition;
}

@end
