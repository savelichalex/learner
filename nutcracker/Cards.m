//
//  Cards.m
//  rememberify
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

@import CoreData;
#import "Cards.h"
#import "AppDelegate.h"

@implementation MWCard
static NSString *cardType = @"MWCard";

+ (NSString *)type {
    return cardType;
}

@end

@implementation Cards {
    NSArray<NSManagedObject *> *upcomingTerms;
    NSManagedObjectContext *managedContext;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _upcoming = [[NSMutableArray alloc] init];
        
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        managedContext = appDelegate.persistentContainer.viewContext;
        
        NSError *error = nil;
        upcomingTerms = [managedContext executeFetchRequest:[TermToLearn fetchRequest] error:&error];
        
//        for (NSManagedObject *o in upcomingTerms) {
//            [managedContext deleteObject:o];
//        }
//        [managedContext save:&error];
        
        if (error != nil) {
            // TODO: error here
        }
        
    }
    return self;
}

+ (instancetype)sharedInstance {
    static Cards *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Cards alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)addTerm:(TermMeaningModel *)model {
    TermToLearn *termCoreDataModel = [NSEntityDescription insertNewObjectForEntityForName:@"TermToLearn" inManagedObjectContext:managedContext];
    
    termCoreDataModel.term = model.term;
    termCoreDataModel.forms = model.forms;
    termCoreDataModel.date = [NSDate date];
    termCoreDataModel.ef = 2.5f;
    termCoreDataModel.interval = 1;
    termCoreDataModel.attempt = 1;
    
    NSError *error = nil;
    if ([managedContext save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (TermMeaningModel *)getUpcomingCard {
    if (upcomingTerms.count == 0) {
        return nil;
    }
    
    return [[TermMeaningModel alloc] initWithPersistedData:(TermToLearn *)upcomingTerms[0]];
}

- (TermMeaningModel *)getNextToUpcomingCard {
    if (upcomingTerms.count < 2) {
        return nil;
    }
    return [[TermMeaningModel alloc] initWithPersistedData:(TermToLearn *)upcomingTerms[1]];
}


@end
