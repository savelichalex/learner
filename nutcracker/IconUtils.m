//
//  IconUtils.m
//  nutcracker
//
//  Created by Алексей Савельев on 23/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "IconUtils.h"

@implementation IconUtils

+ (UIImage *)imageFromSystemBarButon:(UIBarButtonSystemItem)systemItem {
    UIBarButtonItem *tempItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:nil action:nil];
    UIToolbar *bar = [[UIToolbar alloc] init];
    [bar setItems:@[tempItem] animated:NO];
    [bar snapshotViewAfterScreenUpdates:YES];
    
    UIView *itemView = [(id)tempItem view];
    for (UIView *view in itemView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            return [(UIButton *)view imageForState:UIControlStateNormal];
        }
    }
    
    return nil;
}

+ (UIImage *)imageForPlusIcon {
    CGSize size = CGSizeMake(20.0f, 20.0f);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0f);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0f);
    
    CGContextMoveToPoint(context, 10.0f, 0.0f);
    CGContextAddLineToPoint(context, 10.0f, 20.0f);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, 0.0f, 10.0f);
    CGContextAddLineToPoint(context, 20.0f, 10.0f);
    CGContextStrokePath(context);
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
