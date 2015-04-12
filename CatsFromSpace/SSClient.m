//
//  SSClient.m
//  CatsFromSpace
//
//  Created by Chaitanya Bagaria on 4/12/15.
//  Copyright (c) 2015 Space Shrimp. All rights reserved.
//

#import "SSClient.h"

@implementation SSClient

+ (void) submitTag:(NSString *)tag lat:(double)lat lon:(double)lon zoom:(int)zoom
{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://space-cat.herokuapp.com/data"]];

    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"charset" forHTTPHeaderField:@"utf-8"];

    NSDateFormatter *formatter;
    NSString        *dateString;

    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    dateString = [formatter stringFromDate:[NSDate date]];


    NSMutableDictionary *params = [@{
                                        @"lat" : @(lat),
                                        @"lon" : @(lon),
                                        @"zoom": @(zoom),
                                        @"date": dateString,
                                        @"tag" : tag
                                     } mutableCopy];

    NSError *parseError = nil;

    NSLog(@"[SSClient] submitTag params: %@",params);

    // Get json from nsdictionary parameter
    [request setHTTPBody: [NSJSONSerialization dataWithJSONObject: params options: kNilOptions error: &parseError]];
    if (parseError) {
        NSLog(@"[SSClient] submitTag parseError: %@", parseError.localizedDescription);
    } else {
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest: request
                                           queue: queue
                               completionHandler:^(NSURLResponse *response, NSData  *data, NSError * requestError) {
                                   // Process response from server.
                                   [self processResponse:response data: data error: requestError successBlock:nil errorHandler: nil];

                               }];
    }
}

+ (void) processResponse: (NSURLResponse *) response
                    data: (NSData *) data
                   error: (NSError *) error
            successBlock: (void (^)(NSDictionary * returnData)) successHandler
            errorHandler: (void (^)(NSError * error))  errorHandler
{
    // extract dictionary from raw data
    NSDictionary * dictionary = nil;
    if([data length] >= 1) {
        dictionary = [NSJSONSerialization JSONObjectWithData: data options: kNilOptions error: nil];
    }

    NSLog(@"[SSClient] error: %@, response: %@, data: %@",error,response, dictionary);

}

@end
