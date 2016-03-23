//
//  JsonReturn.m
//  Shmooz
//
//  Created by Travis Delly on 3/4/16.
//  Copyright © 2016 Travis Delly. All rights reserved.
//

#import "JsonReturn.h"

@implementation JsonReturn

-(id)initWithJSON:(NSMutableDictionary *)jsonDictionary{
    self = [super init];
    if(self){
        
        self.code = ([jsonDictionary objectForKey:@"code"] && ![[jsonDictionary objectForKey:@"code"] isKindOfClass:[NSNull class]]) ? [[jsonDictionary objectForKey:@"code"] integerValue] : 999;
        
        self.object = ([jsonDictionary objectForKey:@"object"] && ![[jsonDictionary objectForKey:@"object"] isKindOfClass:[NSNull class]]) ? [jsonDictionary objectForKey:@"object"] : nil;
        
        self.message = ([jsonDictionary objectForKey:@"message"] && ![[jsonDictionary objectForKey:@"message"] isKindOfClass:[NSNull class]]) ? [jsonDictionary objectForKey:@"message"] : @"";
        
        if(self.code == 1 && ![self.object isKindOfClass:[NSMutableDictionary class]]){
            
            NSData *jsonData = [(NSString*)[self.object objectForKey:[self.object allKeys].firstObject] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *e;
            [self.object setObject:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e] forKey:[self.object allKeys].firstObject];
        }
        
    }
    return self;
}

-(NSMutableDictionary *)toDict{
    NSMutableDictionary *dict;
    
    [dict setObject:[NSNumber numberWithInteger:self.code] forKey:@"code"];
    [dict setObject:self.object forKey:@"object"];
    [dict setObject:self.message forKey:@"message"];
    
    return dict;
}

-(void)toJson:(NSMutableDictionary *)jsonDictionary{
    
    
    self.code = ([jsonDictionary objectForKey:@"code"] && ![[jsonDictionary objectForKey:@"code"] isKindOfClass:[NSNull class]]) ? [[jsonDictionary objectForKey:@"code"] integerValue] : 999;
    
    self.object = ([jsonDictionary objectForKey:@"object"] && ![[jsonDictionary objectForKey:@"object"] isKindOfClass:[NSNull class]]) ? [jsonDictionary objectForKey:@"object"] : nil;
    
    self.message = ([jsonDictionary objectForKey:@"message"] && ![[jsonDictionary objectForKey:@"message"] isKindOfClass:[NSNull class]]) ? [jsonDictionary objectForKey:@"message"] : @"";
    
    if(self.code == 1 && ![self.object isKindOfClass:[NSMutableDictionary class]]){
        
        NSData *jsonData = [(NSString*)[self.object objectForKey:[self.object allKeys].firstObject] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        [self.object setObject:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e] forKey:[self.object allKeys].firstObject];
    }
    
}

@end
