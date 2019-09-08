//
//  TermToLearn+CoreDataProperties.m
//  nutcracker
//
//  Created by Алексей Савельев on 08/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//
//

#import "TermToLearn+CoreDataProperties.h"

@implementation TermToLearn (CoreDataProperties)

+ (NSFetchRequest<TermToLearn *> *)fetchRequest {
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"TermToLearn"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    [components setHour:8];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *tomorrow = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[calendar dateFromComponents:components] options:0];
    req.predicate = [NSPredicate predicateWithFormat:@"date < %@" argumentArray:@[tomorrow]];
    req.fetchLimit = 20;
    req.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"attempt" ascending:NO]];
    
    return req;
}

@dynamic attempt;
@dynamic date;
@dynamic ef;
@dynamic forms;
@dynamic interval;
@dynamic term;

@end
