//
//  NSString+URLQueryToDictionary.m
//  god
//
//  Created by yangyang on 16/9/20.
//  Copyright © 2016年 shoppingm.cn. All rights reserved.
//

#import "NSString+YOSURLQueryToDictionary.h"
#import "NSString+YOSURLEncodeAndDecode.h"

@implementation NSString (YOSURLQueryToDictionary)

- (NSDictionary *)yos_queryDictionary {
    NSMutableDictionary *dict = @{}.mutableCopy;
    
    NSArray *arr = [self componentsSeparatedByString:@"&"];
    
    for (NSString *temp in arr) {
        
        NSArray *components = [temp componentsSeparatedByString:@"="];
        
        if (components.count == 2) {
            NSString *key = [components[0] description];
            NSString *value = ((NSString *)components[1]).yos_urlDecode;
            
            if (!value.length || [value isEqualToString:@"null"] || [value isEqualToString:@"<null>"]) {
                value = @"";
            }
            
            if (key.length) {
                dict[key] = value;
            }
        }
        
    }
    
    return dict;
}

@end
