//
//  HomeViewController.m
//  nutcracker
//
//  Created by Алексей Савельев on 21/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "HomeViewController.h"

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
    
    // search
    UITextChecker *textChecker;
    NSMutableArray *words;
    UITableView *tableView;
    BOOL isSearching;
    CGFloat activeInSearchCardY;
    
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
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.70 green:0.60 blue:1.00 alpha:1.0]];
    
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
    
    for (UIView* subview in [[searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview setAlpha:0.0];
            break;
        }
    }
    
    [searchBarContainer addSubview:searchBar];
    
    searchBarYActive = [searchBar.topAnchor constraintEqualToAnchor:searchBarContainer.topAnchor constant:20];
    searchBarYInactive = [searchBar.centerYAnchor constraintEqualToAnchor:searchBarContainer.centerYAnchor];
    
    searchBarYInactive.active = YES;
    
    [searchBar.leftAnchor constraintEqualToAnchor:searchBarContainer.leftAnchor constant:20].active = YES;
    [searchBar.rightAnchor constraintEqualToAnchor:searchBarContainer.rightAnchor constant:-20].active = YES;
    
    // second half
    cardLike = [[UIView alloc] init];
    
    cardLike.backgroundColor = [UIColor whiteColor];
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
    cardLikePullBarInner.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
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
    
    // autocomplete
    
    tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 15);
    
    tableView.delegate = self;
    tableView.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    inactiveCardY = cardLike.frame.origin.y;
    activeCardY = self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 10;
}

- (void)placeTableViewToCard {
    [cardLike addSubview:tableView];
    
    [tableView.topAnchor constraintEqualToAnchor:cardLikePullBar.bottomAnchor constant:10].active = YES;
    [tableView.leftAnchor constraintEqualToAnchor:cardLike.leftAnchor constant:15].active = YES;
    [tableView.rightAnchor constraintEqualToAnchor:cardLike.rightAnchor].active = YES;
    [tableView.bottomAnchor constraintEqualToAnchor:cardLike.bottomAnchor].active = YES;
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
    }
    cell.textLabel.text = [words objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)openCard {
    [animator addAnimations:^{
        self->searchBarYInactive.active = NO;
        self->searchBarYActive.active = YES;
        self->searchBar.layer.opacity = 0.0;
        self->cardLikeTopInactive.active = NO;
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
            CGFloat factor = translation.y / (inactiveCardY - activeInSearchCardY);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
