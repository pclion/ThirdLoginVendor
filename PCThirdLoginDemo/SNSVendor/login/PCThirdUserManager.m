//
//  PCThirdUserManager.m
//  PCThirdLoginDemo
//
//  Created by 张培创 on 15/3/13.
//  Copyright (c) 2015年 com.duowan. All rights reserved.
//

#import "PCThirdUserManager.h"

@interface PCThirdUserManager ()

@property (nonatomic, strong) PCUserAuthenticationService *userService;

@end

@implementation PCThirdUserManager

+ (instancetype)defaultManager
{
    static PCThirdUserManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[PCThirdUserManager alloc] init];
    });
    return manager;
}

+ (void)initializeSNSSdkWithWeixinAppId:(NSString *)weixinAppId weixinSecret:(NSString *)weixinSecret weibo:(NSString *)weiboAppKey weiboRedirectUrl:(NSString *)url qq:(NSString *)qqAppKey
{
    [PCUserAuthenticationService initializeSNSSdkWithWeixinAppId:weixinAppId weixinSecret:weixinSecret weibo:weiboAppKey weiboRedirectUrl:url qq:qqAppKey];
}

+ (PCLoginInfo *)getLoginInfoWithUserType:(PCUserType)userType
{
    return [PCUserAuthenticationService getLoginInfoWithUserType:userType];
}

- (void)setupWithUserType:(PCUserType)userType
{
    self.userService = [PCUserAuthenticationService userAuthenticationServiceWithUserType:userType];
}

- (void)setServiceDelegate:(id<PCUserAuthenticationServiceDelegate>)delegate
{
    self.userService.delegate = delegate;
}

- (void)login
{
    [self.userService login];
}

- (BOOL)handleOpenUrl:(NSURL *)url
{
    return [self.userService handleOpenUrl:url];
}

+ (BOOL)isWechatInstall
{
    return [PCUserAuthenticationService isWechatInstall];
}

+ (BOOL)isQQInstall
{
    return [PCUserAuthenticationService isQQInstall];
}

+ (BOOL)isQQZoneInstall
{
    return [PCUserAuthenticationService isQQZoneInstall];
}

@end
