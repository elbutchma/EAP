//
//  ApplicationHelper.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 8/16/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "ApplicationHelper.h"

@implementation ApplicationHelper
+ (NSString *)getApplicationVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    return majorVersion;
}

@end
