//
//  UIViewController+Button.h
//  JSBridge
//
//  Created by yangyang on 2019/8/4.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Button)

- (void)smt_setRightButton:(NSString *)title callback:(voidBlock)block;

- (void)smt_setRightButtons:(NSArray *)titles callbacks:(NSArray *)callbacks;

@end

NS_ASSUME_NONNULL_END
