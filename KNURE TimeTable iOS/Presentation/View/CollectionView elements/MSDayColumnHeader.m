////
////  MSDayColumnHeader.m
////  KNURE TimeTable
////
////  Created by Vladislav Chapaev on 05.11.16.
////  Copyright (c) 2015 Vladislav Chapaev. All rights reserved.
////
//
//#import "MSDayColumnHeader.h"
//
//@interface MSDayColumnHeader ()
//
//@property (nonatomic, strong) UILabel *title;
//@property (nonatomic, strong) UIView *titleBackground;
//
//@end
//
//@implementation MSDayColumnHeader
//
//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        
//        self.titleBackground = [UIView new];
//        self.titleBackground.layer.cornerRadius = nearbyintf(15.0);
//        [self addSubview:self.titleBackground];
//        
//        self.backgroundColor = [UIColor clearColor];
//        self.title = [UILabel new];
//        self.title.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.title];
//        
//        [self.titleBackground makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.title).with.insets(UIEdgeInsetsMake(-6.0, -12.0, -4.0, -12.0));
//        }];
//        
//        [self.title makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//        }];
//    }
//    return self;
//}
//
//- (void)setDay:(NSDate *)day {
//    _day = day;
//    
//    self.title.text = [self.formatter stringFromDate:day];
//    [self setNeedsLayout];
//}
//
//- (void)setItemTitle:(NSString *)itemTitle {
//    _itemTitle = itemTitle;
//    self.title.textAlignment = NSTextAlignmentCenter;
//    self.title.text = [NSString stringWithFormat:@"%@, %@", itemTitle, self.title.text];
//}
//
//- (void)setCurrentDay:(BOOL)currentDay {
//    _currentDay = currentDay;
//    
//    if (currentDay) {
//        self.title.textColor = [UIColor whiteColor];
//        self.title.font = [UIFont boldSystemFontOfSize:16.0];
//        self.titleBackground.backgroundColor = self.titleBackgroundColor;
//    } else {
//        self.title.font = [UIFont systemFontOfSize:16.0];
//        self.title.textColor = self.titleTextColor;
//        self.titleBackground.backgroundColor = [UIColor clearColor];
//    }
//}
//
//@end
