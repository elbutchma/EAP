//
//  AddressesViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/18/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "AddressesViewController.h"
#import "AddressesTableViewCell.h"
#import "ShopifyManager.h"
#import "RegisterViewController.h"

@interface AddressesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *addressesTableView;
@property (nonatomic, strong) BUYCustomer *customer;

@end

@implementation AddressesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *customerDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"customer"];
    self.customer = [[[[ShopifyManager sharedInstance] buyClient] modelManager] insertCustomerWithJSONDictionary:customerDic];
    
    self.addressesTableView.delegate = self;
    self.addressesTableView.dataSource = self;
    
    
    self.title = @"My Locations";
    //add address button
//    [[UIBarButtonItem alloc] initWithTitle:@"add"
//                                                                   style:UIBarButtonItemStylePlain
//                                                                  target:self
//                                                                  action:@selector(createNewAddress)];
    
    
    UIBarButtonItem *addAddressButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(createNewAddress)];
    [self.navigationItem setRightBarButtonItem:addAddressButton animated:YES];
    
    self.addressesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.customer.addresses.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddressesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell"];
    
    if (!cell) {
        cell = [[AddressesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addressCell"];
    }
    BUYAddress *address = [[self.customer.addresses allObjects] objectAtIndex:indexPath.row];
    cell.addressLabel.text = address.address1;
    cell.companyLabel.text = address.company;
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}



#pragma mark - helper methods
-(void)createNewAddress{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RegisterViewController *registerVC = [storyboard instantiateViewControllerWithIdentifier:@"registerVC"];
    registerVC.isAddAddress = YES;
    
    [self.navigationController pushViewController:registerVC animated:YES];
    
    
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
