//
//  ServiceLogic.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 8/16/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "ServiceLogic.h"
#import "NetworkSessionManager.h"
#import <AFNetworkActivityIndicatorManager.h>

@implementation ServiceLogic
ServiceLogic * serviceLogicOBbject=nil;

+ (ServiceLogic *)getObject {
    
    if (serviceLogicOBbject == nil) {
        serviceLogicOBbject = [[ServiceLogic alloc] init];
        }
    return serviceLogicOBbject;
}

-(void)getVersionNumberWithCompleteionBlock:(void(^)(id response))successBlock andFailureBlock:(void(^)(NSError*))failureBlock
{
    
    NetworkSessionManager *sessionManager = [NetworkSessionManager sharedSessionManager];
    
    [sessionManager GET:GET_VERSION_BASE_URL parameters:nil  progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        NSString *responseJSONStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"\n ****** \n Success, NSURLSessionDataTask: %@ ****** Response: %@ \n ****** \n",task.response.description, responseJSONStr);
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"\n ****** \n Failure, NSURLSessionDataTask: %@ ***** Error: %@ \n ****** \n",task.response.description, error);
        failureBlock(error);
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    }];
}

@end
