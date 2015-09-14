//
//  AppearanceBridge.m
//  Frameless
//
//  Created by Jay Stakelon on 10/25/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

// Adapted from http://stackoverflow.com/a/26224862/534343

#import "AppearanceBridge.h"

@implementation AppearanceBridge

+ (void)setSearchBarTextInputAppearance {
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont systemFontOfSize:14]];
//    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
}


@end

