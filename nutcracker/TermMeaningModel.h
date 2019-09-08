//
//  TermMeaningModel.h
//  nutcracker
//
//  Created by Алексей Савельев on 06/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;
#import "TermToLearn+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface TermMeaningDef : NSObject<NSCoding>

@property (nonatomic, copy) NSString *meaning;
@property (nonatomic, copy) NSArray *examples;
@property (nonatomic) BOOL isChoosedForLearning;

@end

@interface TermMeaningForm : NSObject<NSCoding>

@property (readonly) NSString *form;
@property (readonly) NSString *pron;
@property (readonly) NSArray<TermMeaningDef *> *defs;

@end

typedef NS_ENUM(NSInteger, MeaningFetchStatus) {
    MeaningFetchStatusProgress,
    MeaningFetchStatusSuccess,
    MeaningFetchStatusError,
};

@interface TermMeaningModel : NSObject

+ (instancetype)instanceForTerm:(NSString *)term;

- (instancetype)initWithTerm:(NSString *)term;
- (instancetype)initWithPersistedData:(TermToLearn *)term;
- (BOOL)isFetchStatusEqualTo:(MeaningFetchStatus)status;

@property (readonly) NSString *term;
@property (readonly) NSArray<TermMeaningForm *> *forms;
@property () NSNumber *fetchStatus; // MeaningFetchStatus

@end

NS_ASSUME_NONNULL_END
