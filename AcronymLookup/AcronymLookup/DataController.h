//
//  DataController.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Acronym;
@class LongForm;

@interface DataController : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;


+ (instancetype)instance;
- (void)saveContext;

-(NSArray*) fetchAllAcronyms;

-(Acronym*) upsertAcromym:(NSString*)shortForm;

-(LongForm*) upsertLongFrom:(NSString*)longForm
                 forAcronym:(Acronym*)acronym
                 entityData:(NSDictionary*)entityFields;

-(void)logDebugDescription;
@end
