//
//  DictionaryApiParser.m
//  rememberify
//
//  Created by Admin on 26/02/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "DictionaryApiParser.h"

@interface EntryForm ()
@property (nonatomic) NSInteger sortInt;
@end

@implementation EntryForm

@end

@implementation EntryItem

- (instancetype)initWithDef:(NSString *)def andExamples:(NSArray *)examples {
    self = [super init];
    if (self) {
        _def = def;
        _examples = examples == nil ? @[] : examples;
    }
    return self;
}

- (NSString *)getSimpleFormattedDef {
    NSMutableString *formatted = [[NSMutableString alloc] initWithString:_def];
    
    for (NSString *example in _examples) {
        [formatted appendString:@"\n"];
        [formatted appendString:@"// "];
        [formatted appendString:example];
    }
    
    return formatted;
}

@end

@implementation DictionaryApiParser

+ (void)processJSON:(NSData *)json withCallback:(void (^)(NSArray *))cb {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *__autoreleasing *parseError = nil;
        id object = [NSJSONSerialization JSONObjectWithData:json options:0 error:parseError];
        NSArray *entries = [DictionaryApiParser processEntries:(NSArray *)object];
        cb(entries);
    });
}

+ (NSArray *)processEntries:(NSArray *)json {
    NSMutableDictionary *forms = [[NSMutableDictionary alloc] init];
    
    NSInteger sortInt = 0;
    for (NSDictionary *entry in json) {
        NSString *fl = (NSString *)[entry valueForKey:@"fl"];
        NSString *headword = [[entry valueForKey:@"hwi"] valueForKey:@"hw"];
        NSArray *def = (NSArray *)[entry valueForKey:@"def"];
        if (fl == nil || def == nil) continue;
        
        if (forms[headword] != nil) {
            EntryForm *form = forms[headword];
            
            form.defs = [form.defs arrayByAddingObjectsFromArray:def];
            
            continue;
        }
        
        EntryForm *form = [[EntryForm alloc] init];
        form.name = fl;
        form.defs = def;
        form.headword = headword;
        form.sortInt = sortInt++;
        
        [forms setValue:form forKey:headword];
    }
    
    [DictionaryApiParser processForms:[forms allValues]];
    
    return [[forms allValues] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(EntryForm *)obj1 sortInt] > [(EntryForm *)obj2 sortInt];
    }];
}

+ (void)processForms:(NSArray *)forms {
    for (EntryForm *form in forms) {
        NSMutableArray *sections = [[NSMutableArray alloc] init];
        for (NSDictionary *def in form.defs) {
            NSArray *sseq = (NSArray *)[def valueForKey:@"sseq"];
            for (NSArray *sseqItem in sseq) {
                NSArray *section = [DictionaryApiParser getFormDef:sseqItem];
                
                [sections addObject:[section count] == 1 ? [section firstObject] : section];
            }
        }
        form.defs = sections;
    }
}

+ (NSArray *)getFormDef:(NSArray *)defs {
    NSMutableArray *section = [[NSMutableArray alloc] init];
    for (NSArray *def in defs) {
        NSString *defType = [def firstObject];
        NSDictionary *defDetails = [def objectAtIndex:1];
        
        if ([defType isEqualToString:@"sense"]) {
            // Don't know item rather then "sense"
            if (defType == nil) {
                continue;
            }
        }
        
        NSArray *defDetailsDt = [defDetails valueForKey:@"dt"];
        
        NSString *defText = nil;
        NSArray *defExamples = nil;
        
        for (NSArray *dtItem in defDetailsDt) {
            NSString *dtItemType = [dtItem firstObject];
            
            if ([dtItemType isEqualToString:@"text"]) {
                if (defText == nil) {
                    defText = [DictionaryApiParser getTextFromDt:[dtItem objectAtIndex:1]];
                }
                continue;
            }
            
            if ([dtItemType isEqualToString:@"vis"]) {
                if (defExamples == nil) {
                    defExamples = [DictionaryApiParser getExamplesFromDt:[dtItem objectAtIndex:1]];
                }
                continue;
            }
        }
        
        if (defText == nil) {
            continue;
        }
        
        EntryItem *item = [[EntryItem alloc] initWithDef:defText andExamples:defExamples];
        
        [section addObject:item];
    }
    
    return section;
}

+ (NSString *)getTextFromDt:(NSString *)rawDefText {
    return rawDefText;
}

+ (NSArray *)getExamplesFromDt:(NSArray *)rawExamples {
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for (NSDictionary *exampleItem in rawExamples) {
        NSString *rawExampleText = [exampleItem valueForKey:@"t"];
        if (rawExampleText != nil) {
            [arr addObject:rawExampleText];
        }
    }
    return arr;
}

@end
