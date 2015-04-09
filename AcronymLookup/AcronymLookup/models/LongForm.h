//
//  LongForm.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Stat.h"

@interface LongForm : Stat
@property (nonatomic, retain) NSManagedObject* acronym;
@property (nonatomic, retain) NSString* longForm;

-(void)hydrateFromEntityData:(NSDictionary*)dict;
+(NSString*)entityName;
@end
