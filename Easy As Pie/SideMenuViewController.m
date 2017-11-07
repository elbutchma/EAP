//
//  SideMenuViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/18/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "SideMenuViewController.h"
#import "SideMenuTableViewCell.h"
#import <ZDCChat/ZDCChat.h>
#import "ShopifyManager.h"
#import "CustomNavigationController.h"
#import <MFSideMenu.h>
#import "AddressesViewController.h"

@interface SideMenuViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *sideMenuTableView;
@property (nonatomic, strong, readwrite) NSMutableArray *titlesArray;
@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic,strong) MFSideMenuContainerViewController *container;
@property (nonatomic, strong) BUYCustomer *customer;

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sideMenuTableView.delegate = self;
    self.sideMenuTableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWelcomeMessage) name:@"login_token" object:nil];
    
    NSString *welcomeMessage = [self loadWelcomeMessage];
    self.titlesArray = [NSMutableArray arrayWithObjects:welcomeMessage,@"My Locations", @"Live Support", @"Logout", nil];
    
    self.imagesArray = @[@"sidemenu-welcome", @"sidemenu-address", @"sidemenu-chat", @"sidemenu-logout"];
    self.sideMenuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.sideMenuTableView.alwaysBounceVertical = NO;

    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSString*)loadWelcomeMessage{
    NSDictionary *customerDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"customer"];
    self.customer = [[[[ShopifyManager sharedInstance] buyClient] modelManager] insertCustomerWithJSONDictionary:customerDic];
    
    NSString *welcomeMessage = [NSString stringWithFormat:@"Welcome, %@",self.customer.firstName];
    [self.titlesArray replaceObjectAtIndex:0 withObject:welcomeMessage];
    [self.sideMenuTableView reloadData];
    return welcomeMessage;
}


#pragma mark - tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titlesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SideMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sideMenuCell"];
    if(!cell){
        cell = [[SideMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sideMenuCell"];
    }
    
    cell.titleLabel.text = [self.titlesArray objectAtIndex:indexPath.row];
    
    cell.cellImageView.image = [UIImage imageNamed:[self.imagesArray objectAtIndex:indexPath.row]];
    
    if (indexPath.row == 0) {
        [cell.separatorView setHidden:NO];
    } else {
        [cell.separatorView setHidden:YES];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    if (indexPath.row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        AddressesViewController *addressesVC = [storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
        UINavigationController *navController = [self.menuContainerViewController centerViewController];
        [navController pushViewController:addressesVC animated:YES];
        
    }
    else if (indexPath.row == 2) {
        NSDictionary *customerDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"customer"];
        __block BUYCustomer *customer = [[[[ShopifyManager sharedInstance] buyClient] modelManager] insertCustomerWithJSONDictionary:customerDic];
        
        
        [ZDCChat updateVisitor:^(ZDCVisitorInfo *user) {
            user.phone = customer.defaultAddress.phone;
            user.name = [NSString stringWithFormat:@"%@ %@", customer.firstName, customer.lastName];
            user.email = customer.email;
        }];
        [ZDCChat startChat:^(ZDCConfig *config) {
            //        config.preChatDataRequirements.name = ZDCPreChatDataRequired;
            //        config.preChatDataRequirements.email = ZDCPreChatDataRequired;
            //        config.preChatDataRequirements.phone = ZDCPreChatDataRequired;
            //        config.preChatDataRequirements.department = ZDCPreChatDataOptionalEditable;
            //        config.preChatDataRequirements.message = ZDCPreChatDataOptional;
            config.emailTranscriptAction = ZDCEmailTranscriptActionNeverSend;
            
            
        }];
    } else if (indexPath.row == 3){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"customer"];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        CustomNavigationController *mainNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"navController"];
//        [self.navigationController setViewControllers:@[initialVC]];
        
         [self.menuContainerViewController setCenterViewController:mainNavigationController];
    
        
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
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
