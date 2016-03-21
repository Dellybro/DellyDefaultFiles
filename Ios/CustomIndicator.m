//
//  CustomIndicator.m
//  Shmooz
//
//  Created by Travis Delly on 1/5/16.
//  Copyright © 2016 Travis Delly. All rights reserved.
//

#import "CustomIndicator.h"

@implementation CustomIndicator{
    UIActivityIndicatorView *activityView;

}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        CGAffineTransform transform = CGAffineTransformMakeScale(2.2f, 2.2f);
        activityView.transform = transform;
        
        
        [self addSubview:activityView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:activityView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:activityView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    }
    return self;
}
-(void)stop{
    [self removeFromSuperview];
    [activityView stopAnimating];
    
}
-(void)startOnView:(UIView*)view{
    [view addSubview:self];
    [activityView startAnimating];
}
-(void)start:(UIViewController*)superView{
    [superView.view addSubview:self];
    [activityView startAnimating];
}

@end
