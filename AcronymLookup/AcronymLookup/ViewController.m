//
//  ViewController.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "ViewController.h"
#import "ServiceFacade.h"

@interface AcronymBrowswer : UITableViewController<UISearchBarDelegate>
@end

@implementation AcronymBrowswer

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    
    // In a real app we would localize string constants
    searchBar.placeholder = @"Enter an acronym";
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    
    SEL action = @selector(refreshButtonAction:);
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:action];
    self.navigationItem.rightBarButtonItem = refreshButton;
  
  }
  
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  cell.textLabel.text = @(indexPath.row).description;
  return cell;
}


#pragma mark - 

-(void) _startShowingProgress {
  // Some developers may frown upon this as a `hack`, however, this approach
  // has a number of advantages and there is a way to
  // mitigate its shortcomings through checking for protocol conformance
  // in responder chain...

  [[UIApplication sharedApplication] sendAction:@selector(startShowingProgress)
                                             to:nil
                                           from:self
                                       forEvent:nil];
}

-(void) _finishShowingProgress {
  [[UIApplication sharedApplication] sendAction:@selector(finishShowingProgress)
                                             to:nil
                                           from:self
                                       forEvent:nil];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
  
  
  if (searchBar.text.length > 0) {
    [self _startShowingProgress];
    [[ServiceFacade instance] lookupAcronym:searchBar.text
                               withCallback:^(NSArray *longForms, NSError *error) {
                                 [self _finishShowingProgress];
                               }];
  }
}

#pragma mark - Actions

-(void) refreshButtonAction:(id)sender {
  
  
  
  

}

@end



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
- (IBAction) startShowingProgress
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [_indicator startAnimating];
  [_indicator bringSubviewToFront:self.view];
  [_navController.navigationBar setUserInteractionEnabled:NO];
}

// Called through nil-targeted action mechanism
- (IBAction) finishShowingProgress {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [_indicator stopAnimating];
  [_indicator sendSubviewToBack:self.view];
  [_navController.navigationBar setUserInteractionEnabled:YES];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
//  [self startShowingProgress];
  
  UIViewController* vc = [UIViewController new];
  UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
  searchBar.placeholder = @"Please enter an acronym";
  searchBar.delegate = self;
  vc.navigationItem.titleView = searchBar;
  vc.view.backgroundColor = [UIColor redColor];
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  
  [button addTarget:self
             action:@selector(next:)
   forControlEvents:UIControlEventTouchUpInside];
  
  [button setTitle:@"Show View" forState:UIControlStateNormal];
  button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);

  [vc.view addSubview:button];
  
  _tableController = [AcronymBrowswer new];
  _navController = [[UINavigationController alloc] initWithRootViewController:vc];
  [self.view addSubview:_navController.view];
  
  [self configureActivityIndicator];
}

//- (void)didReceiveMemoryWarning {
//  [super didReceiveMemoryWarning];
//  // Dispose of any resources that can be recreated.
//}

-(IBAction)next:(id)sender {
  [_navController pushViewController:_tableController animated:YES];
  
  
//  _indicator.center = self.view.center;  
//  if (_indicator.isAnimating)
//    [self finishShowingProgress];
//  else
//    [self startShowingProgress];
  
}

#pragma mark -

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;                      // return NO to not become first responder
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;                     // called when text starts editing
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0); // called before text changes

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
