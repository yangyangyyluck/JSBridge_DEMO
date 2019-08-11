//
//  constant.h
//  JSBridge
//
//  Created by yangyang on 2019/8/4.
//  Copyright © 2019 yangyang. All rights reserved.
//

#ifndef constant_h
#define constant_h

typedef void (^voidBlock)(void);
#define WSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self

#endif /* constant_h */
