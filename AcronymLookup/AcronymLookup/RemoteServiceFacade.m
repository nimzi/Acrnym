//
//  ServiceFacade.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "RemoteServiceFacade.h"
#import "FTHTTPCodes.h"
#include <iso646.h>

//{
//freq = 245;
//lf = "hidden Markov model";
//since = 1990;
//vars =     (
//            {
//              freq = 148;
//              lf = "hidden Markov model";
//              since = 1992;
//            },
//            {
//              freq = 29;
//              lf = "Hidden Markov Model";
//              since = 1993;
//            },
//            {
//              freq = 26;
//              lf = "hidden Markov models";
//              since = 1995;
//            },
//            {
//              freq = 13;
//              lf = "Hidden Markov Models";
//              since = 2001;
//            },
//            {
//              freq = 9;
//              lf = "Hidden Markov model";
//              since = 1994;
//            },
//            {
//              freq = 6;
//              lf = "Hidden Markov models";
//              since = 1995;
//            },
//            {
//              freq = 2;
//              lf = "Hidden Markov Modeling";
//              since = 2007;
//            },
//            {
//              freq = 2;
//              lf = "hidden Markov Model";
//              since = 2008;
//            },
//            {
//              freq = 2;
//              lf = "Hidden Markov modeling";
//              since = 2000;
//            },
//            {
//              freq = 2;
//              lf = "hidden Markov modeling";
//              since = 1990;
//            },
//            {
//              freq = 1;
//              lf = "Hidden-Markov Model";
//              since = 2008;
//            },
//            {
//              freq = 1;
//              lf = "Hidden Markov modelling";
//              since = 1990;
//            },
//            {
//              freq = 1;
//              lf = "hidden markov models";
//              since = 2000;
//            },
//            {
//              freq = 1;
//              lf = "hidden markov model";
//              since = 2005;
//            },
//            {
//              freq = 1;
//              lf = "hidden-Markov-model";
//              since = 1996;
//            },
//            {
//              freq = 1;
//              lf = "Hidden-Markov-Model";
//              since = 2004;
//            }
//            );
//}


typedef void (^CompletionHandlerType)(NSURLResponse* response, NSData *data, NSError* connectionError);

@interface RemoteServiceFacade()
@property BOOL busy;
@property (strong) typeof(NSOperationQueue*) queue;
@property (strong, readonly) NSString* serviceUrl;
@property (readonly) NSTimeInterval timeoutIntervalForSingleQuery;
@end

@implementation RemoteServiceFacade
+(instancetype) instance {
  static RemoteServiceFacade* shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
  });
  return shared;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _serviceUrl = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";
    _queue = [NSOperationQueue new];
    _queue.maxConcurrentOperationCount = 32;
    
    _timeoutIntervalForSingleQuery = 5.0;
  }
  return self;
}

-(BOOL) isBusy {
  return self.busy;
}


-(NSURL*) urlForAcronym:(NSString*)acronym {
  id encodedAcronym = [acronym stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
  id preparedURLString = [_serviceUrl stringByAppendingFormat:@"?sf=%@", encodedAcronym];
  return [NSURL URLWithString:preparedURLString];
}

static NSError* error(NSInteger code, NSString* message) {
  id info = @{@"message":message};
  id domain = [[RemoteServiceFacade class] description];
  return [NSError errorWithDomain:domain code:code userInfo:info];
}

-(void) lookupAcronym:(NSString*)acronym
         withCallback:(LookupCallbackType)neverCallMeDirectly
{
  LookupCallbackType callback = [neverCallMeDirectly copy];
  
  if (not self.isBusy) {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[self urlForAcronym:acronym]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    [request setTimeoutInterval:_timeoutIntervalForSingleQuery];

    
    // Not strictly necessary to do weak/strong pattern at all since self is a singleton...
    // but making it look "pretty"
    __weak typeof(self) weakSelf = self;
    CompletionHandlerType manifestGrabber = ^(NSURLResponse *response, NSData* data, NSError* connectionError) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (strongSelf) {
        if (connectionError) {
          dispatch_async(dispatch_get_main_queue(), ^{ callback(nil, nil, connectionError); });
        } else {
          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
          NSInteger responseStatusCode = [httpResponse statusCode];
          
          if (responseStatusCode != HTTPCode200OK) {
            //Just to make sure, it works or not
            NSLog(@"WARNING: Status code = %ld", (long)responseStatusCode);
            NSLog(@"%@", [FTHTTPCodes descriptionForCode:responseStatusCode]);
            
            
            NSError* err = error(RSF_BadHTTPResponse, [FTHTTPCodes descriptionForCode:responseStatusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{ callback(nil, nil, err); });
            
          } else {
            NSError* parsingError = nil;
            NSArray* json = (nil == data) ? nil : [NSJSONSerialization JSONObjectWithData:data
                                                                                  options:0
                                                                                    error:&parsingError];
            
            if (parsingError or json == nil or not [json isKindOfClass:[NSArray class]]) {
              NSLog(@"WARNING: Inconsistend format");
              NSError* err = error(RSF_BadData, @"Inconsistend data format");
              dispatch_async(dispatch_get_main_queue(), ^{ callback(nil, nil, err); });
            } else {
              if (not (json.count > 0)) {
                NSLog(@"WARNING: Empty manifest");
                NSError* err = error(RSF_NotFound, @"Empty manifest");
                dispatch_async(dispatch_get_main_queue(), ^{ callback(nil, nil, err); });
              } else {
                //NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //NSLog(@"%@", str);
                
                // extracting short form name
                NSString* sf = json[0][@"sf"];

                // an array of long forms
                NSArray* longForms = json[0][@"lfs"];
                dispatch_async(dispatch_get_main_queue(), ^{ callback(sf, longForms, nil); });
              }
            }
          }
        }
      }
    };
    
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.queue
                           completionHandler:manifestGrabber];
    
    
    
    
    
  }
}


@end
