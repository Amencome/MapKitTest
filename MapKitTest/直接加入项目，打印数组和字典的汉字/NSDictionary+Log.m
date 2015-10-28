//
//  NSDictionary+Log.m
//  ListLog
//
//  Created by YouXianMing on 15/6/5.
//  Copyright (c) 2015年 YouXianMing. All rights reserved.
//

#import "NSDictionary+Log.h"

@implementation NSDictionary (Log)

- (NSString *)descriptionWithLocale:(id)locale {
    
    NSArray         *allKeys = [self allKeys];
    NSMutableString *str     = [[NSMutableString alloc] initWithFormat:@"{\t\n "];
    
    for (NSString *key in allKeys) {
        id value = self[key];
        [str appendFormat:@"\t \"%@\" = %@,\n",key, value];
    }
    
    [str appendString:@"}"];
    
    return str;
}

@end
