//
//  UIViewController+Button.m
//  JSBridge
//
//  Created by yangyang on 2019/8/4.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import "UIViewController+Button.h"
#import <objc/runtime.h>

static const char * KeyButton;
static const char * KeyButtons;

@interface UIViewController ()

@property (nonatomic, copy) voidBlock block;

@property (nonatomic, copy) NSArray *blocks;

@end

@implementation UIViewController (Button)

-(void)smt_setRightButton:(NSString *)title callback:(nonnull voidBlock)block {
    UIButton *btn = [UIButton new];
    btn.frame = CGRectMake(20, 0, 100, 50);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchDown];
    
    self.block = block;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)smt_setRightButtons:(NSArray *)titles callbacks:(NSArray *)callbacks {
    self.blocks = callbacks;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < titles.count; i++) {
        NSString *title =titles[i];
        UIButton *btn = [UIButton new];
        btn.frame = CGRectMake(20, 0, 100, 50);
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(taps:) forControlEvents:UIControlEventTouchDown];
        btn.tag = i;
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        [arr addObject: item];
    }
    
    self.navigationItem.rightBarButtonItems = arr;
}

- (void)setBlock:(void (^)(NSInteger))block {
    if (block) {
        objc_setAssociatedObject(self, &KeyButton, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void (^)(NSInteger))block {
    return objc_getAssociatedObject(self, &KeyButton);
}

- (void)setBlocks:(NSArray *)blocks {
    if (blocks) {
        objc_setAssociatedObject(self, &KeyButtons, blocks, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (NSArray *)blocks {
    return objc_getAssociatedObject(self, &KeyButtons);
}

- (void)tap {
    if (self.block) {
        self.block();
    }
}

- (void)taps:(UIButton *)btn {
    if (self.blocks[btn.tag]) {
        voidBlock black = self.blocks[btn.tag];
        black();
    }
}

@end
