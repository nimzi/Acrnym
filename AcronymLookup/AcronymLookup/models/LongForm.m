//
//  LongForm.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "LongForm.h"


@implementation LongForm

@dynamic acronym;
@dynamic longForm;

-(void)hydrateFromEntityData:(NSDictionary*)dict {
  [super hydrateFromEntityData:dict];
  self.longForm = dict[@"lf"];
}

+(NSString*)entityName { return @"LongForm"; }
@end
