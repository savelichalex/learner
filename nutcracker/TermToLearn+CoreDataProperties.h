//
//  TermToLearn+CoreDataProperties.h
//  nutcracker
//
//  Created by Алексей Савельев on 08/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//
//

#import "TermToLearn+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TermToLearn (CoreDataProperties)

+ (NSFetchRequest<TermToLearn *> *)fetchRequest;

@property (nonatomic) int16_t attempt;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) float ef;
@property (nullable, nonatomic, retain) NSObject *forms;
@property (nonatomic) int16_t interval;
@property (nullable, nonatomic, copy) NSString *term;

@end

NS_ASSUME_NONNULL_END
