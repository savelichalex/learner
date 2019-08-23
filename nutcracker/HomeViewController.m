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

@interface HomeViewController ()

@end

@implementation HomeViewController {
    UIView *searchBarContainer;
    UISearchBar *searchBar;
    NSLayoutConstraint *searchBarYInactive;
    NSLayoutConstraint *searchBarYActive;
    UIView *cardLike;
    NSLayoutConstraint *cardLikeTopInactive;
    NSLayoutConstraint *cardLikeTopSearchActive;
    NSLayoutConstraint *cardLikeTopLearnActive;
    UIView *cardLikePullBar;
    UILayoutGuide *cardLikeContent;
    
    CardViewState state;
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
    cardLike = [[UIView alloc] init];
    
    cardLike.backgroundColor = [UIColor colorNamed:@"card"];
    [cardLike.layer setCornerRadius:20];
    [cardLike.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [cardLike.layer setShadowOffset:CGSizeMake(0.0, -2.0)];
    [cardLike.layer setShadowRadius:4.0];
    [cardLike.layer setShadowOpacity:0.1];
    cardLike.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:cardLike];
    
    cardLikeTopInactive = [cardLike.topAnchor constraintEqualToAnchor:searchBarContainer.bottomAnchor];
    cardLikeTopSearchActive = [cardLike.topAnchor constraintEqualToAnchor:self->searchBar.bottomAnchor constant:10];
    cardLikeTopLearnActive = [cardLike.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10];
    
    cardLikeTopInactive.active = YES;
    
    [cardLike.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [cardLike.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [cardLike.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:20].active = YES;
    
    // card pull bar
    UIView *cardLikePullBarInner = [[UIView alloc] init];
    cardLikePullBarInner.translatesAutoresizingMaskIntoConstraints = NO;
    cardLikePullBarInner.backgroundColor = [UIColor colorNamed:@"puller"];
    [cardLikePullBarInner.layer setCornerRadius:3];
    
    cardLikePullBar = [[UIView alloc] init];
    cardLikePullBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [cardLike addSubview:cardLikePullBar];
    [cardLikePullBar addSubview:cardLikePullBarInner];
    
    [cardLikePullBarInner.widthAnchor constraintEqualToConstant:40].active = YES;
    [cardLikePullBarInner.heightAnchor constraintEqualToConstant:6].active = YES;
    [cardLikePullBarInner.centerXAnchor constraintEqualToAnchor:cardLikePullBar.centerXAnchor].active = YES;
    [cardLikePullBarInner.topAnchor constraintEqualToAnchor:cardLikePullBar.topAnchor constant:10].active = YES;
    [cardLikePullBarInner.bottomAnchor constraintEqualToAnchor:cardLikePullBar.bottomAnchor constant:-10].active = YES;
    
    [cardLikePullBar.topAnchor constraintEqualToAnchor:cardLike.topAnchor].active = YES;
    [cardLikePullBar.leftAnchor constraintEqualToAnchor:cardLike.leftAnchor].active = YES;
    [cardLikePullBar.rightAnchor constraintEqualToAnchor:cardLike.rightAnchor].active = YES;
    
    [cardLikePullBar addGestureRecognizer:recognizer];
    
    cardLikeContent = [[UILayoutGuide alloc] init];
    
    [cardLike addLayoutGuide:cardLikeContent];
    
    [cardLikeContent.topAnchor constraintEqualToAnchor:cardLikePullBar.bottomAnchor constant:10].active = YES;
    [cardLikeContent.leftAnchor constraintEqualToAnchor:cardLike.leftAnchor].active = YES;
    [cardLikeContent.rightAnchor constraintEqualToAnchor:cardLike.rightAnchor].active = YES;
    [cardLikeContent.bottomAnchor constraintEqualToAnchor:cardLike.bottomAnchor].active = YES;
    
    // autocomplete
    
    // card content
    
//    [[Cards sharedInstance] addMWCards:@[@{
//                                             @"word": @"allow",
//                                             @"form": @"noun",
//                                             @"headword": @"some headword",
//                                             @"meaning": @"this is when you agree that someone will do smth"
//                                             }]];
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
    [tabBar.layer setShadowOpacity:0.05];
    tabBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:tabBar];
    
    [tabBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [tabBar.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [tabBar.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    UILabel *homeTabView = [[UILabel alloc] init];
    homeTabView.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    homeTabView.text = @"Home";
    homeTabView.textAlignment = NSTextAlignmentCenter;
    UILabel *wordsTabView = [[UILabel alloc] init];
    wordsTabView.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    wordsTabView.text = @"Words";
    wordsTabView.textAlignment = NSTextAlignmentCenter;
    UILabel *statsTabView = [[UILabel alloc] init];
    statsTabView.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    statsTabView.text = @"Stats";
    statsTabView.textAlignment = NSTextAlignmentCenter;
    
    UIStackView *tabsRow = [[UIStackView alloc] initWithArrangedSubviews:@[homeTabView, wordsTabView, statsTabView]];
    tabsRow.translatesAutoresizingMaskIntoConstraints = NO;
    [tabsRow setAxis:UILayoutConstraintAxisHorizontal];
    [tabsRow setAlignment:UIStackViewAlignmentFirstBaseline];
    [tabsRow setDistribution:UIStackViewDistributionFillProportionally];
    
    [tabBar addSubview:tabsRow];
    
    [tabsRow.topAnchor constraintEqualToAnchor:tabBar.topAnchor constant:20].active = YES;
    [tabsRow.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    [tabsRow.leftAnchor constraintEqualToAnchor:tabBar.leftAnchor constant:20].active = YES;
    [tabsRow.rightAnchor constraintEqualToAnchor:tabBar.rightAnchor constant:-20].active = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    inactiveCardY = cardLike.frame.origin.y;
    activeCardY = self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 10;
}

- (void)placeTableViewToCard {
    tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 15);
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [cardLike addSubview:tableView];
    
    [tableView.topAnchor constraintEqualToAnchor:cardLikeContent.topAnchor].active = YES;
    [tableView.leftAnchor constraintEqualToAnchor:cardLikeContent.leftAnchor constant:15].active = YES;
    [tableView.rightAnchor constraintEqualToAnchor:cardLikeContent.rightAnchor].active = YES;
    [tableView.bottomAnchor constraintEqualToAnchor:cardLikeContent.bottomAnchor].active = YES;
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
    meaningVC = [[MeaningViewController alloc] initWithWord:@"appeal"];
    [self addChildViewController:meaningVC];
    meaningVC.view.frame = cardLikeContent.layoutFrame;
    meaningVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:meaningVC.view];
    
    [meaningVC.view.topAnchor constraintEqualToAnchor:cardLikeContent.topAnchor].active = YES;
    [meaningVC.view.leftAnchor constraintEqualToAnchor:cardLikeContent.leftAnchor].active = YES;
    [meaningVC.view.rightAnchor constraintEqualToAnchor:cardLikeContent.rightAnchor].active = YES;
    [meaningVC.view.bottomAnchor constraintEqualToAnchor:cardLikeContent.bottomAnchor].active = YES;
    
    [meaningVC.view setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation( (self->cardLike.bounds.size.width), 0))];
    
    [meaningVC didMoveToParentViewController:self];
    
    // move things
    [UIView animateWithDuration:0.3 animations:^{
        [self->searchBar setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation(-1 * (self->searchBarContainer.bounds.size.width), 0))];
        self->searchBar.layer.opacity = 0.0;
        [self->meaningTitle setTransform:CGAffineTransformIdentity];
        self->meaningTitle.layer.opacity = 1.0;
        self->backButton.layer.opacity = 1.0;
        [self->tableView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation(-1 * (self->cardLikeContent.layoutFrame.size.width), 0))];
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
        [self->meaningVC.view setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation( (self->cardLike.bounds.size.width), 0))];
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
        
        self->cardLikeTopInactive.active = NO;
        self->cardLikeTopLearnActive.active = YES;
        
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
        
        self->cardLikeTopLearnActive.active = NO;
        self->cardLikeTopInactive.active = YES;
        
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
        
        self->cardLikeTopInactive.active = NO;
        self->cardLikeTopSearchActive.active = YES;
        
        self->tableView.layer.opacity = 1.0;
        
        [self->tabBar setTransform:CGAffineTransformMakeTranslation(0, self->tabBar.bounds.size.height)];
        
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self->activeInSearchCardY = self->cardLike.frame.origin.y;
        self->state = CardViewStateSearching;
    }];
    
    [animator startAnimation];
}

- (void)closeOnSearch {
    [animator addAnimations:^{
        self->searchBarYActive.active = NO;
        self->searchBarYInactive.active = YES;
        
        self->cardLikeTopSearchActive.active = NO;
        self->cardLikeTopInactive.active = YES;
        
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
        
        self->cardLikeTopInactive.active = NO;
        self->cardLikeTopSearchActive.active = YES;
        
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
        
        self->cardLikeTopSearchActive.active = NO;
        self->cardLikeTopInactive.active = YES;
        
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

- (void)pullerPanned:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (state == CardViewStateMeaning) {
            [self closeOnMeaning];
        } else if (state == CardViewStateSearching) {
            [self closeOnSearch];
        } else if (state == CardViewStateLearning) {
            [self closeOnLearning];
        } else {
            [self openOnLearning];
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
        } else {
            factor = -1 * translation.y / (inactiveCardY - activeCardY);
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
            } else {
                [animator stopAnimation:YES];
                [self openOnLearning];
            }
        } else {
            factor = -1 * translation.y / (inactiveCardY - activeCardY);
            if (fabs(factor) > 0.5 || fabs(velocity.y) > 100) {
                [animator continueAnimationWithTimingParameters:nil durationFactor:0];
            } else {
                [animator stopAnimation:YES];
                [self closeOnLearning];
            }
        }
        return;
    }
}

@end
