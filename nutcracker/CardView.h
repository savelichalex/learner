//
//  CardView.h
//  nutcracker
//
//  Created by Алексей Савельев on 24/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CardView : UIView
@property () NSLayoutConstraint *closedConstraint;
@property () NSLayoutConstraint *searchingConstraint;
@property () NSLayoutConstraint *learningConstraint;

@property (readonly) UIView *pullBar;
@property (readonly) UILayoutGuide *content;
@end

NS_ASSUME_NONNULL_END
