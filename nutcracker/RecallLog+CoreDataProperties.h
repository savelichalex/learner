//
//  RecallLog+CoreDataProperties.h
//  nutcracker
//
//  Created by Алексей Савельев on 08/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//
//

#import "RecallLog+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RecallLog (CoreDataProperties)

+ (NSFetchRequest<RecallLog *> *)fetchRequest;

@property (nonatomic) int16_t attempt;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) float ef;
@property (nonatomic) int16_t interval;
@property (nullable, nonatomic, retain) TermToLearn *id;

@end

NS_ASSUME_NONNULL_END
