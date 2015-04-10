//
//  ViewController.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "ViewController.h"
#import "RemoteServiceFacade.h"
#import "DataController.h"
#import "AcronymBrowser.h"
#import <iso646.h>




@interface ViewController() <UISearchBarDelegate>
@end

@implementation ViewController {
  UIActivityIndicatorView* _indicator;
}

#pragma mark - Busy indicator management

- (void) configureActivityIndicator {
  _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  _indicator.color = self.view.tintColor;
  _indicator.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
  
  _indicator.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
  _indicator.layer.masksToBounds = YES;
  _indicator.layer.cornerRadius = 10;
  _indicator.center = self.view.center;
  [self.view addSubview:_indicator];
  
}

// Called through nil-targeted action mechanism
- (void) startShowingProgress
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [_indicator startAnimating];
  [_indicator bringSubviewToFront:self.view];
  [_navController.navigationBar setUserInteractionEnabled:NO];
}

// Called through nil-targeted action mechanism
- (void) finishShowingProgress {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [_indicator stopAnimating];
  [_indicator sendSubviewToBack:self.view];
  [_navController.navigationBar setUserInteractionEnabled:YES];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _tableController = [AcronymBrowswer new];
  _navController = [[UINavigationController alloc] initWithRootViewController:_tableController];
  [self.view addSubview:_navController.view];
  [self configureActivityIndicator];
}


-(IBAction)next:(id)sender {
  [_navController pushViewController:_tableController animated:YES];
  
  
  //  _indicator.center = self.view.center;
  //  if (_indicator.isAnimating)
  //    [self finishShowingProgress];
  //  else
  //    [self startShowingProgress];
  
}


@end
