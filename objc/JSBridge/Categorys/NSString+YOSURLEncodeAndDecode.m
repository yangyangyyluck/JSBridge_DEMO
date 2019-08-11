//
//  NSString+YOSURLEncodeAndDecode.m
//  god
//
//  Created by yangyang on 2016/11/9.
//  Copyright © 2016年 shoppingm.cn. All rights reserved.
//

#import "NSString+YOSURLEncodeAndDecode.h"
#import <CoreFoundation/CFURL.h>

@implementation NSString (YOSURLEncodeAndDecode)
    
- (NSString *)yos_urlEncode {
    NSString *unencodedString = self;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;

}
    
- (NSString *)yos_urlDecode {
    NSString *encodedString = self;
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

@end
