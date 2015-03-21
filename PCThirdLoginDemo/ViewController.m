//
//  ViewController.m
//  PCThirdLoginDemo
//
//  Created by 张培创 on 15/3/12.
//  Copyright (c) 2015年 com.duowan. All rights reserved.
//

#import "ViewController.h"
#import "PCThirdUserManager.h"

@interface ViewController ()<PCUserAuthenticationServiceDelegate>

- (IBAction)wechatAction:(id)sender;
- (IBAction)weiboAction:(id)sender;
- (IBAction)qqAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)wechatAction:(id)sender {
    [[PCThirdUserManager defaultManager] setupWithUserType:PCUserTypeWeChat];
    [[PCThirdUserManager defaultManager] setServiceDelegate:self];
    [[PCThirdUserManager defaultManager] login];
}

- (IBAction)weiboAction:(id)sender {
    [[PCThirdUserManager defaultManager] setupWithUserType:PCUserTypeWeibo];
    [[PCThirdUserManager defaultManager] setServiceDelegate:self];
    [[PCThirdUserManager defaultManager] login];
}

- (IBAction)qqAction:(id)sender {
    [[PCThirdUserManager defaultManager] setupWithUserType:PCUserTypeQQ];
    [[PCThirdUserManager defaultManager] setServiceDelegate:self];
    [[PCThirdUserManager defaultManager] login];
}

- (void)userAuthenticationWithLoginInfo:(PCLoginInfo *)loginInfo status:(PCLoginStatus)status
{
    if (status == PCLoginStatusSuccess) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

@end
