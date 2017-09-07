自定义present、dismiss转场动画的步骤和自定义push、pop转场动画的步骤是一致的，相关内容请看[《iOS自定义转场动画-push和pop》](http://www.jianshu.com/p/28b9523d70a9)。

## 主要涉及的API
这里的内容是[《iOS自定义转场动画-push和pop》](http://www.jianshu.com/p/28b9523d70a9)的补充内容。

push和pop自定义转场动画通过导航控制器的UINavigationControllerDelegate配置，而present和dismiss自定义转场动画通过控制器的本身属性transitioningDelegate（UIViewControllerTransitioningDelegate）配置。

下面是要用到UIViewControllerTransitioningDelegate的几个方法：
```
//指定present动画
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;
//指定dismiss动画
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed;
//指定交互式present动画的控制类
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator;
//指定交互式dismiss动画的控制类
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator;
```
## present转场动画
1、准备工作：
ViewController类，要present到的下一级控制器SecondViewController类。
2、实现present动画：
这里演示的动画类似原生的push和pop动画，present时界面由右向左覆盖上一级界面，dismiss相反过程。

HSLeftPresentAnimation类定义：
```
@interface HSLeftPresentAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresent;

@end

```
为了方便我们将present和dismiss动画写在一起，通过属性isPresent设置动画类型。

```
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
```

3、指定present要使用的转场动画行为：present转场的动画行为是由UIViewControllerTransitioningDelegate协议指定，所以我们设置secondVC的transitioningDelegate属性：
```
SecondViewController * secondVC = [[SecondViewController alloc] init];
secondVC.transitioningDelegate = self;
 [self presentViewController:secondVC animated:YES completion:nil];
```
实现以下协议，指定动画类：
```
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    HSLeftPresentAnimation* leftPresentAnimation = [[HSLeftPresentAnimation alloc] init];
    leftPresentAnimation.isPresent = YES;
    return leftPresentAnimation;
}
```

这样present转场动画就完成了，效果图如下：
![present转场动画](http://upload-images.jianshu.io/upload_images/3447910-9318c9a5bcf88000.gif?imageMogr2/auto-orient/strip)
## dimiss转场动画
自定义dimiss转场动画和present动画步骤一样，在SecondViewController类里面指定transitioningDelegate，并实现协议方法即可。

```
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.transitioningDelegate = self;
}
```

```
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    HSLeftPresentAnimation* leftPresentAnimation = [[HSLeftPresentAnimation alloc] init];
    leftPresentAnimation.isPresent = NO;
    return leftPresentAnimation;

}
```
dimiss转场动画效果图：
![dimiss转场动画效果图](http://upload-images.jianshu.io/upload_images/3447910-2efafdb72195c4eb.gif?imageMogr2/auto-orient/strip)

##  dismiss变为可交互转场动画
现在我们也希望通过向右拖拽界面将界面dismiss掉，上一篇文章有说到可交互转场通过实现UIViewControllerInteractiveTransitioning的协议的类控制，官方为我们提供了一个通过百分比控制交互转场动画的类UIPercentDrivenInteractiveTransition。那么我们就使用它将dismiss变为可交互转场动画。
1、在SecondViewController里面添加手势
```
 //添加手势
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(panGestureRecognizerAction:)];
    [self.view addGestureRecognizer:pan];
```
2、添加手势处理代码：
 ```
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
```
这里和pop手势处理一模一样只是更换了触发dismiss转场动画的代码。

3、通过UIViewControllerTransitioningDelegate指定交互动画的控制类
```
-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return self.interactiveTransition;
}
```
现在基本完成了可交互的dismiss转场动画：
![可交互的dismiss转场动画](http://upload-images.jianshu.io/upload_images/3447910-e29a2d35d1a76d5d.gif?imageMogr2/auto-orient/strip)