//
//  HomeViewController.m
//  nutcracker
//
//  Created by Алексей Савельев on 21/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "HomeViewController.h"
#import "MWCardView.h"
#import "Cards.h"
#import "MeaningViewController.h"
#import "UpcomingViewController.h"
#import "CardView.h"

@interface HomeViewController ()

@end

@implementation HomeViewController {
    UIView *searchBarContainer;
    UISearchBar *searchBar;
    NSLayoutConstraint *searchBarYInactive;
    NSLayoutConstraint *searchBarYActive;
    
    CardViewState state;
    
    CardView *activeCard;
    CardView *backCard;
    
    // search
    UITextChecker *textChecker;
    NSMutableArray *words;
    UITableView *tableView;
    CGFloat activeInSearchCardY;
    
    // new word
    UILabel *meaningTitle;
    UIButton *backButton;
    UIViewController *meaningVC;
    
    // learn
    UIViewPropertyAnimator *animator;
    UIPanGestureRecognizer *recognizer;
    UpcomingViewController *learningVC;
    
    CGFloat inactiveCardY;
    CGFloat activeCardY;
    
    // tab bar
    UIView *tabBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        words = [[NSMutableArray alloc] init];
        textChecker = [[UITextChecker alloc] init];
        
        animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut animations:nil];
        recognizer = [[UIPanGestureRecognizer alloc] init];
        state = CardViewStateClosed;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view setBackgroundColor:[UIColor colorNamed:@"mainBackground"]];
    
    [recognizer addTarget:self action:@selector(pullerPanned:)];
    
    // search
    searchBarContainer = [[UIView alloc] init];
    searchBarContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:searchBarContainer];
    
    [searchBarContainer.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [searchBarContainer.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [searchBarContainer.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [searchBarContainer.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.33f].active = YES;
    
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    searchBar.placeholder = @"Type to add new word";
    
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    searchField.backgroundColor = [UIColor colorNamed:@"card"];
    for (UIView* subview in [[searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview setAlpha:0.0];
            break;
        }
    }
    
    [searchBarContainer addSubview:searchBar];
    
    searchBarYActive = [searchBar.topAnchor constraintEqualToAnchor:searchBarContainer.topAnchor];
    searchBarYInactive = [searchBar.centerYAnchor constraintEqualToAnchor:searchBarContainer.centerYAnchor];
    
    searchBarYInactive.active = YES;
    
    [searchBar.leftAnchor constraintEqualToAnchor:searchBarContainer.leftAnchor constant:20].active = YES;
    [searchBar.rightAnchor constraintEqualToAnchor:searchBarContainer.rightAnchor constant:-20].active = YES;
    
    // second half
        [[Cards sharedInstance] addMWCards:@[@{
                                                 @"word": @"allow",
                                                 @"form": @"noun",
                                                 @"headword": @"some headword",
                                                 @"meaning": @"this is when you agree that someone will do smth"
                                                 }]];
    
    activeCard = [[CardView alloc] init];
    
    [self.view addSubview:activeCard];
    
    activeCard.closedConstraint = [activeCard.topAnchor constraintEqualToAnchor:searchBarContainer.bottomAnchor];
    activeCard.searchingConstraint = [activeCard.topAnchor constraintEqualToAnchor:self->searchBar.bottomAnchor constant:10];
    activeCard.learningConstraint = [activeCard.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10];
    
    activeCard.closedConstraint.active = YES;
    
    [activeCard.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [activeCard.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [activeCard.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [activeCard addGestureRecognizer:recognizer];

    backCard = [[CardView alloc] init];
    backCard.backgroundColor = [UIColor colorNamed:@"backCard"];
    
    [self.view insertSubview:backCard belowSubview:activeCard];
    
    backCard.closedConstraint = [backCard.topAnchor constraintEqualToAnchor:searchBarContainer.bottomAnchor];
    backCard.searchingConstraint = [backCard.topAnchor constraintEqualToAnchor:self->searchBar.bottomAnchor constant:10];
    backCard.learningConstraint = [backCard.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10];
    
    backCard.closedConstraint.active = YES;
    
    [backCard.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [backCard.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [backCard.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [backCard setNeedsLayout];
    [backCard layoutIfNeeded];
    
    // 0.075 == 1 - 0.85 / 2
    [backCard setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.85, 0.85), CGAffineTransformMakeTranslation(0, -(backCard.bounds.size.height * 0.075 + 7)))];
    
    // autocomplete
    
    // card content
    

//
//    MWCardView *content = [[MWCardView alloc] initWithCardData:[[Cards sharedInstance] upcoming][0]];
//    content.translatesAutoresizingMaskIntoConstraints = NO;
//
//    [cardLike addSubview:content];
//
//    [content.topAnchor constraintEqualToAnchor:cardLikePullBar.bottomAnchor].active = YES;
//    [content.leftAnchor constraintEqualToAnchor:cardLike.leftAnchor].active = YES;
//    [content.rightAnchor constraintEqualToAnchor:cardLike.rightAnchor].active = YES;
//    [content.bottomAnchor constraintEqualToAnchor:cardLike.bottomAnchor].active = YES;
//
//    [content render];
    
    // tab bar
    tabBar = [[UIView alloc] init];

    tabBar.backgroundColor = [UIColor colorNamed:@"tabBar"];
    [tabBar.layer setCornerRadius:20];
    tabBar.layer.maskedCorners = kCALayerMaxXMinYCorner|kCALayerMinXMinYCorner;
    [tabBar.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [tabBar.layer setShadowOffset:CGSizeMake(0.0, -2.0)];
    [tabBar.layer setShadowRadius:10.0];
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        [tabBar.layer setShadowOpacity:0.05];
    } else {
        [tabBar.layer setShadowOpacity:0.0];
    }
    
    tabBar.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:tabBar];

    [tabBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [tabBar.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [tabBar.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;

    UILabel *homeTabView = [[UILabel alloc] init];
    homeTabView.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    homeTabView.textColor = [UIColor colorNamed:@"secondaryLabel"];
    homeTabView.text = @"Home";
    homeTabView.textAlignment = NSTextAlignmentCenter;
    UILabel *wordsTabView = [[UILabel alloc] init];
    wordsTabView.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    wordsTabView.textColor = [UIColor colorNamed:@"secondaryLabel"];
    wordsTabView.text = @"Words";
    wordsTabView.textAlignment = NSTextAlignmentCenter;
    UILabel *statsTabView = [[UILabel alloc] init];
    statsTabView.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    statsTabView.textColor = [UIColor colorNamed:@"secondaryLabel"];
    statsTabView.text = @"Stats";
    statsTabView.textAlignment = NSTextAlignmentCenter;

    UIStackView *tabsRow = [[UIStackView alloc] initWithArrangedSubviews:@[homeTabView, wordsTabView, statsTabView]];
    tabsRow.translatesAutoresizingMaskIntoConstraints = NO;
    [tabsRow setAxis:UILayoutConstraintAxisHorizontal];
    [tabsRow setAlignment:UIStackViewAlignmentFirstBaseline];
    [tabsRow setDistribution:UIStackViewDistributionFillProportionally];

    UIView *tabsRowWrapper = [[UIView alloc] init];
    tabsRowWrapper.translatesAutoresizingMaskIntoConstraints = NO;

    [tabBar addSubview:tabsRowWrapper];
    [tabsRowWrapper addSubview:tabsRow];

    [tabsRowWrapper.topAnchor constraintEqualToAnchor:tabBar.topAnchor constant:20].active = YES;
    [tabsRowWrapper.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15].active = YES;
    [tabsRowWrapper.leftAnchor constraintEqualToAnchor:tabBar.leftAnchor constant:20].active = YES;
    [tabsRowWrapper.rightAnchor constraintEqualToAnchor:tabBar.rightAnchor constant:-20].active = YES;
    [tabsRow.topAnchor constraintEqualToAnchor:tabsRowWrapper.topAnchor].active = YES;
    [tabsRow.bottomAnchor constraintEqualToAnchor:tabsRowWrapper.safeAreaLayoutGuide.bottomAnchor constant:0].active = YES;
    [tabsRow.leftAnchor constraintEqualToAnchor:tabsRowWrapper.leftAnchor].active = YES;
    [tabsRow.rightAnchor constraintEqualToAnchor:tabsRowWrapper.rightAnchor].active = YES;
    
    [self mountLearningVC];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        [tabBar.layer setShadowOpacity:0.05];
    } else {
        [tabBar.layer setShadowOpacity:0.0];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    inactiveCardY = activeCard.frame.origin.y;
    activeCardY = self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 10;
}

- (void)placeTableViewToCard {
    tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 15);
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [activeCard addSubview:tableView];
    
    [tableView.topAnchor constraintEqualToAnchor:activeCard.content.topAnchor].active = YES;
    [tableView.leftAnchor constraintEqualToAnchor:activeCard.content.leftAnchor constant:15].active = YES;
    [tableView.rightAnchor constraintEqualToAnchor:activeCard.content.rightAnchor].active = YES;
    [tableView.bottomAnchor constraintEqualToAnchor:activeCard.content.bottomAnchor].active = YES;
}

- (void)mountLearningVC {
    learningVC = [[UpcomingViewController alloc] init];
    [self addChildViewController:learningVC];
    learningVC.view.frame = activeCard.content.layoutFrame;
    learningVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [activeCard addSubview:learningVC.view];
    
    [learningVC.view.topAnchor constraintEqualToAnchor:activeCard.content.topAnchor].active = YES;
    [learningVC.view.leftAnchor constraintEqualToAnchor:activeCard.content.leftAnchor].active = YES;
    [learningVC.view.rightAnchor constraintEqualToAnchor:activeCard.content.rightAnchor].active = YES;
    [learningVC.view.bottomAnchor constraintEqualToAnchor:activeCard.content.bottomAnchor].active = YES;
    
    [learningVC didMoveToParentViewController:self];
}

- (void)unmountLearningVC {
    [self->learningVC willMoveToParentViewController:nil];
    [self->learningVC.view removeFromSuperview];
    [self->learningVC removeFromParentViewController];
}

// MARK:- Search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self placeTableViewToCard];
    tableView.layer.opacity = 0.0;
    
    [self openOnSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [self closeOnSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [words removeAllObjects];
    
    if ([searchText length] < 3) {
        [tableView reloadData];
        return;
    }
    
    NSRange range = NSMakeRange(0, searchText.length);
    
    NSArray *completions = [textChecker completionsForPartialWordRange:range inString:searchText language:@"en"];
    for (NSString *c in completions) {
        [words addObject:c];
    }
    
    [tableView reloadData];
}

// MARK:- Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [words count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorNamed:@"autocompleteColor"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [words objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [searchBar resignFirstResponder];
    meaningTitle = [[UILabel alloc] init];
    meaningTitle.translatesAutoresizingMaskIntoConstraints = NO;
    meaningTitle.text = [words objectAtIndex:indexPath.row];
    meaningTitle.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    meaningTitle.textColor = [UIColor whiteColor];
    
    //[searchBarContainer insertSubview:meaningTitle belowSubview:searchBar];
    [searchBarContainer addSubview:meaningTitle];
    
    [meaningTitle.centerYAnchor constraintEqualToAnchor:searchBar.centerYAnchor].active = YES;
    [meaningTitle.centerXAnchor constraintEqualToAnchor:searchBarContainer.centerXAnchor].active = YES;
    
    [meaningTitle setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation( (self->searchBarContainer.bounds.size.width), 0))];
    
    meaningTitle.layer.opacity = 0.0;
    
    UIImage *backImage = [UIImage imageNamed:@"BackIcon"];
    backButton = [[UIButton alloc] init];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [backButton setImage:[backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [backButton.imageView setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(goBackToSearch) forControlEvents:UIControlEventTouchUpInside];
    backButton.layer.opacity = 0.0;
    
    [searchBarContainer addSubview:backButton];
    
    [backButton.leftAnchor constraintEqualToAnchor:searchBar.leftAnchor].active = YES;
    [backButton.centerYAnchor constraintEqualToAnchor:searchBar.centerYAnchor].active = YES;
    [backButton.widthAnchor constraintEqualToConstant:20].active = YES;
    [backButton.heightAnchor constraintEqualToConstant:20].active = YES;
    
    // content
    meaningVC = [[MeaningViewController alloc] initWithWord:[words objectAtIndex:indexPath.row]];
    [self addChildViewController:meaningVC];
    meaningVC.view.frame = activeCard.content.layoutFrame;
    meaningVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [activeCard addSubview:meaningVC.view];
    
    [meaningVC.view.topAnchor constraintEqualToAnchor:activeCard.content.topAnchor].active = YES;
    [meaningVC.view.leftAnchor constraintEqualToAnchor:activeCard.content.leftAnchor].active = YES;
    [meaningVC.view.rightAnchor constraintEqualToAnchor:activeCard.content.rightAnchor].active = YES;
    [meaningVC.view.bottomAnchor constraintEqualToAnchor:activeCard.content.bottomAnchor].active = YES;
    
    [meaningVC.view setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation( (activeCard.bounds.size.width), 0))];
    
    [meaningVC didMoveToParentViewController:self];
    
    // move things
    [UIView animateWithDuration:0.3 animations:^{
        [self->searchBar setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation(-1 * (self->searchBarContainer.bounds.size.width), 0))];
        self->searchBar.layer.opacity = 0.0;
        [self->meaningTitle setTransform:CGAffineTransformIdentity];
        self->meaningTitle.layer.opacity = 1.0;
        self->backButton.layer.opacity = 1.0;
        [self->tableView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation(-1 * (self->activeCard.content.layoutFrame.size.width), 0))];
        //[self->tableView setTransform:CGAffineTransformMakeTranslation(-1 * (self->cardLike.bounds.size.width), 0)];
        [self->meaningVC.view setTransform:CGAffineTransformIdentity];
        self->state = CardViewStateMeaning;
    }];
}

// MARK:- Setters

- (void)setRightHeaderView:(nullable UIView *)rightHeaderView {
    if (rightHeaderView == nil) {
        [_rightHeaderView removeFromSuperview];
        _rightHeaderView = nil;
        
        return;
    }
    _rightHeaderView = rightHeaderView;
    
    [searchBarContainer addSubview:_rightHeaderView];
    
    [_rightHeaderView.rightAnchor constraintEqualToAnchor:searchBar.rightAnchor].active = YES;
    [_rightHeaderView.centerYAnchor constraintEqualToAnchor:searchBar.centerYAnchor].active = YES;
    [_rightHeaderView.widthAnchor constraintEqualToConstant:20].active = YES;
    [_rightHeaderView.heightAnchor constraintEqualToConstant:20].active = YES;
}

// MARK:- Transitions

- (void)goBackToSearch {
    if (self.rightHeaderView != nil) {
        [UIView animateWithDuration:0.1 animations:^{
            self.rightHeaderView.layer.opacity = 0.0;
        }];
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self->searchBar setTransform:CGAffineTransformIdentity];
        self->searchBar.layer.opacity = 1.0;
        [self->meaningTitle setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation( (self->searchBarContainer.bounds.size.width), 0))];
        self->meaningTitle.layer.opacity = 0.0;
        self->backButton.layer.opacity = 0.0;
        [self->tableView setTransform:CGAffineTransformIdentity];
        [self->meaningVC.view setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation( (self->activeCard.bounds.size.width), 0))];
    } completion:^(BOOL finished) {
        [self->meaningTitle removeFromSuperview];
        [self->backButton removeFromSuperview];
        [self->meaningVC willMoveToParentViewController:nil];
        [self->meaningVC.view removeFromSuperview];
        [self->meaningVC removeFromParentViewController];
        if (self.rightHeaderView != nil) {
            self.rightHeaderView = nil;
        }
        self->state = CardViewStateSearching;
    }];
}

- (void)openOnLearning {
    [animator addAnimations:^{
        self->searchBarYInactive.active = NO;
        self->searchBarYActive.active = YES;
        self->searchBar.layer.opacity = 0.0;
        
        self->activeCard.closedConstraint.active = NO;
        self->activeCard.learningConstraint.active = YES;
        [self->backCard setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
        
        [self->tabBar setTransform:CGAffineTransformMakeTranslation(0, self->tabBar.bounds.size.height)];
        
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self->state = CardViewStateLearning;
    }];
    
    [animator startAnimation];
}

- (void)closeOnLearning {
    [animator addAnimations:^{
        self->searchBarYActive.active = NO;
        self->searchBarYInactive.active = YES;
        self->searchBar.layer.opacity = 1.0;
        
        self->activeCard.learningConstraint.active = NO;
        self->activeCard.closedConstraint.active = YES;
        self->backCard.learningConstraint.active = NO;
        self->backCard.closedConstraint.active = YES;
        
        [self.view layoutIfNeeded];
        
        [self->backCard setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.85, 0.85), CGAffineTransformMakeTranslation(0, -(backCard.bounds.size.height * 0.075 + 7)))];
        
        self->learningVC.view.layer.opacity = 1.0;
        
        [self->tabBar setTransform:CGAffineTransformIdentity];
        
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self->state = CardViewStateClosed;
    }];
    
    [animator startAnimation];
}

- (void)openOnSearch {
    [animator addAnimations:^{
        self->searchBarYInactive.active = NO;
        self->searchBarYActive.active = YES;
        
        self->activeCard.closedConstraint.active = NO;
        self->activeCard.searchingConstraint.active = YES;
        
        self->learningVC.view.layer.opacity = 0.0;
        self->tableView.layer.opacity = 1.0;
        
        [self->tabBar setTransform:CGAffineTransformMakeTranslation(0, self->tabBar.bounds.size.height)];
        
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self->activeInSearchCardY = self->activeCard.frame.origin.y;
        self->state = CardViewStateSearching;
    }];
    
    [animator startAnimation];
}

- (void)closeOnSearch {
    [animator addAnimations:^{
        self->searchBarYActive.active = NO;
        self->searchBarYInactive.active = YES;
        
        self->activeCard.searchingConstraint.active = NO;
        self->activeCard.closedConstraint.active = YES;
        
        self->learningVC.view.layer.opacity = 1.0;
        self->tableView.layer.opacity = 0.0;
        
        [self->tabBar setTransform:CGAffineTransformIdentity];
        
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        //[self->searchBar resignFirstResponder];
        [self->tableView removeFromSuperview];
        self->state = CardViewStateClosed;
    }];
    
    [animator startAnimation];
}

- (void)openOnMeaning {
    [animator addAnimations:^{
        self->searchBarYInactive.active = NO;
        self->searchBarYActive.active = YES;
        [self->searchBar setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation(-1 * (self->searchBarContainer.bounds.size.width), 0))];
        self->searchBar.layer.opacity = 0.0;
        [self->meaningTitle setTransform:CGAffineTransformIdentity];
        self->meaningTitle.layer.opacity = 1.0;
        self->backButton.layer.opacity = 1.0;
        if (self.rightHeaderView) {
            self.rightHeaderView.layer.opacity = 1.0;
        }
        
        self->activeCard.closedConstraint.active = NO;
        self->activeCard.searchingConstraint.active = YES;
        
        self->learningVC.view.layer.opacity = 0.0;
        self->meaningVC.view.layer.opacity = 1.0;
        
        [self->tabBar setTransform:CGAffineTransformMakeTranslation(0, self->tabBar.bounds.size.height)];
        
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self->state = CardViewStateMeaning;
    }];
    
    [animator startAnimation];
}

- (void)closeOnMeaning {
    [animator addAnimations:^{
        self->searchBarYActive.active = NO;
        self->searchBarYInactive.active = YES;
        [self->searchBar setTransform:CGAffineTransformIdentity];
        self->searchBar.layer.opacity = 1.0;
        [self->meaningTitle setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation( (self->searchBarContainer.bounds.size.width), 0))];
        self->meaningTitle.layer.opacity = 0.0;
        self->backButton.layer.opacity = 0.0;
        if (self.rightHeaderView) {
            self.rightHeaderView.layer.opacity = 0.0;
        }
        
        self->activeCard.searchingConstraint.active = YES;
        self->activeCard.closedConstraint.active = YES;
        
        self->learningVC.view.layer.opacity = 1.0;
        self->meaningVC.view.layer.opacity = 0.0;
        
        [self->tabBar setTransform:CGAffineTransformIdentity];
        
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        [self->meaningTitle removeFromSuperview];
        [self->backButton removeFromSuperview];
        if (self.rightHeaderView != nil) {
            self.rightHeaderView = nil;
        }
        
        [self->meaningVC willMoveToParentViewController:nil];
        [self->meaningVC.view removeFromSuperview];
        [self->meaningVC removeFromParentViewController];
        
        [self->tableView removeFromSuperview];
        
        self->state = CardViewStateClosed;
    }];
    
    [animator startAnimation];
}

- (void)closeCard {
    if (state == CardViewStateMeaning) {
        searchBar.searchTextField.text = @"";
        [words removeAllObjects];
        [self closeOnMeaning];
    } else if (state == CardViewStateSearching) {
        [self closeOnSearch];
    } else if (state == CardViewStateLearning) {
        [self closeOnLearning];
    } else {
        [self openOnLearning];
    }
}

- (void)showNextCard {
    CardView *tempCard = activeCard;
    
    activeCard = backCard;
    
    [activeCard addGestureRecognizer:recognizer];
    
    [self->learningVC willMoveToParentViewController:nil];
    [self->learningVC.view removeFromSuperview];
    [self->learningVC removeFromParentViewController];
    [self mountLearningVC];
    [self->learningVC setLearnState];

    backCard = [[CardView alloc] init];
    backCard.backgroundColor = [UIColor colorNamed:@"backCard"];
    
    [self.view insertSubview:backCard belowSubview:activeCard];
    
    backCard.closedConstraint = [backCard.topAnchor constraintEqualToAnchor:searchBarContainer.bottomAnchor];
    backCard.searchingConstraint = [backCard.topAnchor constraintEqualToAnchor:self->searchBar.bottomAnchor constant:10];
    backCard.learningConstraint = [backCard.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10];
    
    backCard.learningConstraint.active = YES;
    
    [backCard.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [backCard.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [backCard.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [backCard setNeedsLayout];
    [backCard layoutIfNeeded];
    
    [backCard setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
    
    [animator addAnimations:^{
        [tempCard setTransform:CGAffineTransformMakeTranslation(-1 * (self->activeCard.bounds.size.width), 0)];
        [self->activeCard setTransform:CGAffineTransformIdentity];
        self->activeCard.closedConstraint.active = NO;
        self->activeCard.learningConstraint.active = YES;
        activeCard.backgroundColor = [UIColor colorNamed:@"card"];
        
        [self->activeCard layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        [tempCard removeFromSuperview];
    }];
    
    [animator startAnimation];
}

- (void)pullerPanned:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (state == CardViewStateMeaning) {
            [self closeOnMeaning];
        } else if (state == CardViewStateSearching) {
            [self closeOnSearch];
        } else if (state == CardViewStateLearning) {
            [self closeOnLearning];
            [self->learningVC closeToLearn];
            [self->learningVC.animator pauseAnimation];
        } else {
            [self openOnLearning];
            [self->learningVC openToLearn];
            [self->learningVC.animator pauseAnimation];
        }
        [animator pauseAnimation];
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        CGFloat factor;
        
        if (state == CardViewStateSearching || state == CardViewStateMeaning) {
            factor = translation.y / (inactiveCardY - activeInSearchCardY);
        } else if (state == CardViewStateLearning) {
            factor = translation.y / (inactiveCardY - activeCardY);
            self->learningVC.animator.fractionComplete = factor;
        } else {
            factor = -1 * translation.y / (inactiveCardY - activeCardY);
            self->learningVC.animator.fractionComplete = factor;
        }
        
        animator.fractionComplete = factor;
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [recognizer translationInView:self.view];
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat factor;
        
        if (state == CardViewStateMeaning) {
            factor = -1 * translation.y / (inactiveCardY - activeInSearchCardY);
            if (fabs(factor) > 0.5 || fabs(velocity.y) > 100) {
                [animator continueAnimationWithTimingParameters:nil durationFactor:0];
                searchBar.searchTextField.text = @"";
                [words removeAllObjects];
            } else {
                [animator stopAnimation:YES];
                [self openOnMeaning];
            }
        } else if (state == CardViewStateSearching) {
            factor = -1 * translation.y / (inactiveCardY - activeInSearchCardY);
            if (fabs(factor) > 0.5 || fabs(velocity.y) > 100) {
                [animator continueAnimationWithTimingParameters:nil durationFactor:0];
                [self->searchBar resignFirstResponder];
            } else {
                [animator stopAnimation:YES];
                [self openOnSearch];
            }
        } else if (state == CardViewStateLearning) {
            factor = translation.y / (inactiveCardY - activeCardY);
            if (fabs(factor) > 0.5 || fabs(velocity.y) > 100) {
                [animator continueAnimationWithTimingParameters:nil durationFactor:0];
                [self->learningVC.animator continueAnimationWithTimingParameters:nil durationFactor:0];
            } else {
                [animator stopAnimation:YES];
                [self openOnLearning];
                [self->learningVC.animator stopAnimation:YES];
                [self->learningVC openToLearn];
            }
        } else {
            factor = -1 * translation.y / (inactiveCardY - activeCardY);
            if (fabs(factor) > 0.5 || fabs(velocity.y) > 100) {
                [animator continueAnimationWithTimingParameters:nil durationFactor:0];
                [self->learningVC.animator continueAnimationWithTimingParameters:nil durationFactor:0];
            } else {
                [animator stopAnimation:YES];
                [self closeOnLearning];
                [self->learningVC.animator stopAnimation:YES];
                [self->learningVC closeToLearn];
            }
        }
        return;
    }
}

@end
