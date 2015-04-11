//
//  DataController.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "DataController.h"
#import <iso646.h>
#import "Acronym.h"
#import "LongForm.h"

@implementation DataController

+(instancetype) instance {
  static DataController* shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
  });
  return shared;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    // forcing initialization of everything upon construction
    [self managedObjectContext];
  }
  return self;
}



-(NSArray*) fetchAllAcronyms {
  NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:[Acronym entityName]];
  NSError* err = nil;
  NSArray* res = [_managedObjectContext executeFetchRequest:req error:&err];
  return res;
}


-(Acronym*) _findAcronym:(NSString*)shortForm {
  Acronym* acronym = nil;
  // NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
  NSFetchRequest* req = [NSFetchRequest new];
  NSEntityDescription* entity = [NSEntityDescription entityForName:[Acronym entityName]
                                            inManagedObjectContext:_managedObjectContext];
  req.entity = entity;
  req.predicate = [NSPredicate predicateWithFormat:@"shortForm == %@", shortForm];
  NSError* err = nil;
  NSArray* res = [_managedObjectContext executeFetchRequest:req error:&err];
  
  if (not err and res.count > 0) {
    acronym = res.firstObject;
  }
  
  return acronym;
}

-(Acronym*) upsertAcromym:(NSString*)shortForm;
{
  Acronym* acronym = [self _findAcronym:shortForm];
  if (acronym == nil) {
    acronym = [NSEntityDescription insertNewObjectForEntityForName:[Acronym entityName]
                                            inManagedObjectContext:_managedObjectContext];
    acronym.shortForm = shortForm;
  }
  
  return acronym;
}

-(LongForm*) upsertLongFrom:(NSString*)longForm
                 forAcronym:(Acronym*)acronym
                 entityData:(NSDictionary*)entityFields
{
  LongForm* obj = nil;
  // This is inefficient but simple... O(n^2).
  // Here we assume the number of long forms won't be great
  for (LongForm* lf in acronym.longForms) {
    if ([lf.longForm isEqualToString:longForm]) {
      obj = lf;
      break;
    }
  }
  
  if (nil == obj) {
    obj = [NSEntityDescription insertNewObjectForEntityForName:[LongForm entityName]
                                            inManagedObjectContext:_managedObjectContext];
    [acronym addLongFormsObject:obj];
  }
  
  [obj hydrateFromEntityData:entityFields];
  return obj;
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AcronymLookup" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AcronymLookup.sqlite"];
  NSError *error = nil;
  NSString *failureReason = @"There was an error creating or loading the application's saved data.";
  if (not [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    // Report any error we got.
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
    dict[NSLocalizedFailureReasonErrorKey] = failureReason;
    dict[NSUnderlyingErrorKey] = error;
    error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
#warning TODO: Improve
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }
  
  return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (!coordinator) {
    return nil;
  }
  
  _managedObjectContext = [[NSManagedObjectContext alloc] init];
  [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  return _managedObjectContext;
}

-(void)deleteAcronym:(Acronym*)acm {
  [_managedObjectContext deleteObject:acm];
  [self saveContext];
}

-(void) saveContext {
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    NSError *error = nil;
    if ([managedObjectContext hasChanges] and not [managedObjectContext save:&error]) {
#warning TODO: Improve
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
  }
}



#pragma mark - Fetched results controller Factory

- (NSFetchedResultsController *)makeControllerforAcronyms:(NSError* __autoreleasing *)error
{
  *error = nil;
  
  NSFetchRequest* fetchRequest = [NSFetchRequest new];
  NSEntityDescription* entity = [NSEntityDescription entityForName:[Acronym entityName]
                                            inManagedObjectContext:_managedObjectContext];
  [fetchRequest setEntity:entity];
  [fetchRequest setFetchBatchSize:250];

  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortForm" ascending:YES];
  [fetchRequest setSortDescriptors:@[sortDescriptor]];
  
  NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:_managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:@"Master"];
  
  if (not [frc performFetch:error]) {
#warning TODO: Improve
    NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);
    return nil;
  } else {
    return frc;
  }
}

#pragma mark - 
- (NSArray*)sortedLongFormsForAcronym:(Acronym*)acronym {
  NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[LongForm entityName]];
  NSSortDescriptor* byFreq = [[NSSortDescriptor alloc] initWithKey:@"frequency" ascending:YES];
  NSSortDescriptor* bySince = [[NSSortDescriptor alloc] initWithKey:@"since" ascending:YES];
  
  NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.acronym = %@", acronym];
  
  fetchRequest.sortDescriptors = @[byFreq, bySince];
  fetchRequest.fetchBatchSize = 250;
  fetchRequest.predicate = predicate;
  
  NSError* error = nil;
  NSArray* res = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  if (nil == error) {
    return res;
  } else {
#warning TODO: Improve
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    return nil;
  }
  
}



@end
