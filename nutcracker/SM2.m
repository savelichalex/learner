//
//  SMAlgorithm.m
//  nutcracker
//
//  Created by Алексей Савельев on 08/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import "SM2.h"

@implementation SM2

- (void)calculateResults:(QualityResponse)response {
    NSInteger recall = [self.attemptInput integerValue];
    NSInteger prevInterval = [self.intervalInput integerValue];
    float ef = [self.efInput floatValue];
    
    NSInteger newInterval = [self getIntervalForAttempt:recall withPrevInterval:prevInterval andEF:ef];
    float newEF = [self getNewEFForQuality:response withRecallAttempt:recall andOldEF:ef];
    
    if (response < 3) {
        recall = 1;
        newInterval = [self getIntervalForAttempt:recall withPrevInterval:prevInterval andEF:ef];
    }
    
    NSDate *nextRecallDate = [NSDate dateWithTimeIntervalSinceNow:(60 * 60 * 24 * newInterval)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *nextRecallDateString = [formatter stringFromDate:nextRecallDate];
    
    NSString *res = [NSString stringWithFormat:@"Next recall will be at %@, store following for next use: attempt - %li, interval - %li, ef - %f", nextRecallDateString, recall, newInterval, newEF];
    NSLog(@"%@", res);
    [self.resultLabel setStringValue:res];
}

- (NSInteger)getIntervalForAttempt:(NSInteger)n withPrevInterval:(NSInteger)i andEF:(float)ef {
    if (n < 1) {
        @throw [NSException exceptionWithName:@"Incorrect recall number" reason:nil userInfo:nil];
    }
    if (n == 1) {
        return 1;
    }
    
    if (n == 2) {
        return 6;
    }
    
    return lroundf((float)i * ef);
}

- (float)getNewEFForQuality:(QualityResponse)q withRecallAttempt:(NSInteger)n andOldEF:(float)ef {
    // EF':=EF+(0.1-(5-q)*(0.08+(5-q)*0.02))
    float newEF = ef + (0.1 - (float)(5 - q) * (0.08 + (float)(5 - q) * 0.02));
    
    if (newEF < 1.3) {
        return 1.3;
    }
    
    return newEF;
}

@end
