//
//  CredentialStore.h
//  Shmooz
//
//  Created by Travis Delly on 1/2/16.
//  Copyright © 2016 Travis Delly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject


- (BOOL)isLoggedIn;
- (void)clearSavedCredentials;

//Auth For User
- (NSString *)authToken;
- (void)setAuthToken:(NSString *)authToken;

//Auth for phone
-(void)setPhoneAuth:(NSString*)authToken;
-(NSString *)phoneAuth;

@end
