//
//  NSArray+Log.m
//  ListLog
//
//  Created by YouXianMing on 15/6/5.
//  Copyright (c) 2015年 mc. All rights reserved.
//

#import "NSArray+Log.h"

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale {
    
    NSMutableString *str = [NSMutableString stringWithFormat:@"(\n"];
    
    for (id obj in self) {
        [str appendFormat:@"\t%@, \n", obj];
    }
    
    [str appendString:@")"];
    
    return str;
}
@end
