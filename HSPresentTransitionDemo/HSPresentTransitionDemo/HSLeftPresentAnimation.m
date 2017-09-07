//
//  HSLeftPresentAnimation.m
//  HSPresentTransitionDemo
//
//  Created by hejianyuan on 2017/5/6.
//  Copyright © 2017年 hejianyuan. All rights reserved.
//

#import "HSLeftPresentAnimation.h"

@implementation HSLeftPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1.f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    UIView* transView = nil;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    if (_isPresent) {
        transView = toView;
        [[transitionContext containerView] addSubview:toView];
        
    }else {
        transView = fromView;
        [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    transView.frame = CGRectMake(_isPresent ?width :0, 0, width, height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        transView.frame = CGRectMake(_isPresent ?0 :width, 0, width, height);
    } completion:^(BOOL finished) {
         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}

@end
