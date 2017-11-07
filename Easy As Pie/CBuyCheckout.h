//
//  CBuyCheckout.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/14/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "ShopifyManager.h"

@interface CBuyCheckout : NSObject
+(instancetype)sharedInstance;
@property (nonatomic, strong) BUYCheckout *checkout;

@end
