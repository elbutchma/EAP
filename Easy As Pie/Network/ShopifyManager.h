//
//  ShopifyManager.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 2/24/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Buy/Buy.h>
#import "Reachability.h"

@interface ShopifyManager : NSObject
@property (nonatomic, strong) BUYClient *buyClient;
@property (nonatomic, strong) NSString *checkoutToken;
@property (nonatomic, strong) id<BUYPaymentToken> paymentToken;
@property (nonatomic) BOOL isAfterCreateCheckout;
@property (nonatomic) BOOL isAfterGettinShippingRates;
@property (nonatomic) BOOL isAfterAddingCreditCard;
@property (nonatomic) BOOL isAddingDiscountCode;
@property (nonatomic, strong) NSString *promoCode;
@property (nonatomic, strong) Reachability *reach;
+(instancetype)sharedInstance;

+(void)getProductsByTags;
+(void)getCollections;
+(void)getProductsOfCollection:(NSNumber*)collectionId;
+(void)authenticateUser:(BUYAccountCredentials*)account;
+(void)registerUser:(BUYAccountCredentials*)account;
+(void)createAdress:(BUYAddress*)address;
+(void)createCheckout:(BUYCheckout*)checkout;
+(void)updateCheckout:(BUYCheckout*)checkout;
+(void)getShippingRates:(NSString *)token;
+(void)addCreditCartToCheckout:(BUYCheckout*)checkout;

@end
