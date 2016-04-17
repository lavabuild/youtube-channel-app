//
//  NSDate+Relativity.h
//  Youtube
//
//  Created by Kevin McCafferty on 20/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Relativity)

-(NSString *)distanceOfTimeInWordsSinceDate:(NSDate *)aDate;
-(NSString *)distanceOfTimeInWordsToNow;

@end
