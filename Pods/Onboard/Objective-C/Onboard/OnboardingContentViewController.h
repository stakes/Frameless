//
//  OnboardingContentViewController.h
//  Onboard
//
//  Created by Mike on 8/17/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OnboardingViewController;

@interface OnboardingContentViewController : UIViewController {
    id _titleText;
    id _body;
    UIImage *_image;
    NSString *_buttonText;
    dispatch_block_t _actionHandler;
    
    UIImageView *_imageView;
    UILabel *_mainTextLabel;
    UILabel *_subTextLabel;
    UIButton *_actionButton;
}

@property (nonatomic, weak) OnboardingViewController *delegate;

@property (nonatomic) CGFloat iconHeight;
@property (nonatomic) CGFloat iconWidth;

@property (nonatomic, strong) UIColor *titleTextColor;
@property (nonatomic, strong) UIColor *bodyTextColor;
@property (nonatomic, strong) UIColor *buttonTextColor;

@property (nonatomic, strong) NSString *titleFontName;
@property (nonatomic) CGFloat titleFontSize;

@property (nonatomic, strong) NSString *bodyFontName;
@property (nonatomic) CGFloat bodyFontSize;

@property (nonatomic, strong) NSString *buttonFontName;
@property (nonatomic) CGFloat buttonFontSize;

@property (nonatomic) CGFloat topPadding;
@property (nonatomic) CGFloat underIconPadding;
@property (nonatomic) CGFloat underTitlePadding;
@property (nonatomic) CGFloat bottomPadding;

- (id)initWithTitle:(id)title body:(id)body image:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action;

- (void)updateAlphas:(CGFloat)newAlpha;

@end
