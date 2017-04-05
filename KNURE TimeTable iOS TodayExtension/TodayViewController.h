//
//  TodayViewController.h
//  KNURE TimeTable iOS TodayExtension
//
//  Created by Vlad Chapaev on 09.11.16.
//  Copyright © 2016 Vlad Chapaev. All rights reserved.
//

@import UIKit;
@import CoreData;
@import NotificationCenter;

#import <MagicalRecord/MagicalRecord.h>

@interface TodayViewController : UICollectionViewController

- (void)setupFetchRequestWithPredicate:(NSPredicate *)predicate;

@end
