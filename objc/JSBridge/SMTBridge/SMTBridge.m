//
//  SMTBridge.m
//  JSBridge
//
//  Created by yangyang on 2019/8/5.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import "SMTBridge.h"
#import <pthread.h>
#import "SMTMessage.h"

const Boolean showLog = YES;

NSString * const SMT_BRIDGE_RESPONSE = @"__SMT_BRIDGE_RESPONSE__";
NSString * const SMT_BRIDGE_LOADED = @"smt://__loaded__";
NSString * const SMT_BRIDGE_MESSAGE = @"smt://__message__";

@interface SMTBridge () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, weak) id webViewDelegate;

@property (nonatomic, strong) NSMutableDictionary<NSString *, SMTHandler> *handlers;

@property (nonatomic, strong) NSMutableArray<SMTMessage *> *messages;

@property (nonatomic, strong) NSMutableDictionary<NSString *, SMTCallback> *callbacks;

@property (nonatomic, assign) NSInteger uniqueId;

@end

@implementation SMTBridge

- (instancetype)initWithWebView:(UIWebView *)webView webViewDelegate:(id)webViewDelegate {
    self = [super init];
    
    if (self) {
        self.webView = webView;
        self.webView.delegate = self;
        self.webViewDelegate = webViewDelegate;
        
        self.messages = [NSMutableArray array];
        self.handlers = [NSMutableDictionary dictionary];
        self.callbacks = [NSMutableDictionary dictionary];
        self.uniqueId = 1;
    }
    
    return self;
}

- (void)dealloc {
    self.webView = nil;
    self.webViewDelegate = nil;
    self.messages = nil;
    self.handlers = nil;
    self.callbacks = nil;
    
    NSLog(@"\r\n--- bridge dealloc ---\r\n");
}

#pragma mark - Private APIs
// bridge内部用来调用js端的response callback
- (void)_callHandler:(NSString *)type data:(id)data responseId:(NSString *)responseId {
    SMTMessage *message = [SMTMessage new];
    message.type = type;
    message.data = data;
    message.responseId = responseId;
    
    [self.messages addObject:message];
    
    if (pthread_main_np()) {
        [self _sendMessages];
    } else {
        WSelf(weakSelf);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf _sendMessages];
        });
    }
}

#pragma mark - APIs
- (void)callHandler:(NSString *)type data:(id)data callback:(__nullable SMTCallback)callback {
    SMTMessage *message = [SMTMessage new];
    message.type = type;
    message.data = data;
    
    if (callback) {
        NSString *callbackId = [self _callbackId];
        message.callbackId = callbackId;
        self.callbacks[callbackId] = [callback copy];
    }
    
    [self.messages addObject:message];
    
    if (pthread_main_np()) {
        [self _sendMessages];
    } else {
        WSelf(weakSelf);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf _sendMessages];
        });
    }
}

- (void)registerHandler:(NSString *)type handler:(SMTHandler)handler {
    self.handlers[type] = [handler copy];
}

#pragma mark - Helpers
- (void)_log:(id)data {
    if (showLog) {
         NSLog(@"%@", data);
    }
}

- (NSString *)_callbackId {
    return [NSString stringWithFormat:@"oc_%zi_%f_%u", ++self.uniqueId, [NSDate date].timeIntervalSince1970, arc4random_uniform(100)];
}

- (NSString *)_objectToJSON:(id)data {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (id)_jsonToObject:(NSString *)json {
    return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)_sendMessages {
    NSMutableArray *messageDicts = [NSMutableArray array];
    [self.messages enumerateObjectsUsingBlock:^(SMTMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        [messageDicts addObject:[message toDict]];
    }];

    NSString *messagesStr = [self _objectToJSON:messageDicts];
    messagesStr = [messagesStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messagesStr = [messagesStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messagesStr = [messagesStr stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messagesStr = [messagesStr stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messagesStr = [messagesStr stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messagesStr = [messagesStr stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messagesStr = [messagesStr stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messagesStr = [messagesStr stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    [self _log:messagesStr];
    
    NSString *jscode = [NSString stringWithFormat:@"window.smtBridge._getMessages('%@')", messagesStr];
    [self.webView stringByEvaluatingJavaScriptFromString:jscode];
    
    [self.messages removeAllObjects];
}

- (void)_getMessages {
    NSString *jscode = [NSString stringWithFormat:@"window.smtBridge._sendMessages()"];
    NSString *messagesStr = [self.webView stringByEvaluatingJavaScriptFromString:jscode];
    NSArray *messageDicts = [self _jsonToObject:messagesStr];
    
    NSMutableArray *messages = [NSMutableArray array];
    [messageDicts enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        SMTMessage *message = [SMTMessage fromDict:dict];
        [messages addObject:message];
    }];
    
    [self _log:messages];
    
    WSelf(weakSelf);
    [messages enumerateObjectsUsingBlock:^(SMTMessage *message, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf _handlerGetMessage:message];
    }];
}

- (void)_handlerGetMessage:(SMTMessage *)message {
    if ([message.type isEqualToString:SMT_BRIDGE_RESPONSE]) {
        SMTCallback callback = self.callbacks[message.responseId];
        callback(message.data);
        [self.callbacks removeObjectForKey:message.responseId];
    } else {
        SMTHandler handler = self.handlers[message.type];
        
        // 设置js端callback的wrapper
        SMTCallback callback;
        if (message.callbackId) {
            WSelf(weakSelf);
            callback = ^(id data) {
                [weakSelf _callHandler:SMT_BRIDGE_RESPONSE data:data responseId:message.callbackId];
            };
        }
        
        if (handler) {
            handler(message.data, callback);
        } else {
            NSLog(@"<SMTBridge> native called handler [${%@}] does not register.", message.type);
        }
    }
}

- (void)_injectBridge {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"smtbridge" ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = request.URL;
    
    NSString *urlStr = url.absoluteString.lowercaseString;
    
    if ([urlStr isEqualToString:SMT_BRIDGE_LOADED]) {
        [self _injectBridge];
        return NO;
    }
    
    // 系统一定是在主线程回调webview hooks
    if ([urlStr isEqualToString:SMT_BRIDGE_MESSAGE]) {
        [self _getMessages];
        return NO;
    }
    
    __strong id webViewDelegateStrong = self.webViewDelegate;
    if (webViewDelegateStrong && [webViewDelegateStrong respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [webViewDelegateStrong webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    __strong id webViewDelegateStrong = self.webViewDelegate;
    if (webViewDelegateStrong && [webViewDelegateStrong respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        return [webViewDelegateStrong webViewDidFinishLoad:webView];
    }
}

@end
