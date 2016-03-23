//
//  JsonReturn.h
//  Shmooz
//
//  Created by Travis Delly on 3/4/16.
//  Copyright © 2016 Travis Delly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonReturn : NSObject

-(void)toJson:(NSMutableDictionary*)jsonDictionary;
-(NSMutableDictionary*)toDict;
-(id)initWithJSON:(NSMutableDictionary*)jsonDictionary;

@property NSInteger code;
@property NSMutableDictionary *object;
@property NSString *message;


@end
