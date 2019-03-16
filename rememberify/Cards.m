//
//  Cards.m
//  rememberify
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "Cards.h"

@implementation MWCardDefItem
@end

@implementation MWCard
static NSString *cardType = @"MWCard";

+ (NSString *)type {
    return cardType;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _defs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (MWCardDefItem *)getRandomDefinition {
    NSUInteger randomIndex = arc4random() % _defs.count;
    
    return _defs[randomIndex];
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

- (void)addMWCardForWord:(NSString *)word entries:(NSArray<NSDictionary *>*)entries {
    MWCard *card = [[MWCard alloc] init];
    [card setFront:word];
    for (NSDictionary *dict in entries) {
        MWCardDefItem *cardDefItem = [[MWCardDefItem alloc] init];
        [cardDefItem setForm:[dict objectForKey:@"form"]];
        [cardDefItem setHeadword:[dict objectForKey:@"headword"]];
        [cardDefItem setMeaning:[dict objectForKey:@"meaning"]];
        [cardDefItem setExamples:[dict objectForKey:@"examples"]];
        
        [card.defs addObject:cardDefItem];
    }
    [(NSMutableArray *)_upcoming addObject:card];
}


@end
