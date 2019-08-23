//
//  ChoosableDef.m
//  rememberify
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "ChoosableDef.h"

@implementation ChoosableDef {
    UITapGestureRecognizer *singleTapRecognizer;
    UIView *backView;
    void(^_onTap)(BOOL);
}

- (instancetype)initWithEntryItem:(EntryItem *)item formType:(NSString *)type headword:(nonnull NSString *)headword onTap:(void(^)(BOOL isActive))onTap {
    self = [super init];
    if (self) {
        _item = item;
        _type = type;
        _headword = headword;
        _isActive = NO;
        _onTap = onTap;
        singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:singleTapRecognizer];
        self.userInteractionEnabled = YES;
        
        [self setAxis:UILayoutConstraintAxisVertical];
        [self setSpacing:5];
        
        backView = [[UIView alloc] init];
        backView.translatesAutoresizingMaskIntoConstraints = NO;
        backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:backView];
        
        UILabel* defLabel = [[UILabel alloc] init];
        defLabel.text = item.def; // TODO: preprocess it
        [defLabel setLineBreakMode:NSLineBreakByWordWrapping];
        defLabel.numberOfLines = 0;
        
        [self addArrangedSubview:defLabel];
        [defLabel sizeToFit];
        
        for (NSString *example in item.examples) {
            UILabel *exampleLabel = [[UILabel alloc] init];
            NSMutableString *exampleStr = [[NSMutableString alloc] initWithString:@"// "];
            [exampleStr appendString:example];
            exampleLabel.text = exampleStr; // TODO: preprocess it
            [exampleLabel setLineBreakMode:NSLineBreakByWordWrapping];
            exampleLabel.numberOfLines = 0;
            exampleLabel.textColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0];
            
            [self addArrangedSubview:exampleLabel];
            [exampleLabel sizeToFit];
        }
    }
    return self;
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    if (_isActive) {
        backView.backgroundColor = [UIColor clearColor];
    } else {
        backView.backgroundColor = [UIColor colorNamed:@"highlighter"];
    }
    _isActive = !_isActive;
    _onTap(_isActive);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
