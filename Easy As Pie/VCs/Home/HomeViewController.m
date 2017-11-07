//
//  HomeViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 2/27/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "HomeViewController.h"
#import "ShopifyManager.h"
#import "UIImageView+WebCache.h"
#import "MenuTableViewCell.h"
#import "ProductsViewController.h"
#import "ArticleViewController.h"
#import "MBProgressHUD.h"
#import "CheckoutViewController.h"
#import "CBuyCart.h"
#import "SideMenuViewController.h"
#import <MFSideMenu.h>
#import "AppDelegate.h"
#import "UIBarButtonItem+Badge.h"
#import "LoginViewController.h"
#import "SliderCollectionViewCell.h"
#import "Reachability.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *imagesView;
@property (weak, nonatomic) IBOutlet UIPageControl *sliderPager;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UIView *menuHeaderSubView;
@property (nonatomic, strong) NSArray<BUYProduct*> *productsArr;
@property (nonatomic, strong) NSArray<BUYCollection*> *collections;
@property (nonatomic, strong) BUYCart *cart;
@property (nonatomic, strong) NSMutableArray<BUYCartLineItem *> *itemsArray;
@property (weak, nonatomic) IBOutlet UIView *menuHeaderView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *sliderBgView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowMenuImage;
@property (weak, nonatomic) IBOutlet UIImageView *openMenuHeaderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTopConstraint;
@property (nonatomic, strong) NSTimer *sliderTimer;
@property (nonatomic) BOOL menuIsOpen;

@property (nonatomic,strong) MFSideMenuContainerViewController *container;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *sliderCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *sliderCollectionViewFlow;

@property (nonatomic, retain) NSTimer *sliderCollectionViewTimer;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self checkReachablityAndLoadSliderAndMenuItems];
    
   
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsRecieved:) name:@"Slider_products_notification" object:self.productsArr ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:@"Slider_products_notification_failed" object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionsRecieved:) name:@"Menu_collections" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionFailed:) name:@"Menu_collections_failed" object:nil];
    
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    
    self.menuIsOpen = NO;
    UISwipeGestureRecognizer *openMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
    [openMenuGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.menuHeaderView addGestureRecognizer:openMenuGesture];
    
    UISwipeGestureRecognizer *closeMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    [closeMenuGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.menuHeaderView addGestureRecognizer:closeMenuGesture];
    
    
    UITapGestureRecognizer *openMenuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
    [self.menuHeaderView addGestureRecognizer:openMenuTap];
    
    //    UITapGestureRecognizer *closeMenuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    //    [self.menuHeaderView addGestureRecognizer:closeMenuTap];
    
    
    
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (accessToken && accessToken.length >0) {
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-button"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleSideMenu)];
        [self.navigationItem setLeftBarButtonItem:menuButton animated:YES];
    }
    
    
    
    
    
    
    
    
    UIImage *homeTitle = [UIImage imageNamed:@"home-title"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:homeTitle];
    
    self.menuHeaderSubView.layer.cornerRadius = 10.0;
    
    //    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.sliderBgView.bounds];
    //    self.sliderBgView.layer.masksToBounds = NO;
    //    self.sliderBgView.layer.shadowColor = [UIColor blackColor].CGColor;
    //    self.sliderBgView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    //    self.sliderBgView.layer.shadowOpacity = 0.5f;
    //    self.sliderBgView.layer.shadowPath = shadowPath.CGPath;
    
    
    //    self.sliderBgView.layer.shadowColor = [UIColor grayColor].CGColor;
    //    self.sliderBgView.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    //    self.sliderBgView.layer.shadowOpacity = 0.5;
    //    self.sliderBgView.layer.shadowRadius = 1.0;
    
    
    [self initializeCollectionView];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cart-button"] style:UIBarButtonItemStylePlain target:self action:@selector(goToCheckout)];
    
    
    
    self.cart = [CBuyCart sharedInstance].cart;
    self.itemsArray = [self.cart.lineItemsArray copy];
    NSString *badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.itemsArray.count];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    self.navigationItem.rightBarButtonItem.badgeValue = badgeValue;
    
    
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES
     ];
    
    //    self.scrollView set
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - collectionview
-(void)initializeCollectionView{
    
    [self.sliderCollectionView registerNib:[UINib nibWithNibName:@"SliderCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"sliderCell"];
    
    self.sliderCollectionViewFlow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.sliderCollectionViewFlow.itemSize = CGSizeMake(self.sliderCollectionView.bounds.size.width, self.sliderCollectionView.bounds.size.height);
    self.sliderCollectionViewFlow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [self.sliderCollectionView setCollectionViewLayout:self.sliderCollectionViewFlow animated:YES];
    self.sliderCollectionView.showsHorizontalScrollIndicator = NO;
    
    
    self.sliderCollectionView.dataSource = self;
    self.sliderCollectionView.delegate = self;
    
    [self.sliderCollectionView setContentOffset:self.sliderCollectionView.contentOffset animated:NO];
}



-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.productsArr.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SliderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sliderCell" forIndexPath:indexPath];
    
    NSArray *imagesArray = [[self.productsArr objectAtIndex:indexPath.item] imagesArray];
    NSURL *productImageUrl = [[imagesArray objectAtIndex:0] sourceURL];
    
    [cell.sliderImageView sd_setImageWithURL:productImageUrl];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BUYProduct *product = [self.productsArr objectAtIndex:indexPath.item];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    if ([product.tags containsObject:@"collection"]) {
        for (NSString *tag in product.tags) {
            if (![tag isEqualToString:@"Slider_product"] && ![tag isEqualToString:@"collection"]) {
                
                [self closeMenu];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                
                ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
                productsVC.category = @"";
                productsVC.collectionId = [formatter numberFromString:tag];
                [self.navigationController pushViewController:productsVC animated:YES];
            }
        }
    } else if ([product.tags containsObject:@"product"]){
        NSString *collectionId;
        NSString *productId;
        for (NSString *tag in product.tags) {
            
            if ([tag containsString:@"col"]) {
                collectionId = [[tag componentsSeparatedByString:@"_"] objectAtIndex:1];
            }
            else if (![tag isEqualToString:@"Slider_product"] && ![tag isEqualToString:@"product"]) {
                productId = tag;
                
                
            }
        }
        
        //open products VC
        [self closeMenu];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
        
        productsVC.category = product.title;
        productsVC.collectionId = [formatter numberFromString:collectionId];
        productsVC.productId = [formatter numberFromString:productId];
        
        [self.navigationController pushViewController:productsVC animated:YES];
        
        
        NSLog(@"product");
    } else if ([product.tags containsObject:@"article"]){
        
        for (NSString *tag in product.tags) {
            if (! [tag isEqualToString:@"Slider_product"] && ![tag isEqualToString:@"article"]) {
                
            }
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ArticleViewController *articleVc = [storyboard instantiateViewControllerWithIdentifier:@"articleVC"];
        articleVc.product = product;
        [self.navigationController pushViewController:articleVc animated:YES];
        NSLog(@"article");
    }
}

#pragma mark - shopify methods
-(void)checkReachablityAndLoadSliderAndMenuItems{
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [reach startNotifier];
    if (reach.isReachable) {
        [ShopifyManager getProductsByTags];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"message:@"Your internet conenction is not working, please check your connection and click Refresh."  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *refreshAction = [UIAlertAction actionWithTitle:@"Refresh" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self checkReachablityAndLoadSliderAndMenuItems];
        }];
        
        [alertController addAction:refreshAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


-(void)reachabilityChanged:(NSNotification*)notification {
    Reachability *reach = (Reachability*) notification.object;
    
    //    if (reach.isReachable) {
    //    [self checkReachablityAndLoadSliderAndMenuItems];
    //    } else{
    //
    //    }
}

-(void)productsRecieved:(NSNotification*)notification{
    self.productsArr = [notification.userInfo objectForKey:@"products"];
    [self.sliderCollectionView reloadData];
    
    
    
    
    
    [ShopifyManager getCollections];
    
}

-(void)requestFailed:(NSNotification*)notification{
    //    NSError *error = [notification.userInfo objectForKey:@"error"];
    //    NSString *errorMessage ;
    //    if (error.userInfo && [error.userInfo objectForKey:@"error"]) {
    //        errorMessage = [error.userInfo objectForKey:@"error"];
    //    } else {
    //        errorMessage = [error localizedDescription];
    //    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error occured, please check your internet connection and click Refresh" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Refresh" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ShopifyManager getProductsByTags];
    }];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)collectionsRecieved:(NSNotification*)notification{
    self.collections = [notification.userInfo objectForKey:@"collections"];
    [self.menuTableView reloadData];
    if (self.menuTableView.contentSize.height < self.menuTableView.frame.size.height) {
        self.menuTableView.scrollEnabled = NO;
    }
    else {
        self.menuTableView.scrollEnabled = YES;
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //start timer to auto scroll products collection view
    if (!self.sliderCollectionViewTimer) {
        
        self.sliderCollectionViewTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                         repeats:YES block:^(NSTimer * _Nonnull timer) {
                                                                             NSArray *visibleItems = [self.sliderCollectionView indexPathsForVisibleItems];
                                                                             
                                                                             if (!visibleItems || visibleItems.count == 0) {
                                                                                 visibleItems = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForItem:0 inSection:0] , nil];
                                                                             }
                                                                             NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
                                                                             
                                                                             if (currentItem.item+1 == self.productsArr.count) {
                                                                                 currentItem = [NSIndexPath indexPathForItem:-1 inSection:currentItem.section];
                                                                             }
                                                                             NSIndexPath *nextItem = [NSIndexPath indexPathForItem:currentItem.item + 1 inSection:currentItem.section];
                                                                             
                                                                             [self.sliderCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
                                                                             
                                                                         }];
    }
}

-(void)collectionFailed:(NSNotification*)notification{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSError *error = [notification.userInfo objectForKey:@"error"];
    NSString *errorMessage ;
    if ([error.userInfo objectForKey:@"error"]) {
        errorMessage = [error.userInfo objectForKey:@"error"];
    } else {
        errorMessage = [error localizedDescription];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int currentIndex = scrollView.contentOffset.x / self.imagesView.frame.size.width;
    [self.sliderPager setCurrentPage:currentIndex];
}


-(void)openMenu{
    if (!self.menuIsOpen) {
        
        
        [UIView animateWithDuration:0.5 animations:^{
            self.menuTopConstraint.constant = -self.view.frame.size.height;
            
            self.menuIsOpen = YES;
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            [self.menuHeaderSubView setHidden:YES];
            [self.shadowMenuImage setHidden:YES];
            [self.openMenuHeaderImageView setHidden:NO];
            [self.shadowMenuImage setImage:[UIImage imageNamed:@"bottom-menu-image-open"]];
            [self.menuHeaderView setBackgroundColor:[UIColor whiteColor]];
            
        }];
        
        
    } else{
        [self closeMenu];
    }
}

-(void)closeMenu{
    if (self.menuIsOpen) {
        
        
        //        [self.menuHeaderSubView setHidden:YES];
        //        [self.shadowMenuImage setHidden:NO];
        //        [self.menuHeaderView setBackgroundColor:[UIColor clearColor]];
        //        [UIView animateWithDuration:1 animations:^{
        //
        //            self.menuTopConstraint.constant = -56;
        //            self.menuIsOpen = NO;
        //
        //            [self.view layoutIfNeeded];
        //        }];
        
        
        [self.menuHeaderSubView setHidden:YES];
        [self.shadowMenuImage setHidden:NO];
        [self.openMenuHeaderImageView setHidden:YES];
        [self.shadowMenuImage setImage:[UIImage imageNamed:@"bottom-menu-image-closed"]];
        [self.menuHeaderView setBackgroundColor:[UIColor clearColor]];
        [UIView animateWithDuration:0.5 animations:^{
            self.menuTopConstraint.constant = -56;
            self.menuIsOpen = NO;
            
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}




-(void)selectImageFromSlider:(id)sender{
    UIImageView *image = (UIImageView*)[sender view];
    
    BUYProduct *product = [self.productsArr objectAtIndex:image.tag];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    if ([product.tags containsObject:@"collection"]) {
        for (NSString *tag in product.tags) {
            if (! [tag isEqualToString:@"Slider_product"] && ![tag isEqualToString:@"collection"]) {
                
                [self closeMenu];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                
                ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
                productsVC.category = product.title;
                productsVC.collectionId = [formatter numberFromString:tag];
                [self.navigationController pushViewController:productsVC animated:YES];
            }
        }
    } else if ([product.tags containsObject:@"product"]){
        NSString *collectionId;
        NSString *productId;
        for (NSString *tag in product.tags) {
            
            if ([tag containsString:@"col"]) {
                collectionId = [[tag componentsSeparatedByString:@"_"] objectAtIndex:1];
            }
            else if (![tag isEqualToString:@"Slider_product"] && ![tag isEqualToString:@"product"]) {
                productId = tag;
                
                
            }
        }
        
        //open products VC
        [self closeMenu];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
        
        productsVC.category = product.title;
        productsVC.collectionId = [formatter numberFromString:collectionId];
        productsVC.productId = [formatter numberFromString:productId];
        
        [self.navigationController pushViewController:productsVC animated:YES];
        
        
        NSLog(@"product");
    } else if ([product.tags containsObject:@"article"]){
        
        for (NSString *tag in product.tags) {
            if (! [tag isEqualToString:@"Slider_product"] && ![tag isEqualToString:@"article"]) {
                
            }
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ArticleViewController *articleVc = [storyboard instantiateViewControllerWithIdentifier:@"articleVC"];
        articleVc.product = product;
        [self.navigationController pushViewController:articleVc animated:YES];
        NSLog(@"article");
    }
    
    //    for (NSString *tag in product.tags) {
    //        if ([[tag lowercaseString] isEqualToString:@"collection"]) {
    //            NSLog(@"collection");
    //        }
    //        else if ([[tag lowercaseString] isEqualToString:@"product"]) {
    //            NSLog(@"product");
    //        } else if ([[tag lowercaseString] isEqualToString:@"article"]) {
    //            NSLog(@"article");
    //        }
    //    }
    
    
}

#pragma mark - tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.collections.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    if (!cell) {
        cell = [[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCell"];
    }
    BUYCollection *collection = [self.collections objectAtIndex:indexPath.row];
    cell.collectionLabel.text = collection.title;
    [cell.collectionImageView sd_setImageWithURL:[[collection image] sourceURL]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    [self closeMenu];
    BUYCollection *collection = [self.collections objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
    productsVC.category = collection.title;
    productsVC.collectionId = collection.identifier;
    [self.navigationController pushViewController:productsVC animated:YES];
}

#pragma mark - actions
-(void)goToCheckout{
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (!accessToken && (accessToken.length <= 0)) {
        
        UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"Login" message:@"You have to login first" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
                
                [self.navigationController setViewControllers:@[loginVC] animated:YES];
                
            });
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            
        }];
        [alert addAction:loginAction];
        [alert addAction:cancelAction];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        
        
        
        
    } else {
        BUYCart *cart = [CBuyCart sharedInstance].cart;
        if (cart.lineItemsArray.count > 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            CheckoutViewController *checkoutVc = [storyboard instantiateViewControllerWithIdentifier:@"checkoutVC"];
            [self.navigationController pushViewController:checkoutVc animated:YES];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Please add products to cart first." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
            
        }
        
    }
    
    
    
    
    
    
}




-(void)toggleSideMenu{
    //    self.menuContainerViewController =
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
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
