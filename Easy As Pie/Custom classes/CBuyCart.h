//
//  CBuyCart.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/12/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "ShopifyManager.h"
@import Foundation;
@interface CBuyCart : NSObject
@property (nonatomic, strong) BUYCart *cart;
+(instancetype)sharedInstance;


@end
