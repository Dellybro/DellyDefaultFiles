//
//  CustomScripts.m
//  Shmooz
//
//  Created by Travis Delly on 1/9/16.
//  Copyright © 2016 Travis Delly. All rights reserved.
//

#import "CustomScripts.h"
#import <UIKit/UIKit.h>

@implementation CustomScripts


+ (NSDate*)getLocalTime:(NSDate*)currentDate{
    NSDate* sourceDate = currentDate;
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    return destinationDate;
}

+(void)saveImageToTemp:(NSString*)downloadingFilePath name:(NSString*)imageString{
    
    UIImage *image = [UIImage imageWithContentsOfFile:downloadingFilePath];
    
    //save to disk
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    
    NSError *error;
    [imageData writeToFile:[NSString stringWithFormat:@"tmp/%@",imageString] options:NSDataWritingAtomic error:&error];
}

+(NSString*)locationFromLatAndLongitude:(float)latitude and:(float)longitude{
    
    
    //[self showLoadingView:@"Loading.."];
    NSError *error = nil;
    
    NSString *lookUpString  = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&amp;sensor=false", latitude,longitude];
    
    lookUpString = [lookUpString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:lookUpString]];
    if(jsonResponse){
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonResponse options:kNilOptions error:&error];
        
        if(jsonDict){
            NSArray *resultArray = [jsonDict objectForKey:@"results"];
            
            if([[jsonDict objectForKey:@"status"] isEqualToString:@"OK"]){
                return [[resultArray objectAtIndex:0] objectForKey:@"formatted_address"];
            }else{
                return nil;
            }
        }else{
            return nil;
        }
    }
    return nil;
    
}


+(NSString*)getTimeStamp:(NSString*)dateString{
    
    NSLog(@"%@", dateString);
    //Way to much
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSSZ"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSLog(@"%@", date);
    
    [dateFormatter setDateFormat:@"(EEEE) hh:mm a"];
    NSString *stringDate = [dateFormatter stringFromDate:date];
    
    return [NSString stringWithFormat:@"%@",stringDate];
}

+(NSString*)GetDayAndTime:(NSDate*)date{
    //Way to much
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM dd, yyyy (EEEE) hh:mm a"];
    NSString *stringDate = [format stringFromDate:date];
    
    return stringDate;
}

//Thanks to Stack Over Flow - John
+(NSString*)generateRandomString:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

//address/city/state/zip
+(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude = 0, longitude = 0;
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *esc_addr =  [addressStr stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude=latitude;
    center.longitude = longitude;
    return center;
    
}

@end
