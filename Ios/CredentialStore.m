//
//  CredentialStore.m
//  Shmooz
//
//  Created by Travis Delly on 1/2/16.
//  Copyright © 2016 Travis Delly. All rights reserved.
//

#import "CredentialStore.h"
#import <SSKeychain/SSKeychain.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#define SERVICE_NAME_USER @"user"
#define SERVICE_NAME_PHONE @"phone"
#define AUTH_TOKEN_KEY @"auth_token"

@implementation CredentialStore


- (BOOL)isLoggedIn {
    NSString *auth = [self authToken];
    return auth != nil;
}

- (void)clearSavedCredentials {
    [self setAuthToken:nil];
    [self setPhoneAuth:nil];
    if ([FBSDKAccessToken currentAccessToken]) {
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
    }
}

//Phone auth
-(void)setPhoneAuth:(NSString*)authToken{
    [self setSecureValuePhone:authToken forKey:AUTH_TOKEN_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"token-changed" object:self];
}

-(NSString *)phoneAuth{
    NSString *auth = [self secureValueForKeyPhone:AUTH_TOKEN_KEY];
    return auth;
}

- (void)setSecureValuePhone:(NSString *)value forKey:(NSString *)key {
    if (value) {
        [SSKeychain setPassword:value
                     forService:SERVICE_NAME_PHONE
                        account:key];
    } else {
        [SSKeychain deletePasswordForService:SERVICE_NAME_USER account:key];
    }
}
- (NSString *)secureValueForKeyPhone:(NSString *)key {
    return [SSKeychain passwordForService:SERVICE_NAME_PHONE account:key];
}

//User Auth
- (NSString *)authToken {
    NSString *auth = [self secureValueForKeyUser:AUTH_TOKEN_KEY];
    return auth;
}

- (void)setAuthToken:(NSString *)authToken {
    [self setSecureValueUser:authToken forKey:AUTH_TOKEN_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"token-changed" object:self];
}

- (void)setSecureValueUser:(NSString *)value forKey:(NSString *)key {
    if (value) {
        [SSKeychain setPassword:value
                     forService:SERVICE_NAME_USER
                        account:key];
    } else {
        [SSKeychain deletePasswordForService:SERVICE_NAME_USER account:key];
    }
}

- (NSString *)secureValueForKeyUser:(NSString *)key {
    return [SSKeychain passwordForService:SERVICE_NAME_USER account:key];
}

@end
