//
//  ItemsTableViewCell.h
//  KNURE TimeTable
//
//  Created by Vlad Chapaev on 11.03.17.
//  Copyright © 2017 Vlad Chapaev. All rights reserved.
//

@import UIKit;

#import "Item+CoreDataProperties.h"
#import "EventParser.h"

@protocol ItemsTableViewCellDelegate <NSObject>

@required
- (void)didFinishDownloadWithError:(NSError *)error;

@end

@interface ItemsTableViewCell : UITableViewCell

@property (weak, nonatomic) Item *item;

@property (weak, nonatomic) id <ItemsTableViewCellDelegate> delegate;

/**
 Update the timetable of selected item

 @param item
 */
- (void)updateItem:(Item *)item;

/**
 Events that belong to listed item will be export to iOS calendar
 
 @param item listed item
 @param range range of date to export
 */
- (void)exportToCalendar:(Item *)item inRange:(CalendarExportRange)range;

@end
