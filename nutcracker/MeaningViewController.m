//
//  MeaningViewController.m
//  rememberify
//
//  Created by Admin on 03/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "MeaningViewController.h"
#import "DictionaryApiParser.h"
#import "ChoosableDef.h"
#import "Cards.h"
#import "UpcomingPickingViewController.h"

@interface MeaningViewController ()

@end

@implementation MeaningViewController {
    NSMutableArray *choosableDefs;
    NSString *_word;
}

- (instancetype)initWithWord:(NSString *)word {
    self = [super init];
    if (self) {
        choosableDefs = [[NSMutableArray alloc] init];
        _word = word;
        
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:word ofType:@"json"];
        NSData *json = [NSData dataWithContentsOfFile:jsonPath];
        
        [DictionaryApiParser processJSON:json withCallback:^(NSArray * _Nonnull forms) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationItem setTitle:[word uppercaseString]];
                self.view.backgroundColor = [UIColor whiteColor];
                
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
                
                [wrapperStack.topAnchor constraintEqualToAnchor:svInner.topAnchor constant:20].active = YES;
                [wrapperStack.leftAnchor constraintEqualToAnchor:svInner.leftAnchor constant:15].active = YES;
                [wrapperStack.rightAnchor constraintEqualToAnchor:svInner.rightAnchor constant:-15].active = YES;
                [wrapperStack.bottomAnchor constraintEqualToAnchor:svInner.bottomAnchor constant:-20].active = YES;
                
                for (EntryForm *form in forms) {
                    if ([form.defs count] == 0) {
                        continue;
                    }
                    
                    UIView *wrapperSectionItem = [[UIView alloc] init];
                    wrapperSectionItem.translatesAutoresizingMaskIntoConstraints = NO;
                    wrapperSectionItem.backgroundColor = [UIColor whiteColor];
                    wrapperSectionItem.layer.cornerRadius = 20;
                    [wrapperSectionItem.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
                    [wrapperSectionItem.layer setShadowOffset:CGSizeMake(0.0, 5.0)];
                    [wrapperSectionItem.layer setShadowRadius:5.0];
                    [wrapperSectionItem.layer setShadowOpacity:0.3];
                    
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
                    sectionName.text = form.name;
                    sectionName.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
                    
                    [titleStack addArrangedSubview:sectionName];
                    
                    UILabel *sectionHeadword = [[UILabel alloc] init];
                    sectionHeadword.text = form.headword;
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
                    for (id section in form.defs) {
                        if ([section isKindOfClass:[EntryItem class]]) {
                            ChoosableDef *def = [[ChoosableDef alloc] initWithEntryItem:section formType:form.name headword:form.headword];
                            [self->choosableDefs addObject:def];
                            [defsStackView addArrangedSubview:def];
                        }
                        if ([section isKindOfClass:[NSArray class]]) {
                            for (EntryItem *entry in section) {
                                ChoosableDef *def = [[ChoosableDef alloc] initWithEntryItem:entry formType:form.name headword:form.headword];
                                [self->choosableDefs addObject:def];
                                [defsStackView addArrangedSubview:def];
                            }
                        }
                    }
                    
                    [sectionItem addArrangedSubview:defsStackView];
                    
                    [wrapperSectionItem addSubview:sectionItem];
                    
                    [wrapperSectionItem.leftAnchor constraintEqualToAnchor:wrapperStack.leftAnchor].active = YES;
                    [wrapperSectionItem.rightAnchor constraintEqualToAnchor:wrapperStack.rightAnchor].active = YES;
                    [wrapperSectionItem.heightAnchor constraintEqualToAnchor:sectionItem.heightAnchor constant:40].active = YES;
                    
                    [sectionItem.topAnchor constraintEqualToAnchor:wrapperSectionItem.topAnchor constant:20].active = YES;
                    [sectionItem.leftAnchor constraintEqualToAnchor:wrapperSectionItem.leftAnchor constant:20].active = YES;
                    [sectionItem.rightAnchor constraintEqualToAnchor:wrapperSectionItem.rightAnchor constant:-20].active = YES;
                    [sectionItem.bottomAnchor constraintEqualToAnchor:wrapperSectionItem.bottomAnchor constant:-20].active = YES;
                }
            });
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAdd)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationController.navigationBar.translucent = YES;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(1.0, 1.0);
    gradient.colors = @[
                        (id)[UIColor colorWithRed:0.61 green:0.88 blue:0.36 alpha:1.0].CGColor,
                        (id)[UIColor colorWithRed:0.00 green:0.89 blue:0.68 alpha:1.0].CGColor
                        ];
    
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)onAdd {
    // TODO: create Card
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    for (ChoosableDef* item in choosableDefs) {
        if (item.isActive) {
            [entries addObject:@{@"word": _word,
                                 @"form": item.type,
                                 @"headword": item.headword,
                                 @"meaning": item.item.def,
                                 @"examples": item.item.examples}];
        }
    }
    if ([entries count] > 0) {
        [[Cards sharedInstance] addMWCards:entries];
     
        UpcomingPickingViewController *vc = [[UpcomingPickingViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)renderMeaning:(NSString *)meaning {
    UILabel *label = [[UILabel alloc] init];
    
    label.text = meaning;
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    label.numberOfLines = 0;
    
    [self.view addSubview:label];
    [label sizeToFit];
}

@end
