//
//  MWCardView.m
//  rememberify
//
//  Created by Admin on 10/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "MWCardView.h"

@implementation MWCardView {
    MWCard *_cardData;
    MWCardDefItem *_cardDefData;
    UIStackView *wordStack;
    NSLayoutConstraint *wordsCenterX;
    NSLayoutConstraint *wordsCenterY;
    UILabel *def;
    UIButton *showAnswerButton;
}

- (instancetype)initWithCardData:(MWCard *)cardData andDefData:(MWCardDefItem *)cardDefData {
    self = [super init];
    if (self) {
        _cardData = cardData;
        _cardDefData = cardDefData;
    }
    return self;
}

- (void)applyStyles {
    self.backgroundColor = [UIColor whiteColor];
    [self.layer setCornerRadius:20];
    [self.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(0.0, -2.0)];
    [self.layer setShadowRadius:4.0];
    [self.layer setShadowOpacity:0.1];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)fitInParent:(UIView *)parent {
    [self.leftAnchor constraintEqualToAnchor:parent.leftAnchor].active = YES;
    [self.topAnchor constraintEqualToAnchor:parent.topAnchor constant:10].active = YES;
    [self.rightAnchor constraintEqualToAnchor:parent.rightAnchor].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:parent.bottomAnchor].active = YES;
}

- (UIButton *)getStyledButton:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
    [button sizeToFit];
    button.contentEdgeInsets = UIEdgeInsetsMake(15, 30, 15, 30);
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    return button;
}

- (void)renderData {
    wordStack = [[UIStackView alloc] init];
    [wordStack setAxis:UILayoutConstraintAxisVertical];
    [wordStack setAlignment:UIStackViewAlignmentCenter];
    [wordStack setSpacing:12];
    wordStack.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:wordStack];
    
    wordsCenterX = [wordStack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor];
    wordsCenterX.active = YES;
    wordsCenterY = [wordStack.centerYAnchor constraintEqualToAnchor:self.centerYAnchor];
    wordsCenterY.active = YES;
    [wordStack.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:30].active = YES;
    [wordStack.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-30].active = YES;
    
    UILabel *front = [[UILabel alloc] init];
    front.text = [_cardData.front uppercaseString];
    front.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
    front.textColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
    
    [wordStack addArrangedSubview:front];
    
    UILabel *form = [[UILabel alloc] init];
    form.text = _cardDefData.form;
    form.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
    form.textColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0];
    
    [wordStack addArrangedSubview:form];
    
    NSError *bcError = nil;
    NSRegularExpression *bcRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{(bc)\\}" options:NSRegularExpressionCaseInsensitive error:&bcError];
    NSString *meaning = [bcRegex stringByReplacingMatchesInString:_cardDefData.meaning options:0 range:NSMakeRange(0, _cardDefData.meaning.length) withTemplate:@""];
    NSError *sxError = nil;
    NSRegularExpression *sxRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{sx\\|([^\\|]+)\\|([^\\}]*)\\}" options:NSRegularExpressionCaseInsensitive error:&sxError];
    meaning = [sxRegex stringByReplacingMatchesInString:meaning options:0 range:NSMakeRange(0, meaning.length) withTemplate:@"($1)"];
    
    def = [[UILabel alloc] init];
    def.text = meaning;
    def.font = [UIFont systemFontOfSize:20 weight:UIFontWeightRegular];
    def.textColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
    [def setContentMode:UIViewContentModeTop];
    [def setLineBreakMode:NSLineBreakByWordWrapping];
    def.numberOfLines = 0;
    
    [wordStack addArrangedSubview:def];
    def.hidden = YES;
    //[def sizeToFit];
    
    if (_cardDefData.examples.count > 0) {
        for (NSString *example in _cardDefData.examples) {
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{wi\\}([^\\{]+)\\{\\/wi\\}" options:NSRegularExpressionCaseInsensitive error:&error];
            NSArray *matches = [regex matchesInString:example options:0 range:NSMakeRange(0, example.length)];
            NSString *resultString = [NSString string];
            
            for (NSTextCheckingResult *match in matches) {
                resultString = [example stringByReplacingCharactersInRange:match.range withString:[example substringWithRange:[match rangeAtIndex:1]]];
            }
            
            NSMutableAttributedString *attributedExample = [[NSMutableAttributedString alloc] initWithString:resultString];
            [attributedExample addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0] range:NSMakeRange(0, resultString.length)];
            [attributedExample addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20 weight:UIFontWeightRegular] range:NSMakeRange(0, resultString.length)];
            
            for (NSTextCheckingResult *match in matches) {
                NSRange matchRange = NSMakeRange(match.range.location, [match rangeAtIndex:1].length);
                [attributedExample addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0] range:matchRange];
                [attributedExample addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:20] range:matchRange];
            }
            
            UILabel *exampleLabel = [[UILabel alloc] init];
            [exampleLabel setLineBreakMode:NSLineBreakByWordWrapping];
            exampleLabel.numberOfLines = 0;
            exampleLabel.attributedText = attributedExample;
            
            [wordStack addArrangedSubview:exampleLabel];
        }
    }
    
    showAnswerButton = [self getStyledButton:@"Show answer"];
    
    [self addSubview:showAnswerButton];
    
    [showAnswerButton.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:40].active = YES;
    [showAnswerButton.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-40].active = YES;
    [showAnswerButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [showAnswerButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-40].active = YES;
    
    [showAnswerButton addTarget:self action:@selector(onShowAnswerTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)renderFrontInParent:(UIView *)parent {
    [self applyStyles];
    [parent addSubview:self];
    [self fitInParent:parent];
    [self renderData];
}

- (void)renderFrontInParent:(UIView *)parent belowView:(UIView *)prev {
    [self applyStyles];
    [parent insertSubview:self belowSubview:prev];
    [self fitInParent:parent];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self setTransform:CGAffineTransformConcat(
        CGAffineTransformMakeScale(0.85, 0.85),
        CGAffineTransformMakeTranslation(
            0,
            -(self.bounds.size.height * 0.075 + 10)
        )
    )];
    
    [self renderData];
}

- (void)moveAway:(void (^)(BOOL))completion {
    [UIView animateWithDuration:0.3 animations:^{
        [self setTransform:CGAffineTransformMakeTranslation(-1 * (self.bounds.size.width + 100), 0)];
    } completion:completion];
}

- (void)moveToFront:(void (^)(BOOL))completion {
    [UIView animateWithDuration:0.35 animations:^{
        [self setTransform:CGAffineTransformIdentity];
    } completion:completion];
}

// MARK: - Handle presses

- (void)onShowAnswerTap:(UIButton *)button {
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        // self->wordsCenterX.active = NO;
        self->wordsCenterY.active = NO;
        [self->wordStack.topAnchor constraintEqualToAnchor:self.topAnchor constant:60].active = YES;
        self->def.hidden = NO;
        [self layoutIfNeeded];
    }];
    
    [UIView animateWithDuration:0.15 animations:^{
        [self->showAnswerButton setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self->showAnswerButton removeFromSuperview];
        
        UIButton *perfectButton = [self getStyledButton:@"Easy"];
        [perfectButton addTarget:self action:@selector(onPerfect:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *correctWithDelayButton = [self getStyledButton:@"Correct with delay"];
        [correctWithDelayButton addTarget:self action:@selector(onCorrectWithDelay:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *correctWithDifficaltyButton = [self getStyledButton:@"Correct but hard"];
        [correctWithDifficaltyButton addTarget:self action:@selector(onCorrectButHard:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *incorrectButton = [self getStyledButton:@"Incorrect"];
        [incorrectButton addTarget:self action:@selector(onIncorrect:) forControlEvents:UIControlEventTouchUpInside];
        
        UIStackView *qualityStack = [[UIStackView alloc] init];
        [qualityStack setAxis:UILayoutConstraintAxisVertical];
        [qualityStack setSpacing:10];
        qualityStack.translatesAutoresizingMaskIntoConstraints = NO;
        
        [qualityStack addArrangedSubview:perfectButton];
        [qualityStack addArrangedSubview:correctWithDelayButton];
        [qualityStack addArrangedSubview:correctWithDifficaltyButton];
        [qualityStack addArrangedSubview:incorrectButton];
        
        [qualityStack setAlpha:0.0];
        
        [self addSubview:qualityStack];
        
        [qualityStack.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:30].active = YES;
        [qualityStack.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-30].active = YES;
        [qualityStack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-40].active = YES;
        
        [UIView animateWithDuration:0.15 animations:^{
            [qualityStack setAlpha:1.0];
        }];
    }];
}

- (void)onPerfect:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(onAnswerQualityFeedback:)]) {
        [self.delegate onAnswerQualityFeedback:CardQualityFeedbackPerfect];
        [self moveAway:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)onCorrectWithDelay:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(onAnswerQualityFeedback:)]) {
        [self.delegate onAnswerQualityFeedback:CardQualityFeedbackCorrectWithDelay];
        [self moveAway:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)onCorrectButHard:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(onAnswerQualityFeedback:)]) {
        [self.delegate onAnswerQualityFeedback:CardQualityFeedbackCorrectButHard];
        [self moveAway:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)onIncorrect:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(onAnswerQualityFeedback:)]) {
        [self.delegate onAnswerQualityFeedback:CardQualityFeedbackIncorrect];
        [self moveAway:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

@end
