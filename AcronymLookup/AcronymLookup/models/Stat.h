//
//  Stat.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Utilities.h"

@interface Stat : NSManagedObject

@property (nonatomic, retain) NSNumber* since;
@property (nonatomic, retain) NSNumber* frequency;

-(void)hydrateFromEntityData:(NSDictionary*)dict;

@end
