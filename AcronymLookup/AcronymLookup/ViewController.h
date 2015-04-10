//
//  ViewController.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

@import UIKit;

#import "ProgressManaging.h"

@interface ViewController : UIViewController<ProgressManaging>
@property (nonatomic) UINavigationController* navController;
@property (nonatomic) UITableViewController* tableController;
@end

