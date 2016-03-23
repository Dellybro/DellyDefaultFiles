//
//  HTTPHelper.h
//  Shmooz
//
//  Created by Travis Delly on 12/23/15.
//  Copyright © 2015 Travis Delly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JsonReturn.h"

#import <AWSS3/AWSS3.h>
#import <AWSCognitoIdentity.h>
#import <AWSCognitoIdentityResources.h>

@interface HTTPHelper : NSObject <UIAlertViewDelegate>

//Only return needed
@property JsonReturn *latestReturn;

//Only Methods Needed for databasing
-(NSInteger)postMethod:(NSString*)typeOfUser method:(NSString*)method action:(NSString*)action post:(NSString*)post auth:(NSString*)auth_token version:(NSString*)version;
-(NSInteger)methodGet:(NSString*)typeOfUser method:(NSString*)method action:(NSString*)action auth:(NSString*)auth_token version:(NSString*)version;
-(NSInteger)signin:(NSString *)username for:(NSString *)password fortype:(NSString*)typeOfUser version:(NSString*)version;

//AWS
-(void)importPhotoFromAWS:(UIImageView*)image path:(NSString*)imageName;

-(void)uploadPhotoToAWS:(UIImage *)imageToUpload forType:(NSString*)type forId:(int)type_id view:(UIViewController*)controller index:(int)picIndex completionHandler:(void (^)(BOOL success, NSURLResponse *response))completionHandler;

-(UIAlertController*)alert:(NSString*)alertTitle with:(NSString*)alertMessage buttonAction:(UIAlertAction*)button;
-(void)DBAlertOnController:(NSString*)alertTitle buttonAction:(UIAlertAction*)button controller:(UIViewController*)controller;
-(void)AlertOnController:(NSString*)alertTitle message:(NSString*)alertMessage buttonAction:(UIAlertAction*)button controller:(UIViewController*)controller;
@end

#define API_V2 @"api/v2"
#define API_V1 @"api/v1"

#define ORGANIZATION @"organization"
#define ORGANIZATIONS @"organizations"

#define BROADCAST @"broadcast"
#define BROADCASTS @"broadcasts"

#define EVENT @"event"
#define EVENTS @"events"

#define PINNED_SKILL @"pinned_skill"
#define PINNED_SKILLS @"pinned_skills"


#define PINNED_EVENT @"pinned_event"
#define PINNED_EVENTS @"pinned_events"

#define USER @"user"
#define USERS @"users"

#pragma mark - Paths

#define UPDATE @"update"
#define GET_BY_AUTH @"get_by_auth"
#define GET_EVENTS_BROADCASTS @"get_events_broadcasts"
#define SIGNIN @"signin"
#define CREATE @"create"
#define UPDATE_IMAGE @"update_image"
#define ADD_MULITPLE_HOBBIES @"add_multiple_hobbies"
#define ADD_MULITPLE_PINNED_SKILLS @"add_multiple_pinned_skills"
#define CREATE_RELATIONSHIP @"create_relationship"
#define SEND_MESSAGE @"send_message"
#define REGISTER_FOR_EVENT @"register_for_event"
#define PIN_EVENT @"pin_event"
#define UNPIN_EVENT @"unpin_event"
#define FIND_EVENTS_BY_COORDINATES @"find_events_by_coordinates"
#define FIND_EVENTS_BY_QUERY @"find_events_by_query"
