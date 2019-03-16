//
//  ChoosableLabel.m
//  rememberify
//
//  Created by Admin on 05/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "ChoosableLabel.h"

@implementation ChoosableLabel {
    UITapGestureRecognizer *recognizer;
    Boolean isActive;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        isActive = NO;
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:recognizer];
        self.userInteractionEnabled = YES;
    }
    return self;
}
         
- (void)onTap:(UITapGestureRecognizer *)recognizer {
    if (isActive) {
        self.backgroundColor = [UIColor clearColor];
    } else {
        self.backgroundColor = [UIColor yellowColor];
    }
    isActive = !isActive;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
