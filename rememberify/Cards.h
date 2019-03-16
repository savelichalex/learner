//
//  Cards.h
//  rememberify
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (void)addMWCards:(NSArray<NSDictionary *>*)entries;

@property (nonatomic, copy) NSArray *upcoming;

@end

NS_ASSUME_NONNULL_END
