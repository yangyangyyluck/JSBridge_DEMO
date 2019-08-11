//
//  SMTBridge.h
//  JSBridge
//
//  Created by yangyang on 2019/8/5.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SMTCallback)(id __nullable data);
typedef void (^SMTHandler)(id __nullable data, SMTCallback __nullable callback);

@interface SMTBridge : NSObject

- (instancetype)initWithWebView:(UIWebView *)webView webViewDelegate:(id)webViewDelegate;

- (void)callHandler:(NSString *)type data:(id)data callback:(__nullable SMTCallback)block;

- (void)registerHandler:(NSString *)type handler:(SMTHandler)block;

@end

NS_ASSUME_NONNULL_END
