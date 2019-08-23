//
//  MWCardView.h
//  rememberify
//
//  Created by Admin on 10/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cards.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CardQualityFeedback) {
    CardQualityFeedbackPerfect,
    CardQualityFeedbackCorrectWithDelay,
    CardQualityFeedbackCorrectButHard,
    CardQualityFeedbackIncorrect
};

@protocol MWCardViewDelegate <NSObject>
@required
- (void)onAnswerQualityFeedback:(CardQualityFeedback)quality;
@end

@interface MWCardView : UIView

@property (nonatomic, weak) id<MWCardViewDelegate> delegate;

- (instancetype)initWithCardData:(MWCard *)cardData;

- (void)render;
- (void)renderFrontInParent:(UIView *)parent;
- (void)renderFrontInParent:(UIView *)parent belowView:(UIView *)prev;

- (void)moveToFront:(void (^)(BOOL))completion;

@end

NS_ASSUME_NONNULL_END
