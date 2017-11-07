//
//  SliderCollectionViewCell.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 4/22/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "SliderCollectionViewCell.h"

@implementation SliderCollectionViewCell
-(void)awakeFromNib{
    [super awakeFromNib];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.autoresizesSubviews = YES;
}
@end
