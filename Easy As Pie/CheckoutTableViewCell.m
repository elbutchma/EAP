//
//  CheckoutTableViewCell.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/5/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "CheckoutTableViewCell.h"

@implementation CheckoutTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)addPromoCode:(UIButton *)sender {
    [self.delegate processAddPromoCode:self.promoCodetextField.text];
    self.promoCodetextField.text = @"";
}

@end
