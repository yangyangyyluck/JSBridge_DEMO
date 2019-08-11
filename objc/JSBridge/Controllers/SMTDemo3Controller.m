//
//  SMTDemo1Controller.m
//  JSBridge
//
//  Created by yangyang on 2019/8/4.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import "SMTDemo3Controller.h"
#import <WebKit/WebKit.h>
#import "SVProgressHUD.h"

@interface SMTDemo3Controller () <WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) WKUserContentController *userContentController;

@end

@implementation SMTDemo3Controller

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)setup {
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    WKUserContentController *userContentController = [WKUserContentController new];
    config.userContentController = userContentController;
    
    self.userContentController = userContentController;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webView.navigationDelegate = self;
    
    [self setupJavaScriptHandlers];
    
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view);
        make.left.and.top.mas_equalTo(0);
    }];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://t.smartisan.com:3000/wk"]]];
    
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

- (void)dealloc {
    [self.userContentController removeScriptMessageHandlerForName:@"messageFromWeb"];
}

- (void)setupJavaScriptHandlers {
    WSelf(weakSelf);
    [self.userContentController addScriptMessageHandler:weakSelf name:@"messageFromWeb"];
}

- (void)sendMessage {
    NSString *js = @"document.querySelector('#content1').innerHTML='hello, 这是从Native过来的问候';";
    [self.webView evaluateJavaScript:js completionHandler:nil];
}

- (void)getMessage {
    NSString *js = @"document.querySelector('#content2').innerHTML";
    [self.webView evaluateJavaScript:js completionHandler:^(NSString *data, NSError * _Nullable error) {
        [SVProgressHUD showInfoWithStatus:data];
    }];
}

#pragma - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [SVProgressHUD showInfoWithStatus:message.body[@"msg"]];
}

#pragma - webview delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([[url scheme] isEqualToString:@"smt"]) {
        NSDictionary *query = [[url query] yos_queryDictionary];
        [SVProgressHUD showInfoWithStatus:query[@"msg"]];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end
