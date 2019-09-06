//
//  UpcomingViewController.h
//  nutcracker
//
//  Created by Алексей Савельев on 24/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CardQualityFeedback) {
    CardQualityFeedbackPerfect,
    CardQualityFeedbackCorrectWithDelay,
    CardQualityFeedbackCorrectButHard,
    CardQualityFeedbackIncorrect
};

@interface UpcomingViewController : UIViewController

@property (readonly) UIViewPropertyAnimator *animator;

- (void)openToLearn;
- (void)closeToLearn;
- (void)setLearnState;

@end

NS_ASSUME_NONNULL_END
