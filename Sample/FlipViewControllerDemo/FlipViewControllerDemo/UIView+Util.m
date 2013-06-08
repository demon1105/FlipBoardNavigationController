//
//  UIView+Util.m
//  FlipViewControllerDemo
//
//  Created by demon on 6/8/13.
//  Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
//

#import "UIView+Util.h"

@implementation UIView (Util)

-(void)exchangeSubview:(UIView*)view1
           withSubview:(UIView*)view2
{
    int index1 = [self.subviews indexOfObject:view1];
    int index2 = [self.subviews indexOfObject:view2];
    [self exchangeSubviewAtIndex:index1
              withSubviewAtIndex:index2];
}

@end
