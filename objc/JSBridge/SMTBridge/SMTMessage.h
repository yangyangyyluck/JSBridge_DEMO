//
//  STMMessage.h
//  JSBridge
//
//  Created by yangyang on 2019/8/7.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMTMessage : NSObject

@property (nonatomic, copy) NSString *type;

@property (nonatomic, strong) id data;

@property (nonatomic, copy) NSString *callbackId;

@property (nonatomic, copy) NSString *responseId;

- (NSDictionary *)toDict;
+ (SMTMessage *)fromDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
