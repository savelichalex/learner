//
//  IconUtils.h
//  nutcracker
//
//  Created by Алексей Савельев on 23/08/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IconUtils : NSObject

+ (UIImage *)imageFromSystemBarButon:(UIBarButtonSystemItem)systemItem;
+ (UIImage *)imageForPlusIcon;

@end

NS_ASSUME_NONNULL_END
