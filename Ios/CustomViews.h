//
//  CustomViews.h
//  Shmooz
//
//  Created by Travis Delly on 1/1/16.
//  Copyright © 2016 Travis Delly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CustomField.h"
#import "StringImage.h"

@interface CustomViews : NSObject
+(void)bounceView:(UIView*)view;
+(void)shrinkViewToCenterOfView:(UIView *)view completionHandler:(void (^)(BOOL success))completionHandler;

+(void)shrinkViewToPoint:(CGPoint)point view:(UIView *)view completionHandler:(void (^)(BOOL success))completionHandler;

+(void)growView:(UIView*)view;
+(void)expandingCircle:(UIView*)circle;
+(void)AnimateView:(UIView*)view;
+(UIImageView*)customImageViewNoBorder:(NSString*)imageString;
+(UILabel *)LabelWithShadow;

+(UITextField*)nonBorderedTextField:(NSString*)placeholder;

+(UITextField*)borderedTextFieldWithPlaceHolder:(NSString*)placeholder;

+(UIButton*)buttonWithString:(NSString *)string;
+(UIButton *)buttonWithImage:(UIImage *)image;

+(UISlider *)sliderBar;
+(UILabel *)customLabel;

+(UIImageView*)customImageView:(NSString*)imageString;
+(UIView*)headerView;

+(UIButton*)buttonWithNoBackground:(NSString*)text;

+(UITextView*)defaultTextView:(NSString *)text;

+(void)bounceUPMainCell:(UIView*)view;

@end
