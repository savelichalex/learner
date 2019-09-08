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
#import "TermMeaningModel.h"

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
    
    TermMeaningModel *upcoming = [[Cards sharedInstance] getUpcomingCard];
    
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
    word.text = [upcoming.term uppercaseString];
    
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
    __weak UpcomingViewController *weakThis = self;
    [_animator addAnimations:^{
        UpcomingViewController *this = weakThis;
        if (this == nil) return;
        
        [this setLearnState];
    }];
    
    [_animator startAnimation];
}

- (void)closeToLearn {
    __weak UpcomingViewController *weakThis = self;
    [_animator addAnimations:^{
        UpcomingViewController *this = weakThis;
        if (this == nil) return;
        
        this->header.layer.opacity = 1.0;
        
        this->wordLearningFrontConstraint.active = NO;
        this->wordLearningAnswerConstraint.active = NO;
        this->wordClosedConstraint.active = YES;
        
        this->showAnswerButton.layer.opacity = 0.0;
        if (this->answerQualityButtons != nil) {
            this->answerQualityButtons.layer.opacity = 0.0;
        }
        
        [this.view layoutIfNeeded];
    }];
    
    [_animator startAnimation];
}

- (void)onShowAnswerTap:(UIButton *)button {
    TermMeaningModel *upcoming = [[Cards sharedInstance] getUpcomingCard];
    
    UIScrollView *answerStackWrapper = [[UIScrollView alloc] init];
    answerStackWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:answerStackWrapper];
    
    [answerStackWrapper.topAnchor constraintEqualToAnchor:word.bottomAnchor constant:20].active = YES;
    [answerStackWrapper.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30].active = YES;
    [answerStackWrapper.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-30].active = YES;
    
    UIView *answerStackInner = [[UIView alloc] init];
    answerStackInner.translatesAutoresizingMaskIntoConstraints = NO;
    
    [answerStackWrapper addSubview:answerStackInner];
    
    [answerStackInner.topAnchor constraintEqualToAnchor:answerStackWrapper.topAnchor].active = YES;
    [answerStackInner.leadingAnchor constraintEqualToAnchor:answerStackWrapper.leadingAnchor].active = YES;
    [answerStackInner.trailingAnchor constraintEqualToAnchor:answerStackWrapper.trailingAnchor].active = YES;
    [answerStackInner.bottomAnchor constraintEqualToAnchor:answerStackWrapper.bottomAnchor].active = YES;
    [answerStackInner.widthAnchor constraintEqualToAnchor:answerStackWrapper.widthAnchor].active = YES;
    
    UIStackView *answerStack = [[UIStackView alloc] init];
    answerStack.translatesAutoresizingMaskIntoConstraints = NO;
    [answerStack setAxis:UILayoutConstraintAxisVertical];
    [answerStack setSpacing:5];
    
    [answerStackInner addSubview:answerStack];
    
    [answerStack.topAnchor constraintEqualToAnchor:answerStackInner.topAnchor].active = YES;
    [answerStack.leadingAnchor constraintEqualToAnchor:answerStackInner.leadingAnchor].active = YES;
    [answerStack.trailingAnchor constraintEqualToAnchor:answerStackInner.trailingAnchor].active = YES;
    [answerStack.bottomAnchor constraintEqualToAnchor:answerStackInner.bottomAnchor].active = YES;
    
    for (TermMeaningForm *form in upcoming.forms) {
        for (TermMeaningDef *def in form.defs) {
            if (def.isChoosedForLearning == YES) {
                UILabel* defLabel = [[UILabel alloc] init];
                defLabel.text = def.meaning;
                [defLabel setLineBreakMode:NSLineBreakByWordWrapping];
                defLabel.numberOfLines = 0;
                
                [answerStack addArrangedSubview:defLabel];
                [defLabel sizeToFit];
                
                for (NSString *example in def.examples) {
                    UILabel *exampleLabel = [[UILabel alloc] init];
                    NSMutableString *exampleStr = [[NSMutableString alloc] initWithString:@"// "];
                    [exampleStr appendString:example];
                    exampleLabel.text = exampleStr; // TODO: preprocess it
                    [exampleLabel setLineBreakMode:NSLineBreakByWordWrapping];
                    exampleLabel.numberOfLines = 0;
                    exampleLabel.textColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0];
                    
                    [answerStack addArrangedSubview:exampleLabel];
                    
                    [exampleLabel sizeToFit];
                }
            }
        }
    }
    
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
    
    
    [answerStackWrapper.bottomAnchor constraintEqualToAnchor:answerQualityButtons.topAnchor constant:-20].active = YES;
    [answerQualityButtons.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    [answerQualityButtons.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
    [answerQualityButtons.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20].active = YES;
    [answerQualityButtons.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    [self.view layoutIfNeeded];
    
    __weak UpcomingViewController *weakThis = self;
    [_animator addAnimations:^{
        UpcomingViewController *this = weakThis;
        if (this == nil) return;
        
        this->wordLearningFrontConstraint.active = NO;
        this->wordLearningAnswerConstraint.active = YES;
        
        this->showAnswerButton.layer.opacity = 0.0;
        this->answerQualityButtons.layer.opacity = 1.0;
        
        [this.view layoutIfNeeded];
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
