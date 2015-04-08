//
//  ViewController.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "ViewController.h"


@interface AcronymBrowswer : UITableViewController {

}
@end

@implementation AcronymBrowswer

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  cell.textLabel.text = @(indexPath.row).description;
  return cell;
}
@end



@interface ViewController() <UISearchBarDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  
  _tableController = [UITableViewController new];
  _navController = [[UINavigationController alloc] initWithRootViewController:vc];
  [self.view addSubview:_navController.view];

}

//- (void)didReceiveMemoryWarning {
//  [super didReceiveMemoryWarning];
//  // Dispose of any resources that can be recreated.
//}

-(IBAction)next:(id)sender {
  [_navController pushViewController:_tableController animated:YES];
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
