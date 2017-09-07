//
//  ViewController.m
//  HSPushPopTransitionDemo
//
//  Created by hejianyuan on 2017/5/4.
//  Copyright © 2017年 hejianyuan. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "HSPushAnimation.h"

@interface ViewController () <UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    self.navigationItem.title = @"Push转场动画Demo";
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 40;
    
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, 100, width-40, height);
    [btn1 setTitle:@"自定义Push" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.view addSubview:btn1];
   
    [btn1 addTarget:self action:@selector(btn1Action) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)btn1Action{
    SecondViewController * secondVC = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:secondVC animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        return [[HSPushAnimation alloc] init];
    }
    
    return nil;
}




@end
