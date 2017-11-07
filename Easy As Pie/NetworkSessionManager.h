//
//  NetworkSessionManager.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 8/16/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#define GET_VERSION_BASE_URL @"https://mgragab.github.io/appversions.json"

@interface NetworkSessionManager : AFHTTPSessionManager

+(instancetype) sharedSessionManager;

@end
