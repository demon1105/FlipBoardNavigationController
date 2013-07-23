//
//  FlipBoardNavigationController.m
//  iamkel.net
//
//  Created by Michael henry Pantaleon on 4/30/13.
//  Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
//

#import "FlipBoardNavigationController.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kAnimationDuration = 0.5f;
static const CGFloat kAnimationDelay = 0.0f;
static const CGFloat kOffsetTrigger = 30.0f;
static const CGFloat kMaxBlackMaskAlpha = 0.8f;
static const CGFloat kViewScaleSize = 0.95f;


typedef enum {
    PanDirectionNone = 0,
    PanDirectionLeft = 1,
    PanDirectionRight = 2
} PanDirection;


@interface FlipBoardNavigationController ()<UIGestureRecognizerDelegate>{
    NSMutableArray *_gestures;
    UIView *_blackMask;
    CGPoint _panOrigin;
    BOOL _animationInProgress;
}

- (void) addPanGestureToView:(UIView*)view;
- (CGRect) getSlidingRectForOffset:(CGFloat)offset ;
- (void) rollBackViewController;
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction;

- (UIViewController *)currentViewController;
- (UIViewController *)previousViewController;
@end

@implementation FlipBoardNavigationController

- (id) initWithRootViewController:(UIViewController*)rootViewController {
    if (self = [super init]) {
        self.viewControllers = [NSMutableArray arrayWithObject:rootViewController];
    }
    return self;
}

- (void) dealloc {
    self.viewControllers = nil;
    _gestures  = nil;
    _blackMask = nil;
}

- (void) loadView {
    [super loadView];
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    [rootViewController willMoveToParentViewController:self];
    [self addChildViewController:rootViewController];
    UIView * rootView = rootViewController.view;
    CGSize viewSize = self.view.frame.size;
    rootView.frame = CGRectMake(0.0f, 0.0f, viewSize.width, viewSize.height);
    [self.view addSubview:rootView];
    [rootViewController didMoveToParentViewController:self];
    _blackMask = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewSize.width, viewSize.height)];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0;
    [self.view insertSubview:_blackMask atIndex:0];
    
}
-(void)addRightPanViewController:(UIViewController*)viewController
{
    [self.view addSubview:viewController.view];
    [self addPanGestureToView:viewController.view];
}
#pragma mark - PushViewController With Completion Block
- (void) pushViewController:(UIViewController *)viewController completion:(FlipBoardNavigationControllerCompletionBlock)handler {
    _animationInProgress = YES;
    viewController.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
    _blackMask.alpha = 0.0;
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view bringSubviewToFront:_blackMask];
    [self.view addSubview:viewController.view];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        [self currentViewController].view.transform = CGAffineTransformScale(transf, kViewScaleSize, kViewScaleSize);
        viewController.view.frame = self.view.bounds;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            [self.viewControllers addObject:viewController];
            [viewController didMoveToParentViewController:self];
            _animationInProgress = NO;
            _gestures = [[NSMutableArray alloc] init];
            [self addPanGestureToView:[self currentViewController].view];
            handler();
        }
    }];
}

- (void) pushViewController:(UIViewController *)viewController {
    [self pushViewController:viewController completion:^{}];
}

#pragma mark - PopViewController With Completion Block
- (void) popViewControllerWithCompletion:(FlipBoardNavigationControllerCompletionBlock)handler {
    _animationInProgress = YES;
    if (self.viewControllers.count < 2) {
        return;
    }
    UIViewController *currentVC = [self currentViewController];
    UIViewController *previousVC = [self previousViewController];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        currentVC.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        CGAffineTransform transf = CGAffineTransformIdentity;
        previousVC.view.transform = CGAffineTransformScale(transf, 1.0, 1.0);
        previousVC.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [currentVC willMoveToParentViewController:nil];
            [self.view bringSubviewToFront:[self previousViewController].view];
            [currentVC removeFromParentViewController];
            [currentVC didMoveToParentViewController:nil];
            [currentVC.view removeFromSuperview];///修正view不能释放 jack 2013-7-2
            [self.viewControllers removeObject:currentVC];
            _animationInProgress = NO;
            handler();
        }
    }];
    
}

- (void) popViewController:(UIViewController*)viewControler withCompletion:(FlipBoardNavigationControllerCompletionBlock)handler
{
    BOOL exist = NO;
    for (UIViewController * subControler in  self.viewControllers)
    {
        if(subControler==viewControler)
        {
            exist = YES;
            break;
        }
    }
    if (self.viewControllers.count < 2||!exist) {
        return;
    }
    
    UIViewController *currentVC    = [self currentViewController];
    if(currentVC==viewControler)
    {
        [self popViewControllerWithCompletion:handler];
        return;
    }
    
    [viewControler willMoveToParentViewController:nil];
    [viewControler removeFromParentViewController];
    [viewControler didMoveToParentViewController:nil];
    [viewControler.view removeFromSuperview];
    [self.viewControllers removeObject:viewControler];
    handler();
}

- (void) popViewController {
    [self popViewControllerWithCompletion:^{}];
}

- (void) rollBackViewController {
    _animationInProgress = YES;
    
    UIViewController * vc = [self currentViewController];
    UIViewController * nvc = [self previousViewController];
    CGRect rect = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    self.view.transform = self.view.transform;
    [UIView animateWithDuration:((vc.view.frame.origin.x *kAnimationDuration)/self.view.frame.size.width) delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        nvc.view.transform = CGAffineTransformScale(transf, kViewScaleSize, kViewScaleSize);
        vc.view.frame = rect;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            _animationInProgress = NO;
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ChildViewController
- (UIViewController *)currentViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>0) {
        result = [self.viewControllers lastObject];
    }
    return result;
}

#pragma mark - ParentViewController
- (UIViewController *)previousViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>1) {
        result = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
    }
    return result;
}

#pragma mark - Add Pan Gesture
- (void) addPanGestureToView:(UIView*)view
{
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(gestureRecognizerDidPan:)];
    panGesture.cancelsTouchesInView = YES;
    panGesture.maximumNumberOfTouches = 1;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    [_gestures addObject:panGesture];

}

#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIViewController * vc =  [self.viewControllers lastObject];
    _panOrigin = vc.view.frame.origin;
    gestureRecognizer.enabled = YES;
    _rightPanViewCenterPoint = self.rightPanController.view.center;
    return !_animationInProgress;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

-(void)rightPanViewControllerAnimationEndWithDirection:(PanDirection)direction
{
    _animationInProgress = YES;
    CGRect frame = CGRectZero;
    switch (direction)
    {
        case PanDirectionLeft:
            break;
        case PanDirectionRight:
            frame.origin = CGPointMake(320, 0);
        default:
            break;
    }
    frame.size = self.rightPanController.view.frame.size;
    
    [UIView animateWithDuration:((self.rightPanController.view.frame.origin.x *kAnimationDuration)/self.view.frame.size.width)
                     animations:^()
     {
         if(direction==PanDirectionRight)
         {
             [self.view exchangeSubview:[self currentViewController].view
                            withSubview:_blackMask];
         }
         self.rightPanController.view.frame =frame;
         CGFloat newAlpha = direction==PanDirectionLeft?kMaxBlackMaskAlpha:0.0;
         _blackMask.alpha = newAlpha;
         
         CGAffineTransform transf = CGAffineTransformIdentity;
         CGFloat newTransformValue = direction==PanDirectionLeft?kViewScaleSize:1.0;
         [self currentViewController].view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
         if(direction==PanDirectionRight)
             [self currentViewController].view.userInteractionEnabled = YES;
         _animationInProgress = NO;
     }];
}

- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(_animationInProgress) return;
    CGPoint currentPoint = [panGesture translationInView:self.view];
    CGFloat x = currentPoint.x + _panOrigin.x;
    CGFloat offset = 0;
    
    PanDirection panDirection = PanDirectionNone;
    CGPoint vel = [panGesture velocityInView:self.view];
    if (vel.x > kOffsetTrigger) {
        panDirection = PanDirectionRight;
    } else {
        panDirection = PanDirectionLeft;
    }
    
    BOOL moveLeft = vel.x<1;
    UIViewController * vc= [self currentViewController];
    
    if(self.rightPanController&&self.rightPanController.view.frame.origin.x==0&&moveLeft)
        return;
    if(self.rightPanController&&//是否存在右侧的panViewController
       ((moveLeft&&_rightPanController.view.center.x>160)||//向左滑入rightPanView
        (!moveLeft&&_rightPanController.view.center.x<480))&&//向右推出rightPanView
       !_originTouchProcess)//当前是否正在处理原有的touch事件
    {
        if([self.view.subviews indexOfObject:self.currentViewController.view]>
           [self.view.subviews indexOfObject:_blackMask])
        {
            [self.view exchangeSubview:[self currentViewController].view
                           withSubview:_blackMask];
        }
        [self currentViewController].view.userInteractionEnabled = NO;
        _rightTouchProcess = YES;
        vc = self.rightPanController;
        CGPoint center = CGPointMake(_rightPanViewCenterPoint.x+currentPoint.x, vc.view.center.y);
        
        offset = CGRectGetWidth(self.rightPanController.view.frame) - x;
        CGAffineTransform transf = CGAffineTransformIdentity;
        CGFloat percentValue = abs(currentPoint.x)/320.0;
        CGFloat newAlphaValue = percentValue* kMaxBlackMaskAlpha;
        BOOL rightPanIsShow = _rightPanViewCenterPoint.x==160;
        newAlphaValue = rightPanIsShow?1-newAlphaValue:newAlphaValue;
        CGFloat newTransformValueFRTL =  1-(1-kViewScaleSize)*percentValue;
        CGFloat newTransformValueFLTR =  kViewScaleSize+(1-kViewScaleSize)*percentValue;
        
        CGFloat newTransformValue = rightPanIsShow?newTransformValueFLTR:newTransformValueFRTL;
        [self currentViewController].view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
        _blackMask.alpha = newAlphaValue;
        
        if(center.x<160)
        {
            vc.view.center = CGPointMake(160, vc.view.center.y);
            [self currentViewController].view.userInteractionEnabled = YES;
            return;
        }
        vc.view.center = center;
        
    }
    if(_rightTouchProcess)
    {
        if (panGesture.state == UIGestureRecognizerStateEnded ||
            panGesture.state == UIGestureRecognizerStateCancelled){
            panDirection = moveLeft?PanDirectionLeft:PanDirectionRight;
            _rightTouchProcess = NO;
            [self rightPanViewControllerAnimationEndWithDirection:panDirection];
            
        }
        return;
    }
    _originTouchProcess = YES;
    offset = CGRectGetWidth(vc.view.frame) - x;
    vc.view.frame = [self getSlidingRectForOffset:offset];
    
    CGAffineTransform transf = CGAffineTransformIdentity;
    CGFloat newTransformValue =  1 - (offset/(self.view.frame.size.width/10))/100;
    CGFloat newAlphaValue = (offset/self.view.frame.size.width)* kMaxBlackMaskAlpha;
    
    [self previousViewController].view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
    
    _blackMask.alpha = newAlphaValue;
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        _originTouchProcess = NO;
        [self completeSlidingAnimationWithDirection:panDirection];
    }
}

// This will complete the animation base on pan direction
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction {
    if(direction==PanDirectionRight){
        [self popViewController];
    }else {
        [self rollBackViewController];
    }
}

// Get the current position for the visible viewcontrollers
- (CGRect) getSlidingRectForOffset:(CGFloat)offset {
    
    CGRect rectToReturn = CGRectZero;
    UIViewController * vc;
    vc = [self currentViewController];
    rectToReturn.size = vc.view.frame.size;
    CGFloat width = CGRectGetWidth(vc.view.frame);
    rectToReturn.origin = CGPointMake(MIN(MAX(width-offset,0),vc.view.frame.size.width), 0.0);
    return rectToReturn;
}

@end


#pragma mark - UIViewController Category
//For Global Access of flipViewController
@implementation UIViewController (FlipBoardNavigationController)
@dynamic flipboardNavigationController;

- (FlipBoardNavigationController *)flipboardNavigationController
{
    
    if([self.parentViewController isKindOfClass:[FlipBoardNavigationController class]]){
        return (FlipBoardNavigationController*)self.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController isKindOfClass:[FlipBoardNavigationController class]]){
        return (FlipBoardNavigationController*)[self.parentViewController parentViewController];
    }
    else{
        return nil;
    }
    
}

@end