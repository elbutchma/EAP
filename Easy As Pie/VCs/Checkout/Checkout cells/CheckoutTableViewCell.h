//
//  CheckoutTableViewCell.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/5/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddPromoCodeDelegate <NSObject>

-(void)processAddPromoCode:(NSString*)promoCode;
@end

@interface CheckoutTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *promoCodetextField;
@property (weak, nonatomic) IBOutlet UIButton *applyPromoCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *orderValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxesValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalOrderValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;

@property (nonatomic, weak) id <AddPromoCodeDelegate> delegate;

@end
