//
//  TodayViewController.m
//  KNURE TimeTable iOS TodayExtension
//
//  Created by Vlad Chapaev on 09.11.16.
//  Copyright © 2016 Vlad Chapaev. All rights reserved.
//

#import "TodayViewController.h"
#import "MSCollectionViewCalendarLayout.h"
#import "LessonCollectionViewCell.h"
#import "Lesson+CoreDataClass.h"
#import "UIScrollView+EmptyDataSet.h"

#import "MSGridline.h"
#import "MSTimeRowHeaderBackground.h"
#import "MSDayColumnHeaderBackground.h"
#import "MSDayColumnHeader.h"
#import "MSTimeRowHeader.h"
#import "MSCurrentTimeIndicator.h"
#import "MSCurrentTimeGridline.h"

NSString *const MSEventCellReuseIdentifier = @"MSEventCellReuseIdentifier";
NSString *const MSDayColumnHeaderReuseIdentifier = @"MSDayColumnHeaderReuseIdentifier";
NSString *const MSTimeRowHeaderReuseIdentifier = @"MSTimeRowHeaderReuseIdentifier";

NSString *const TimeTableCacheName = @"TimeTableCacheName";
NSString *const TimetableSelectedItem = @"TimetableSelectedItem";
NSString *const TimetableVerticalMode = @"TimetableVerticalMode";

CGFloat const sectonWidth = 110;
CGFloat const timeRowHeaderWidth = 44;
CGFloat const dayColumnHeaderHeight = 40;

@interface TodayViewController () <NCWidgetProviding, MSCollectionViewDelegateCalendarLayout, NSFetchedResultsControllerDelegate, DZNEmptyDataSetSource>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) MSCollectionViewCalendarLayout *collectionViewCalendarLayout;

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSArray <NSDate *>* pairDates;
@property (assign, nonatomic) short maxPairNumber;
@property (assign, nonatomic) short minPairNumber;

@property (assign, nonatomic) BOOL isRunningInFullScreen;

@property (assign, nonatomic) BOOL isDarkMode;
@property (assign, nonatomic) BOOL showEmptyDays;

@end

@implementation TodayViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.collectionViewCalendarLayout = [[MSCollectionViewCalendarLayout alloc] init];
        self.collectionViewCalendarLayout.delegate = self;
        
        NSManagedObjectModel *model = [NSManagedObjectModel MR_defaultManagedObjectModel];
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.Shogunate.KNURE-Sked"];
        storeURL = [storeURL URLByAppendingPathComponent:@"DataStorage.sqlite"];
        
        [persistentStoreCoordinator MR_addSqliteStoreNamed:storeURL withOptions:nil];
        [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:persistentStoreCoordinator];
        [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:persistentStoreCoordinator];
        
        self = [super initWithCollectionViewLayout:self.collectionViewCalendarLayout];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.Shogunate.KNURE-Sked"];
    NSDictionary *selectedItem = [sharedDefaults valueForKey:TimetableSelectedItem];
    if (selectedItem) {
        [self setupFetchRequestWithItem:selectedItem];
    }
    [self setupProperties];
    [self setupCollectionView];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeExpanded) {
        self.preferredContentSize = CGSizeMake(0.0, 260.0);
    } else if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = maxSize;
    }
}

#pragma mark - Setup

- (void)setupCollectionView {
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView registerClass:LessonCollectionViewCell.class forCellWithReuseIdentifier:MSEventCellReuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:MSTimeRowHeader.class forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:MSTimeRowHeaderReuseIdentifier];
    
    self.collectionViewCalendarLayout.timeRowHeaderWidth = timeRowHeaderWidth;
    self.collectionViewCalendarLayout.dayColumnHeaderHeight = dayColumnHeaderHeight;
    
    self.collectionViewCalendarLayout.sectionLayoutType = MSSectionLayoutTypeVerticalTile;
    self.collectionViewCalendarLayout.sectionWidth = self.collectionView.frame.size.width - timeRowHeaderWidth - 10;
    self.collectionViewCalendarLayout.hourHeight = 30;
    
    [self.collectionViewLayout registerClass:MSCurrentTimeGridline.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
    [self.collectionViewLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindVerticalGridline];
    [self.collectionViewLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
    [self.collectionViewLayout registerClass:MSTimeRowHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
    [self.collectionViewLayout registerClass:MSDayColumnHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
    [self.collectionViewLayout registerClass:MSCurrentTimeIndicator.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
}

- (void)setupProperties {
    NSArray *pairNumbers = [self.fetchedResultsController.fetchedObjects valueForKey:@"number_pair"];
    self.maxPairNumber = [[pairNumbers valueForKeyPath:@"@max.intValue"] shortValue];
    self.minPairNumber = [[pairNumbers valueForKeyPath:@"@min.intValue"] shortValue] - 1;
    
    self.formatter = [[NSDateFormatter alloc]init];
    [self.formatter setDateFormat:@"EEEE, dd MMMM"];
    
    NSArray <NSDate *>*startTimeList = [self.fetchedResultsController.fetchedObjects valueForKey:@"start_time"];
    NSArray <NSDate *>*endTimeList = [self.fetchedResultsController.fetchedObjects valueForKey:@"end_time"];
    NSArray <NSDate *>*newArray = [startTimeList arrayByAddingObjectsFromArray:endTimeList];
    NSMutableArray <NSDate *>*dates = [[NSMutableArray alloc]init];
    for (NSDate *date in newArray) {
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSDateComponents *component = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
        [dates addObject:[calendar dateFromComponents:component]];
    }
    self.pairDates = [[[NSOrderedSet orderedSetWithArray:dates] array] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)setupFetchRequestWithItem:(NSDictionary *)selectedItem {
    NSFetchRequest *fetchRequest = [Lesson fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"item_id == %@", [selectedItem valueForKey:@"id"]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start_time" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:@"day" cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionViewCalendarLayout invalidateLayoutCache];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [(id <NSFetchedResultsSectionInfo>)self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LessonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MSEventCellReuseIdentifier forIndexPath:indexPath];
    cell.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == MSCollectionElementKindDayColumnHeader) {
        MSDayColumnHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day = [self.collectionViewCalendarLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        NSDate *currentDay = [self currentTimeComponentsForCollectionView:self.collectionView layout:self.collectionViewCalendarLayout];
        
        NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:day];
        NSDate *startOfCurrentDay = [[NSCalendar currentCalendar] startOfDayForDate:currentDay];
        
        dayColumnHeader.formatter = self.formatter;
        dayColumnHeader.day = day;
        dayColumnHeader.currentDay = [startOfDay isEqualToDate:startOfCurrentDay];
        
        return dayColumnHeader;
        
    } else if (kind == MSCollectionElementKindTimeRowHeader) {
        MSTimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowHeader.time = [self.collectionViewCalendarLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        return timeRowHeader;
    }
    return [[UICollectionReusableView alloc]init];
}

#pragma mark - MSCollectionViewDelegateCalendarLayout

- (NSArray <NSDate *>*)timeListForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout {
    return self.pairDates;
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout {
    return [NSDate date];
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Lesson *lesson = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return lesson.start_time;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Lesson *lesson = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return lesson.end_time;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout dayForSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    Lesson *lesson = [sectionInfo.objects firstObject];
    return lesson.day;
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"TimeTable_NoItems", nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"TimeTable_NoItemsMessage", nil);
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
