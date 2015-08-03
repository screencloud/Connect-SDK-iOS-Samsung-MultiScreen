//
//  MSDevice.m
//  ScreenCloudMSFFramework
//
//  Created by Jirasak Saebang on 7/27/15.
//  Copyright (c) 2015 codegent. All rights reserved.
//

#import "MSDevice.h"

@implementation MSDevice

- (void)getApplication:(NSString *)runTitle completionBlock:(void (^)(MSApplication *, NSError *))completionBlock queue:(dispatch_queue_t)queue
{
    dispatch_async(queue, ^{
        
    });
}

- (void)connectToChannel:(NSString *)channelId clientAttributes:(NSDictionary *)clientAttributes completionBlock:(void (^)(MSChannel *, NSError *))completionBlock queue:(dispatch_queue_t)queue
{
    
}

@end
