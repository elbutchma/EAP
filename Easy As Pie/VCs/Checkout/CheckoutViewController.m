//
//  CheckoutViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 2/27/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "CheckoutViewController.h"
#import "CheckoutItemsTableViewCell.h"
#import "CheckoutTableViewCell.h"
#import "ShopifyManager.h"
#import "UIImageView+WebCache.h"
#import "CBuyCart.h"
#import "CBuyCheckout.h"
#import "MBProgressHUD.h"
#import "ActionSheetStringPicker.h"
#import "CheckoutsuccessViewController.h"



@interface CheckoutViewController () <UITableViewDelegate, UITableViewDataSource,AddPromoCodeDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *checkoutTableView;
@property (nonatomic, strong) NSMutableArray<BUYCartLineItem *> *itemsArray;
@property (nonatomic, strong) BUYCart *cart;
@property (nonatomic, strong) NSMutableArray *itemsQuantitiesArray;
@property (nonatomic, assign) BOOL isAvailableTime;
@property (nonatomic, assign) float discountAmount;
@property (nonatomic, strong) BUYCustomer *customer;
@property (nonatomic, strong) NSMutableArray *addressesArray;
@property (nonatomic, strong) NSMutableArray *addressesStringsArray;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;
@property (nonatomic, strong) NSMutableDictionary *productsQuantityDictionary;
@property (nonatomic, strong) NSMutableArray *productsArray;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAvailableTime = [self checkIfAvailableTime];
    if (!self.isAvailableTime) {
        [self showNotAvailableAlert];
    }
    
    self.discountAmount = 0.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkoutSucceeded:) name:@"checkout_completed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkoutFailed) name:@"checkout_failed" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(promoCodeAdded) name:@"promoCode_added" object:nil];
    self.cart = [CBuyCart sharedInstance].cart;
    
    self.itemsArray = [self.cart.lineItemsArray copy];
    
    NSDictionary *customerDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"customer"];
    self.customer = [[[[ShopifyManager sharedInstance] buyClient] modelManager] insertCustomerWithJSONDictionary:customerDic];
    

 
    self.addressesArray = [NSMutableArray new];
    self.addressesStringsArray = [NSMutableArray new];
    for (BUYAddress *address in self.customer.addresses) {
        if (address.address1) {
            [self.addressesArray addObject:address];
            [self.addressesStringsArray addObject:address.address1];
        }
        
    }
   
    [self.checkoutButton addTarget:self action:@selector(completeCheckOut) forControlEvents:UIControlEventTouchUpInside];
    
    [self.continueShoppingButton addTarget:self action:@selector(continueShoppingAction) forControlEvents:UIControlEventTouchUpInside];

    self.title = @"CHECKOUT";
    self.navigationItem.backBarButtonItem.title = @"back";
    
    [self createProductsDictionary];
    [self createProductsQuantitiesDictionary];
    self.checkoutTableView.delegate = self;
    self.checkoutTableView.dataSource = self;
}

#pragma mark - tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.itemsArray.count < 1) {
        return 0;
    } else {
        return 2;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.productsArray.count;
    } else {
        return 1;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CheckoutItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutItemCell"];
        if (!cell) {
            cell = [[CheckoutItemsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"checkoutItemCell"];
        }
        
        BUYCartLineItem *item = [self.itemsArray objectAtIndex:indexPath.row];


        
//        BUYProduct *product =  item.variant.product;
//        NSArray *imagesArray = product.imagesArray;
//        NSURL *imageUrl = [[imagesArray objectAtIndex:0] sourceURL];
//        [cell.itemImageView sd_setImageWithURL:imageUrl];
//        cell.itemNameLabel.text = product.title;
//        cell.itemUnitPrice.text = [NSString stringWithFormat:@"%0.2f",product.minimumPrice.floatValue];
        
        
        ////////////////////////////////////////////////////////////
        BUYProductVariant *variant = [self.productsArray objectAtIndex:indexPath.row];
        NSNumber *savedValue = [self.productsQuantityDictionary objectForKey:variant.identifier];
        ////////////////////////////////////////////////////////////
        
        for (int index = 0; index < self.itemsArray.count; index++) {
            BUYCartLineItem *arrayItem = [self.itemsArray objectAtIndex:index];
            if ([arrayItem.variant.identifier intValue] == [variant.identifier intValue]) {
                item = arrayItem;
                break;
            }
        }
        
        BUYProduct *product =  variant.product;
        NSArray *imagesArray = product.imagesArray;
        NSURL *imageUrl = [[imagesArray objectAtIndex:0] sourceURL];
        [cell.itemImageView sd_setImageWithURL:imageUrl];
        cell.itemNameLabel.text = product.title;
        cell.itemUnitPrice.text = [NSString stringWithFormat:@"%0.2f",product.minimumPrice.floatValue];

        cell.stepper.value = savedValue.doubleValue;
        
        cell.stepper.tag = [variant.identifier intValue];
        cell.itemTotalPrice.text = [NSString stringWithFormat:@"%0.2f",item.linePrice.floatValue];
        
        [cell.stepper setIncrementImage:[[UIImage imageNamed:@"stepper-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [cell.stepper setDecrementImage:[[UIImage imageNamed:@"stepper-minus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        
        
        [cell.stepper setTintColor:[UIColor clearColor]];
        
        
//        cell.quantityLabel.text = [NSString stringWithFormat:@"%i",item.quantity.intValue];
                cell.quantityLabel.text = [NSString stringWithFormat:@"%i",((NSNumber*)[self.productsQuantityDictionary objectForKey:variant.identifier]).intValue];
        
        
        cell.layer.shadowOpacity = 1.0;
        cell.layer.shadowRadius = 1;
        cell.layer.shadowOffset = CGSizeMake(0, 2);
        cell.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    } else{
        CheckoutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutCell"];
        if (!cell) {
            cell = [[CheckoutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"checkoutCell"];
        }
        

        
        float orderValue = [self caluclateTotalPrice];
//        for (int i = 0; i<self.cart.lineItemsArray.count; i++) {
//            BUYCartLineItem *item = [self.itemsArray objectAtIndex:i];
//            orderValue += item.linePrice.floatValue;
//        }
        
        if (self.discountAmount > 0.0) {
            orderValue = orderValue - self.discountAmount;
        }
        
        float taxValue = (orderValue*13/100);
        float totalOrderValue =orderValue + 5.0;
        
        cell.orderValueLabel.text = [NSString stringWithFormat:@"%0.2f EGP", orderValue];
        cell.shippingValueLabel.text = @"5.0 EGP";
        cell.taxesValueLabel.text = [NSString stringWithFormat:@"%0.2f EGP",taxValue];
        cell.totalOrderValueLabel.text = [NSString stringWithFormat:@"%0.2f EGP",totalOrderValue] ;
        
        
        cell.delegate = self;
        cell.promoCodetextField.delegate = self;
        [cell.checkoutButton addTarget:self action:@selector(completeCheckOut) forControlEvents:UIControlEventTouchUpInside];
        [cell.continueShoppingButton addTarget:self action:@selector(continueShoppingAction) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 120;
    } else {
        return 210;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - add promo code delegate
-(void)processAddPromoCode:(NSString *)promoCode{
    
    [self.view endEditing:YES];
    NSLog(@"promo code : %@", promoCode);
    BUYCheckout *checkout = [[[ShopifyManager sharedInstance].buyClient modelManager] checkoutWithCart:self.cart];
    [[ShopifyManager sharedInstance] setIsAddingDiscountCode:YES];
    [[ShopifyManager sharedInstance] setPromoCode:promoCode];
    [ShopifyManager createCheckout:checkout];
    
    
}

-(void)promoCodeAdded{
    NSLog(@"%@",[CBuyCheckout sharedInstance].checkout.discount.JSONDictionary);
    
    
    self.discountAmount = [CBuyCheckout sharedInstance].checkout.discount.amount.floatValue;
    
    UIAlertController *promoCodeAlert = [UIAlertController alertControllerWithTitle:@"Success" message:[NSString stringWithFormat:@"You have received %0.2f EGP discount.",self.discountAmount] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [promoCodeAlert addAction:OkAction];
    [self presentViewController:promoCodeAlert animated:YES completion:nil];
    
    
    [self.checkoutTableView reloadData];
}
#pragma mark - actions
-(void)completeCheckOut{
    
    if (!self.isAvailableTime) {
        [self showNotAvailableAlert];
    } else {

    
        
        [ActionSheetStringPicker showPickerWithTitle:@"Select your address"
                                                rows:self.addressesStringsArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               NSLog(@"selected: %@",(NSString*) selectedValue);
                                               
                                               //complete checkout
                                               
                                               [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                               
                                               BUYCheckout *checkout;
//                                               if (![CBuyCheckout sharedInstance].checkout) {
                                                   checkout = [[[ShopifyManager sharedInstance].buyClient modelManager] checkoutWithCart:self.cart];
                                                   [CBuyCheckout sharedInstance].checkout = checkout;
//                                               } else {
//                                                   checkout = [CBuyCheckout sharedInstance].checkout;
//                                               }
//                                               
                                               BUYAddress *address = [self.addressesArray objectAtIndex:selectedIndex];
                                               checkout.shippingAddress = address;
                                               checkout.billingAddress = address;
                                               
                                               [ShopifyManager createCheckout:checkout];

                                                                                            
                                               
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.view];
        
        
            }
    
    
}


-(void)continueShoppingAction{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)checkoutSucceeded:(NSNotification*)notification{
    
    [[CBuyCart sharedInstance].cart clearCart];
    
//    ZHPopupView *popupView = [ZHPopupView popUpDialogViewInView:nil
//                                                        iconImg:[UIImage imageNamed:@"success"]
//                                                backgroundStyle:ZHPopupViewBackgroundType_SimpleOpacity
//                                                          title:@"Order placed"
//                                                        content:@"Order details has been sent to your email. \n If you have any questions or concerns please contact us through the live chat.\n Thanks for using EASY as PIE"
//                                                   buttonTitles:@[@"Ok"]
//                                            confirmBtnTextColor:nil otherBtnTextColor:nil
//                                             buttonPressedBlock:^(NSInteger btnIdx) {
//                                                 
//                                                 [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
//                                                 
//                                             }];
//    
//    
//    
//    [popupView setContentTextAlignment:NSTextAlignmentCenter];
//    
//    [popupView present];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CheckoutsuccessViewController *successVC = [storyboard instantiateViewControllerWithIdentifier:@"CheckoutsuccessViewController"];
    [self.navigationController pushViewController:successVC animated:YES];
    
    
}

-(void)checkoutFailed{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Checkout failed, please check your internet connection." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [self performSelector:@selector(completeCheckOut) withObject:nil afterDelay:1];
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }];
    
    [alert addAction:okAction];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - stepper action
- (IBAction)updateQuantity:(UIStepper *)sender {
    UIStepper *stepper = (UIStepper*)sender;
    
//    BUYCartLineItem *lineItem = [self.itemsArray objectAtIndex:stepper.tag];
    
//    int oldQuantity = lineItem.quantity.intValue;
    
//    BUYProductVariant *variant = lineItem.variant;
    BUYProductVariant *variant;
    
    for (int x=0; x<self.productsArray.count; x++) {
        BUYProductVariant *arrayVariant = [self.productsArray objectAtIndex:x];
        if ([arrayVariant.identifier intValue] == stepper.tag) {
            variant = [self.productsArray objectAtIndex:x];
            break;
        }
    }
    
    NSNumber *oldQuantity = [self.productsQuantityDictionary objectForKey:variant.identifier];
    
    if (oldQuantity.intValue < stepper.value) {
            [self.cart addVariant:variant];
//            [self.cart setVariant:lineItem.variant withTotalQuantity:stepper.value];
        } else {
            [self.cart removeVariant:variant];
//            [[CBuyCart sharedInstance].cart setVariant:lineItem.variant withTotalQuantity:stepper.value];
        }
    

    
//    self.itemsArray = [[CBuyCart sharedInstance].cart.lineItemsArray copy];
 
    [CBuyCart sharedInstance].cart = self.cart;
    
    [self createProductsDictionary];
    [self createProductsQuantitiesDictionary];
    
    [self.checkoutTableView reloadData];
    
    
    if (self.productsArray.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Items Dictionaries initialization
- (void)createProductsQuantitiesDictionary {
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
    
    NSLog(@"items quantities %@", self.productsQuantityDictionary);
}

- (void)createProductsDictionary {
    self.productsArray = [NSMutableArray new];
    
    for (int i = 0; i< self.cart.lineItemsArray.count; i++) {
        BUYCartLineItem *lineItem = [[self.cart lineItemsArray] objectAtIndex:i];
        NSNumber *cartVariantId = lineItem.variant.identifier;
        
    ///////////
        // add item in variants array if not exist, if exist do nothing
        //then in cell for row get value from dictionary (while variant.id == [dictionary objectforkey:variant])
        
        BOOL cartAlreadyContainsVariant = NO;
        for (int j = 0; j < self.productsArray.count; j++) {
            
            BUYProductVariant *variant = [self.productsArray objectAtIndex:j];

            if (variant.identifier == cartVariantId) {
                cartAlreadyContainsVariant = YES;
                break;
            }
        }
        
        if (!cartAlreadyContainsVariant) {
            [self.productsArray addObject:lineItem.variant];
        }
        
        
    }
    
    for (BUYProductVariant *variant in self.productsArray) {
        NSLog(@"variants array variant name %@, variant id %@",variant.product.title,variant.identifier);
    }
    
}

#pragma mark - check available times
-(BOOL)checkIfAvailableTime{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    NSInteger hour = [components hour];
//    NSInteger minute = [components minute];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *day =[dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"The day of the week: %@", day);
    
    if (hour > 16 || hour < 8 || [[day lowercaseString] isEqualToString:@"friday"] || [[day lowercaseString] isEqualToString:@"saturday"]) {
        return false;
    }else{
        return true;
    }
    
}

#pragma mark - not available alert
-(void)showNotAvailableAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"We are available only from 8 AM to 4 PM except for Friday and Saturday!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    [alert addAction:action];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - uitextfield delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect f = self.view.frame;
//        f.origin.y = -keyboardSize.height;
//        self.view.frame = f;
//    }];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect f = self.view.frame;
//        f.origin.y = 0.0f;
//        self.view.frame = f;
//    }];
}

- (double)caluclateTotalPrice {
    
    double totalPrice = 0;
    
    for (BUYProductVariant *variant in self.productsArray) {
        BUYProduct *product = variant.product;
        NSNumber *savedValue = [self.productsQuantityDictionary objectForKey:variant.identifier];
        
        totalPrice+= (product.minimumPrice.floatValue*savedValue.intValue);
    }
    
    return totalPrice;
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
