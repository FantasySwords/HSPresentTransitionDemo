//
//  ThirdViewController.m
//  HSPresentTransitionDemo
//
//  Created by hejianyuan on 2017/7/5.
//  Copyright © 2017年 hejianyuan. All rights reserved.
//

#import "ThirdViewController.h"
#import "HSPresentationController.h"


@interface ThirdViewController ()

@property (nonatomic, assign) BOOL isPresent;

//@property (nonatomic, strong) UIView * containerView;

@end

@implementation ThirdViewController

- (instancetype)init{
    if (self = [super init]) {
        //self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        self.isPresent = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor] ;
    
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat height = [UIScreen mainScreen].bounds.size.height;
//    
//    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, height - 100.f, width, 100.f)];
//    view.backgroundColor = [UIColor redColor];
//    [self.view addSubview:view];
//    
//    self.view.frame = CGRectMake(0, height - 100.f, width, 100.f);
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.isPresent = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self;
}


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
    
    transView.alpha = _isPresent ?0 :1.f;
    transView.superview.alpha =  _isPresent ?0 :1.f;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        transView.alpha = _isPresent ?1.f :0;
        transView.superview.alpha =  _isPresent ?1.f :0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source{
    return [[HSPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}


@end
