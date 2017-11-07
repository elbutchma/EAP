//
//  ShopifyManager.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 2/24/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "ShopifyManager.h"
#import "Constants.h"
#import "CBuyCheckout.h"


@implementation ShopifyManager

+(instancetype)sharedInstance{
    static ShopifyManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.buyClient = [[BUYClient alloc] initWithShopDomain:SHOP_DOMAIN apiKey:API_KEY appId:APP_ID];
        manager.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        
    });
    return manager;
}


+(void)getProductsByTags{    
    
    [[[self sharedInstance] buyClient] getProductsByTags:@[@"Slider_product"] page:1 completion:^(NSArray<BUYProduct *> * _Nullable products, NSError * _Nullable error) {
        if (error == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Slider_products_notification" object:nil userInfo:@{@"products":products}];
            
        } else {
            NSLog(@"%@",error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Slider_products_notification_failed" object:nil userInfo:@{@"error":error.userInfo}];
            
        }
    }];
    
}

+(void)getCollections{
    [[[self sharedInstance] buyClient] getCollectionsPage:1 completion:^(NSArray<BUYCollection *> * _Nullable collections, NSUInteger page, BOOL reachedEnd, NSError * _Nullable error) {
        if (error == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Menu_collections" object:nil userInfo:@{@"collections":collections}];
        }else {
            NSLog(@"%@",error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Menu_collections_failed" object:nil userInfo:@{@"error":error.userInfo}];
        }
        
    }];
}


+(void)getProductsOfCollection:(NSNumber*)collectionId{
    
    [[[self sharedInstance] buyClient] getProductsPage:1 inCollection:collectionId completion:^(NSArray<BUYProduct *> * _Nullable products, NSUInteger page, BOOL reachedEnd, NSError * _Nullable error) {
        
        if (error == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"collection_products" object:nil userInfo:@{@"products":products}];
        }else {
            NSLog(@"%@",error);
        }
        
        
    }];
    
}

+(void)authenticateUser:(BUYAccountCredentials*)account{
    
    [[[self sharedInstance] buyClient] loginCustomerWithCredentials:account callback:^(BUYCustomer * _Nullable customer, BUYCustomerToken * _Nullable token, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"%@",token.accessToken);
            [[NSUserDefaults standardUserDefaults] setObject:token.accessToken forKey:@"access_token"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[customer JSONDictionary] forKey:@"customer"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login_token" object:nil userInfo:@{@"login_token":token, @"customer":customer}];
        }
        else {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login_token_error" object:nil userInfo:@{@"error":error}];
            
        }

    }];
}

+(void)registerUser:(BUYAccountCredentials*)account{
    [[[self sharedInstance] buyClient] createCustomerWithCredentials:account callback:^(BUYCustomer * _Nullable customer, BUYCustomerToken * _Nullable token, NSError * _Nullable error) {
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"registeration_success" object:nil userInfo:@{@"customer":customer}];
            });
            
            [[NSUserDefaults standardUserDefaults] setObject:token.accessToken forKey:@"access_token"];
            [[NSUserDefaults standardUserDefaults] setObject:[customer JSONDictionary] forKey:@"customer"];
            [[[self sharedInstance] buyClient] setCustomerToken:token];
        } else {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"registeration_failed" object:nil userInfo:@{@"error":error}];
        }
        
    }];
}

+(void)createAdress:(BUYAddress*)address{
    [[[self sharedInstance] buyClient] createAddress:address callback:^(BUYAddress * _Nullable address, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"address added");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"address_added" object:nil];
        } else {
            NSLog(@"%@", error);
         [[NSNotificationCenter defaultCenter] postNotificationName:@"address_failed" object:nil];
        }
    }];
}

+(void)createCheckout:(BUYCheckout*)checkout{
    
    if ([[[self sharedInstance] reach] isReachable]) {
        [[[self sharedInstance] buyClient] createCheckout:checkout completion:^(BUYCheckout * _Nullable checkout, NSError * _Nullable error) {
            
            if (!error) {
                //            NSDictionary *addressDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"address"];
                //            BUYAddress *address = [[[self sharedInstance] buyClient].modelManager insertAddressWithJSONDictionary:addressDic];
                
                
                checkout.customerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"customerId"];
                //            checkout.billingAddress = address;
                //            checkout.shippingAddress = address;
                checkout.email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
                
                
                
                if ([[self sharedInstance] promoCode].length > 0) {
                    
                    [checkout setDiscountCode:[[self sharedInstance] promoCode]];
                    [[self sharedInstance] setIsAfterCreateCheckout:NO];
                } else{
                    [[self sharedInstance] setIsAfterCreateCheckout:YES];
                }
                [self updateCheckout:checkout];
                
                
            } else {
                NSLog(@"%@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
                });
                
            }
        }];

    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
        });
    }
    
}



+(void)getShippingRates:(NSString *)token{
    
    if ([[[self sharedInstance] reach] isReachable]) {
        [[[self sharedInstance] buyClient] getShippingRatesForCheckoutWithToken:token completion:^(NSArray<BUYShippingRate *> * _Nullable shippingRates, BUYStatus status, NSError * _Nullable error) {
            
            if (!error) {
                BUYShippingRate *rate = [shippingRates objectAtIndex:0];
                BUYCheckout *checkout = [CBuyCheckout sharedInstance].checkout;
                [checkout setShippingRate:rate];
                [CBuyCheckout sharedInstance].checkout = checkout;
                
                [[self sharedInstance] setIsAfterGettinShippingRates:YES];
                
                [self updateCheckout:[CBuyCheckout sharedInstance].checkout];
            } else {
                NSLog(@"%@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
                });
            }
            
        }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
        });
    }
    
}

+(void)addCreditCartToCheckout:(BUYCheckout*)checkout{
    BUYCreditCard *creditCard = [[BUYCreditCard alloc] init];
    
    
    creditCard.number = @"1";
    creditCard.expiryMonth = @"2";
    creditCard.expiryYear = @"2026";
    creditCard.cvv = @"111";
    creditCard.nameOnCard = @"Dinosaur Banana";
    
    
    
    
    if ([[[self sharedInstance] reach] isReachable]) {
        // Associate the credit card with the checkout
        [[[self sharedInstance] buyClient] storeCreditCard:creditCard checkout:checkout completion:^(id<BUYPaymentToken>  _Nullable paymentToken, NSError * _Nullable error) {
            
            if (!error) {
                [[self sharedInstance] setCheckoutToken:checkout.token];
                [[self sharedInstance] setPaymentToken:paymentToken];
                [[self sharedInstance] setIsAfterAddingCreditCard:YES];
                
                //            [self updateCheckout:checkout];
                [self completeCheckoutWithCheckoutToken:checkout.token andPaymentToken:paymentToken];
                
            } else {
                NSLog(@"%@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
                });
            }
            
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
        });
    }
    
   
}

+(void)completeCheckoutWithCheckoutToken:(NSString*)checkoutToken andPaymentToken:(id<BUYPaymentToken>)paymentToken{
    
    
    if ([[[self sharedInstance] reach] isReachable]) {
        [[[self sharedInstance] buyClient] completeCheckoutWithToken:[CBuyCheckout sharedInstance].checkout.token paymentToken:paymentToken completion:^(BUYCheckout * _Nullable checkout, NSError * _Nullable error) {
            
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_completed" object:nil];
                });
            }
            else {
                NSLog(@"%@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
                });
            }
            
        }];

    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
        });
    }
}


+(void)updateCheckout:(BUYCheckout*)checkout{
    
    if ([[[self sharedInstance] reach] isReachable]) {
        [[[self sharedInstance] buyClient] updateCheckout:checkout completion:^(BUYCheckout * _Nullable checkout, NSError * _Nullable error) {
            if (!error) {
                
                
                
                
                //call get shhipping rates after create checkout
                if ([[self sharedInstance] isAfterCreateCheckout]) {
                    [[self sharedInstance] setIsAfterCreateCheckout:NO];
                    [CBuyCheckout sharedInstance].checkout = checkout;
                    [self getShippingRates:checkout.token];
                }
                
                
                //after getting shippingrates
                if ([[self sharedInstance] isAfterGettinShippingRates]) {
                    [[self sharedInstance] setIsAfterGettinShippingRates:NO];
                    [self addCreditCartToCheckout:checkout];
                    
                    
                }
                
                if ([[self sharedInstance] isAfterAddingCreditCard]) {
                    [[self sharedInstance] setIsAfterAddingCreditCard:NO];
                    [self completeCheckoutWithCheckoutToken:[CBuyCheckout sharedInstance].checkout.token andPaymentToken:[[self sharedInstance] paymentToken]];
                }
                
                if ([[self sharedInstance] isAddingDiscountCode]) {
                    [[self sharedInstance] setIsAddingDiscountCode:NO];
                    [CBuyCheckout sharedInstance].checkout = checkout;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"promoCode_added" object:nil];
                }
                
                
            } else {
                NSLog(@"%@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"checkout_failed" object:nil];
        });
    }
   
}


+(void)applyPromoCode:(NSString*)code forCheckout:(BUYCheckout*)checkout{
    [[self sharedInstance] setIsAddingDiscountCode:YES];
    [self createCheckout:checkout];
    
    
    
    //create checkout
    //checkout setDiscountCode:code
    //update checkout
    //checkout.getdiscount.code/amount
    
    BUYDiscount *discount = [[[[self sharedInstance] buyClient] modelManager] discountWithCode:code];
//    BUYCheckout *checkout = [CBuyCheckout sharedInstance].checkout;
    checkout.discount = discount;
    
    [self updateCheckout:checkout];
    
}
@end

