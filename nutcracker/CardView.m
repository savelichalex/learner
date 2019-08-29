//
//  CardView.m
//  nutcracker
//
//  Created by Алексей Савельев on 24/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "CardView.h"
#import "HomeViewController.h"

@implementation CardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self render];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        [self.layer setShadowOpacity:0.1];
    } else {
        [self.layer setShadowOpacity:0.0];
    }
}

- (void)render {
    self.backgroundColor = [UIColor colorNamed:@"card"];
    [self.layer setCornerRadius:20];
    [self.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(0.0, -2.0)];
    [self.layer setShadowRadius:4.0];
    
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        [self.layer setShadowOpacity:0.1];
    } else {
        [self.layer setShadowOpacity:0.0];
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // card pull bar
    UIView *cardLikePullBarInner = [[UIView alloc] init];
    cardLikePullBarInner.translatesAutoresizingMaskIntoConstraints = NO;
    cardLikePullBarInner.backgroundColor = [UIColor colorNamed:@"puller"];
    [cardLikePullBarInner.layer setCornerRadius:3];
    
    _pullBar = [[UIView alloc] init];
    _pullBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_pullBar];
    [_pullBar addSubview:cardLikePullBarInner];
    
    [cardLikePullBarInner.widthAnchor constraintEqualToConstant:40].active = YES;
    [cardLikePullBarInner.heightAnchor constraintEqualToConstant:6].active = YES;
    [cardLikePullBarInner.centerXAnchor constraintEqualToAnchor:_pullBar.centerXAnchor].active = YES;
    [cardLikePullBarInner.topAnchor constraintEqualToAnchor:_pullBar.topAnchor constant:13].active = YES;
    [cardLikePullBarInner.bottomAnchor constraintEqualToAnchor:_pullBar.bottomAnchor constant:-7].active = YES;
    
    [_pullBar.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_pullBar.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [_pullBar.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    
    _content = [[UILayoutGuide alloc] init];
    
    [self addLayoutGuide:_content];
    
    [_content.topAnchor constraintEqualToAnchor:_pullBar.bottomAnchor constant:10].active = YES;
    [_content.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [_content.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [_content.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-15].active = YES;
}

@end
