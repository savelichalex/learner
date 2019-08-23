//
//  HomeViewController.h
//  nutcracker
//
//  Created by Алексей Савельев on 21/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CardViewState) {
    CardViewStateClosed,
    CardViewStateLearning,
    CardViewStateSearching,
    CardViewStateMeaning,
};

@interface HomeViewController : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic, nullable) UIView *rightHeaderView;

- (void)closeCard;

@end

NS_ASSUME_NONNULL_END
