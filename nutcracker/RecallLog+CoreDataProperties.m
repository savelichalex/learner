//
//  RecallLog+CoreDataProperties.m
//  nutcracker
//
//  Created by Алексей Савельев on 08/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//
//

#import "RecallLog+CoreDataProperties.h"

@implementation RecallLog (CoreDataProperties)

+ (NSFetchRequest<RecallLog *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RecallLog"];
}

@dynamic attempt;
@dynamic date;
@dynamic ef;
@dynamic interval;
@dynamic id;

@end
