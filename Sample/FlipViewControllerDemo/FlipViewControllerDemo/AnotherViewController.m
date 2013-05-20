//
//  AnotherViewController.m
//  FlipViewControllerDemo
//
//  Created by Michael henry Pantaleon on 5/2/13.
//  Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
//

#import "AnotherViewController.h"

@interface AnotherViewController ()

@end

@implementation AnotherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn addTarget:self
            action:@selector(popController:)
  forControlEvents:UIControlEventTouchUpInside];
    btn.frame =CGRectMake(100, 100, 100, 100);
    [self.view addSubview:btn];
}

-(void)popController:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTT"
                                                        object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
