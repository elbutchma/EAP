//
//  NetworkManager.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 8/16/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "NetworkSessionManager.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
@implementation NetworkSessionManager


+(instancetype) sharedSessionManager
{
    static  NetworkSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NetworkSessionManager alloc] initWithBaseURL:[NSURL URLWithString:GET_VERSION_BASE_URL]];
        [sharedManager setDefaultConfigurations];
    });
    return sharedManager;
}


-(void) setDefaultConfigurations {
    [AFNetworkActivityIndicatorManager sharedManager].activationDelay = 0;
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // response serializer
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:[NSSet setWithObjects:@"text/html", @"application/json",nil]];
    
    // request serializer
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.requestSerializer.timeoutInterval = 120;
    
    
}
@end
