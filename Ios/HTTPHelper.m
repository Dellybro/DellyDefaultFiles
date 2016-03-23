 //
//  HTTPHelper.m
//  Shmooz
//
//  Created by Travis Delly on 12/23/15.
//  Copyright © 2015 Travis Delly. All rights reserved.
//

#import "HTTPHelper.h"
#import "AppDelegate.h"


@interface HTTPHelper()
@property AppDelegate *sharedDelegate;
@property NSString* baseURL;
@property NSString* startURL;

@end

NSString *const S3BucketName = @"schmooz-userphoto-bucket";
AWSRegionType const CognitoRegionType = AWSRegionUSEast1;
AWSRegionType const DefaultServiceRegionType = AWSRegionUSWest2;
NSString *const CognitoIdentityPoolId = @"us-east-1:fea84b01-f7d1-4376-a0f1-79f5c955625a";


@implementation HTTPHelper{
}



-(id)init{
    self = [super init];
    if (self){
        _sharedDelegate = [[UIApplication sharedApplication] delegate];
        NSString *urlLocalhost = @"localhost:3000";
//        NSString *urlHeroku = @"mysterious-stream-63319.herokuapp.com";
        _baseURL = [NSString stringWithFormat:@"http://%@/api/v1", urlLocalhost];
        _startURL = [NSString stringWithFormat:@"http://%@", urlLocalhost];
        
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType: CognitoRegionType identityPoolId:CognitoIdentityPoolId];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:DefaultServiceRegionType credentialsProvider:credentialsProvider];
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
        
        
    }
    return self;
}


#pragma Amazon S3Bucket
-(void)importPhotoFromAWS:(UIImageView*)image path:(NSString *)imageName{
    
    NSData *profData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"tmp/%@",imageName]];
    
    if(profData){
        image.image = [UIImage imageWithData:profData];
        return;
    }
    
    //Start activity indicator on view
    CustomIndicator *indicator = [[CustomIndicator alloc] initWithFrame:image.frame];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [indicator startOnView:image];
    
    [image addConstraint:[NSLayoutConstraint constraintWithItem:indicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:image attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [image addConstraint:[NSLayoutConstraint constraintWithItem:indicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:image attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [image addConstraint:[NSLayoutConstraint constraintWithItem:indicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:image attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [image addConstraint:[NSLayoutConstraint constraintWithItem:indicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:image attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    //NSString *policy = @"arn:aws:s3:::schmooz-users-photo-bucket/*";
    //Setup AWS
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = S3BucketName;
    downloadRequest.key = imageName;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    // Download the file.
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]withBlock:^id(AWSTask *task) {
        if (task.error){
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                        break;
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        NSLog(@"Error: %@", task.error);
                        break;
                }
            } else {
                // Unknown error.
                NSLog(@"Error: %@", task.error);
            }
        }
        
        
        
        if (task.result) {
            //AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                
                [CustomScripts saveImageToTemp:downloadingFilePath name:imageName];
                
                [indicator stop];
                [image setImage:[UIImage imageWithContentsOfFile:downloadingFilePath]];
            });
            //File downloaded successfully.
        }else{
            [indicator stop];
        }
        return nil;
    }];
}

-(void)uploadPhotoToAWS:(UIImage *)imageToUpload forType:(NSString*)type forId:(int)type_id view:(UIViewController*)controller index:(int)picIndex completionHandler:(void (^)(BOOL success, NSURLResponse *response))completionHandler {
    //Start activity indicator if needed.
    controller ? [_sharedDelegate.activityIndicator start:controller] : nil;
    
    //Setup Post to database
    //Needs work for Auth_token access
    NSString *post1 = [NSString stringWithFormat:@"%@[id]=%i&picture[picture_index]=%i", type, type_id, picIndex];
    //Send off to Database
    if([_sharedDelegate.HTTPRequest postMethod:type method:@"update_image" action:nil post:post1 auth:_sharedDelegate.loggedInUser.auth_token version:API_V2] == 1){
        //Grab the current picture
        NSMutableDictionary *currentPicture = [_sharedDelegate.HTTPRequest.latestReturn.object objectForKey:@"picture"];
    
        NSData *imageData = UIImageJPEGRepresentation(imageToUpload, 1.0);
        
        NSString *key = [currentPicture objectForKey:@"name"];
        
        AWSS3GetPreSignedURLRequest *getPreSignedURLRequest = [AWSS3GetPreSignedURLRequest new];
        getPreSignedURLRequest.bucket = S3BucketName;
        getPreSignedURLRequest.key = key;
        getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodPUT;
        getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:3600];
        
        NSString *fileContentTypeString = @"text/plain";
        getPreSignedURLRequest.contentType = fileContentTypeString;
        
        //Need to find a way to set this as a variable?
        
        [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder] getPreSignedURL:getPreSignedURLRequest] continueWithBlock:^id(AWSTask *task) {
            
            if (task.error) {
                NSLog(@"Error: %@", task.error);
            } else {
                
                NSURL *presignedURL = task.result;
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:presignedURL];
                request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                [request setHTTPMethod:@"PUT"];
                [request setValue:fileContentTypeString forHTTPHeaderField:@"Content-Type"];
                
                NSURLSessionUploadTask *uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:imageData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    
                    //Get main thread to dispatch activity indactor
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        controller ? [_sharedDelegate.activityIndicator stop] : nil;
                    });
                    //Send back completion
                    completionHandler(YES,response);
                    if (error) {
                        
                        NSLog(@"Upload errer: %@", error);
                    }else{
                        
                        NSLog(@"upload successful");
                    }
                }];
                
                [uploadTask resume];
            }
            return nil;
            
        }];
    }
}
#pragma My Methods

#pragma mark - Only Methods Needed, Other will be deleted over time

-(NSInteger)postMethod:(NSString*)typeOfUser method:(NSString*)method action:(NSString*)action post:(NSString*)post auth:(NSString*)auth_token version:(NSString *)version{
    
    //setup url
    NSString* finalURL;
    if(action == nil){
        finalURL = [NSString stringWithFormat:@"%@/%@/%@/%@", _startURL, version,typeOfUser, method];
    } else {
        finalURL = [NSString stringWithFormat:@"%@/%@/%@/%@%@", _startURL, version, typeOfUser, method, action];
    }
    //setup request using mutableurlrequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:finalURL]];
    
    //setup postdata
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    //set request
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    if(!(auth_token == nil)){
        NSString *authValue = [NSString stringWithFormat:@"Token %@", auth_token];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    //Make REQUEST
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //return status codes.
    if(error == nil){
        NSError *jsonError;
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        _latestReturn = [[JsonReturn alloc] initWithJSON:json];
        return _latestReturn.code;
    } else {
        return 0;
    }
}

-(NSInteger)methodGet:(NSString*)typeOfUser method:(NSString*)method action:(NSString*)action auth:(NSString*)auth_token version:(NSString *)version{
    NSString *finalURL;
    if(action == nil){
        
        finalURL = [NSString stringWithFormat:@"%@/%@/%@/%@", _startURL, version, typeOfUser, method];
        
    } else {
        
        finalURL = [NSString stringWithFormat:@"%@/%@/%@/%@%@", _startURL, version, typeOfUser, method, action];
        
    }
    
    //setup request using mutableurlrequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:finalURL]];
    
    //set request
    [request setHTTPMethod:@"GET"];
    if(!(auth_token == nil)){
        NSString *authValue = [NSString stringWithFormat:@"Token %@", auth_token];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    //Make REQUEST
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error == nil){
        NSError *jsonError;
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        _latestReturn = [[JsonReturn alloc] initWithJSON:json];
        return _latestReturn.code;
    }else{
        return 0;
    }
    
}

-(NSInteger)signin:(NSString *)username for:(NSString *)password fortype:(NSString*)typeOfUser version:(NSString *)version{
    
    
    NSString *theURL = [NSString stringWithFormat:@"%@/%@/%@/signin?email=%@&password=%@", _startURL, version, typeOfUser, username.lowercaseString, password];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:theURL]];
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error == nil){
        NSError *jsonError;
        NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableContainers
                                                         error:&jsonError];
        
        _latestReturn = [[JsonReturn alloc] initWithJSON:json];
        return _latestReturn.code;
    } else {
        return 0;
    }
}

-(UIAlertController*)alert:(NSString*)alertTitle with:(NSString*)alertMessage buttonAction:(UIAlertAction*)button{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:button];
    
    return alert;
}

-(void)DBAlertOnController:(NSString*)alertTitle buttonAction:(UIAlertAction*)button controller:(UIViewController*)controller{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                   message:_sharedDelegate.HTTPRequest.latestReturn.message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:button];
    
    [controller presentViewController:alert animated:YES completion:nil];
}

-(void)AlertOnController:(NSString *)alertTitle message:(NSString *)alertMessage buttonAction:(UIAlertAction *)button controller:(UIViewController *)controller{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:button];
    
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
