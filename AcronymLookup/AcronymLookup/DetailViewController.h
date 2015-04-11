//
//  DetailViewController.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/10/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//


@import UIKit;

@interface DetailViewController : UITableViewController
@property (strong, nonatomic) NSArray* longForms;
-(instancetype)initWithLongForms:(NSArray*)longForms;
@end
