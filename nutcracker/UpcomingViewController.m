//
//  UpcomingViewController.m
//  nutcracker
//
//  Created by Алексей Савельев on 24/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "UpcomingViewController.h"
#import "Cards.h"
#import "HomeViewController.h"

@interface UpcomingViewController ()

@end

@implementation UpcomingViewController {
    UILabel *header;
    UILabel *word;
    NSLayoutConstraint *wordClosedConstraint;
    NSLayoutConstraint *wordLearningFrontConstraint;
    NSLayoutConstraint *wordLearningAnswerConstraint;
    
    UIButton *showAnswerButton;
    UIStackView* answerQualityButtons;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut animations:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    header = [[UILabel alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
    header.textColor = [UIColor colorNamed:@"mainText"];
    [header setLineBreakMode:NSLineBreakByWordWrapping];
    header.textAlignment = NSTextAlignmentCenter;
    header.numberOfLines = 0;
    
    [self.view addSubview:header];
    
    [header.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20].active = YES;
    [header.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15].active = YES;
    [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15].active = YES;
    
    MWCard *upcoming = [[Cards sharedInstance] getUpcomingCard];
    
    if (upcoming == nil) {
        header.text = @"There're no new words to learn, please add smth.";
        return;
    } else {
        header.text = @"Next word is:";
    }
    
    word = [[UILabel alloc] init];
    word.translatesAutoresizingMaskIntoConstraints = NO;
    word.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
    word.textColor = [UIColor colorNamed:@"mainText"];
    word.text = [upcoming.front uppercaseString];
    
    [self.view addSubview:word];
    
    [word.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    wordClosedConstraint = [word.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:20];
    wordClosedConstraint.active = YES;
    wordLearningFrontConstraint = [word.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-40];
    wordLearningAnswerConstraint = [word.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20];
    
    showAnswerButton = [self getStyledButton:@"Show answer"];
    showAnswerButton.layer.opacity = 0.0;
    
    [self.view addSubview:showAnswerButton];
    
    [showAnswerButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
    [showAnswerButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20].active = YES;
    [showAnswerButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [showAnswerButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    
    [showAnswerButton addTarget:self action:@selector(onShowAnswerTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)getStyledButton:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorNamed:@"secondaryLabel"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor colorNamed:@"button"];
    [button sizeToFit];
    button.contentEdgeInsets = UIEdgeInsetsMake(15, 30, 15, 30);
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    return button;
}

- (void)setLearnState {
    header.layer.opacity = 0.0;
    
    wordClosedConstraint.active = NO;
    wordLearningFrontConstraint.active = YES;
    
    showAnswerButton.layer.opacity = 1.0;
    
    [self.view layoutIfNeeded];
}

- (void)openToLearn {
    [_animator addAnimations:^{
        [self setLearnState];
    }];
    
    [_animator startAnimation];
}

- (void)closeToLearn {
    [_animator addAnimations:^{
        self->header.layer.opacity = 1.0;
        
        self->wordLearningFrontConstraint.active = NO;
        self->wordLearningAnswerConstraint.active = NO;
        self->wordClosedConstraint.active = YES;
        
        self->showAnswerButton.layer.opacity = 0.0;
        if (self->answerQualityButtons != nil) {
            self->answerQualityButtons.layer.opacity = 0.0;
        }
        
        [self.view layoutIfNeeded];
    }];
    
    [_animator startAnimation];
}

- (void)onShowAnswerTap:(UIButton *)button {
    UIButton *perfect = [self getStyledButton:@"Perfect response"];
    [perfect addTarget:self action:@selector(onPerfect) forControlEvents:UIControlEventTouchUpInside];
    UIButton *correctWithHesi = [self getStyledButton:@"Correct after hesitation"];
    UIButton *correctWithDifficulty = [self getStyledButton:@"Currect with difficulty"];;
    UIButton *incorrectButAnswerEasyToRecall = [self getStyledButton:@"Incorrect, answer is easy"];
    UIButton *incorrectButAnswerKnown = [self getStyledButton:@"Incorrect, answer is known"];
    UIButton *blackout = [self getStyledButton:@"Complete blackout"];
    
    answerQualityButtons = [[UIStackView alloc] initWithArrangedSubviews:@[
        perfect,
        correctWithHesi,
        correctWithDifficulty,
        incorrectButAnswerEasyToRecall,
        incorrectButAnswerKnown,
        blackout
    ]];
    answerQualityButtons.translatesAutoresizingMaskIntoConstraints = NO;
    [answerQualityButtons setAxis:UILayoutConstraintAxisVertical];
    [answerQualityButtons setSpacing:10];
    answerQualityButtons.layer.opacity = 0.0;
    
    [self.view addSubview:answerQualityButtons];
    
    [answerQualityButtons.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    [answerQualityButtons.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
    [answerQualityButtons.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20].active = YES;
    [answerQualityButtons.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    [self.view layoutIfNeeded];
    
    [_animator addAnimations:^{
        self->wordLearningFrontConstraint.active = NO;
        self->wordLearningAnswerConstraint.active = YES;
        
        self->showAnswerButton.layer.opacity = 0.0;
        self->answerQualityButtons.layer.opacity = 1.0;
        
        [self.view layoutIfNeeded];
    }];
    
    [_animator startAnimation];
}

- (void)onPerfect {
    HomeViewController *parent = (HomeViewController *)self.parentViewController;
    [parent showNextCard];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
