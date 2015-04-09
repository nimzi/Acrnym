//
//  ServiceFacade.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceFacadeDelegate.h"

// longForms is an array of deserialized JSON
// the callback will asways happen on main queue
typedef void (^LookupCallbackType)(NSString* shortForm, NSArray* longForms, NSError* error);

@interface RemoteServiceFacade : NSObject
@property (weak, nonatomic) id<ServiceFacadeDelegate> delegate;
-(BOOL) isBusy;
+(instancetype) instance;

-(void) lookupAcronym:(NSString*)acronym
         withCallback:(LookupCallbackType)callback;
@end
