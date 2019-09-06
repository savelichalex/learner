//
//  ChoosableDef.h
//  rememberify
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermMeaningModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChoosableDef : UIStackView

- (instancetype)initWithEntryItem:(TermMeaningDef *)item formType:(NSString *)type headword:(NSString *)headword onTap:(void(^)(BOOL isActive))onTap;

@property (nonatomic, copy) TermMeaningDef *item;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *headword;
@property (nonatomic) Boolean isActive;

@end

NS_ASSUME_NONNULL_END
