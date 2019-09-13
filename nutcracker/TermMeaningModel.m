//
//  TermMeaningModel.m
//  nutcracker
//
//  Created by Алексей Савельев on 06/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "TermMeaningModel.h"
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>

xmlDocPtr loadDocument(NSString *url) {
    NSURL *defUrl = [NSURL URLWithString:url];
    NSData *documentData = [NSData dataWithContentsOfURL:defUrl];
    
    if (!documentData) {
        return NULL;
    }
    
    return htmlReadMemory([documentData bytes], (int)[documentData length], "", NULL, HTML_PARSE_NOERROR);
}

NSString* getClassName(xmlNodePtr node) {
    xmlChar *className = xmlGetProp(node, (const xmlChar *)"class");
    
    if (className == NULL) return NULL;
    
    NSString *str = [NSString stringWithUTF8String:(const char *)className];
    
    xmlFree(className);
    
    return str;
}

@implementation TermMeaningDef

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isChoosedForLearning = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.meaning = [coder decodeObjectOfClass:[NSString class] forKey:@"meaning"];
        self.examples = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [NSString class], nil] forKey:@"examples"];
        self.isChoosedForLearning = [coder decodeBoolForKey:@"isChoosedForLearning"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.meaning forKey:@"meaning"];
    [coder encodeObject:self.examples forKey:@"examples"];
    [coder encodeBool:self.isChoosedForLearning forKey:@"isChoosedForLearning"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

@interface TermMeaningForm ()

@property (readwrite, copy) NSString *form;
@property (readwrite, copy) NSString *pron;
@property (readwrite, copy) NSArray<TermMeaningDef *> *defs;

@end

@implementation TermMeaningForm

@synthesize form;
@synthesize pron;
@synthesize defs;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.form = [coder decodeObjectOfClass:[NSString class] forKey:@"form"];
        self.pron = [coder decodeObjectOfClass:[NSString class] forKey:@"pron"];
        self.defs = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [TermMeaningDef class], nil] forKey:@"defs"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.form forKey:@"form"];
    [coder encodeObject:self.pron forKey:@"pron"];
    [coder encodeObject:self.defs forKey:@"defs"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

@interface TermMeaningModel ()

@property (readwrite, copy) NSArray<TermMeaningForm *> *forms;

@end

@implementation TermMeaningModel {
    NSString *smth;
}

@synthesize forms;

+ (instancetype)instanceForTerm:(NSString *)term {
    TermMeaningModel *instance = [[TermMeaningModel alloc] initWithTerm:term];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        xmlDocPtr doc = loadDocument([NSString stringWithFormat:@"https://dictionary.cambridge.org/us/dictionary/english/%@", term]);
        
        NSString *query = @"//*[contains(concat(' ', normalize-space(@class), ' '), ' entry-body__el ')]";
        
        if (doc == NULL) {
            NSLog(@"Unable to parse or download page.");
            dispatch_async(dispatch_get_main_queue(), ^{
                [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
            });
            return;
        }
        
        xmlXPathContextPtr xpathCtx;
        xmlXPathObjectPtr xpathObj;
        
        xpathCtx = xmlXPathNewContext(doc);
        
        if (xpathCtx == NULL) {
            NSLog(@"Unable to create XPath context.");
            xmlFreeDoc(doc);
            dispatch_async(dispatch_get_main_queue(), ^{
                [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
            });
            return;
        }
        
        xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
        
        if (xpathObj == NULL) {
            NSLog(@"Unable to evaluate XPath context.");
            xmlXPathFreeContext(xpathCtx);
            xmlFreeDoc(doc);
            dispatch_async(dispatch_get_main_queue(), ^{
                [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
            });
            return;
        }
        
        xmlNodeSetPtr nodes = xpathObj->nodesetval;
        
        if (!nodes) {
            NSLog(@"Nodes was nil.");
            xmlXPathFreeObject(xpathObj);
            xmlXPathFreeContext(xpathCtx);
            xmlFreeDoc(doc);
            dispatch_async(dispatch_get_main_queue(), ^{
                [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
            });
            return;
        }
        
        NSMutableArray *result = [NSMutableArray new];
        
        for (NSInteger i = 0; i < nodes->nodeNr; i++) {
            TermMeaningForm *termMeaning = [[TermMeaningForm alloc] init];
            
            xmlNodePtr node = nodes->nodeTab[i];
            
            xmlNodePtr posHeader = node->children->next;
            for (; posHeader; posHeader = posHeader->next) {
                NSString *className = getClassName(posHeader);
                if (className == NULL) {
                    continue;
                }
                if ([className rangeOfString:@"pos-header"].location != NSNotFound) {
                    break;
                }
            }
            
            if (posHeader == NULL) {
                // TODO: error here, document isn't what is expected
                dispatch_async(dispatch_get_main_queue(), ^{
                    [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                });
                return;
            }
            
            xmlXPathContextPtr xpathCtx;
            xmlXPathObjectPtr xpathObj;
            
            xpathCtx = xmlXPathNewContext((xmlDocPtr)posHeader);
            
            if (xpathCtx == NULL) {
                NSLog(@"Unable to create XPath context.");
                xmlFreeDoc(doc);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                });
                return;
            }
            
            NSString *posQuery = @"//*[contains(concat(' ', normalize-space(@class), ' '), ' pos ')]";
            xpathObj = xmlXPathEvalExpression((xmlChar *)[posQuery cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
            
            if (xpathObj == NULL) {
                NSLog(@"Unable to evaluate XPath context.");
                xmlXPathFreeContext(xpathCtx);
                xmlFreeDoc(doc);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                });
                return;
            }
            
            xmlNodeSetPtr posNodes = xpathObj->nodesetval;
            for (NSInteger i = 0; i < posNodes->nodeNr; i++) {
                xmlNodePtr node = posNodes->nodeTab[i];
                
                xmlChar *nodeContent = xmlNodeGetContent(node);
                
                termMeaning.form = [NSString stringWithUTF8String:(const char *)nodeContent];
                
                xmlFree(nodeContent);
            }
            
            xmlXPathFreeObject(xpathObj);
            
            NSString *pronQuery = @"//*[contains(concat(' ', normalize-space(@class), ' '), ' ipa ')]";
            xpathObj = xmlXPathEvalExpression((xmlChar *)[pronQuery cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
            
            if (xpathObj == NULL) {
                NSLog(@"Unable to evaluate XPath context.");
                xmlXPathFreeContext(xpathCtx);
                xmlFreeDoc(doc);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                });
                return;
            }
            
            xmlNodeSetPtr pronNodes = xpathObj->nodesetval;
            for (NSInteger i = 0; i < pronNodes->nodeNr; i++) {
                xmlNodePtr node = pronNodes->nodeTab[i];
                
                xmlChar *nodeContent = xmlNodeGetContent(node);
                
                // TODO: check for us
                if ([getClassName(node->parent->parent) rangeOfString:@"us"].location != NSNotFound) {
                    termMeaning.pron = [NSString stringWithUTF8String:(const char *)nodeContent];
                }
                
                xmlFree(nodeContent);
            }
            
            xmlXPathFreeObject(xpathObj);
            xmlXPathFreeContext(xpathCtx);
            
            xmlNodePtr posBody = node->children;
            for (; posBody; posBody = posBody->next) {
                NSString *className = getClassName(posBody);
                if (className == NULL) {
                    continue;
                }
                if ([className rangeOfString:@"pos-body"].location != NSNotFound) {
                    break;
                }
            }
            
            if (posBody == NULL) {
                // TODO: error here, document isn't what is expected
                dispatch_async(dispatch_get_main_queue(), ^{
                    [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                });
                return;
            }
            
            xpathCtx = xmlXPathNewContext((xmlDocPtr)posBody);
            
            if (xpathCtx == NULL) {
                NSLog(@"Unable to create XPath context.");
                xmlFreeDoc(doc);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                });
                return;
            }
            
            NSString *defBlockQuery = @"//*[contains(concat(' ', normalize-space(@class), ' '), ' def-block ')]";
            xpathObj = xmlXPathEvalExpression((xmlChar *)[defBlockQuery cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
            
            if (xpathObj == NULL) {
                NSLog(@"Unable to evaluate XPath context.");
                xmlXPathFreeContext(xpathCtx);
                xmlFreeDoc(doc);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                });
                return;
            }
            
            NSMutableArray *defs = [NSMutableArray new];
            
            xmlNodeSetPtr defNodes = xpathObj->nodesetval;
            for (NSInteger i = 0; i < defNodes->nodeNr; i++) {
                xmlNodePtr node = defNodes->nodeTab[i];
                
                xmlXPathContextPtr xpathCtx;
                xmlXPathObjectPtr xpathObj;
                
                TermMeaningDef *def = [[TermMeaningDef alloc] init];
                
                xpathCtx = xmlXPathNewContext((xmlDocPtr)node);
                
                NSString *defQuery = @"//*[contains(concat(' ', normalize-space(@class), ' '), ' def ')]";
                xpathObj = xmlXPathEvalExpression((xmlChar *)[defQuery cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
                
                if (xpathObj == NULL) {
                    NSLog(@"Unable to evaluate XPath context.");
                    xmlXPathFreeContext(xpathCtx);
                    xmlFreeDoc(doc);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                    });
                    return;
                }
                
                xmlNodeSetPtr defNodes = xpathObj->nodesetval;
                for (NSInteger i = 0; i < defNodes->nodeNr; i++) {
                    xmlNodePtr node = defNodes->nodeTab[i];
                    
                    xmlChar *nodeContent = xmlNodeGetContent(node);
                    def.meaning = [NSString stringWithUTF8String:(const char *)nodeContent];
                    
                    xmlFree(nodeContent);
                }
                
                xmlXPathFreeObject(xpathObj);
                
                NSString *exampQuery = @"//*[contains(concat(' ', normalize-space(@class), ' '), ' examp ')]";
                xpathObj = xmlXPathEvalExpression((xmlChar *)[exampQuery cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
                
                if (xpathObj == NULL) {
                    NSLog(@"Unable to evaluate XPath context.");
                    xmlXPathFreeContext(xpathCtx);
                    xmlFreeDoc(doc);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [instance setValue:@(MeaningFetchStatusError) forKey:@"fetchStatus"];
                    });
                    return;
                }
                
                NSMutableArray *examples = [NSMutableArray new];
                xmlNodeSetPtr exampNodes = xpathObj->nodesetval;
                for (NSInteger i = 0; i < exampNodes->nodeNr; i++) {
                    xmlNodePtr node = exampNodes->nodeTab[i];
                    
                    xmlChar *nodeContent = xmlNodeGetContent(node);
                    
                    [examples addObject:[NSString stringWithUTF8String:(const char *)nodeContent]];
                    
                    xmlFree(nodeContent);
                }
                def.examples = examples;
                
                [defs addObject:def];
            }
        
            //xmlXPathFreeNodeSet(posNodes);
            //xmlXPathFreeNodeSet(pronNodes);
            //xmlXPathFreeNodeSet(defNodes);
            xmlXPathFreeObject(xpathObj);
            xmlXPathFreeContext(xpathCtx);
            //xmlFreeNode(posHeader);
            //xmlFreeNode(posBody);
            
            termMeaning.defs = defs;
            [result addObject:termMeaning];
        }
        
        xmlXPathFreeObject(xpathObj);
        xmlXPathFreeContext(xpathCtx);
        xmlFreeDoc(doc);
        
        [instance setForms:result];
        dispatch_async(dispatch_get_main_queue(), ^{
            [instance setValue:@(MeaningFetchStatusSuccess) forKey:@"fetchStatus"];
        });
    });
    
    return instance;
}

- (instancetype)initWithTerm:(NSString *)term {
    self = [super init];
    if (self) {
        _term = term;
        _fetchStatus = @(MeaningFetchStatusProgress);
    }
    return self;
}

- (instancetype)initWithPersistedData:(TermToLearn *)term {
    self = [super init];
    if (self) {
        _term = term.term;
        self.forms = (NSArray<TermMeaningForm *> *)term.forms;
        _fetchStatus = @(MeaningFetchStatusSuccess);
    }
    return self;
}

- (BOOL)isFetchStatusEqualTo:(MeaningFetchStatus)status {
    return [_fetchStatus integerValue] == status;
}

@end
