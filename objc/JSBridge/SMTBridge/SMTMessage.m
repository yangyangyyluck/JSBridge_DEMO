//
//  STMMessage.m
//  JSBridge
//
//  Created by yangyang on 2019/8/7.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import "SMTMessage.h"

@implementation SMTMessage

- (NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = self.type;
    
    if (self.data) {
        dict[@"data"] = self.data;
    }
    
    if (self.callbackId) {
        dict[@"callbackId"] = self.callbackId;
    }
    
    if (self.responseId) {
        dict[@"responseId"] = self.responseId;
    }
    
    return [dict copy];
}

+ (SMTMessage *)fromDict:(NSDictionary *)dict {
    SMTMessage *message = [SMTMessage new];
    message.type = dict[@"type"];
    message.data = dict[@"data"];
    message.callbackId = dict[@"callbackId"];
    message.responseId = dict[@"responseId"];
    
    return message;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\rtype : %@\rdata : %@\rcallbackId : %@\rresponseId : %@\r", self.type, self.data, self.callbackId, self.responseId];
}

@end
