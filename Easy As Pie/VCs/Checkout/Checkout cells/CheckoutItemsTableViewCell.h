//
//  CheckoutItemsTableViewCell.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 2/28/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckoutItemsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemUnitPrice;
@property (weak, nonatomic) IBOutlet UILabel *itemTotalPrice;
@property (weak, nonatomic) IBOutlet UIView *steppetView;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

@end
