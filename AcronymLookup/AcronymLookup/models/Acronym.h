//
//  Acronym.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Stat.h"

@class LongForm;

@interface Acronym : Stat
@property (nonatomic, retain) NSString* shortForm;
@property (nonatomic, retain) NSSet* longForms;

-(void)hydrateFromJSON:(id)json;
@end

@interface Acronym (CoreDataGeneratedAccessors)
- (void)addLongFormsObject:(LongForm *)value;
- (void)removeLongFormsObject:(LongForm *)value;
- (void)addLongForms:(NSSet *)values;
- (void)removeLongForms:(NSSet *)values;
@end
