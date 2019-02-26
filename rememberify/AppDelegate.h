//
//  AppDelegate.h
//  rememberify
//
//  Created by Admin on 26/02/2019.
//  Copyright © 2019 savelichalex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

