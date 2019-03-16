//
//  UpcomingPickingViewController.m
//  rememberify
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "UpcomingPickingViewController.h"
#import "Cards.h"

@interface UpcomingPickingViewController ()

@end

@implementation UpcomingPickingViewController {
    NSInteger index;
    MWCard *intermediateCard; // TODO: polimorphic type
    
    UIView *cardsWrapper;
    
    MWCardView *firstCard;
    MWCardView *secondCard;
    MWCardView *thirdCard;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        index = 0;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(1.0, 1.0);
    gradient.colors = @[
                        (id)[UIColor colorWithRed:0.61 green:0.88 blue:0.36 alpha:1.0].CGColor,
                        (id)[UIColor colorWithRed:0.00 green:0.89 blue:0.68 alpha:1.0].CGColor
                        ];
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    UIView *buttons = [[UIView alloc] init];
    buttons.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:buttons];
    
    [buttons.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30].active = YES;
    [buttons.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:15].active = YES;
    [buttons.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-15].active = YES;
    // [buttonsStack.widthAnchor constraintEqualToConstant:20].active = YES;
    [buttons.heightAnchor constraintEqualToConstant:20].active = YES;
    
    UIImage *closeImage = [UpcomingPickingViewController imageFromSystemBarButon:UIBarButtonSystemItemStop];
    
    UIButton *close = [[UIButton alloc] init];
    
    close.translatesAutoresizingMaskIntoConstraints = NO;
    [close setImage:[closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [close.imageView setTintColor:[UIColor whiteColor]];
    [close addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttons addSubview:close];
    
    [close.topAnchor constraintEqualToAnchor:buttons.topAnchor].active = YES;
    [close.leftAnchor constraintEqualToAnchor:buttons.leftAnchor].active = YES;
    [close.widthAnchor constraintEqualToConstant:20].active = YES;
    [close.heightAnchor constraintEqualToConstant:20].active = YES;
    
    // [buttons.heightAnchor constraintEqualToAnchor:close.heightAnchor].active = YES;
    
    cardsWrapper = [[UIView alloc] init];
    cardsWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:cardsWrapper];
    
    [cardsWrapper.topAnchor constraintEqualToAnchor:buttons.bottomAnchor].active = YES;
    [cardsWrapper.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:15].active = YES;
    [cardsWrapper.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-15].active = YES;
    [cardsWrapper.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20].active = YES;
    
    NSArray *upcoming = [[Cards sharedInstance] upcoming];
    if (upcoming.count >= index + 1) {
        firstCard = [[MWCardView alloc] initWithCardData:upcoming[index]];
        firstCard.delegate = self;
    
        [firstCard renderFrontInParent:cardsWrapper];
    }
    
    if (upcoming.count >= index + 2) {
        secondCard = [[MWCardView alloc] initWithCardData:upcoming[index + 1]];
        secondCard.delegate = self;
    
        [secondCard renderFrontInParent:cardsWrapper belowView:firstCard];
        
        index = index + 1;
    }
}

+ (UIImage *)imageFromSystemBarButon:(UIBarButtonSystemItem)systemItem {
    UIBarButtonItem *tempItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:nil action:nil];
    UIToolbar *bar = [[UIToolbar alloc] init];
    [bar setItems:@[tempItem] animated:NO];
    [bar snapshotViewAfterScreenUpdates:YES];
    
    UIView *itemView = [(id)tempItem view];
    for (UIView *view in itemView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            return [(UIButton *)view imageForState:UIControlStateNormal];
        }
    }
    
    return nil;
}

- (void)onAnswerQualityFeedback:(CardQualityFeedback)quality {
    NSArray *upcoming = [[Cards sharedInstance] upcoming];
    
    if (upcoming.count >= index + 2) {
        thirdCard = [[MWCardView alloc] initWithCardData:upcoming[index + 1]];
        thirdCard.delegate = self;
        [thirdCard renderFrontInParent:cardsWrapper belowView:secondCard];
    }
    if (upcoming.count >= index + 1) {
        [secondCard moveToFront:^(BOOL finished) {
            self->firstCard = self->secondCard;
            if (upcoming.count >= self->index + 2) {
                self->secondCard = self->thirdCard;
            }
            self->index = self->index + 1;
        }];
    }
}

- (void)onClose:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

@end
