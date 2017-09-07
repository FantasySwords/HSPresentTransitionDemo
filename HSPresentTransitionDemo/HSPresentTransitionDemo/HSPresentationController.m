//
//  HSPresentationController.m
//  HSPresentTransitionDemo
//
//  Created by hejianyuan on 2017/7/6.
//  Copyright © 2017年 hejianyuan. All rights reserved.
//

#import "HSPresentationController.h"

@implementation HSPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController{
    
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        
    }
    
    return self;
}

- (void)containerViewWillLayoutSubviews{
    self.presentedView.frame = CGRectMake(100, 100, 100, 100);
    self.containerView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    
}


@end
