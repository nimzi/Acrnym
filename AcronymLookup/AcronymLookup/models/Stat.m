//
//  Stat.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "Stat.h"


@implementation Stat

@dynamic since;
@dynamic frequency;

-(void)hydrateFromEntityData:(NSDictionary*)dict {
  self.since = dict[@"since"];
  self.frequency = dict[@"freq"];
}

@end
