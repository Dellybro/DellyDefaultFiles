//
//  CustomIndicator.h
//  Shmooz
//
//  Created by Travis Delly on 1/5/16.
//  Copyright © 2016 Travis Delly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomIndicator : UIView

-(void)stop;
-(void)start:(UIViewController*)superView;
-(void)startOnView:(UIView*)view;

@end
