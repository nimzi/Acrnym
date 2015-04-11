//
//  AcronymBrowser.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/9/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//


#import "AcronymBrowser.h"
#import "RemoteServiceFacade.h"
#import "DataController.h"
#import "ProgressManaging.h"
#import "DetailViewController.h"
#import <iso646.h>


@interface BrowserCell : UITableViewCell
@end

@implementation BrowserCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
    self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
  }
  
  return self;
}

-(void)prepareForReuse {
}

@end


#pragma mark -


@implementation AcronymBrowswer {
  NSFetchedResultsController* _fetchedResultsController;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self.tableView registerClass:[BrowserCell class] forCellReuseIdentifier:@"Cell"];
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
    
    NSError* error = nil;
    _fetchedResultsController = [[DataController instance] makeControllerforAcronyms:&error];
    
    if (_fetchedResultsController != nil and error == nil) {
      _fetchedResultsController.delegate = self;
    } else {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // This should all be localized...
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Database Unavailable"
                                                        message:@"Unable to access the local database of acronyms."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
      });
    }
  }
  
  return self;
}

#pragma - TableView delegate/datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController sections][section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath { return YES; }

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [[DataController instance] deleteAcronym:[_fetchedResultsController objectAtIndexPath:indexPath]];
  }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  Acronym* object = [_fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = object.shortForm;
  cell.detailTextLabel.text = [NSString stringWithFormat: @"%lu long forms", (unsigned long)object.longForms.count];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  Acronym* object = [_fetchedResultsController objectAtIndexPath:indexPath];
  [self _installDetailView:object];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  Acronym* object = [_fetchedResultsController objectAtIndexPath:indexPath];
  
  __weak typeof(self) weakSelf = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [weakSelf _installDetailView:object];
  });
  
}

-(void) _installDetailView:(Acronym*)object {
  NSArray* longForms = [[DataController instance] sortedLongFormsForAcronym:object];
  UITableViewController* controller = [[DetailViewController alloc] initWithLongForms:longForms];
  controller.title = object.shortForm;
  [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark -

-(void) _startShowingProgress {
  // Some developers may frown upon this as a `hack`, however, this approach
  // has a number of advantages and there is a way to
  // mitigate its shortcomings through checking for protocol conformance
  // in responder chain...
  UIApplication* app = [UIApplication sharedApplication];
  [app sendAction:@selector(startShowingProgress) to:nil from:self forEvent:nil];
}

-(void) _finishShowingProgress {
  UIApplication* app = [UIApplication sharedApplication];
  [app sendAction:@selector(finishShowingProgress) to:nil from:self forEvent:nil];
}


#pragma mark - UISearchBarDelegate

- (Acronym*)_upsertAcronym:(NSString*)shortForm withLongForms:(NSArray*)longForms {
  Acronym* anm = [[DataController instance] upsertAcromym:shortForm];
  for (NSDictionary* dict in longForms) {
    NSString* name = dict[@"lf"];
    if (nil != name)
      [[DataController instance] upsertLongFrom:name forAcronym:anm entityData:dict];
  }
  
  [[DataController instance] saveContext];
  return anm;
}

-(void)_showSearchTermNotFoundAlert:(NSString*)searchTerm {
  id title = [NSString stringWithFormat:@"'%@' not found", searchTerm];
  id msg = @"Sorry, the acronym you were loking for doesn't exist in our database";
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}


-(void)_showErrorAlert:(NSError*)error {
  id title = @"Warning";
  id msg = [error localizedDescription];
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
  
  if (searchBar.text.length > 0) {
    [self _startShowingProgress];
    RemoteServiceFacade* service = [RemoteServiceFacade instance];
    
    __weak typeof(self) weakSelf = self;
    [service lookupAcronym:searchBar.text
              withCallback: ^(NSString* sf, NSArray *longForms, NSError *error) {
                typeof(self) strongSelf = weakSelf;
                NSString* searchTerm = searchBar.text;
                searchBar.text = @"";
                
                if (sf.length > 0) {
                  Acronym* acm = [strongSelf _upsertAcronym:sf withLongForms:longForms];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf _installDetailView:acm];
                  });
                } else if (nil != error) {
                  switch (error.code) {
                    case RSF_NotFound:
                      [strongSelf _showSearchTermNotFoundAlert:searchTerm];
                      break;
                      
#warning TODO: Handle cases more granularly
                      
                    case RSF_BadData:
                    case RSF_BadHTTPResponse:
                    default:
                      [strongSelf _showErrorAlert:error];
                      break;
                  }
                  
                }
                
                [strongSelf _finishShowingProgress];
              }];
  }
}

#pragma mark - Actions

-(void) refreshButtonAction:(id)sender {
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Not implemented"
                                                  message:@"Refresh all items in the database"
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

#pragma mark - FetchResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    default:
      return;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  UITableView* tableView = self.tableView;
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
      
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView endUpdates];
}


@end
