//
//  SMTDemo1Controller.m
//  JSBridge
//
//  Created by yangyang on 2019/8/4.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import "SMTDemo2Controller.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "SVProgressHUD.h"

@interface SMTDemo2Controller () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) JSContext *context;

@end

@implementation SMTDemo2Controller

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)setup {
    self.webView = [UIWebView new];
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view);
        make.left.and.top.mas_equalTo(0);
    }];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:3000"]]];
    
    WSelf(weakSelf);
    
    NSArray *titles = @[
                        @"Msg2Web",
                        @"getData",
                        ];
    NSArray *callbacks = @[
                           ^() {
                               [weakSelf sendMessage];
                           },
                            ^() {
                                [weakSelf getMessage];
                            }
                           ];
    [self smt_setRightButtons:titles callbacks:callbacks];
}

- (void)sendMessage {
    NSString *js = @"document.querySelector('#content1').innerHTML='hello, 这是从Native过来的问候';";
    [self.context evaluateScript:js];
}

- (void)getMessage {
    JSValue *value = [self.context evaluateScript:@"document.querySelector('#content2').innerHTML"];
    NSString *str = [value toObject];
    [SVProgressHUD showInfoWithStatus:str];
}

#pragma - webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    if ([[url scheme] isEqualToString:@"smt"]) {
        // 做逻辑 & return false
        // ...
        NSDictionary *query = [[url query] yos_queryDictionary];
        [SVProgressHUD showInfoWithStatus:query[@"msg"]];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
}

@end
