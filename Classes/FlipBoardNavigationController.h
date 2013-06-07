//
//  FlipBoardNavigationController.h
//  iamkel.net
//
//  Created by Michael henry Pantaleon on 4/30/13.
//  Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FlipBoardNavigationControllerCompletionBlock)(void);

@interface FlipBoardNavigationController : UIViewController
{
    BOOL _rightPanViewProcessTouch;
}
@property(nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic,strong) UIViewController * rightPanController;
-(void)addRightPanViewController:(UIViewController*)viewController;
- (id) initWithRootViewController:(UIViewController*)rootViewController;

- (void) pushViewController:(UIViewController *)viewController;
- (void) pushViewController:(UIViewController *)viewController completion:(FlipBoardNavigationControllerCompletionBlock)handler;
- (void) popViewController;
- (void) popViewControllerWithCompletion:(FlipBoardNavigationControllerCompletionBlock)handler;
- (void) popViewController:(UIViewController*)viewControler withCompletion:(FlipBoardNavigationControllerCompletionBlock)handler;
@end

@interface UIViewController (FlipBoardNavigationController)
@property (nonatomic, retain) FlipBoardNavigationController *flipboardNavigationController;
@end




