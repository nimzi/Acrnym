//
//  ServiceFacadeDelegate.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

@class ServiceFacade;

@protocol ServiceFacadeDelegate<NSObject>
-(void) serviceFacade:(ServiceFacade*)facade didLoadEntry:(id)entry;
-(void) serviceFacadeDidBecomeBusy:(ServiceFacade*)facade;
-(void) serviceFacadeDidBecomeIdle:(ServiceFacade*)facade;
@end
