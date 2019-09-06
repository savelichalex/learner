//
//  TermMeaningModel.h
//  nutcracker
//
//  Created by Алексей Савельев on 06/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TermMeaningDef : NSObject

@property (nonatomic, copy) NSString *meaning;
@property (nonatomic, copy) NSArray *examples;

@end

@interface TermMeaningForm : NSObject

@property (readonly) NSString *form;
@property (readonly) NSString *pron;
@property (readonly) NSArray<NSDictionary *> *defs;

@end

typedef NS_ENUM(NSInteger, MeaningFetchStatus) {
    MeaningFetchStatusProgress,
    MeaningFetchStatusSuccess,
    MeaningFetchStatusError,
};

@interface TermMeaningModel : NSObject

+ (instancetype)instanceForTerm:(NSString *)term;

- (instancetype)initWithTerm:(NSString *)term;
- (BOOL)isFetchStatusEqualTo:(MeaningFetchStatus)status;

@property (readonly) NSString *term;
@property (readonly) NSArray<TermMeaningForm *> *forms;
@property () NSNumber *fetchStatus; // MeaningFetchStatus

@end

NS_ASSUME_NONNULL_END
