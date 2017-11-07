//
//  ArticleViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/7/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "ArticleViewController.h"
#import "UIImageView+WebCache.h"

@interface ArticleViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UITextView *articleDescriptionTextView;

@end

@implementation ArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *imagesArray = [self.product imagesArray];
    NSURL *productImageUrl = [[imagesArray objectAtIndex:0] sourceURL];
    [self.articleImageView sd_setImageWithURL:productImageUrl];
    
    self.articleDescriptionTextView.text = _product.stringDescription;
    
    self.title = @"Article";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
