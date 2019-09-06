//
//  MeaningViewController.m
//  rememberify
//
//  Created by Admin on 03/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "MeaningViewController.h"
#import "ChoosableDef.h"
#import "Cards.h"
#import "HomeViewController.h"
#import "IconUtils.h"
#import "TermMeaningModel.h"

@interface MeaningViewController ()

@end

@implementation MeaningViewController {
    NSMutableArray *choosableDefs;
    NSString *_word;
    int _choosedCount;
    
    TermMeaningModel *term;
}

- (instancetype)initWithWord:(NSString *)word {
    self = [super init];
    if (self) {
        choosableDefs = [[NSMutableArray alloc] init];
        _word = word;
        _choosedCount = 0;
     
        term = [TermMeaningModel instanceForTerm:word];
        [term addObserver:self forKeyPath:@"fetchStatus" options:0 context:nil];
    }
     
    return self;
}

- (void)viewDidLoad {
    [self renderContent];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:@"fetchStatus"]) {
        return;
    }
    [self renderContent];
}

- (void)renderContent {
    if ([term isFetchStatusEqualTo:MeaningFetchStatusProgress]) {
        return [self renderProgress];
    }
    if ([term isFetchStatusEqualTo:MeaningFetchStatusError]) {
        return [self renderError];
    }
    return [self renderMeaning];
}

- (void)renderProgress {
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
//    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
//
//    [self.view addSubview:spinner];
//
//    [spinner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
//    [spinner.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)renderError {
    // TODO
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
    
- (void)renderMeaning {
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIScrollView *sv = [[UIScrollView alloc] init];
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:sv];
    
    UILayoutGuide *margins = self.view.layoutMarginsGuide;
    [sv.topAnchor constraintEqualToAnchor:margins.topAnchor].active = YES;
    [sv.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [sv.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [sv.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    UIView *svInner = [[UIView alloc] init];
    svInner.translatesAutoresizingMaskIntoConstraints = NO;
    
    [sv addSubview:svInner];
    [svInner.topAnchor constraintEqualToAnchor:sv.topAnchor].active = YES;
    [svInner.leftAnchor constraintEqualToAnchor:sv.leftAnchor].active = YES;
    [svInner.rightAnchor constraintEqualToAnchor:sv.rightAnchor].active = YES;
    [svInner.bottomAnchor constraintEqualToAnchor:sv.bottomAnchor].active = YES;
    [svInner.widthAnchor constraintEqualToAnchor:sv.widthAnchor].active = YES;
    
    UIStackView *wrapperStack = [[UIStackView alloc] init];
    [wrapperStack setAxis:UILayoutConstraintAxisVertical];
    [wrapperStack setAlignment:UIStackViewAlignmentLeading];
    [wrapperStack setSpacing:20];
    wrapperStack.translatesAutoresizingMaskIntoConstraints = NO;
    
    [svInner addSubview:wrapperStack];
    
    [wrapperStack.topAnchor constraintEqualToAnchor:svInner.topAnchor].active = YES;
    [wrapperStack.leftAnchor constraintEqualToAnchor:svInner.leftAnchor constant:15].active = YES;
    [wrapperStack.rightAnchor constraintEqualToAnchor:svInner.rightAnchor constant:-15].active = YES;
    [wrapperStack.bottomAnchor constraintEqualToAnchor:svInner.bottomAnchor constant:-20].active = YES;
    
    for (TermMeaningForm *form in term.forms) {
        if ([form.defs count] == 0) {
            continue;
        }
        
        UIView *wrapperSectionItem = [[UIView alloc] init];
        wrapperSectionItem.translatesAutoresizingMaskIntoConstraints = NO;
        
        [wrapperStack addArrangedSubview:wrapperSectionItem];
        
        UIStackView *sectionItem = [[UIStackView alloc] init];
        sectionItem.translatesAutoresizingMaskIntoConstraints = NO;
        [sectionItem setAxis:UILayoutConstraintAxisVertical];
        [sectionItem setSpacing:10];
        
        UIStackView *titleStack = [[UIStackView alloc] init];
        titleStack.translatesAutoresizingMaskIntoConstraints = NO;
        [titleStack setAxis:UILayoutConstraintAxisHorizontal];
        [titleStack setAlignment:UIStackViewAlignmentFirstBaseline];
        [titleStack setDistribution:UIStackViewDistributionFillEqually];
        
        [sectionItem addArrangedSubview:titleStack];
        
        [titleStack.leftAnchor constraintEqualToAnchor:sectionItem.leftAnchor].active = YES;
        [titleStack.rightAnchor constraintEqualToAnchor:sectionItem.rightAnchor].active = YES;
        
        UILabel *sectionName = [[UILabel alloc] init];
        sectionName.text = form.form;
        sectionName.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        
        [titleStack addArrangedSubview:sectionName];
        
        UILabel *sectionHeadword = [[UILabel alloc] init];
        sectionHeadword.text = form.pron;
        sectionHeadword.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
        sectionHeadword.textColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0];
        sectionHeadword.textAlignment = NSTextAlignmentRight;
        
        [titleStack addArrangedSubview:sectionHeadword];
        
        UIView *separator = [[UIView alloc] init];
        separator.translatesAutoresizingMaskIntoConstraints = NO;
        [separator setBackgroundColor:[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0]];
        
        [sectionItem addArrangedSubview:separator];
        
        [separator.leadingAnchor constraintEqualToAnchor:sectionItem.leadingAnchor].active = YES;
        [separator.trailingAnchor constraintEqualToAnchor:sectionItem.trailingAnchor].active = YES;
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:separator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1];
        
        [separator addConstraint:heightConstraint];
        
        UIStackView *defsStackView = [[UIStackView alloc] init];
        defsStackView.translatesAutoresizingMaskIntoConstraints = NO;
        [defsStackView setAxis:UILayoutConstraintAxisVertical];
        [defsStackView setSpacing:20];
        
        for (TermMeaningDef *defDict in form.defs) {
            ChoosableDef *def = [[ChoosableDef alloc] initWithEntryItem:defDict formType:form.form headword:form.pron onTap:^(BOOL isActive) {
                [self onChooseTap:isActive];
            }];
            [self->choosableDefs addObject:def];
            [defsStackView addArrangedSubview:def];
        }
        
        [sectionItem addArrangedSubview:defsStackView];
        
        [wrapperSectionItem addSubview:sectionItem];
        
        [wrapperSectionItem.leftAnchor constraintEqualToAnchor:wrapperStack.leftAnchor].active = YES;
        [wrapperSectionItem.rightAnchor constraintEqualToAnchor:wrapperStack.rightAnchor].active = YES;
        [wrapperSectionItem.heightAnchor constraintEqualToAnchor:sectionItem.heightAnchor constant:40].active = YES;
        
        [sectionItem.topAnchor constraintEqualToAnchor:wrapperSectionItem.topAnchor].active = YES;
        [sectionItem.leftAnchor constraintEqualToAnchor:wrapperSectionItem.leftAnchor constant:20].active = YES;
        [sectionItem.rightAnchor constraintEqualToAnchor:wrapperSectionItem.rightAnchor constant:-20].active = YES;
        [sectionItem.bottomAnchor constraintEqualToAnchor:wrapperSectionItem.bottomAnchor constant:-20].active = YES;
    }
}

- (void)onChooseTap:(BOOL)isActive {
    if (isActive) {
        [self onChoose];
    } else {
        [self onUnchoose];
    }
}

- (void)onChoose {
    if (_choosedCount == 0) {
        HomeViewController* parent = (HomeViewController *)self.parentViewController;
        
        UIImage *closeImage = [IconUtils imageForPlusIcon];
        
        UIButton *close = [[UIButton alloc] init];
        close.translatesAutoresizingMaskIntoConstraints = NO;
        [close setImage:[closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [close.imageView setTintColor:[UIColor whiteColor]];
        [close addTarget:self action:@selector(onAdd) forControlEvents:UIControlEventTouchUpInside];
        close.layer.opacity = 0.0;
        [close setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
        
        parent.rightHeaderView = close;
        
        [UIView animateWithDuration:0.2 animations:^{
            close.layer.opacity = 1.0;
            [close setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                [close setTransform:CGAffineTransformIdentity];
            }];
        }];
    }
    _choosedCount += 1;
}

- (void)onUnchoose {
    _choosedCount -= 1;
    if (_choosedCount == 0) {
        HomeViewController* parent = (HomeViewController *)self.parentViewController;
        parent.rightHeaderView = nil;
    }
}

- (void)onAdd {
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    for (ChoosableDef* item in choosableDefs) {
        if (item.isActive) {
            [entries addObject:@{@"word": _word,
                                 @"form": item.type,
                                 @"headword": item.headword,
                                 @"meaning": item.item.meaning,
                                 @"examples": item.item.examples}];
        }
    }
    [[Cards sharedInstance] addMWCards:entries];
    
    HomeViewController* parent = (HomeViewController *)self.parentViewController;
    [parent closeCard];
}

- (void)renderMeaning:(NSString *)meaning {
    UILabel *label = [[UILabel alloc] init];
    
    label.text = meaning;
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    label.numberOfLines = 0;
    
    [self.view addSubview:label];
    [label sizeToFit];
}

- (void)dealloc {
    [term removeObserver:self forKeyPath:@"fetchStatus"];
}

@end
