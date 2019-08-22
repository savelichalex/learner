#import <Foundation/Foundation.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>

void downloadDefinition(NSString *term) {
    NSURL *defUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://dictionary.cambridge.org/us/dictionary/english/%@", term]];
    NSData *documentData = [NSData dataWithContentsOfURL:defUrl];
    
    NSString *query = @"//*[@class='def']";
    
    if (!documentData) {
        return;
    }
    
    xmlDocPtr doc = htmlReadMemory([documentData bytes], (int)[documentData length], "", NULL, HTML_PARSE_NOERROR);
    
    if (doc == NULL) {
        NSLog(@"Unable to parse.");
        return;
    }
    
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
    xpathCtx = xmlXPathNewContext(doc);
    
    if (xpathCtx == NULL) {
        NSLog(@"Unable to create XPath context.");
        xmlFreeDoc(doc);
        return;
    }
    
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    
    if (xpathObj == NULL) {
        NSLog(@"Unable to evaluate XPath context.");
        xmlXPathFreeContext(xpathCtx);
        xmlFreeDoc(doc);
        return;
    }
    
    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    
    if (!nodes) {
        NSLog(@"Nodes was nil.");
        xmlXPathFreeObject(xpathObj);
        xmlXPathFreeContext(xpathCtx);
        xmlFreeDoc(doc);
        return;
    }
    
    NSMutableArray *resultNodes = [NSMutableArray array];
    for (NSInteger i = 0; i < nodes->nodeNr; i++) {
        xmlNodePtr node = nodes->nodeTab[i];
        xmlChar *nodeContent = xmlNodeGetContent(node);
        [resultNodes addObject:[NSString stringWithCString:(const char *)nodeContent encoding:NSUTF8StringEncoding]];
        xmlFree(nodeContent);
    }
    
    NSLog(@"%@", resultNodes);
    
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    xmlFreeDoc(doc);
}

//int main() {
//    downloadDefinition(@"pity");
//}
