//
//  SSClient.h
//  CatsFromSpace
//
//  Created by Chaitanya Bagaria on 4/12/15.
//  Copyright (c) 2015 Space Shrimp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSClient : NSObject

+ (void) submitTag:(NSString *)tag lat:(double)lat lon:(double)lon zoom:(int)zoom;

@end
