iOS7.0后苹果提供了自定义转场动画的API，利用这些API我们可以改变 push和pop（navigation非模态），present和dismiss（模态），标签切换（tabbar）的默认转场动画。
## 主要涉及的API

1、UIViewControllerAnimatedTransitioning：转场动画协议，实现此协议定义转场的动画行为。

```
// 定义转场动画的时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext;

// 定义转场动画的行为
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;
```
2、 UIViewControllerContextTransitioning：转场动画上下文，这个协议定义了转场动画具体参数，控制转场动画的状态，这个协议一般由系统实现，在转场发生时提供给我们使用。

**From**和**To**：转场是两个视图控制器（ViewController）的行为，由一个视图控制器切换到另一个视图控制器，原先呈现的视图控制器叫**FromViewController**，将要呈现的视图控制器叫**ToViewController**，那么FromViewController的view叫做**FromView**，ToViewController的view叫做**ToView**。

对应push和pop来说是两个不同的转场，它们的From和To在两个转场中使相互调换的。
![控制器A push到 控制器B，那么From是A， To是B](http://upload-images.jianshu.io/upload_images/3447910-490fd1feb1f17ca4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![控制器B pop到 控制器A， 那么From是B， To是A](http://upload-images.jianshu.io/upload_images/3447910-5f10e34fa726ec5b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**containerView**:转场动画完成都是在containerView里面。

3、UIViewControllerInteractiveTransitioning：转场的交互协议，用来控制转场动画的状态或进度。
```
//设置转场进度, 取值范围 [0..1]
- (void)updateInteractiveTransition:(CGFloat)percentComplete;
//完成转场，呈现to
- (void)finishInteractiveTransition;
//取消转场，呈现from
- (void)cancelInteractiveTransition;
```
4、UIPercentDrivenInteractiveTransition：官方提供的实现UIViewControllerInteractiveTransitioning协议的类，可以直接使用。

上面简单的介绍了转场动画涉及的API，这一节主要通过导航控制器的push和pop转场动画来介绍这些自定义转场动画的流程。

## push转场动画
1、准备工作：
带有导航控制器的ViewController类，要push到的下一级控制器SecondViewController类。
2、在类HSPushAnimation中实现UIViewControllerAnimatedTransitioning协议，定义push转场动画行为。

```
@interface HSPushAnimation : NSObject <UIViewControllerAnimatedTransitioning>
@end 
``` 

```
@implementation HSPushAnimation
//设置转场动画的时长
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 2.f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //from
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
   //to
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    //UITransitionContextFromViewKey和UITransitionContextToViewKey定义在iOS8.0以后的SDK中，所以在iOS8.0以下SDK中将toViewController和fromViewController的view设置给toView和fromView
    //iOS8.0 之前和之后view的层次结构发生变化，所以iOS8.0以后UITransitionContextFromViewKey获得view并不是fromViewController的view
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    //这个非常重要，将toView加入到containerView中
    [[transitionContext containerView]  addSubview:toView];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    toView.frame = CGRectMake(width, 0, width, height);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.frame = CGRectMake(0, 0, width, height);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];

}
@end
```
上面代码定义了一个非常简单的动画，toView从左到右覆盖fromView，和系统默认动画一样，只是时间设置的比较长。

转场动画所有要呈现的元素都要放在containerView中，fromView默认已经在containerView中了。

3、指定push要使用的转场动画行为：由于要自定义转场动画所以我们需要指定转场动画行为。push转场的动画行为是由UINavigationControllerDelegate协议指定，所以我们在ViewController设置导航控制器的Delegate：
```
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}
```
实现以下协议，指定动画类：
```
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        return [[HSPushAnimation alloc] init];
    }
    return nil;
}
```
这个方法可以分别指定push和pop的动画类，这里我们只定义push动画，所以只要指定UINavigationControllerOperationPush时的动画行为即可。

这样push转场动画就完成了，效果图如下：
![自定义push动画](http://upload-images.jianshu.io/upload_images/3447910-053fb56b351bc178.gif?imageMogr2/auto-orient/strip)

## pop转场动画
1、pop转场动画和push转场动画类似，在类HSPopAnimation中实现UIViewControllerAnimatedTransitioning协议。
```
@implementation HSPopAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
   
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    //将toView加到fromView的下面，非常重要！！！
    [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    fromView.frame = CGRectMake(0, 0, width, height);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromView.frame = CGRectMake(width, 0, width, height);
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
```
这里pop动画基本和push动画是相反的过程，当然你也可以指定别的方式的动画。
这里from、to和push动画里面的from、to值已经互换了，所以如果将push和pop动画写在一起的话，要特别注意，不过建议**将push和pop动画分别定义到不同的类中**，方便管理。
2、在SecondViewControlle类中设置导航控制器的Delegate，并实现以下协议：
```
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPop) {
        return [[HSPopAnimation alloc] init];
    }
    return nil;
}
```
pop转场动画就完成了，效果图如下：
![pop转场动画](http://upload-images.jianshu.io/upload_images/3447910-4042d61d6e672957.gif?imageMogr2/auto-orient/strip)
## 可交互转场动画
先来看看可交互转场动画效果
![可交互转场动画](http://upload-images.jianshu.io/upload_images/3447910-c854036cce709a3f.gif?imageMogr2/auto-orient/strip)
可交互转场动画的实现需要实现UIViewControllerInteractiveTransitioning协议，幸好官方给我们提供了UIPercentDrivenInteractiveTransition类可以直接使用，你也可以继承UIPercentDrivenInteractiveTransition来使用。
UIViewControllerInteractiveTransitioning协议的功能主要是控制转场动画的状态，即动画完成的百分比，所以只有在转场中才有用。

比如我们通过``` [self.navigationController popViewControllerAnimated:YES]```触发pop转场动画，然后在转场动画结束之前通过```- (void)updateInteractiveTransition:(CGFloat)percentComplete```更改转场动画的完成的百分比，那么转场动画将由实现UIViewControllerInteractiveTransitioning的类接管，而不是由定时器管理，之后就可以随意设置动画状态了。

交互动画往往配合手势操作，手势操作产生一序列百分比数通过updateInteractiveTransition方法实时更新转场动画状态。

1、现在添加为SecondViewControlle的view添加手势：
```
//添加pan手势
UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] init];
[pan addTarget:self action:@selector(panGestureRecognizerAction:)];
[self.view addGestureRecognizer:pan];
```
2、触发转场动画，通过手势产生百分比数值，更新转场动画状态：
```
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan{
    
    //产生百分比
    CGFloat process = [pan translationInView:self.view].x / ([UIScreen mainScreen].bounds.size.width);
    
    process = MIN(1.0,(MAX(0.0, process)));
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
        //触发pop转场动画
        [self.navigationController popViewControllerAnimated:YES];
        
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
**手势开始状态**：手势开始时创建UIPercentDrivenInteractiveTransition对象，通过popViewControllerAnimated方法触发转场动画。
**手势变化状态**：通过计算得到的百分比实时更新转场动画的状态。
**手势取消或者结束状态**：根据完成的百分比决定是否完成转场或者取消转场。

3、开始转场动画时，就需要指定一个实现UIViewControllerInteractiveTransitioning协议的对象来控制转场动画的状态，否则转场动画状态由定时器管理。在SecondViewControlle类中，我们通过UINavigationControllerDelegate协议将interactiveTransition对象传给UIKit：

```
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}
```
```
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    if ([animationController isKindOfClass:[HSPopAnimation class]]) {
        return self.interactiveTransition;
    }
    return nil;
}
```
以上步骤就将pop的可交互转场动画完成了。

## push和pop转场动画基本流程

![push和pop转场动画基本流程图](http://upload-images.jianshu.io/upload_images/3447910-ed0597b08b758761.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> Note：
- 动画的状态和转场的状态是不一样的，动画完成后，不代表转场完成，所以我们要在动画的completion里面决定是否完成转场：[transitionContext completeTransition:!transitionContext.transitionWasCancelled];
- 转场是一个过程，所有的动画都在containerView里面完成。
- 不需要交互的转场interactionControllerForAnimationController方法一定要返回nil

✨文章的源码将在完成完成下篇present和dismiss动画时候上传。

本文作为读书笔记，不是科普读物，所以知识有可能理解错误，如有请您不吝赐教。