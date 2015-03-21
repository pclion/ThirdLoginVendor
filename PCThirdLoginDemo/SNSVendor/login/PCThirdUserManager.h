//
//  PCThirdUserManager.h
//  PCThirdLoginDemo
//
//  Created by 张培创 on 15/3/13.
//  Copyright (c) 2015年 com.duowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCUserAuthenticationService.h"

@interface PCThirdUserManager : NSObject

/*
 *  用户操作管理对象
 */
+ (instancetype)defaultManager;

/**
 *  注册SNS
 *
 *  @param weixinAppId 微信appid
 *  @param weixinSecret 微信secret
 *  @param weiboAppKey 微博appkey
 *  @param url         微博回调地址
 *  @param qqAppKey    qq appkey
 */
+ (void)initializeSNSSdkWithWeixinAppId:(NSString *)weixinAppId weixinSecret:(NSString *)weixinSecret weibo:(NSString *)weiboAppKey weiboRedirectUrl:(NSString *)url qq:(NSString *)qqAppKey;

+ (PCLoginInfo *)getLoginInfoWithUserType:(PCUserType)userType;

/*
 *  初始化当前登录用户类型
 */
- (void)setupWithUserType:(PCUserType)userType;

/**
 *  设置回调delegate
 *
 *  @param delegate delegate
 */
- (void)setServiceDelegate:(id<PCUserAuthenticationServiceDelegate>)delegate;

/*
 *  微信，微博，QQ第三方登录
 */
- (void)login;

/**
 *  打开url
 *
 *  @param url application url
 *
 *  @return 是否成功
 */
- (BOOL)handleOpenUrl:(NSURL *)url;

/**
 *  判断当前手机是否有安装微信
 *
 *  @return 结果
 */
+ (BOOL)isWechatInstall;

/**
 *  判断当前手机是否有安装QQ
 *
 *  @return 结果
 */
+ (BOOL)isQQInstall;

+ (BOOL)isQQZoneInstall;

@end
