//
//  ProgressManaging.h
//  AcronymLookup
//
//  Created by Paul Agron on 4/9/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

@import Foundation;

@protocol ProgressManaging <NSObject>
- (void) startShowingProgress;
- (void) finishShowingProgress;
@end
