//
//  CBuyCart.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/12/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "CBuyCart.h"

@implementation CBuyCart
+(instancetype)sharedInstance{
    static CBuyCart *cart = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cart = [[self alloc] init];
        
    });
    return cart;
}
@end
