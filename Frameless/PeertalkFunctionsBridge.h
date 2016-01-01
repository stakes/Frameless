//
//  PeertalkFunctionsBridge.h
//  Frameless
//
//  Created by Jay Stakelon on 12/31/15.
//  Copyright © 2015 Jay Stakelon. All rights reserved.
//

#import "PTChannel.h"

typedef struct _PTExampleTextFrame {
    uint32_t length;
    uint8_t utf8text[0];
} PTExampleTextFrame;

@interface PeertalkFunctionsBridge : NSObject

+ (NSString*)parseTextFrame:(PTData*)payload;

@end

