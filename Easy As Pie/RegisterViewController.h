//
//  RegisterViewController.h
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/7/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (nonatomic) BOOL isAddAddress;
@end
