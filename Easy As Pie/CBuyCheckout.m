//
//  CBuyCheckout.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/14/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "CBuyCheckout.h"

@implementation CBuyCheckout
+(instancetype)sharedInstance{
    static CBuyCheckout *checkout = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checkout = [[self alloc] init];
    });
    return checkout;
}
@end
