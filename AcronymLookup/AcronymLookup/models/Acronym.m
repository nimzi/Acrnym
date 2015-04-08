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

-(void)hydrateFromJSON:(id)json {
  [super hydrateFromJSON:json];
}

@end
