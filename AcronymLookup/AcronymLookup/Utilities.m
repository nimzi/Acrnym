//
//  Utilities.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/8/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//


#import "Utilities.h"

id strongCast(id obj, Class clz) {
  if (obj == nil) return nil;
  if ([obj isKindOfClass:clz]) return obj; else return nil;
}

id arrayCast(id obj) {
  return strongCast(obj, [NSArray class]);
}

id dictCast(id obj) {
  return strongCast(obj, [NSDictionary class]);
}