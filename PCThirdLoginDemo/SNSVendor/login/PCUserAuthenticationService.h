//
//  PCUserAuthenticationService.h
//  PCThirdLoginDemo
//
//  Created by 张培创 on 15/3/12.
//  Copyright (c) 2015年 com.duowan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PCUserTypeWeChat = 1,       //微信用户
    PCUserTypeWeibo,        //微博用户
    PCUserTypeQQ            //QQ用户
} PCUserType;               //用户登录类型

typedef enum : NSUInteger {
    PCLoginStatusSuccess,
    PCLoginStatusFailure,
} PCLoginStatus;

@class PCLoginInfo;

@protocol PCUserAuthenticationServiceDelegate <NSObject>

/**
 *  获取第三方登录的信息，用于登录自身服务器
 *
 *  @param loginInfo 信息
 *  @param status    登录状态
 */
- (void)userAuthenticationWithLoginInfo:(PCLoginInfo *)loginInfo status:(PCLoginStatus)status;

@end

@interface PCUserAuthenticationService : NSObject

@property (nonatomic, weak) id<PCUserAuthenticationServiceDelegate>delegate;
@property (nonatomic) PCUserType currentUserType;

/*
 *  获取实例方法
 */
+ (instancetype)userAuthenticationServiceWithUserType:(PCUserType)userType;

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

/**
 *  微信是否安装
 *
 *  @return 是否安装
 */
+ (BOOL)isWechatInstall;

/**
 *  qq是否安装
 *
 *  @return 是否安装
 */
+ (BOOL)isQQInstall;

/**
 *  qqZone是否安装
 *
 *  @return 是否安装
 */
+ (BOOL)isQQZoneInstall;

/**
 *  打开url
 *
 *  @param url application url
 *
 *  @return 是否成功
 */
- (BOOL)handleOpenUrl:(NSURL *)url;

/*
 *  微博，微信，QQ登录方法
 */
- (void)login;

/**
 *  获取第三方用户信息
 */
- (void)getThirdUserInfoWithLoginInfo:(PCLoginInfo *)loginInfo completion:(void (^)(id responseObj, NSError *error))completion;

/**
 *  内部方法
 *
 *  @param url        url
 *  @param completion completion
 */
- (void)sendRequestUrl:(NSString *)url completion:(void (^)(id responseObj, NSError *error))completion;

@end

/**
 *  第三方登录信息
 */
@interface PCLoginInfo : NSObject<NSCoding>

@property (nonatomic) PCUserType userType;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSDate *expiationDate;

@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *headImageUrl;
@property (nonatomic, copy) NSString *unionID;

@end
