//
//  DictionaryApiParser.h
//  rememberify
//
//  Created by Admin on 26/02/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EntryForm : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *headword;
@property (nonatomic, copy) NSArray *defs;
@end

@interface EntryItem : NSObject

- (NSString *)getSimpleFormattedDef;
@property (nonatomic, copy) NSString *def;
@property (nonatomic, copy) NSArray *examples;

@end

@interface DictionaryApiParser : NSObject

+ (void)processJSON:(NSData *)json withCallback:(void (^)(NSArray *))cb;

@end

NS_ASSUME_NONNULL_END
