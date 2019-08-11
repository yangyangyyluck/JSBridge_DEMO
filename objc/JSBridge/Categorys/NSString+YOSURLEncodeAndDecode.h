//
//  NSString+YOSURLEncodeAndDecode.h
//  god
//
//  Created by yangyang on 2016/11/9.
//  Copyright © 2016年 shoppingm.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YOSURLEncodeAndDecode)
    
- (NSString *)yos_urlEncode;
- (NSString *)yos_urlDecode;

@end
