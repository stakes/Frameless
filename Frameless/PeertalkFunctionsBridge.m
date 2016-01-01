//
//  PeertalkFunctionsBridge.m
//  Frameless
//
//  Created by Jay Stakelon on 12/31/15.
//  Copyright © 2015 Jay Stakelon. All rights reserved.
//

#import "PeertalkFunctionsBridge.h"

@implementation PeertalkFunctionsBridge

+ (NSString*)parseTextFrame:(PTData*)payload {
    PTExampleTextFrame *textFrame = (PTExampleTextFrame*)payload.data;
    textFrame->length = ntohl(textFrame->length);
    NSString *message = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];
    return message;
}

@end