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
    
    // search
    UITextChecker *textChecker;
    NSMutableArray *words;
    UITableView *tableView;
    BOOL isSearching;
    CGFloat activeInSearchCardY;
    
    // new word
    UILabel *meaningTitle;
    UIButton *backButton;
    UIViewController *meaningVC;
    
    // learn
    UIViewPropertyAnimator *animator;
    UIPanGestureRecognizer *recognizer;
    BOOL isOpened;
    
    CGFloat inactiveCardY;
    CGFloat activeCardY;
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
        isOpened = NO;
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
    [searchBarContainer.bottomAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    cardLikeTopInactive = [cardLike.topAnchor constraintEqualToAnchor:self.view.centerYAnchor];
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
    
    tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 15);
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    inactiveCardY = cardLike.frame.origin.y;
    activeCardY = self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 10;
}

- (void)placeTableViewToCard {
    [cardLike addSubview:tableView];
    
    [tableView.topAnchor constraintEqualToAnchor:cardLikeContent.topAnchor].active = YES;
    [tableView.leftAnchor constraintEqualToAnchor:cardLikeContent.leftAnchor constant:15].active = YES;
    [tableView.rightAnchor constraintEqualToAnchor:cardLikeContent.rightAnchor].active = YES;
    [tableView.bottomAnchor constraintEqualToAnchor:cardLikeContent.bottomAnchor].active = YES;
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self placeTableViewToCard];
    tableView.layer.opacity = 0.0;
    isSearching = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self->searchBarYInactive.active = NO;
        self->searchBarYActive.active = YES;
        self->cardLikeTopInactive.active = NO;
        self->cardLikeTopSearchActive.active = YES;
        self->cardLikeTopLearnActive.active = NO;
        self->tableView.layer.opacity = 1.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self->activeInSearchCardY = self->cardLike.frame.origin.y;
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.25 animations:^{
        self->searchBarYInactive.active = YES;
        self->searchBarYActive.active = NO;
        self->cardLikeTopInactive.active = YES;
        self->cardLikeTopSearchActive.active = NO;
        self->cardLikeTopLearnActive.active = NO;
        self->tableView.layer.opacity = 0.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self->tableView removeFromSuperview];
        self->isSearching = NO;
    }];
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
    }];
}

- (void)goBackToSearch {
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
    }];
}

- (void)openCard {
    [animator addAnimations:^{
        self->searchBarYInactive.active = NO;
        self->searchBarYActive.active = YES;
        self->searchBar.layer.opacity = 0.0;
        self->cardLikeTopInactive.active = NO;
        self->cardLikeTopSearchActive.active = NO;
        self->cardLikeTopLearnActive.active = YES;
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self->isOpened = YES;
    }];
    
    [animator startAnimation];
}

- (void)closeCard {
    [animator addAnimations:^{
        self->searchBarYInactive.active = YES;
        self->searchBarYActive.active = NO;
        self->searchBar.layer.opacity = 1.0;
        self->cardLikeTopInactive.active = YES;
        self->cardLikeTopSearchActive.active = NO;
        self->cardLikeTopLearnActive.active = NO;
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self->isOpened = NO;
    }];
    
    [animator startAnimation];
}

- (void)closeOnSearch {
    [animator addAnimations:^{
        self->searchBarYInactive.active = YES;
        self->searchBarYActive.active = NO;
        self->cardLikeTopInactive.active = YES;
        self->cardLikeTopSearchActive.active = NO;
        self->cardLikeTopLearnActive.active = NO;
        self->tableView.layer.opacity = 0.0;
        [self.view layoutIfNeeded];
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        [self->tableView removeFromSuperview];
        self->isSearching = NO;
    }];
    
    [animator startAnimation];
}

- (void)pullerPanned:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (isSearching) {
            [searchBar resignFirstResponder];
            [self closeOnSearch];
        } else if (!isOpened) {
            [self openCard];
        } else {
            [self closeCard];
        }
        [animator pauseAnimation];
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        CGFloat factor;
        
        if (isSearching) {
            factor = translation.y / (inactiveCardY - activeInSearchCardY);
        } else {
            factor = translation.y / (inactiveCardY - activeCardY);
            if (!isOpened) {
                factor = factor * -1;
            }
        }
        
        animator.fractionComplete = factor;
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [recognizer translationInView:self.view];
        CGPoint velocity = [recognizer velocityInView:self.view];
        if (isSearching) {
            //CGFloat factor = translation.y / (inactiveCardY - activeInSearchCardY);
            [animator continueAnimationWithTimingParameters:nil durationFactor:0];
        } else {
            CGFloat factor = translation.y / (inactiveCardY - activeCardY);
            if (fabs(factor) > 0.5 || fabs(velocity.y) > 100) {
                [animator continueAnimationWithTimingParameters:nil durationFactor:0];
            } else {
                [animator stopAnimation:YES];
                if (isOpened) {
                    [self openCard];
                } else {
                    [self closeCard];
                }
            }
        }
        //
        return;
    }
}

@end
