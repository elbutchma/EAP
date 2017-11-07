//
//  ProductsViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 2/28/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "ProductsViewController.h"
#import "ShopifyManager.h"
#import "ProductsTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "CheckoutViewController.h"
#import "CBuyCart.h"
#import "UIBarButtonItem+Badge.h"
#import "LoginViewController.h"

@interface ProductsViewController () <UITableViewDelegate, UITableViewDataSource, NSCoding>
@property (weak, nonatomic) IBOutlet UITableView *productsTableView;
@property (nonatomic, strong) NSArray<BUYProduct *> *productsArray;
@property (nonatomic, strong) NSMutableArray *itemsQuantitiesArray;
@property (nonatomic, strong) BUYCart *cart;
@property (nonatomic, strong) NSMutableDictionary *productsQuantityDictionary;
@end

@implementation ProductsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.productsTableView.delegate = self;
    self.productsTableView.dataSource = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ShopifyManager getProductsOfCollection:self.collectionId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsRecieved:) name:@"collection_products" object:nil];
    
    
    self.cart = [[[ShopifyManager sharedInstance] buyClient].modelManager insertCartWithJSONDictionary:nil];
    
    if (self.category.length > 0) {
        self.title = self.category;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    NSString *badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.cart.lineItemsArray.count];
    self.navigationItem.rightBarButtonItem.badgeValue = badgeValue;
    
    self.cart = [CBuyCart sharedInstance].cart;
    [self createProductsDictionary];
    [self.productsTableView reloadData];
}

- (void)createProductsDictionary {
    self.productsQuantityDictionary = [NSMutableDictionary new];

    for (int i = 0; i< self.cart.lineItemsArray.count; i++) {
        BUYCartLineItem *lineItem = [[self.cart lineItemsArray] objectAtIndex:i];
        int quantity = [lineItem.quantity intValue];
        NSNumber *variantId = lineItem.variant.identifier;

            if ([self.productsQuantityDictionary objectForKey:variantId]) {
                NSNumber *oldValue = [self.productsQuantityDictionary objectForKey:variantId];
                [self.productsQuantityDictionary setObject:[NSNumber numberWithInt:quantity+oldValue.intValue] forKey:variantId];
            } else {
                [self.productsQuantityDictionary setObject:[NSNumber numberWithInt:quantity] forKey:variantId];
            }
    }
    
    NSLog(@"items %@", self.productsQuantityDictionary);
}

#pragma mark - table view delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 380;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.productsArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productsCell"];
    
    if (!cell) {
        cell = [[ProductsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"productsCell"];
    }
    
    
    [cell.stepper setStepValue:1.0];
    BUYProduct *product = [self.productsArray objectAtIndex:indexPath.row];
    NSArray *imagesArray = [product imagesArray];
    NSURL *productImageUrl = [[imagesArray objectAtIndex:0] sourceURL];

    [cell.productImageView sd_setImageWithURL:productImageUrl placeholderImage:[UIImage imageNamed:@"temp-product"]];
    
    cell.productNameLabel.text = product.title;
    cell.productDescriptionLabel.text = product.stringDescription;

    
    cell.stepper.tag = indexPath.row;
    [cell.stepper addTarget:self action:@selector(updateQuantity:) forControlEvents:UIControlEventValueChanged];
    int stepperValue;
    if ((int)cell.stepper.value == 0) {
        stepperValue = 1;
    } else{
        stepperValue = cell.stepper.value;
    }
    
    [cell.stepper setIncrementImage:[[UIImage imageNamed:@"stepper-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [cell.stepper setDecrementImage:[[UIImage imageNamed:@"stepper-minus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    
    [cell.stepper setTintColor:[UIColor clearColor]];
  
    BUYProductVariant *variant = [[product variantsArray] objectAtIndex:0];
    
    
    NSString *value = @"";
    NSNumber *variantValue = [self.productsQuantityDictionary objectForKey:variant.identifier];
    
    if (variantValue != nil) {
        value = [NSString stringWithFormat:@"%@",variantValue];
    } else {
        value = @"0";
    }
    
    
    cell.stepper.value = [value intValue];
    
    cell.quantityLabel.text = [NSString stringWithFormat:@"%i",(int)cell.stepper.value];
    
    cell.productPriceLabel.text = [NSString stringWithFormat:@"%0.2f",stepperValue *product.minimumPrice.floatValue];
    cell.layer.shadowOpacity = 1.0;
    cell.layer.shadowRadius = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 2);
    cell.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


-(void)productsRecieved:(NSNotification*)notification{
    self.productsArray = [notification.userInfo objectForKey:@"products"];

    [self.productsTableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.productId) {
        for (int i=0; i<self.productsArray.count; i++) {
            
            BUYProduct *product = [self.productsArray objectAtIndex:i];
            for (NSString *tag in product.tags) {
                if (![tag isEqualToString:@"Slider_product"] && ![tag isEqualToString:@"product"] && ![tag containsString:@"col"] && (self.productId == product.identifier)){
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.productsTableView scrollToRowAtIndexPath:indexPath
                                         atScrollPosition:UITableViewScrollPositionTop
                                                 animated:YES];
                }
            }
        }
    }
    
     [self createCheckoutBarItemWithBadge];
}

-(void)updateQuantity:(id)sender{
    UIStepper *stepper = (UIStepper*)sender;

    ////////////////////////////////////////////////////////////////////////////
    
    if (!self.cart) {

        self.cart = [[[ShopifyManager sharedInstance] buyClient].modelManager insertCartWithJSONDictionary:nil];
        
        [CBuyCart sharedInstance].cart = self.cart;
    }
    
    
    
    BUYProduct *product = [self.productsArray objectAtIndex:stepper.tag];
    BUYProductVariant *variant = [product.variantsArray objectAtIndex:0];

    NSNumber *oldQuantity = [self.productsQuantityDictionary objectForKey:variant.identifier];

    BOOL itemIsInCart = NO;
    BUYProductVariant *cartItemVariant = nil;
    for (int i = 0; i< self.cart.lineItemsArray.count; i++) {
        BUYCartLineItem *lineItem = [[self.cart lineItemsArray] objectAtIndex:i];
        NSNumber *cartItemVariantId = lineItem.variant.identifier;
        
        if (cartItemVariantId == variant.identifier) {
            itemIsInCart = YES;
            cartItemVariant = lineItem.variant;
            break;
        }
    }
    
    if (stepper.value > oldQuantity.doubleValue) {
        if (itemIsInCart && cartItemVariant) {
            [[CBuyCart sharedInstance].cart addVariant:cartItemVariant];

        } else {
            [[CBuyCart sharedInstance].cart addVariant:variant];
        }
        
//        [[CBuyCart sharedInstance].cart addVariant:variant];
//        [variant setProduct:product];
//        [self.cart setVariant:variant withTotalQuantity:stepper.value];
//        
        
    } else{
        if (itemIsInCart && cartItemVariant) {
            [[CBuyCart sharedInstance].cart removeVariant:cartItemVariant];
            
        } else {
            [[CBuyCart sharedInstance].cart removeVariant:variant];
        }
        
//        [[CBuyCart sharedInstance].cart removeVariant:variant];
//        [variant setProduct:product];
//        [self.cart setVariant:variant withTotalQuantity:stepper.value];
    }
    
    self.cart = [CBuyCart sharedInstance].cart;
    [self createProductsDictionary];
    
    ////////////////////////////////////////////////////////////////////////////
    self.itemsQuantitiesArray [stepper.tag] = [NSString stringWithFormat:@"%i",(int) stepper.value];
    

    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.productsTableView reloadData];
        [self createCheckoutBarItemWithBadge];

    });
}

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
        
        
        
        
    } else{
        if (self.cart.lineItemsArray.count > 0) {
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

#pragma mark - shopping cart menu badge
-(void)createCheckoutBarItemWithBadge{
    NSString * badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[[[CBuyCart sharedInstance].cart lineItemsArray]count]];
    
  
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cart-button"] style:UIBarButtonItemStylePlain target:self action:@selector(goToCheckout)];
    
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    self.navigationItem.rightBarButtonItem.badgeValue = badgeValue;
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
