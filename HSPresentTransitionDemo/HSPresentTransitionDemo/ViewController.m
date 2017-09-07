//
//  ViewController.m
//  HSPresentTransitionDemo
//
//  Created by hejianyuan on 2017/5/4.
//  Copyright © 2017年 hejianyuan. All rights reserved.
//

#import "ViewController.h"
#import "HSLeftPresentAnimation.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@interface ViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 40;
    
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, 100, width-40, height);
    [btn1 setTitle:@"自定义Present1" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(btn1Action) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(20, 200, width-40, height);
    [btn2 setTitle:@"自定义Present2" forState:UIControlStateNormal];
    btn2.backgroundColor = [UIColor orangeColor];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(btn2Action) forControlEvents:UIControlEventTouchUpInside];
    
   
}

- (void)btn1Action{
    SecondViewController * secondVC = [[SecondViewController alloc] init];
    secondVC.transitioningDelegate = self;
    //secondVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [self presentViewController:secondVC animated:YES completion:nil];
}

- (void)btn2Action{
    ThirdViewController * thirdVC = [[ThirdViewController alloc] init];
    //thirdVC.transitioningDelegate = self;
    //thirdVC.transitioningDelegate = thirdVC;
   
    [self presentViewController:thirdVC animated:YES completion:nil];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    HSLeftPresentAnimation* leftPresentAnimation = [[HSLeftPresentAnimation alloc] init];
    leftPresentAnimation.isPresent = YES;
    return leftPresentAnimation;
}



@end
