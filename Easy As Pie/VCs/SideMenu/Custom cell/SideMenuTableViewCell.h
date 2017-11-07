//
//  SideMenuTableViewCell.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/18/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end
