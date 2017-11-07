//
//  CheckoutItemsTableViewCell.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 2/28/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "CheckoutItemsTableViewCell.h"
#import "UIHelper.h"
@implementation CheckoutItemsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

//    self.quantityLabel.layer.borderColor = [[UIHelper colorWithHexString:@"ffbd00"] CGColor];
//    self.quantityLabel.layer.borderWidth = 1.0;
//    self.quantityLabel.layer.cornerRadius = 2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
