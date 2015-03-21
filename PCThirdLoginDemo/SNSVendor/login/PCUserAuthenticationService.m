//
//  PCUserAuthenticationService.m
//  PCThirdLoginDemo
//
//  Created by 张培创 on 15/3/12.
//  Copyright (c) 2015年 com.duowan. All rights reserved.
//

#import "PCUserAuthenticationService.h"
#import "WXApi.h"
#import "WeiboSDK.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

static NSString *WeixinAPPId = @"";
static NSString *WeixinSecret = @"";
static NSString *WeiboAPPKey = @"";
static NSString *WeiboRedirectUrl = @"";
static NSString *QQAPPKey = @"";

#define kWechatStoreKey @"kWechatStoreKey"
#define kWeiboStoreKey  @"kWeiboStoreKey"
#define KQQStoreKey     @"KQQStoreKey"

@implementation PCLoginInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.userType forKey:@"userType"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [aCoder encodeObject:self.expiationDate forKey:@"expiationDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.userType = [aDecoder decodeIntForKey:@"userType"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.refreshToken = [aDecoder decodeObjectForKey:@"refreshToken"];
        self.expiationDate = [aDecoder decodeObjectForKey:@"expiationDate"];
    }
    return self;
}

@end

#pragma mark - 微博用户

@interface PCWeiboUserAuthenticationService : PCUserAuthenticationService<WeiboSDKDelegate>

@end

@implementation PCWeiboUserAuthenticationService

- (BOOL)handleOpenUrl:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (void)login
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = WeiboRedirectUrl;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

#pragma mark - Weibo Delegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        WBAuthorizeResponse *resp = (WBAuthorizeResponse *)response;
        PCLoginInfo *loginInfo = [[PCLoginInfo alloc] init];
        loginInfo.userType = self.currentUserType;
        loginInfo.uid = resp.userID;
        loginInfo.token = resp.accessToken;
        loginInfo.refreshToken = resp.refreshToken;
        loginInfo.expiationDate = resp.expirationDate;
        
        if (resp.accessToken) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:loginInfo];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:kWeiboStoreKey];
            if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
                [self.delegate userAuthenticationWithLoginInfo:loginInfo status:PCLoginStatusSuccess];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
                [self.delegate userAuthenticationWithLoginInfo:nil status:PCLoginStatusFailure];
            }
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
            [self.delegate userAuthenticationWithLoginInfo:nil status:PCLoginStatusFailure];
        }
    }
}

@end

#pragma mark - 微信用户

@interface PCWeChatUserAuthenticationService : PCUserAuthenticationService<WXApiDelegate>

@end

@implementation PCWeChatUserAuthenticationService

- (BOOL)handleOpenUrl:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)login
{
    PCLoginInfo *info = [PCUserAuthenticationService getLoginInfoWithUserType:self.currentUserType];
    if (info) {
        if ([info.expiationDate compare:[NSDate date]] != NSOrderedAscending) {
            if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
                [self.delegate userAuthenticationWithLoginInfo:info status:PCLoginStatusSuccess];
            }
        } else {
            [self refreshWeChatTokenWithRefreshToken:info.refreshToken completion:^(id responseObj, NSError *error) {
                [self parserJsonObj:responseObj];
            }];
        }
    } else {
        SendAuthReq* req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"";
        [WXApi sendReq:req];
    }
}

- (void)getWeChatAccessTokenWithCode:(NSString *)code completion:(void (^)(id responseObj, NSError *error))completion
{
    if (code == nil) {
        completion(nil, [NSError errorWithDomain:@"登录失败" code:999 userInfo:nil]);
        return;
    }
    NSString *requestUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WeixinAPPId, WeixinSecret, code];
    
    [self sendRequestUrl:requestUrl completion:completion];
}

- (void)refreshWeChatTokenWithRefreshToken:(NSString *)refreshToken completion:(void (^)(id responseObj, NSError *error))completion
{
    if (refreshToken == nil) {
        completion(nil, [NSError errorWithDomain:@"登录失败" code:999 userInfo:nil]);
        return;
    }
    NSString *requestUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", WeixinAPPId, refreshToken];
    [self sendRequestUrl:requestUrl completion:completion];
}

- (void)parserJsonObj:(id)responseObj
{
    //获取鉴权结果
    //错误码返回值不一致，需做处理
    if ([responseObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)responseObj;
        NSString *code = dict[@"errcode"];
        if (code == nil) {
            PCLoginInfo *loginInfo = [[PCLoginInfo alloc] init];
            loginInfo.userType = self.currentUserType;
            loginInfo.uid = dict[@"openid"];
            loginInfo.token = dict[@"access_token"];
            loginInfo.refreshToken = dict[@"refresh_token"];
            loginInfo.expiationDate = [NSDate dateWithTimeIntervalSinceNow:[dict[@"expires_in"] integerValue]];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:loginInfo];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:kWechatStoreKey];
            
            if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
                [self.delegate userAuthenticationWithLoginInfo:loginInfo status:PCLoginStatusSuccess];
            }
        } else {
            //登录失败
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWechatStoreKey];
            if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
                [self.delegate userAuthenticationWithLoginInfo:nil status:PCLoginStatusFailure];
            }
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
            [self.delegate userAuthenticationWithLoginInfo:nil status:PCLoginStatusFailure];
        }
    }
}

#pragma mark - WeChat Delegate

- (void)onReq:(BaseReq *)req
{
    
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isMemberOfClass:[SendAuthResp class]]) {
        NSString *code = [(SendAuthResp *)resp code];
        [self getWeChatAccessTokenWithCode:code completion:^(id responseObj, NSError *error) {
            [self parserJsonObj:responseObj];
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
            [self.delegate userAuthenticationWithLoginInfo:nil status:PCLoginStatusFailure];
        }
    }
}

@end

#pragma mark - qq用户

@interface PCQQUserAuthenticationService : PCUserAuthenticationService<TencentSessionDelegate>

@property (strong, nonatomic) TencentOAuth *tencentOAuth;

@end

@implementation PCQQUserAuthenticationService

- (BOOL)handleOpenUrl:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}

- (TencentOAuth *)tencentOAuth
{
    if (!_tencentOAuth) {
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAPPKey andDelegate:self];
    }
    return _tencentOAuth;
}

- (void)login
{
    NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
    [self.tencentOAuth authorize:permissions inSafari:NO];
}

- (void)loginQQInfo
{
    if (self.tencentOAuth.accessToken && self.tencentOAuth.expirationDate && self.tencentOAuth.openId) {
        PCLoginInfo *loginInfo = [[PCLoginInfo alloc] init];
        loginInfo.userType = self.currentUserType;
        loginInfo.uid = self.tencentOAuth.openId;
        loginInfo.token = self.tencentOAuth.accessToken;
        loginInfo.expiationDate = self.tencentOAuth.expirationDate;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:loginInfo];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:KQQStoreKey];
        
        if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
            [self.delegate userAuthenticationWithLoginInfo:loginInfo status:PCLoginStatusSuccess];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(userAuthenticationWithLoginInfo:status:)]) {
            [self.delegate userAuthenticationWithLoginInfo:nil status:PCLoginStatusFailure];
        }
    }
}

#pragma mark - QQ Delegate

- (void)tencentDidLogin
{
    [self loginQQInfo];
}

- (void)tencentDidNotNetWork
{
    [self loginQQInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [self loginQQInfo];
}

@end

@implementation PCUserAuthenticationService

+ (instancetype)userAuthenticationServiceWithUserType:(PCUserType)userType
{
    PCUserAuthenticationService *service = [[PCUserAuthenticationService alloc] init];
    switch (userType) {
        case PCUserTypeWeibo:
            service = [[PCWeiboUserAuthenticationService alloc] init];
            break;
        case PCUserTypeWeChat:
            service = [[PCWeChatUserAuthenticationService alloc] init];
            break;
        case PCUserTypeQQ:
            service = [[PCQQUserAuthenticationService alloc] init];
            break;
        default:
            break;
    }
    service.currentUserType = userType;
    return service;
}

+ (BOOL)isWechatInstall
{
    return [WXApi isWXAppInstalled];
}

+ (BOOL)isQQInstall
{
    return [TencentOAuth iphoneQQInstalled];
}

+ (BOOL)isQQZoneInstall
{
    return [TencentOAuth iphoneQZoneInstalled];
}

+ (void)initializeSNSSdkWithWeixinAppId:(NSString *)weixinAppId weixinSecret:(NSString *)weixinSecret weibo:(NSString *)weiboAppKey weiboRedirectUrl:(NSString *)url qq:(NSString *)qqAppKey
{
    WeixinAPPId = weixinAppId;
    WeixinSecret = weixinSecret;
    WeiboAPPKey = weiboAppKey;
    WeiboRedirectUrl = url;
    QQAPPKey = qqAppKey;
    
    // 微博SDK注册
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:WeiboAPPKey];
    
    // 微信SDK注册
    [WXApi registerApp:WeixinAPPId];
}

+ (PCLoginInfo *)getLoginInfoWithUserType:(PCUserType)userType
{
    PCLoginInfo *loginInfo = nil;
    NSData *data = nil;
    switch (userType) {
        case PCUserTypeQQ:
            data = [[NSUserDefaults standardUserDefaults] objectForKey:KQQStoreKey];
            loginInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            break;
        case PCUserTypeWeChat:
            data = [[NSUserDefaults standardUserDefaults] objectForKey:kWechatStoreKey];
            loginInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            break;
        case PCUserTypeWeibo:
            data = [[NSUserDefaults standardUserDefaults] objectForKey:kWeiboStoreKey];
            loginInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            break;
        default:
            break;
    }
    
    return loginInfo;
}

- (void)sendRequestUrl:(NSString *)url completion:(void (^)(id responseObj, NSError *error))completion
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(obj, connectionError);
        } else {
            completion(nil, connectionError);
        }
    }];
}

- (BOOL)handleOpenUrl:(NSURL *)url
{
    return NO;
}

- (void)login
{
    
}

@end
