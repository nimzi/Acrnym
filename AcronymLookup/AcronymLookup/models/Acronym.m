//
//  Acronym.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "Acronym.h"
#import "LongForm.h"


@implementation Acronym

@dynamic shortForm;
@dynamic longForms;

-(void)hydrateFromEntityData:(NSDictionary*)dict {
  self.shortForm = dict[@"sf"];
}

+(NSString*)entityName { return @"Acronym"; }

@end
