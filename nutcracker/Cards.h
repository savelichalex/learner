//
//  Cards.h
//  rememberify
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TermMeaningModel.h"
#import "TermToLearn+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWCard : NSObject
+ (NSString *)type;
@property (nonatomic, copy) NSString *front;
@property (nonatomic, copy) NSString *form;
@property (nonatomic, copy) NSString *headword;
@property (nonatomic, copy) NSString *meaning;
@property (nonatomic, copy) NSArray<NSString *> *examples;

@end

@interface Cards : NSObject

+ (instancetype)sharedInstance;
- (void)addTerm:(TermMeaningModel *)model;
- (TermMeaningModel *)getUpcomingCard;
- (TermMeaningModel *)getNextToUpcomingCard;

@property (nonatomic, copy) NSArray *upcoming;

@end

NS_ASSUME_NONNULL_END
