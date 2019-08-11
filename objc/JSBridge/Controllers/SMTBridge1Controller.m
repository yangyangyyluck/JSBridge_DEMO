//
//  SMTDemo1Controller.m
//  JSBridge
//
//  Created by yangyang on 2019/8/4.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import "SMTBridge1Controller.h"
#import "SMTBridge.h"
#import "SVProgressHUD.h"

@interface SMTBridge1Controller () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) SMTBridge *bridge;

@end

@implementation SMTBridge1Controller

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)setupBridge {
    self.bridge = [[SMTBridge alloc] initWithWebView:self.webView webViewDelegate:self];
    
    [self.bridge registerHandler:@"showMessage" handler:^(NSString *data, SMTCallback  _Nonnull callback) {
        [SVProgressHUD showInfoWithStatus: data];
    }];
    
    [self.bridge registerHandler:@"getUserInfo" handler:^(id  __nullable data, SMTCallback  __nullable callback) {
        [SVProgressHUD showInfoWithStatus:[data description]];
        if (callback) {
            callback(@{
                       @"id": @12345,
                       @"username": @"大灰狼和小白兔",
                       });
        }
    }];
}

- (void)setup {
    self.webView = [UIWebView new];
    self.webView.delegate = self;
    
    [self setupBridge];
    
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view);
        make.left.and.top.mas_equalTo(0);
    }];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:3000/smtbridge1"]]];
    
    WSelf(weakSelf);
    
    NSArray *titles = @[
                        @"btn1",
                        @"btn2",
                        ];
    NSArray *callbacks = @[
                           ^() {
                               [weakSelf btn1];
                           },
                            ^() {
                                [weakSelf btn2];
                            }
                           ];
    [self smt_setRightButtons:titles callbacks:callbacks];
}

- (void)btn1 {
    [self.bridge callHandler:@"setText" data:@"狂风! 听我号令!" callback:nil];
}

- (void)btn2 {
    [self.bridge callHandler:@"setText2" data:@"不胜利! 毋宁死!" callback:^(id data){
        [SVProgressHUD showInfoWithStatus: [data description]];
    }];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"--- shouldStartLoadWithRequest : %@ ---", request.URL);
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"--- webViewDidFinishLoad ---");
}

@end
