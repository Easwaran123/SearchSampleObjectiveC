//
//  AppDelegate.h
//  SampleSearchObjective
//
//  Created by v-20 on 7/17/17.
//  Copyright © 2017 VividInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;


@end

