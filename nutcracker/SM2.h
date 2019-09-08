//
//  SMAlgorithm.h
//  nutcracker
//
//  Created by Алексей Савельев on 08/09/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QualityResponse) {
    QualityResponsePerfect = 5,
    QualityResponseCorrectWithHesitation = 4,
    QualityResponseCorrectButDifficult = 3,
    QualityResponseIncorrectButEasyToRecall = 2,
    QualityResponseIncorrectButRemember = 1,
    QualityResponseCompleteBlackout = 0
};

@interface SM2 : NSObject

@end

NS_ASSUME_NONNULL_END
