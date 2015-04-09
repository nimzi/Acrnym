//
//  ServiceFacadeDelegate.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

@class RemoteServiceFacade;

@protocol ServiceFacadeDelegate<NSObject>
-(void) serviceFacade:(RemoteServiceFacade*)facade didLoadEntry:(id)entry;
-(void) serviceFacadeDidBecomeBusy:(RemoteServiceFacade*)facade;
-(void) serviceFacadeDidBecomeIdle:(RemoteServiceFacade*)facade;
@end
