//
//  Cards.m
//  rememberify
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "Cards.h"

@implementation MWCard
static NSString *cardType = @"MWCard";

+ (NSString *)type {
    return cardType;
}

@end

@implementation Cards

- (instancetype)init
{
    self = [super init];
    if (self) {
        _upcoming = [[NSMutableArray alloc] init];
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

- (void)addMWCards:(NSArray<NSDictionary *>*)entries {
    for (NSDictionary *dict in entries) {
        MWCard *card = [[MWCard alloc] init];
        [card setFront:[dict objectForKey:@"word"]];
        [card setForm:[dict objectForKey:@"form"]];
        [card setHeadword:[dict objectForKey:@"headword"]];
        [card setMeaning:[dict objectForKey:@"meaning"]];
        [card setExamples:[dict objectForKey:@"examples"]];
         
        [(NSMutableArray *)_upcoming addObject:card];
    }
}

- (MWCard *)getUpcomingCard {
    if (_upcoming.count == 0) {
        return nil;
    }
    return _upcoming[0];
}

- (MWCard *)getNextToUpcomingCard {
    if (_upcoming.count < 2) {
        return nil;
    }
    return _upcoming[1];
}


@end
